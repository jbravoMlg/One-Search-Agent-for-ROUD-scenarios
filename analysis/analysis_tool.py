#!/usr/bin/env python3
"""
ROS 2 experiment analysis tool for RTT and multilateration positioning.

- Reads ROS 2 Humble bags with rosbags.
- Filters by time interval and altitude.
- Calculates RTT, RSSI, and multilateration distance errors against ground truth.
- Generates altitude, RSSI, RTT, ground-truth, ECDF, and estimate plots.
- Prints detailed statistical metrics.

Key CLI parameters:
    - Surveyed P1 and X4 coordinates.
    - Propagation-model parameters (P0, n, d0).
    - Altitude threshold for GPS filtering.
    - Takeoff and landing offsets.
"""

import argparse
import logging
from dataclasses import dataclass
from pathlib import Path
from typing import List, Tuple, Optional, Dict, Any

import matplotlib.pyplot as plt
import numpy as np
from geopy.distance import geodesic
from rosbags.rosbag2 import Reader
from rosbags.typesys import Stores, get_typestore


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]


# -------------------------------------------------------------------------
# Logging configuration
# -------------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s: %(message)s",
)


# -------------------------------------------------------------------------
# Configuration data classes
# -------------------------------------------------------------------------
@dataclass
class PathLossModel:
    """Log-distance path-loss propagation model."""
    p0: float = -45.0  # RSSI at 1 m (dBm)
    n: float = 2.0     # Path-loss exponent
    d0: float = 1.0    # Reference distance (m)


@dataclass
class AnchorCoords:
    """Coordinates of a smartphone or anchor to locate."""
    lat: float
    lon: float
    alt: float


@dataclass
class BagConfig:
    """Configuration for one experiment bag."""
    bag_path: Path
    multilateration_topic: str


# -------------------------------------------------------------------------
# Basic utilities
# -------------------------------------------------------------------------
def parse_coord3(arg: str) -> AnchorCoords:
    """Parse a CLI coordinate in 'lat,lon,alt' format."""
    try:
        parts = [float(x.strip()) for x in arg.split(",")]
        if len(parts) != 3:
            raise ValueError
        return AnchorCoords(lat=parts[0], lon=parts[1], alt=parts[2])
    except Exception:
        raise argparse.ArgumentTypeError(
            f"Invalid coordinates '{arg}'. Use the format lat,lon,alt"
        )


def get_bag_start_end_time(bag_path: Path) -> Tuple[Optional[float], Optional[float]]:
    """
    Return the ROS 2 bag start and end epoch times in seconds.
    """
    try:
        with Reader(str(bag_path)) as reader:
            start_time = reader.start_time * 1e-9
            end_time = reader.end_time * 1e-9
        return start_time, end_time
    except Exception as e:
        logging.error(f"Error reading bag {bag_path}: {e}")
        return None, None


def estimate_distance(rssi: int, model: PathLossModel) -> float:
    """
    Estimate distance from RSSI using the log-distance path-loss model.
    d = d0 * 10^((P0 - RSSI) / (10 * n))
    """
    distance = model.d0 * 10 ** ((model.p0 - rssi) / (10.0 * model.n))
    logging.debug(f"Estimating distance: RSSI={rssi}, Distance={distance:.2f} m")
    return distance


def euclidean_distance_3d(
    coord1: Tuple[float, float, float],
    coord2: Tuple[float, float, float],
) -> float:
    """
    Calculate the 3-D Euclidean distance between two coordinates.
    """
    horizontal = geodesic((coord1[0], coord1[1]), (coord2[0], coord2[1])).meters
    alt_diff = abs(coord1[2] - coord2[2])
    return float(np.hypot(horizontal, alt_diff))

def horizontal_vertical_errors(
    est_coords: List[Tuple[float, float, float]],
    gt: AnchorCoords,
) -> Tuple[List[float], List[float], List[float]]:
    """
    Calculate horizontal, vertical, and 3-D errors between position estimates
    and the surveyed anchor coordinate.

    Returns:
        horiz_errors: direct horizontal geodesic distance (m)
        vert_errors: altitude difference (m)
        pos_errors_3d: 3-D error (m)
    """
    horiz_errors: List[float] = []
    vert_errors: List[float] = []
    pos_errors_3d: List[float] = []

    gt_tuple = (gt.lat, gt.lon, gt.alt)

    for (lat, lon, alt) in est_coords:
        # Direct horizontal geodesic error without altitude.
        horiz = geodesic((lat, lon), (gt.lat, gt.lon)).meters
        # Signed vertical error.
        vert = float(alt - gt.alt)
        # Total 3-D error.
        pos3d = float(np.hypot(horiz, vert))

        horiz_errors.append(horiz)
        vert_errors.append(vert)
        pos_errors_3d.append(pos3d)

    return horiz_errors, vert_errors, pos_errors_3d


def compute_cep(
    horizontal_errors: List[float],
    p: float,
) -> float:
    """
    Return the CEP radius containing p percent of horizontal estimates.
    """
    if not horizontal_errors:
        return float("nan")
    return float(np.percentile(np.asarray(horizontal_errors, dtype=float), p))


def get_gps_position_at_time(
    gps_times: List[float],
    gps_data: List[Tuple[float, float, float]],
    query_time: float,
) -> Optional[Tuple[float, float, float]]:
    """
    Return the GPS position closest in time to `query_time`.
    """
    if not gps_times:
        return None
    idx = int(np.argmin(np.abs(np.asarray(gps_times) - query_time)))
    return gps_data[idx]


def calculate_error(
    estimated_distances: List[float],
    real_distances: List[float],
) -> List[float]:
    """Return absolute errors |estimated - ground truth|."""
    return [abs(est - real) for est, real in zip(estimated_distances, real_distances)]


def compute_speed_profile(gps_data, gps_times, min_dt=0.2, max_speed=30.0):
    speeds_3d = []
    speeds_h = []
    speed_times = []

    for i in range(1, len(gps_data)):
        p_prev = gps_data[i-1]
        p_curr = gps_data[i]
        t_prev = gps_times[i-1]
        t_curr = gps_times[i]

        dt = t_curr - t_prev
        if dt <= 0:
            continue

        # Horizontal distance.
        d_h = geodesic((p_prev[0], p_prev[1]),
                       (p_curr[0], p_curr[1])).meters
        # 3-D distance.
        dz = p_curr[2] - p_prev[2]
        d_3d = np.hypot(d_h, dz)

        v_h = d_h / dt
        v_3d = d_3d / dt

        # Reject outliers and irregular samples.
        if dt < min_dt or v_3d > max_speed:
            continue

        speeds_h.append(v_h)
        speeds_3d.append(v_3d)
        speed_times.append(0.5 * (t_prev + t_curr))

    return speed_times, speeds_3d, speeds_h



