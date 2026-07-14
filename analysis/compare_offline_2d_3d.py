#!/usr/bin/env python3
"""Offline 2-D vs 3-D Huber ILS comparison for the included field bag."""

import argparse
import logging
from collections import defaultdict, deque
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

import numpy as np
import pyproj
from geopy.distance import geodesic
from rosbags.rosbag2 import Reader
from rosbags.typesys import Stores, get_typestore


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
GPS_TOPIC = "/FX8/fix"
RTT_TOPIC = "/Anchor1F/wifi_rtt_estimation"
RAW_MULTILATERATION_TOPIC = "/geo_multilateration_fx8_1f"
FILTERED_MULTILATERATION_TOPIC = "/FX8/multilateration_all"
TARGETS = ("P1", "X4")


@dataclass(frozen=True)
class Target:
    lat: float
    lon: float
    alt: float


@dataclass(frozen=True)
class Estimate:
    time_s: float
    lat: float
    lon: float
    alt: float | None
    converged: bool = True
    condition: float | None = None


@dataclass
class SolverSummary:
    count: int
    failures: int
    horizontal_mean: float
    horizontal_median: float
    horizontal_p95: float
    vertical_mean: float | None = None
    vertical_median: float | None = None
    vertical_p95_abs: float | None = None
    error3d_mean: float | None = None
    error3d_median: float | None = None
    error3d_p95: float | None = None
    condition_median: float | None = None
    condition_p95: float | None = None


@dataclass(frozen=True)
class TableMetric:
    count: int
    mean: float
    p95: float


WGS84 = pyproj.CRS("EPSG:4979")
ECEF = pyproj.CRS("EPSG:4978")
TO_ECEF = pyproj.Transformer.from_crs(WGS84, ECEF, always_xy=True)
TO_WGS84 = pyproj.Transformer.from_crs(ECEF, WGS84, always_xy=True)


def wgs84_to_ecef(lat: float, lon: float, alt: float) -> np.ndarray:
    x, y, z = TO_ECEF.transform(lon, lat, alt)
    return np.asarray((x, y, z), dtype=float)


def ecef_to_wgs84(ecef_position: Iterable[float]) -> tuple[float, float, float]:
    lon, lat, alt = TO_WGS84.transform(*ecef_position)
    return float(lat), float(lon), float(alt)


def distance_3d(
    point: tuple[float, float, float],
    target: Target,
) -> float:
    horizontal = geodesic((point[0], point[1]), (target.lat, target.lon)).meters
    return float(np.hypot(horizontal, point[2] - target.alt))


def huber_weights(residuals: np.ndarray, threshold: float = 0.7317) -> np.ndarray:
    weights = np.ones(len(residuals), dtype=float)
    outliers = np.abs(residuals) > threshold
    weights[outliers] = threshold / np.abs(residuals[outliers])
    return weights


def projected_2d_ranges(anchor_positions: np.ndarray, distances: np.ndarray) -> np.ndarray:
    projected = distances.copy()
    min_height = float(np.min(anchor_positions[:, 2]))
    for idx, (distance, anchor) in enumerate(zip(distances, anchor_positions)):
        height_delta = float(anchor[2] - min_height)
        if distance > abs(height_delta):
            projected[idx] = float(np.sqrt(distance * distance - height_delta * height_delta))
    return projected


def geometry_condition(position: np.ndarray, anchors: np.ndarray) -> float:
    ranges = np.linalg.norm(position - anchors, axis=1)
    if np.any(ranges <= 1e-9):
        return float("inf")
    h_matrix = (position - anchors) / ranges[:, None]
    return float(np.linalg.cond(h_matrix.T @ h_matrix))