def compute_path_length(
    gps_data: List[Tuple[float, float, float]]
) -> Tuple[float, float]:
    """
    Calculate total UAV path length from GPS positions.

    Returns:
        total_3d: 3-D path length (m).
        total_horiz: horizontal path length (m).
    """
    if len(gps_data) < 2:
        return 0.0, 0.0

    total_3d = 0.0
    total_horiz = 0.0

    for i in range(1, len(gps_data)):
        p_prev = gps_data[i - 1]
        p_curr = gps_data[i]

        # 3-D distance.
        d3 = euclidean_distance_3d(p_prev, p_curr)
        total_3d += d3

        # Horizontal distance using latitude and longitude only.
        dh = geodesic(
            (p_prev[0], p_prev[1]),
            (p_curr[0], p_curr[1])
        ).meters
        total_horiz += dh

    return total_3d, total_horiz


def calculate_signed_error(
    estimated_distances: List[float],
    real_distances: List[float],
) -> List[float]:
    """Return signed errors (estimate minus ground truth) for bias analysis."""
    return [est - real for est, real in zip(estimated_distances, real_distances)]

def compute_multilateration_position_errors(
    P1_estimated: List[Tuple[float, float, float]],
    X4_estimated: List[Tuple[float, float, float]],
    anchors: Tuple[AnchorCoords, AnchorCoords],
) -> Tuple[List[float], List[float]]:
    """
        Calculate 3-D mobile-position error for each multilateration estimate:
      - dist( P1_est[i], P1_GT )
      - dist( X4_est[i], X4_GT )

    Args:
                P1_estimated: estimated coordinates for mobile P1.
                X4_estimated: estimated coordinates for mobile X4.
                anchors: (P1_GT, X4_GT) as AnchorCoords values.

    Returns:
        (mlt_pos_error_P1, mlt_pos_error_X4)
    """
    P1_coords, X4_coords = anchors

    P1_gt = (P1_coords.lat, P1_coords.lon, P1_coords.alt)
    X4_gt = (X4_coords.lat, X4_coords.lon, X4_coords.alt)

    mlt_pos_error_P1 = [
        euclidean_distance_3d(est, P1_gt) for est in P1_estimated
    ]
    mlt_pos_error_X4 = [
        euclidean_distance_3d(est, X4_gt) for est in X4_estimated
    ]

    return mlt_pos_error_P1, mlt_pos_error_X4


def ecdf(data: List[float]) -> Tuple[np.ndarray, np.ndarray]:
    """Return the empirical CDF of a dataset."""
    data_arr = np.asarray(data)
    data_sorted = np.sort(data_arr)
    y_vals = np.arange(1, len(data_sorted) + 1) / len(data_sorted)
    return data_sorted, y_vals


def percentile(data: List[float], q: float) -> float:
    """Return percentile q of the data."""
    return float(np.percentile(np.asarray(data), q))


# -------------------------------------------------------------------------
# Bag reading
# -------------------------------------------------------------------------
def read_bag(
    bag_path: Path,
    bag_start_time: float,
    start_interval: float,
    end_interval: float,
    altitude_threshold: float,
    multilateration_topic: str,
    pathloss_model: PathLossModel,
) -> Tuple:
    """
    Read a ROS 2 bag and return data structures ready for analysis.
    """

    gps_data: List[Tuple[float, float, float]] = []
    gps_times: List[float] = []

    rssi_data_P1: List[float] = []
    rssi_times_P1: List[float] = []
    rssi_data_X4: List[float] = []
    rssi_times_X4: List[float] = []
    rssi_values_P1: List[int] = []
    rssi_values_X4: List[int] = []

    multilateration_distances_P1: List[float] = []
    multilateration_times_P1: List[float] = []
    multilateration_distances_X4: List[float] = []
    multilateration_times_X4: List[float] = []

    rtt_distances_P1: List[float] = []
    rtt_times_P1: List[float] = []
    rtt_distances_X4: List[float] = []
    rtt_times_X4: List[float] = []

    P1_coord_estimated: List[Tuple[float, float, float]] = []
    X4_coord_estimated: List[Tuple[float, float, float]] = []

    typestore = get_typestore(Stores.ROS2_HUMBLE)
    filtered_gps_times: List[float] = []

    # Track the UAV's current altitude state.
    last_altitude: Optional[float] = None
    last_alt_valid: bool = False


    try:
        with Reader(str(bag_path)) as reader:
            for connection, timestamp, rawdata in reader.messages():
                time_relative = (timestamp * 1e-9) - bag_start_time

                if time_relative < start_interval or time_relative > end_interval:
                    continue

                # GPS: /FX8/fix
                if connection.topic == "/FX8/fix":
                    try:
                        msg = typestore.deserialize_cdr(rawdata, connection.msgtype)
                        altitude = float(msg.altitude)

                        last_altitude = altitude
                        last_alt_valid = (altitude >= altitude_threshold)

                        if altitude < altitude_threshold:
                            filtered_gps_times.append(time_relative)
                            continue

                        gps_entry = (float(msg.latitude), float(msg.longitude), altitude)
                        gps_data.append(gps_entry)
                        gps_times.append(time_relative)
                    except Exception as e:
                        logging.warning(f"Error deserializing GPS: {e}")
                        continue

                # RTT + RSSI: /Anchor1F/wifi_rtt_estimation
                elif connection.topic == "/Anchor1F/wifi_rtt_estimation":
                    try:
                        msg = typestore.deserialize_cdr(rawdata, connection.msgtype)
                        parts = [p.strip() for p in msg.data.split(",")]
                        if len(parts) < 4:
                            continue

                        estimated_distance = float(parts[0])
                        rssi = int(parts[2])
                        label = parts[3]

                        # Estimate distance with the path-loss model.
                        estimated_distance_rssi = estimate_distance(rssi, pathloss_model)

                        if altitude_threshold > 0.0 and not last_alt_valid:
                            continue


                        if label == "P1":
                            rtt_distances_P1.append(estimated_distance)
                            rtt_times_P1.append(time_relative)
                            rssi_data_P1.append(estimated_distance_rssi)
                            rssi_times_P1.append(time_relative)
                            rssi_values_P1.append(rssi)
                        elif label == "X4":
                            rtt_distances_X4.append(estimated_distance)
                            rtt_times_X4.append(time_relative)
                            rssi_data_X4.append(estimated_distance_rssi)
                            rssi_times_X4.append(time_relative)
                            rssi_values_X4.append(rssi)
                    except Exception as e:
                        logging.warning(f"Error parsing RTT+RSSI: {e}")
                        continue

                # Multilateration: /geo_multilateration_fx8_1f or /FX8/multilateration_all.
                elif connection.topic == multilateration_topic:
                    try:
                        msg = typestore.deserialize_cdr(rawdata, connection.msgtype)
                        parts = [p.strip() for p in msg.data.split(",")]
                        if len(parts) < 4:
                            continue

                        lat = float(parts[0])
                        lon = float(parts[1])
                        #alt = float(parts[2]) if parts[2] else 94.70
                        alt = 94.70
                        label = parts[3]

                        if altitude_threshold > 0.0 and not last_alt_valid:
                            continue

                        # Use the latest valid UAV GPS position.
                        if not gps_data:
                            continue
                        robot_position = gps_data[-1]
                        estimated_distance = euclidean_distance_3d(
                            robot_position, (lat, lon, alt)
                        )

                        if label == "P1":
                            multilateration_distances_P1.append(estimated_distance)
                            multilateration_times_P1.append(time_relative)
                            P1_coord_estimated.append((lat, lon, alt))
                        elif label == "X4":
                            multilateration_distances_X4.append(estimated_distance)
                            multilateration_times_X4.append(time_relative)
                            X4_coord_estimated.append((lat, lon, alt))
                    except Exception as e:
                        logging.warning(f"Error parsing multilateration: {e}")
                        continue

    except FileNotFoundError:
        logging.error(f"Bag not found: {bag_path}")
        return ()

    logging.info(f"GPS samples discarded by altitude: {len(filtered_gps_times)}")
    logging.info(f"GPS samples processed: {len(gps_times)}")

    return (
        gps_data,
        gps_times,
        rssi_data_P1,
        rssi_times_P1,
        rssi_data_X4,
        rssi_times_X4,
        multilateration_distances_P1,
        multilateration_times_P1,
        multilateration_distances_X4,
        multilateration_times_X4,
        rtt_distances_P1,
        rtt_times_P1,
        rtt_distances_X4,
        rtt_times_X4,
        X4_coord_estimated,
        P1_coord_estimated,
        rssi_values_X4,
        rssi_values_P1,
    )