def huber_ils(
    anchors: list[np.ndarray],
    distances: list[float],
    dimension: int,
) -> tuple[np.ndarray | None, bool, float | None]:
    anchor_array = np.asarray(anchors, dtype=float)
    distance_array = np.asarray(distances, dtype=float)

    if dimension == 2:
        distance_array = projected_2d_ranges(anchor_array, distance_array)
        anchor_array = anchor_array[:, :2]
    elif dimension != 3:
        raise ValueError("dimension must be 2 or 3")

    closest_idx = int(np.argmin(distance_array))
    position = anchor_array[closest_idx].copy() + 1.0
    old_max_step = 1e10

    for _ in range(40):
        previous = position.copy()
        ranges = np.linalg.norm(position - anchor_array, axis=1)
        if np.any(ranges <= 1e-9):
            return None, False, None

        h_matrix = (position - anchor_array) / ranges[:, None]
        residuals = distance_array - ranges
        weights = np.diag(huber_weights(residuals))

        try:
            gain = np.linalg.inv((h_matrix.T @ weights) @ h_matrix) @ h_matrix.T @ weights
        except np.linalg.LinAlgError:
            return None, False, None

        step = gain @ residuals
        position = position + step
        max_step = float(np.max(np.abs(step)))

        if max_step < 1e-2 and max_step != 0.0:
            return position, True, geometry_condition(position, anchor_array)

        if max_step - old_max_step > 0.5:
            return previous, True, geometry_condition(previous, anchor_array)

        old_max_step = max_step

    return position, False, geometry_condition(position, anchor_array)


def summarize(
    estimates: list[Estimate],
    target: Target,
    failures: int = 0,
) -> SolverSummary:
    if not estimates:
        return SolverSummary(
            count=0,
            failures=failures,
            horizontal_mean=float("nan"),
            horizontal_median=float("nan"),
            horizontal_p95=float("nan"),
        )

    horizontal = np.asarray(
        [geodesic((estimate.lat, estimate.lon), (target.lat, target.lon)).meters for estimate in estimates],
        dtype=float,
    )
    altitudes = [estimate.alt for estimate in estimates if estimate.alt is not None]
    conditions = [estimate.condition for estimate in estimates if estimate.condition is not None]

    summary = SolverSummary(
        count=len(estimates),
        failures=failures,
        horizontal_mean=float(np.mean(horizontal)),
        horizontal_median=float(np.median(horizontal)),
        horizontal_p95=float(np.percentile(horizontal, 95)),
    )

    if altitudes:
        vertical = np.asarray([alt - target.alt for alt in altitudes], dtype=float)
        error3d = np.hypot(horizontal[: len(vertical)], vertical)
        summary.vertical_mean = float(np.mean(vertical))
        summary.vertical_median = float(np.median(vertical))
        summary.vertical_p95_abs = float(np.percentile(np.abs(vertical), 95))
        summary.error3d_mean = float(np.mean(error3d))
        summary.error3d_median = float(np.median(error3d))
        summary.error3d_p95 = float(np.percentile(error3d, 95))

    if conditions:
        condition_array = np.asarray(conditions, dtype=float)
        summary.condition_median = float(np.median(condition_array))
        summary.condition_p95 = float(np.percentile(condition_array, 95))

    return summary


def summarize_values(values: list[float]) -> TableMetric:
    if not values:
        return TableMetric(count=0, mean=float("nan"), p95=float("nan"))
    values_array = np.asarray(values, dtype=float)
    return TableMetric(
        count=len(values),
        mean=float(np.mean(values_array)),
        p95=float(np.percentile(values_array, 95)),
    )


def summarize_horizontal(estimates: list[Estimate], target: Target) -> TableMetric:
    errors = [
        geodesic((estimate.lat, estimate.lon), (target.lat, target.lon)).meters
        for estimate in estimates
    ]
    return summarize_values(errors)


def median_filter_estimates(
    estimates_by_target: dict[str, list[Estimate]],
    window_size: int = 20,
) -> dict[str, list[Estimate]]:
    filtered = {target: [] for target in TARGETS}

    for label, estimates in estimates_by_target.items():
        latitudes: deque[float] = deque(maxlen=window_size)
        longitudes: deque[float] = deque(maxlen=window_size)
        altitudes: deque[float] = deque(maxlen=window_size)

        for estimate in estimates:
            if estimate.alt is None:
                continue
            latitudes.append(estimate.lat)
            longitudes.append(estimate.lon)
            altitudes.append(estimate.alt)

            if len(latitudes) == window_size:
                filtered[label].append(
                    Estimate(
                        time_s=estimate.time_s,
                        lat=float(np.median(latitudes)),
                        lon=float(np.median(longitudes)),
                        alt=float(np.median(altitudes)),
                    )
                )

    return filtered