# -------------------------------------------------------------------------
# Plots
# -------------------------------------------------------------------------
def plot_rssi_error(
    rssi_data_P1: List[float],
    rssi_times_P1: List[float],
    rssi_data_X4: List[float],
    rssi_times_X4: List[float],
    gps_times: List[float],
    gps_data: List[Tuple[float, float, float]],
    real_positions: Tuple[AnchorCoords, AnchorCoords],
) -> Tuple[List[float], List[float]]:
    """
    Calculate RSSI-model distance errors against P1 and X4 ground truth.
    """
    P1_pos, X4_pos = real_positions

    gps_to_P1_rssi = [
        get_gps_position_at_time(gps_times, gps_data, t) for t in rssi_times_P1
    ]
    gps_to_X4_rssi = [
        get_gps_position_at_time(gps_times, gps_data, t) for t in rssi_times_X4
    ]

    gps_P1_filtered = []
    rssi_P1_filtered = []
    rssi_times_P1_filtered = []
    for d, pos, t in zip(rssi_data_P1, gps_to_P1_rssi, rssi_times_P1):
        if pos is not None:
            gps_P1_filtered.append(pos)
            rssi_P1_filtered.append(d)
            rssi_times_P1_filtered.append(t)

    gps_X4_filtered = []
    rssi_X4_filtered = []
    rssi_times_X4_filtered = []
    for d, pos, t in zip(rssi_data_X4, gps_to_X4_rssi, rssi_times_X4):
        if pos is not None:
            gps_X4_filtered.append(pos)
            rssi_X4_filtered.append(d)
            rssi_times_X4_filtered.append(t)

    gps_distances_P1 = [
        euclidean_distance_3d(pos, (P1_pos.lat, P1_pos.lon, P1_pos.alt))
        for pos in gps_P1_filtered
    ]
    gps_distances_X4 = [
        euclidean_distance_3d(pos, (X4_pos.lat, X4_pos.lon, X4_pos.alt))
        for pos in gps_X4_filtered
    ]

    rssi_error_P1 = calculate_error(rssi_P1_filtered, gps_distances_P1)
    rssi_error_X4 = calculate_error(rssi_X4_filtered, gps_distances_X4)

    fig, ax = plt.subplots(figsize=(12, 8))
    ax.plot(
        rssi_times_P1_filtered,
        rssi_error_P1,
        label="Distance Error P1 (RSSI)",
        color="blue",
        linestyle="-",
        marker="o",
    )
    ax.plot(
        rssi_times_X4_filtered,
        rssi_error_X4,
        label="Distance Error X4 (RSSI)",
        color="purple",
        linestyle="-",
        marker="x",
    )
    ax.set_title("RSSI Distance Estimation Error", fontsize=18)
    ax.set_xlabel("Time (s)", fontsize=16)
    ax.set_ylabel("Error (m)", fontsize=16)
    ax.grid(True)
    legend = ax.legend(fontsize=16)
    legend.set_draggable(True)
    plt.tight_layout()
    # plt.show()  # Let the caller decide whether to display the plot.
    return rssi_error_P1, rssi_error_X4


def plot_multilateration_rtt_error(
    multilateration_distances_P1: List[float],
    multilateration_times_P1: List[float],
    multilateration_distances_X4: List[float],
    multilateration_times_X4: List[float],
    rtt_distances_P1: List[float],
    rtt_times_P1: List[float],
    rtt_distances_X4: List[float],
    rtt_times_X4: List[float],
    gps_times: List[float],
    gps_data: List[Tuple[float, float, float]],
    real_positions: Tuple[AnchorCoords, AnchorCoords],
) -> Tuple[List[float], List[float], List[float], List[float]]:
    """
    Calculate RTT and radial-difference multilateration errors for metrics and ECDFs.
    """
    P1_pos, X4_pos = real_positions

    gps_to_P1_rtt = [
        get_gps_position_at_time(gps_times, gps_data, t) for t in rtt_times_P1
    ]
    gps_to_X4_rtt = [
        get_gps_position_at_time(gps_times, gps_data, t) for t in rtt_times_X4
    ]
    gps_to_P1_multilat = [
        get_gps_position_at_time(gps_times, gps_data, t)
        for t in multilateration_times_P1
    ]
    gps_to_X4_multilat = [
        get_gps_position_at_time(gps_times, gps_data, t)
        for t in multilateration_times_X4
    ]

    valid_P1_rtt = [
        (d, pos) for d, pos in zip(rtt_distances_P1, gps_to_P1_rtt) if pos is not None
    ]
    valid_X4_rtt = [
        (d, pos) for d, pos in zip(rtt_distances_X4, gps_to_X4_rtt) if pos is not None
    ]
    valid_P1_multilat = [
        (d, pos)
        for d, pos in zip(multilateration_distances_P1, gps_to_P1_multilat)
        if pos is not None
    ]
    valid_X4_multilat = [
        (d, pos)
        for d, pos in zip(multilateration_distances_X4, gps_to_X4_multilat)
        if pos is not None
    ]

    gps_distances_P1_rtt = [
        euclidean_distance_3d(pos, (P1_pos.lat, P1_pos.lon, P1_pos.alt))
        for _, pos in valid_P1_rtt
    ]
    gps_distances_X4_rtt = [
        euclidean_distance_3d(pos, (X4_pos.lat, X4_pos.lon, X4_pos.alt))
        for _, pos in valid_X4_rtt
    ]
    gps_distances_P1_multilat = [
        euclidean_distance_3d(pos, (P1_pos.lat, P1_pos.lon, P1_pos.alt))
        for _, pos in valid_P1_multilat
    ]
    gps_distances_X4_multilat = [
        euclidean_distance_3d(pos, (X4_pos.lat, X4_pos.lon, X4_pos.alt))
        for _, pos in valid_X4_multilat
    ]

    rtt_error_P1 = calculate_error(
        [d for d, _ in valid_P1_rtt], gps_distances_P1_rtt
    )
    rtt_error_X4 = calculate_error(
        [d for d, _ in valid_X4_rtt], gps_distances_X4_rtt
    )
    multilateration_error_P1 = calculate_error(
        [d for d, _ in valid_P1_multilat], gps_distances_P1_multilat
    )
    multilateration_error_X4 = calculate_error(
        [d for d, _ in valid_X4_multilat], gps_distances_X4_multilat
    )

    return rtt_error_P1, rtt_error_X4, multilateration_error_P1, multilateration_error_X4


# -------------------------------------------------------------------------
# ECDF of multilateration position errors
# -------------------------------------------------------------------------

def plot_ecdf_position_errors(
    pos_error_P1: List[float],
    pos_error_X4: List[float],
    title: str = "ECDF of Multilateration Position Errors (3D)",
    percentiles: Tuple[int, int] = (50, 80, 95),
    show: bool = True,
    save_path: Optional[str] = None,
) -> None:
    """
    Plot the ECDF of 3-D multilateration position errors against ground truth.
    """
    if not pos_error_P1 and not pos_error_X4:
        logging.warning("plot_ecdf_position_errors: no position-error data available.")
        return

    err_P1 = np.asarray(pos_error_P1, dtype=float)
    err_X4 = np.asarray(pos_error_X4, dtype=float)

    fig, ax = plt.subplots(figsize=(10, 6))

    color_P1 = "#1f77b4"
    color_X4 = "#ff7f0e"
    linewidth = 2.5

    # P1
    if err_P1.size > 0:
        x_P1, y_P1 = ecdf(err_P1.tolist())
        label_P1 = f"P1 (N={len(err_P1)})"
        ax.plot(x_P1, y_P1, label=label_P1, color=color_P1,
                linestyle="-", linewidth=linewidth)

        for p in percentiles:
            v = float(np.percentile(err_P1, p))
            ax.axvline(v, color=color_P1, linestyle="--", linewidth=1)
            ax.annotate(
                f"{p}%: {v:.2f} m",
                xy=(v, 0.95),
                xytext=(10, 5),
                textcoords="offset points",
                fontsize=11,
                color=color_P1,
                arrowprops=dict(arrowstyle="->", color=color_P1),
            )

    # X4
    if err_X4.size > 0:
        x_X4, y_X4 = ecdf(err_X4.tolist())
        label_X4 = f"X4 (N={len(err_X4)})"
        ax.plot(x_X4, y_X4, label=label_X4, color=color_X4,
                linestyle="-", linewidth=linewidth)

        for p in percentiles:
            v = float(np.percentile(err_X4, p))
            ax.axvline(v, color=color_X4, linestyle="--", linewidth=1)
            ax.annotate(
                f"{p}%: {v:.2f} m",
                xy=(v, 0.85),
                xytext=(10, -25),
                textcoords="offset points",
                fontsize=11,
                color=color_X4,
                arrowprops=dict(arrowstyle="->", color=color_X4),
            )

    ax.set_title(title, fontsize=16)
    ax.set_xlabel("3D Positioning Error (m)", fontsize=14)
    ax.set_ylabel("Cumulative Probability", fontsize=14)
    ax.grid(True, linestyle="--", alpha=0.7)

    leg = ax.legend(fontsize=12, loc="lower right")
    leg.set_draggable(True)

    plt.tight_layout()
    if save_path:
        plt.savefig(save_path, dpi=300)
    if show:
        plt.show()
    else:
        plt.close(fig)


def plot_combined_ecdf(
    em_P1: List[float],
    em_X4: List[float],
    rtt_error_P1: List[float],
    rtt_error_X4: List[float],
) -> None:
    """Plot a combined ECDF of RTT and multilateration errors."""
    def _p(data: List[float], q: float) -> float:
        return percentile(data, q)

    fig, axes = plt.subplots(1, 2, figsize=(20, 6), sharey=True)
    ax_rtt, ax_mlt = axes

    palette = {"uav_P1": "#1f77b4", "uav_X4": "#ff7f0e"}
    linestyles = {"uav": "-"}
    linewidth = 2.5
    percentiles_list = [80, 95]

    offsets = {
        "rtt": {
            "uav_P1": {80: 0, 95: 25},
            "uav_X4": {80: 0, 95: -25},
        },
        "mlt": {
            "uav_P1": {80: 5, 95: -45},
            "uav_X4": {80: -7, 95: 30},
        },
    }

    # RTT
    labels_rtt = [
        (f"RTT to P1 (detected {len(rtt_error_P1)} times)", rtt_error_P1, "uav_P1"),
        (f"RTT to X4 (detected {len(rtt_error_X4)} times)", rtt_error_X4, "uav_X4"),
    ]
    for label, error, key in labels_rtt:
        x, y = ecdf(error)
        color = palette[key]
        ax_rtt.plot(x, y, label=label, color=color,
                    linestyle=linestyles["uav"], linewidth=linewidth)

        for perc in percentiles_list:
            v = _p(error, perc)
            ax_rtt.axvline(x=v, color=color, linestyle="--", linewidth=1)
            y_offset = offsets["rtt"][key][perc]
            ax_rtt.annotate(
                f"{perc}%: {v:.2f}m",
                xy=(v, 0.95),
                xytext=(10, y_offset),
                textcoords="offset points",
                fontsize=12,
                color=color,
                arrowprops=dict(arrowstyle="->", color=color),
            )

    ax_rtt.set_xlabel("RTT Distance Error (m)", fontsize=15)
    ax_rtt.set_ylabel("Cumulative Probability", fontsize=15)
    ax_rtt.grid(True, linestyle="--", alpha=0.7)
    legend1 = ax_rtt.legend(fontsize=12, loc="upper left")
    legend1.set_draggable(True)

    # Multilateration.
    labels_mlt = [
        (f"Multilateration to P1 (located {len(em_P1)} times)", em_P1, "uav_P1"),
        (f"Multilateration to X4 (located {len(em_X4)} times)", em_X4, "uav_X4"),
    ]
    for label, error, key in labels_mlt:
        x, y = ecdf(error)
        color = palette[key]
        ax_mlt.plot(x, y, label=label, color=color,
                    linestyle=linestyles["uav"], linewidth=linewidth)

        for perc in percentiles_list:
            v = _p(error, perc)
            ax_mlt.axvline(x=v, color=color, linestyle="--", linewidth=1)
            y_offset = offsets["mlt"][key][perc]
            ax_mlt.annotate(
                f"{perc}%: {v:.2f}m",
                xy=(v, 0.95),
                xytext=(5, y_offset),
                textcoords="offset points",
                fontsize=12,
                color=color,
                arrowprops=dict(arrowstyle="->", color=color),
            )

    ax_mlt.set_xlabel("Positioning Error (m)", fontsize=15)
    ax_mlt.grid(True, linestyle="--", alpha=0.7)
    legend2 = ax_mlt.legend(fontsize=12, loc="upper left")
    legend2.set_draggable(True)

    plt.tight_layout()
    plt.show()