def nearest_gps_distance_error(
    estimate_distance: float,
    estimate_time: float,
    gps_times: list[float],
    gps_data: list[tuple[float, float, float]],
    target: Target,
) -> float | None:
    if not gps_times:
        return None
    idx = int(np.argmin(np.abs(np.asarray(gps_times, dtype=float) - estimate_time)))
    return abs(estimate_distance - distance_3d(gps_data[idx], target))


def read_stored_estimates(
    bag_path: Path,
    topic: str,
    targets: dict[str, Target],
    altitude_threshold: float,
    takeoff_offset: float,
    landing_offset: float,
) -> dict[str, list[Estimate]]:
    estimates = {target: [] for target in TARGETS}
    typestore = get_typestore(Stores.ROS2_HUMBLE)
    latest_alt_valid = False

    with Reader(str(bag_path)) as reader:
        adjusted_start = reader.start_time * 1e-9 + takeoff_offset
        adjusted_end = reader.end_time * 1e-9 - landing_offset

        for connection, timestamp, rawdata in reader.messages():
            stamp_s = timestamp * 1e-9
            if stamp_s < adjusted_start or stamp_s > adjusted_end:
                continue

            time_s = stamp_s - adjusted_start

            if connection.topic == GPS_TOPIC:
                msg = typestore.deserialize_cdr(rawdata, connection.msgtype)
                latest_alt_valid = float(msg.altitude) >= altitude_threshold
                continue

            if connection.topic != topic:
                continue

            if altitude_threshold > 0.0 and not latest_alt_valid:
                continue

            msg = typestore.deserialize_cdr(rawdata, connection.msgtype)
            parts = [part.strip() for part in msg.data.split(",")]
            if len(parts) < 4 or parts[3] not in targets:
                continue

            estimates[parts[3]].append(
                Estimate(time_s=time_s, lat=float(parts[0]), lon=float(parts[1]), alt=None)
            )

    return estimates