def plot_altitude_uav(
    gps_data: List[Tuple[float, float, float]],
    gps_times: List[float],
    rtt_distances_P1: List[float],
    rtt_times_P1: List[float],
    rtt_distances_X4: List[float],
    rtt_times_X4: List[float],
    rssi_values_X4: List[int],
    rssi_values_P1: List[int],
    anchors: Tuple[AnchorCoords, AnchorCoords],
) -> None:
    """Plot UAV altitude, RSSI, RTT, and ground-truth distances."""
    if not gps_data:
        logging.error("No GPS data remain after filtering; skipping plot_altitude_uav.")
        return

    P1_pos, X4_pos = anchors
    P1_real = (P1_pos.lat, P1_pos.lon, P1_pos.alt)
    X4_real = (X4_pos.lat, X4_pos.lon, X4_pos.alt)

    groundT_uavToP1 = [euclidean_distance_3d(g, P1_real) for g in gps_data]
    groundT_uavToX4 = [euclidean_distance_3d(g, X4_real) for g in gps_data]
    altitudes = [g[2] for g in gps_data]

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 12))
    plt.subplots_adjust(hspace=0.3, top=0.95)

    # Altitude and RSSI.
    ax_rssi = ax1.twinx()
    dash_dot_dot = (0, (3, 1, 1, 1, 1, 1))

    ax1.plot(
        gps_times,
        altitudes,
        label="UAV Altitude",
        color="green",
        linewidth=2,
        linestyle=dash_dot_dot,
    )
    ax1.set_ylabel("Altitude (m)", fontsize=14, color="green")
    ax1.tick_params(axis="y", labelsize=12, colors="green")
    ax1.grid(True)
    ax1.spines["left"].set_color("green")

    ax_rssi.scatter(
        rtt_times_P1,
        rssi_values_P1,
        label="Signal detection from P1",
        marker="*",
        color="#d62728",
        edgecolors="k",
        s=100,
        alpha=0.7,
    )
    ax_rssi.scatter(
        rtt_times_X4,
        rssi_values_X4,
        label="Signal detection from X4",
        marker="o",
        color="#ff9896",
        edgecolors="k",
        s=100,
        alpha=0.7,
    )
    ax_rssi.set_ylabel("RSSI (dBm)", fontsize=14, color="red")
    ax_rssi.tick_params(axis="y", labelsize=12, colors="red")
    ax_rssi.spines["right"].set_color("red")

    h1, l1 = ax1.get_legend_handles_labels()
    h2, l2 = ax_rssi.get_legend_handles_labels()
    ax1.legend(h1 + h2, l1 + l2, fontsize=12, loc="upper left")

    # RTT + ground truth distances
    ax3 = ax2.twinx()
    ax2.plot(
        rtt_times_P1,
        rtt_distances_P1,
        label="RTT estimation to P1",
        color="#1f77b4",
        linewidth=2,
        linestyle="-",
    )
    ax2.plot(
        rtt_times_X4,
        rtt_distances_X4,
        label="RTT estimation to X4",
        color="#aec7e8",
        linewidth=2,
        linestyle="--",
    )
    ax3.plot(
        gps_times,
        groundT_uavToP1,
        label="Ground Truth to P1",
        color="green",
        linewidth=2,
        linestyle="-",
    )
    ax3.plot(
        gps_times,
        groundT_uavToX4,
        label="Ground Truth to X4",
        color="green",
        linewidth=2,
        linestyle="--",
    )

    ax2.set_xlabel("Time (s)", fontsize=14)
    ax2.set_ylabel("RTT Distance (m)", fontsize=14, color="blue")
    ax2.tick_params(axis="y", labelcolor="blue", labelsize=12)
    ax2.grid(True, linestyle="--", linewidth=0.5, alpha=0.7)

    ax3.set_ylabel("Ground Truth Distance (m)", fontsize=14, color="green")
    ax3.tick_params(axis="y", labelcolor="green", labelsize=12)

    ax2.legend(fontsize=12, loc="upper left")
    ax3.legend(fontsize=12, loc="upper right")

    fig.suptitle(
        "UAV Altitude, RSSI, RTT, and Ground Truth",
        fontsize=18,
        fontweight="bold",
    )
    plt.tight_layout(rect=[0, 0.03, 1, 0.95])
    plt.show()


def plot_estimations(
    p1_coord_estimated: List[Tuple[float, float, float]],
    x4_coord_estimated: List[Tuple[float, float, float]],
    anchors: Tuple[AnchorCoords, AnchorCoords],
    cep50_P1: Optional[float] = None,
    cep90_P1: Optional[float] = None,
    cep50_X4: Optional[float] = None,
    cep90_X4: Optional[float] = None,
) -> None:
    """
    Plot latitude/longitude estimates against surveyed positions, with optional
    horizontal CEP circles in meters.
    """
    from matplotlib.patches import Circle

    P1_pos, X4_pos = anchors

    lat_P1 = [c[0] for c in p1_coord_estimated]
    lon_P1 = [c[1] for c in p1_coord_estimated]
    lat_X4 = [c[0] for c in x4_coord_estimated]
    lon_X4 = [c[1] for c in x4_coord_estimated]

    LAT_TO_M = 111320.0
    LON_TO_M = 89400.0  # Approximate conversion at the experiment latitude.

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 6))

    # P1
    x_P1 = np.array(lon_P1) * LON_TO_M
    y_P1 = np.array(lat_P1) * LAT_TO_M
    x_P1_gt = P1_pos.lon * LON_TO_M
    y_P1_gt = P1_pos.lat * LAT_TO_M

    ax1.scatter(x_P1, y_P1, s=20, label="P1 Est.")
    ax1.scatter(x_P1_gt, y_P1_gt, marker="x", color="red", s=80, label="P1 GT")

    # Add CEP circles when provided.
    for r, ls, lbl in [
        (cep50_P1, "-", "CEP50"),
        (cep90_P1, "--", "CEP90"),
    ]:
        if r is not None and not np.isnan(r):
            circ = Circle((x_P1_gt, y_P1_gt), r, fill=False, linestyle=ls, alpha=0.7)
            ax1.add_patch(circ)

    ax1.set_aspect("equal", "box")
    ax1.set_xlabel("Longitude (m)", fontsize=12)
    ax1.set_ylabel("Latitude (m)", fontsize=12)
    ax1.set_title("Estimations for P1", fontsize=14)
    ax1.grid(True, linestyle="--", alpha=0.7)
    ax1.legend()

    # X4
    x_X4 = np.array(lon_X4) * LON_TO_M
    y_X4 = np.array(lat_X4) * LAT_TO_M
    x_X4_gt = X4_pos.lon * LON_TO_M
    y_X4_gt = X4_pos.lat * LAT_TO_M

    ax2.scatter(x_X4, y_X4, s=20, label="X4 Est.")
    ax2.scatter(x_X4_gt, y_X4_gt, marker="x", color="red", s=80, label="X4 GT")

    for r, ls, lbl in [
        (cep50_X4, "-", "CEP50"),
        (cep90_X4, "--", "CEP90"),
    ]:
        if r is not None and not np.isnan(r):
            circ = Circle((x_X4_gt, y_X4_gt), r, fill=False, linestyle=ls, alpha=0.7)
            ax2.add_patch(circ)

    ax2.set_aspect("equal", "box")
    ax2.set_xlabel("Longitude (m)", fontsize=12)
    ax2.set_ylabel("Latitude (m)", fontsize=12)
    ax2.set_title("Estimations for X4", fontsize=14)
    ax2.grid(True, linestyle="--", alpha=0.7)
    ax2.legend()

    plt.tight_layout()
    plt.show()


# -------------------------------------------------------------------------
# Metrics and result output
# -------------------------------------------------------------------------
def summarize_errors(name: str, errors: List[float]) -> Dict[str, float]:
    """Return standard metrics for a list of errors."""
    arr = np.asarray(errors, dtype=float)
    return {
        "count": len(arr),
        "min": float(np.min(arr)) if arr.size else float("nan"),
        "max": float(np.max(arr)) if arr.size else float("nan"),
        "mean": float(np.mean(arr)) if arr.size else float("nan"),
        "median": float(np.median(arr)) if arr.size else float("nan"),
        "std": float(np.std(arr)) if arr.size else float("nan"),
        "rmse": float(np.sqrt(np.mean(arr ** 2))) if arr.size else float("nan"),
        "p50": percentile(errors, 50) if arr.size else float("nan"),
        "p80": percentile(errors, 80) if arr.size else float("nan"),
        "p95": percentile(errors, 95) if arr.size else float("nan"),
    }


def print_stats_block(
    title: str,
    stats_P1: Dict[str, float],
    stats_X4: Dict[str, float],
) -> None:
    print(title)
    print("-" * 60)
    print(f"{'Metric':<15} {'P1 (m)':<15} {'X4 (m)':<15}")
    print("-" * 60)
    for key in ["count", "min", "max", "mean", "median", "std", "rmse", "p80", "p95"]:
        print(
            f"{key:<15} "
            f"{stats_P1.get(key, float('nan')):<15.2f} "
            f"{stats_X4.get(key, float('nan')):<15.2f}"
        )
    print()


def display_positioning_metrics(
    pos_err_P1_3d: List[float],
    pos_err_X4_3d: List[float],
    horiz_err_P1: List[float],
    horiz_err_X4: List[float],
    vert_err_P1: List[float],
    vert_err_X4: List[float],
) -> None:
    """
    Print 3-D, horizontal, and vertical positioning-error metrics and CEP50/CEP90.
    """
    stats_pos_P1 = summarize_errors("POS3D P1", pos_err_P1_3d)
    stats_pos_X4 = summarize_errors("POS3D X4", pos_err_X4_3d)
    stats_h_P1 = summarize_errors("HORIZ P1", horiz_err_P1)
    stats_h_X4 = summarize_errors("HORIZ X4", horiz_err_X4)
    # Vertical errors are signed; report their distribution statistics.
    vert_P1_arr = np.asarray(vert_err_P1, dtype=float)
    vert_X4_arr = np.asarray(vert_err_X4, dtype=float)

    cep50_P1 = compute_cep(horiz_err_P1, 50)
    cep90_P1 = compute_cep(horiz_err_P1, 90)
    cep50_X4 = compute_cep(horiz_err_X4, 50)
    cep90_X4 = compute_cep(horiz_err_X4, 90)

    print("POSITIONING ERROR (3D):")
    print("-" * 60)
    print(f"{'Metric':<15} {'P1 (m)':<15} {'X4 (m)':<15}")
    print("-" * 60)
    for key in ["count", "min", "max", "mean", "median", "std", "rmse", "p80", "p95"]:
        print(
            f"{key:<15} "
            f"{stats_pos_P1.get(key, float('nan')):<15.2f} "
            f"{stats_pos_X4.get(key, float('nan')):<15.2f}"
        )
    print()

    print("HORIZONTAL POSITION ERROR (plan view):")
    print("-" * 60)
    print(f"{'Metric':<15} {'P1 (m)':<15} {'X4 (m)':<15}")
    print("-" * 60)
    for key in ["min", "max", "mean", "median", "p80", "p95"]:
        print(
            f"{key:<15} "
            f"{stats_h_P1.get(key, float('nan')):<15.2f} "
            f"{stats_h_X4.get(key, float('nan')):<15.2f}"
        )
    print()

    print("VERTICAL ERROR (altitude difference, signed):")
    print("-" * 60)
    print(f"{'Metric':<15} {'P1 (m)':<15} {'X4 (m)':<15}")
    print("-" * 60)
    for name, arr in [("mean", np.mean), ("median", np.median), ("std", np.std)]:
        vP = float(arr(vert_P1_arr)) if vert_P1_arr.size else float("nan")
        vX = float(arr(vert_X4_arr)) if vert_X4_arr.size else float("nan")
        print(f"{name:<15} {vP:<15.2f} {vX:<15.2f}")
    print()

    print("CEP METRICS (horizontal, in meters):")
    print("-" * 60)
    print(f"{'CEP':<15} {'P1 (m)':<15} {'X4 (m)':<15}")
    print("-" * 60)
    print(f"{'CEP50':<15} {cep50_P1:<15.2f} {cep50_X4:<15.2f}")
    print(f"{'CEP90':<15} {cep90_P1:<15.2f} {cep90_X4:<15.2f}")
    print("-" * 60 + "\n")