def read_and_solve(
    bag_path: Path,
    targets: dict[str, Target],
    altitude_threshold: float,
    takeoff_offset: float,
    landing_offset: float,
) -> tuple[
    dict[str, dict[str, list[Estimate]]],
    dict[str, dict[str, int]],
    dict[str, list[float]],
]:
    estimates: dict[str, dict[str, list[Estimate]]] = {
        "stored_2d": {target: [] for target in TARGETS},
        "offline_2d": {target: [] for target in TARGETS},
        "offline_3d": {target: [] for target in TARGETS},
    }
    failures: dict[str, dict[str, int]] = {
        "offline_2d": {target: 0 for target in TARGETS},
        "offline_3d": {target: 0 for target in TARGETS},
    }
    gps_data: list[tuple[float, float, float]] = []
    gps_times: list[float] = []
    rtt_distances: dict[str, list[float]] = {target: [] for target in TARGETS}
    rtt_times: dict[str, list[float]] = {target: [] for target in TARGETS}
    anchor_buffers: dict[str, deque[np.ndarray]] = defaultdict(lambda: deque(maxlen=40))
    distance_buffers: dict[str, deque[float]] = defaultdict(lambda: deque(maxlen=40))

    typestore = get_typestore(Stores.ROS2_HUMBLE)
    latest_gps: tuple[float, float, float] | None = None
    latest_ecef: np.ndarray | None = None
    latest_alt_valid = False

    with Reader(str(bag_path)) as reader:
        adjusted_start = reader.start_time * 1e-9 + takeoff_offset
        adjusted_end = reader.end_time * 1e-9 - landing_offset

        for connection, timestamp, rawdata in reader.messages():
            stamp_s = timestamp * 1e-9
            if stamp_s < adjusted_start or stamp_s > adjusted_end:
                continue

            time_s = stamp_s - adjusted_start

            if connection.topic == GPS_TOPIC:
                msg = typestore.deserialize_cdr(rawdata, connection.msgtype)
                latest_gps = (float(msg.latitude), float(msg.longitude), float(msg.altitude))
                latest_ecef = wgs84_to_ecef(*latest_gps)
                latest_alt_valid = latest_gps[2] >= altitude_threshold
                if latest_alt_valid:
                    gps_data.append(latest_gps)
                    gps_times.append(time_s)
                continue

            if altitude_threshold > 0.0 and not latest_alt_valid:
                continue

            if connection.topic == RAW_MULTILATERATION_TOPIC:
                msg = typestore.deserialize_cdr(rawdata, connection.msgtype)
                parts = [part.strip() for part in msg.data.split(",")]
                if len(parts) < 4 or parts[3] not in targets:
                    continue
                estimates["stored_2d"][parts[3]].append(
                    Estimate(time_s=time_s, lat=float(parts[0]), lon=float(parts[1]), alt=None)
                )
                continue

            if connection.topic != RTT_TOPIC or latest_gps is None or latest_ecef is None:
                continue

            msg = typestore.deserialize_cdr(rawdata, connection.msgtype)
            parts = [part.strip() for part in msg.data.split(",")]
            if len(parts) < 4 or parts[3] not in targets:
                continue

            distance = float(parts[0])
            label = parts[3]
            rtt_distances[label].append(distance)
            rtt_times[label].append(time_s)
            anchor_buffers[label].append(latest_ecef)
            distance_buffers[label].append(distance)

            anchors = list(anchor_buffers[label])
            distances = list(distance_buffers[label])

            if len(distances) >= 3:
                position_2d, converged_2d, condition_2d = huber_ils(anchors, distances, 2)
                if position_2d is None:
                    failures["offline_2d"][label] += 1
                else:
                    ecef_2d = np.asarray((position_2d[0], position_2d[1], latest_ecef[2]), dtype=float)
                    lat, lon, alt = ecef_to_wgs84(ecef_2d)
                    estimates["offline_2d"][label].append(
                        Estimate(time_s, lat, lon, alt, converged_2d, condition_2d)
                    )

            if len(distances) >= 4:
                position_3d, converged_3d, condition_3d = huber_ils(anchors, distances, 3)
                if position_3d is None:
                    failures["offline_3d"][label] += 1
                else:
                    lat, lon, alt = ecef_to_wgs84(position_3d)
                    estimates["offline_3d"][label].append(
                        Estimate(time_s, lat, lon, alt, converged_3d, condition_3d)
                    )

    estimates["offline_3d_filtered"] = median_filter_estimates(estimates["offline_3d"])

    rtt_errors = {target: [] for target in TARGETS}
    for label in TARGETS:
        for distance, time_s in zip(rtt_distances[label], rtt_times[label]):
            error = nearest_gps_distance_error(distance, time_s, gps_times, gps_data, targets[label])
            if error is not None:
                rtt_errors[label].append(error)

    return estimates, failures, rtt_errors


def print_photo_style_table(
    threshold: float,
    rtt_errors: dict[str, list[float]],
    stored_2d_raw: dict[str, list[Estimate]],
    stored_2d_filtered: dict[str, list[Estimate]],
    offline_3d_raw: dict[str, list[Estimate]],
    offline_3d_filtered: dict[str, list[Estimate]],
    targets: dict[str, Target],
) -> None:
    subset = "Complete interval" if threshold == 0 else f"Above {threshold:.0f} m WGS84"
    print(f"\n{subset}")
    print(
        "| Target | RTT detections | RTT mean / P95 (m) | "
        "2D raw mean / P95 (m) | 2D filtered mean / P95 (m) | "
        "3D raw horizontal mean / P95 (m) | 3D filtered horizontal mean / P95 (m) |"
    )
    print("|---|---:|---:|---:|---:|---:|---:|")
    for label in ("X4", "P1"):
        rtt_metric = summarize_values(rtt_errors[label])
        raw_2d_metric = summarize_horizontal(stored_2d_raw[label], targets[label])
        filtered_2d_metric = summarize_horizontal(stored_2d_filtered[label], targets[label])
        raw_3d_metric = summarize_horizontal(offline_3d_raw[label], targets[label])
        filtered_3d_metric = summarize_horizontal(offline_3d_filtered[label], targets[label])
        print(
            f"| {label} | {rtt_metric.count} | {format_metric(rtt_metric)} | "
            f"{format_metric(raw_2d_metric)} | {format_metric(filtered_2d_metric)} | "
            f"{format_metric(raw_3d_metric)} | {format_metric(filtered_3d_metric)} |"
        )