def display_results(
    altitude_threshold: float,
    rssi_data_P1: List[float],
    rtt_distances_P1: List[float],
    multilateration_distances_P1: List[float],
    rssi_data_X4: List[float],
    rtt_distances_X4: List[float],
    multilateration_distances_X4: List[float],
    gps_data: List[Tuple[float, float, float]],
    gps_times: List[float],
    multilateration_error_P1: List[float],
    multilateration_error_X4: List[float],
    rtt_error_P1: List[float],
    rtt_error_X4: List[float],
    rssi_error_P1_total: List[float],
    rssi_error_X4_total: List[float],
    gps_distances_P1: List[float],
    gps_distances_X4: List[float],
) -> None:
    print("\n" + "*" * 60)
    print(f"RESULTS FOR UAV ALTITUDE ABOVE: {altitude_threshold:.2f} m")
    print("*" * 60 + "\n")

    # Detections.
    print("UAV SIGNAL DETECTION:")
    print("-" * 50)
    print(f"{'Signal Detection':<25} {'P1':<10} {'X4':<10}")
    print("-" * 50)
    print(f"{'RSSI Count':<25} {len(rssi_data_P1):<10} {len(rssi_data_X4):<10}")
    print(f"{'RTT Count':<25} {len(rtt_distances_P1):<10} {len(rtt_distances_X4):<10}")
    print(
        f"{'Multilateration Count':<25} "
        f"{len(multilateration_distances_P1):<10} {len(multilateration_distances_X4):<10}\n"
    )

    print("UAV GPS DATA:")
    print("-" * 50)
    print(f"Total GPS Positions: {len(gps_data):<10}")
    print(f"Total GPS Times: {len(gps_times):<10}\n")

    stats_mlt_P1 = summarize_errors("Multilateration P1", multilateration_error_P1)
    stats_mlt_X4 = summarize_errors("Multilateration X4", multilateration_error_X4)
    print_stats_block("MULTILATERATION ERRORS:", stats_mlt_P1, stats_mlt_X4)

    stats_rtt_P1 = summarize_errors("RTT P1", rtt_error_P1)
    stats_rtt_X4 = summarize_errors("RTT X4", rtt_error_X4)
    print_stats_block("RTT ERRORS:", stats_rtt_P1, stats_rtt_X4)

    stats_rssi_P1 = summarize_errors("RSSI P1", rssi_error_P1_total)
    stats_rssi_X4 = summarize_errors("RSSI X4", rssi_error_X4_total)
    print_stats_block("RSSI ERRORS:", stats_rssi_P1, stats_rssi_X4)

    stats_dist_P1 = summarize_errors("Dist P1", gps_distances_P1)
    stats_dist_X4 = summarize_errors("Dist X4", gps_distances_X4)
    print_stats_block("UAV DISTANCES TO TARGETS:", stats_dist_P1, stats_dist_X4)

    print("*" * 60 + "\n")


# -------------------------------------------------------------------------
# Main pipeline for each bag
# -------------------------------------------------------------------------
def process_bag(
    bag_cfg: BagConfig,
    bag_start_time: float,
    bag_end_time: float,
    altitude_threshold: float,
    anchors: Tuple[AnchorCoords, AnchorCoords],
    pathloss_model: PathLossModel,
) -> None:
    P1_coords, X4_coords = anchors

    start_interval = 0.0
    end_interval = bag_end_time - bag_start_time

    res = read_bag(
        bag_cfg.bag_path,
        bag_start_time,
        start_interval,
        end_interval,
        altitude_threshold,
        bag_cfg.multilateration_topic,
        pathloss_model,
    )

    if not res:
        logging.error(f"Could not read bag: {bag_cfg.bag_path}")
        return

    (
        gps_data,
        gps_times,
        rssi_data_P1,
        rssi_times_P1,
        rssi_data_X4,
        rssi_times_X4,
        multilateration_distances_P1,
        multilateration_times_P1,
        multilateration_distances_X4,
        multilateration_times_X4,
        rtt_distances_P1,
        rtt_times_P1,
        rtt_distances_X4,
        rtt_times_X4,
        X4_coord_estimated,
        P1_coord_estimated,
        rssi_values_X4,
        rssi_values_P1,
    ) = res

    if not gps_data:
        logging.error("No GPS data available; skipping this bag.")
        return

    P1_tuple = (P1_coords.lat, P1_coords.lon, P1_coords.alt)
    X4_tuple = (X4_coords.lat, X4_coords.lon, X4_coords.alt)

    gps_distances_P1 = [euclidean_distance_3d(g, P1_tuple) for g in gps_data]
    gps_distances_X4 = [euclidean_distance_3d(g, X4_tuple) for g in gps_data]

    # ---- Total UAV path length ----
    total_dist_3d, total_dist_h = compute_path_length(gps_data)

    print("UAV PATH LENGTH:")
    print("-" * 60)
    print(f"{'Type':<20} {'meters':<15} {'km':<15}")
    print("-" * 60)
    print(f"{'3D path length':<20} {total_dist_3d:<15.2f} {total_dist_3d/1000.0:<15.3f}")
    print(f"{'Horizontal path':<20} {total_dist_h:<15.2f} {total_dist_h/1000.0:<15.3f}")
    print()


        # ---- UAV speed profile ----
    speed_times, v3d, vh = compute_speed_profile(gps_data, gps_times)

    if v3d:
        # Calculate statistics in meters per second.
        stats_v3d = summarize_errors("UAV speed 3D", v3d)
        stats_vh  = summarize_errors("UAV speed horiz", vh)

        # Print values in meters per second and kilometers per hour.
        def _print_speed_block(title: str, stats: Dict[str, float]):
            print(title)
            print("-" * 60)
            print(f"{'Metric':<15} {'m/s':<15} {'km/h':<15}")
            print("-" * 60)
            for key in ["min", "max", "mean", "median", "p80", "p95"]:
                v_ms = stats.get(key, float("nan"))
                v_kmh = v_ms * 3.6
                print(f"{key:<15} {v_ms:<15.2f} {v_kmh:<15.2f}")
            print()

        _print_speed_block("UAV SPEED (3D):", stats_v3d)
        _print_speed_block("UAV SPEED (horizontal):", stats_vh)


        # Optionally plot horizontal speed over time.
    if speed_times and vh:
        plt.figure(figsize=(10, 4))
        plt.plot(speed_times, [v * 3.6 for v in vh], label="UAV horizontal speed")
        plt.xlabel("Time (s)")
        plt.ylabel("Speed (km/h)")
        plt.title("UAV horizontal speed profile")
        plt.grid(True, linestyle="--", alpha=0.7)
        plt.legend()
        plt.tight_layout()
        plt.show()


    # Plots.
    plot_altitude_uav(
        gps_data,
        gps_times,
        rtt_distances_P1,
        rtt_times_P1,
        rtt_distances_X4,
        rtt_times_X4,
        rssi_values_X4,
        rssi_values_P1,
        anchors,
    )

    # RTT range errors. The radial-difference multilateration values
    # returned by this helper are intentionally not used as position errors.
    rtt_error_P1, rtt_error_X4, _radial_difference_mlt_P1, _radial_difference_mlt_X4 = plot_multilateration_rtt_error(
        multilateration_distances_P1,
        multilateration_times_P1,
        multilateration_distances_X4,
        multilateration_times_X4,
        rtt_distances_P1,
        rtt_times_P1,
        rtt_distances_X4,
        rtt_times_X4,
        gps_times,
        gps_data,
        anchors,
    )

    # RSSI error plot: estimated distance against ground truth.
    _rssi_error_plot_P1, _rssi_error_plot_X4 = plot_rssi_error(
        rssi_data_P1,
        rssi_times_P1,
        rssi_data_X4,
        rssi_times_X4,
        gps_times,
        gps_data,
        anchors,
    )


    rssi_error_P1_total = calculate_error(rssi_data_P1, gps_distances_P1)
    rssi_error_X4_total = calculate_error(rssi_data_X4, gps_distances_X4)


        # --- Positioning errors from multilateration coordinates ---
    horiz_P1, vert_P1, pos3d_P1 = horizontal_vertical_errors(P1_coord_estimated, P1_coords)
    horiz_X4, vert_X4, pos3d_X4 = horizontal_vertical_errors(X4_coord_estimated, X4_coords)

    # ECDF of 3-D positioning error.
    plot_ecdf_position_errors(pos3d_P1, pos3d_X4)

    # Detailed positioning metrics and CEP.
    display_positioning_metrics(
        pos3d_P1,
        pos3d_X4,
        horiz_P1,
        horiz_X4,
        vert_P1,
        vert_X4,
    )


    # ECDF: RTT range error and direct horizontal positioning error.
    plot_combined_ecdf(horiz_P1, horiz_X4, rtt_error_P1, rtt_error_X4)

    # Mobile-position errors for P1 and X4 against ground truth.
    mlt_pos_error_P1, mlt_pos_error_X4 = compute_multilateration_position_errors(
        P1_coord_estimated,   # P1 estimates.
        X4_coord_estimated,   # X4 estimates.
        anchors,
    )

    plot_ecdf_position_errors(
        mlt_pos_error_P1,
        mlt_pos_error_X4,
        title=f"ECDF - Multilateration Position Error ({bag_cfg.bag_path.name})",
        save_path=None,    # Example: f"ecdf_pos_{bag_cfg.bag_path.stem}.png"
    )

    # Plot estimates against surveyed positions.
    cep50_P1 = compute_cep(horiz_P1, 50)
    cep90_P1 = compute_cep(horiz_P1, 90)
    cep50_X4 = compute_cep(horiz_X4, 50)
    cep90_X4 = compute_cep(horiz_X4, 90)

    plot_estimations(
        P1_coord_estimated,
        X4_coord_estimated,
        anchors,
        cep50_P1=cep50_P1,
        cep90_P1=cep90_P1,
        cep50_X4=cep50_X4,
        cep90_X4=cep90_X4,
    )


    display_results(
        altitude_threshold,
        rssi_data_P1,
        rtt_distances_P1,
        multilateration_distances_P1,
        rssi_data_X4,
        rtt_distances_X4,
        multilateration_distances_X4,
        gps_data,
        gps_times,
        horiz_P1,
        horiz_X4,
        rtt_error_P1,
        rtt_error_X4,
        rssi_error_P1_total,
        rssi_error_X4_total,
        gps_distances_P1,
        gps_distances_X4,
    )



# -------------------------------------------------------------------------
# main + argparse
# -------------------------------------------------------------------------
def main() -> None:
    parser = argparse.ArgumentParser(
        description="Analyze ROS 2 experiments with RTT and multilateration."
    )
    parser.add_argument(
        "--p1",
        type=parse_coord3,
        default="36.71678533,-4.48830800,94.70",
        help="P1 coordinates (lat,lon,alt).",
    )
    parser.add_argument(
        "--x4",
        type=parse_coord3,
        default="36.71680367,-4.48832033,94.70",
        help="X4 coordinates (lat,lon,alt).",
    )
    parser.add_argument(
        "--p0",
        type=float,
        default=-45.0,
        help="RSSI at 1 m (dBm) for the propagation model.",
    )
    parser.add_argument(
        "--n",
        type=float,
        default=2.0,
        help="Path-loss exponent for the propagation model.",
    )
    parser.add_argument(
        "--d0",
        type=float,
        default=1.0,
        help="Reference distance d0 (m) for the propagation model.",
    )
    parser.add_argument(
        "--alt-threshold",
        type=float,
        default=0.0,
        help="Altitude threshold (m) for accepting GPS samples.",
    )
    parser.add_argument(
        "--takeoff-offset",
        type=float,
        default=71.0,
        help="Time offset (s) added at the start of the bag after takeoff.",
    )
    parser.add_argument(
        "--landing-offset",
        type=float,
        default=10.0,
        help="Time offset (s) subtracted at the end of the bag before landing.",
    )

    parser.add_argument(
    "--bag",
    action="append",
    metavar=("PATH", "TOPIC"),
    nargs=2,
    help="ROS bag and multilateration-topic pair (PATH, TOPIC); may be repeated.",
    )


    args = parser.parse_args()

    anchors = (args.p1, args.x4)
    pathloss_model = PathLossModel(p0=args.p0, n=args.n, d0=args.d0)
    altitude_threshold = args.alt_threshold
    time_take_off = args.takeoff_offset
    time_landing = args.landing_offset

    bags: list[BagConfig] = []

    if args.bag:
        for path_str, topic_str in args.bag:
            bags.append(BagConfig(bag_path=Path(path_str), multilateration_topic=topic_str))
    else:
        # Use the repository datasets by default for the included field experiment.
        bags = [
            BagConfig(
                bag_path=REPOSITORY_ROOT / "data" / "jemerg24-realTime",
                multilateration_topic="/geo_multilateration_fx8_1f",
            ),
            BagConfig(
                bag_path=REPOSITORY_ROOT / "data" / "jemerg24-filtered",
                multilateration_topic="/FX8/multilateration_all",
            ),
        ]


    for bag_cfg in bags:
        logging.info(f"Processing bag: {bag_cfg.bag_path}")
        bag_start_time, bag_end_time = get_bag_start_end_time(bag_cfg.bag_path)

        if bag_start_time is None or bag_end_time is None:
            logging.error(
                f"Skipping bag due to missing times: {bag_cfg.bag_path}"
            )
            continue

        adjusted_start_time = bag_start_time + time_take_off
        adjusted_end_time = bag_end_time - time_landing

        if adjusted_start_time >= adjusted_end_time:
            logging.error(
                f"Invalid time range after offsets for bag: {bag_cfg.bag_path}"
            )
            continue

        process_bag(
            bag_cfg,
            adjusted_start_time,
            adjusted_end_time,
            altitude_threshold,
            anchors,
            pathloss_model,
        )


if __name__ == "__main__":
    main()


"""
Examples:

python analysis_tool.py \
  --p1 "36.71678,-4.48830,94.7" \
  --x4 "36.71680,-4.48832,94.7" \
  --p0 -42 \
  --n 2.3 \
  --alt-threshold 10 \
  --takeoff-offset 76 \
  --landing-offset 5

python analysis_tool.py --alt-threshold 0 \
    --bag data/jemerg24-realTime /geo_multilateration_fx8_1f \
    --bag data/jemerg24-filtered /FX8/multilateration_all

"""