def format_metric(metric: TableMetric) -> str:
    if metric.count == 0 or np.isnan(metric.mean) or np.isnan(metric.p95):
        return "-"
    return f"{metric.mean:.2f} / {metric.p95:.2f}"


def print_summary_table(
    threshold: float,
    estimates: dict[str, dict[str, list[Estimate]]],
    failures: dict[str, dict[str, int]],
    targets: dict[str, Target],
) -> None:
    print(f"\nAltitude threshold: {threshold:.0f} m WGS84")
    print("-" * 118)
    print(
        f"{'solver':<12} {'target':<6} {'n':>5} {'fail':>5} "
        f"{'h_mean':>9} {'h_med':>9} {'h_p95':>9} "
        f"{'z_bias':>9} {'|z|p95':>9} {'3d_mean':>9} {'3d_p95':>9} {'cond_p95':>10}"
    )
    print("-" * 118)

    for solver in ("stored_2d", "offline_2d", "offline_3d", "offline_3d_filtered"):
        for label in TARGETS:
            summary = summarize(
                estimates[solver][label],
                targets[label],
                failures.get(solver, {}).get(label, 0),
            )
            print(
                f"{solver:<12} {label:<6} {summary.count:>5} {summary.failures:>5} "
                f"{summary.horizontal_mean:>9.2f} {summary.horizontal_median:>9.2f} {summary.horizontal_p95:>9.2f} "
                f"{format_optional(summary.vertical_mean):>9} "
                f"{format_optional(summary.vertical_p95_abs):>9} "
                f"{format_optional(summary.error3d_mean):>9} "
                f"{format_optional(summary.error3d_p95):>9} "
                f"{format_optional(summary.condition_p95):>10}"
            )


def format_optional(value: float | None) -> str:
    if value is None or np.isnan(value):
        return "-"
    if np.isinf(value):
        return "inf"
    return f"{value:.2f}"


def parse_thresholds(raw: str) -> list[float]:
    return [float(value.strip()) for value in raw.split(",") if value.strip()]


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Compare 2-D raw/filtered estimates with offline 3-D Huber ILS."
    )
    parser.add_argument(
        "--bag",
        type=Path,
        default=REPOSITORY_ROOT / "data" / "jemerg24-realTime",
        help="Raw rosbag directory containing GPS, RTT, and raw multilateration topics.",
    )
    parser.add_argument(
        "--filtered-bag",
        type=Path,
        default=REPOSITORY_ROOT / "data" / "jemerg24-filtered",
        help="Filtered rosbag directory containing /FX8/multilateration_all.",
    )
    parser.add_argument(
        "--alt-thresholds",
        default="0,105,115",
        help="Comma-separated altitude thresholds in meters WGS84.",
    )
    parser.add_argument("--takeoff-offset", type=float, default=71.0)
    parser.add_argument("--landing-offset", type=float, default=10.0)
    parser.add_argument(
        "--diagnostics",
        action="store_true",
        help="Also print the detailed 2-D/3-D diagnostic table.",
    )
    args = parser.parse_args()

    logging.basicConfig(level=logging.WARNING, format="%(levelname)s: %(message)s")

    targets = {
        "P1": Target(lat=36.71678533, lon=-4.48830800, alt=94.70),
        "X4": Target(lat=36.71680367, lon=-4.48832033, alt=94.70),
    }

    for threshold in parse_thresholds(args.alt_thresholds):
        estimates, failures, rtt_errors = read_and_solve(
            args.bag,
            targets,
            threshold,
            args.takeoff_offset,
            args.landing_offset,
        )
        stored_2d_filtered = read_stored_estimates(
            args.filtered_bag,
            FILTERED_MULTILATERATION_TOPIC,
            targets,
            threshold,
            args.takeoff_offset,
            args.landing_offset,
        )
        print_photo_style_table(
            threshold,
            rtt_errors,
            estimates["stored_2d"],
            stored_2d_filtered,
            estimates["offline_3d"],
            estimates["offline_3d_filtered"],
            targets,
        )
        if args.diagnostics:
            print_summary_table(threshold, estimates, failures, targets)


if __name__ == "__main__":
    main()