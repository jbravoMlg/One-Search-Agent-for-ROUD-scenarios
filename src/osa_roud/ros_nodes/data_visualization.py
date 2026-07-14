import matplotlib.pyplot as plt
from geopy.distance import geodesic
from rosbags.rosbag2 import Reader
from rosbags.typesys import Stores, get_typestore
import numpy as np
import logging
from pathlib import Path
from typing import List, Tuple, Any, Optional

# Logging configuration
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

# Propagation model constants
P0 = -45  # RSSI at 1 meter (dBm)
N = 2.0   # Path loss exponent related to signal attenuation
D0 = 1.0  # Reference distance in meters

# Static positions of P1 and X4 (latitude, longitude, altitude in meters)
P1_COORDS = (36.71678533, -4.48830800, 94.70)
X4_COORDS = (36.71680367, -4.48832033, 94.70)


def get_bag_start_end_time(bag_path: str) -> tuple:
    """
    Get the start and end times of a rosbag2 file.

    Args:
        bag_path (str): Path to the rosbag file.

    Returns:
        tuple: (start_time, end_time) in seconds as float.
    """
    try:
        with Reader(bag_path) as reader:
            start_time = reader.start_time * 1e-9  # Convert from nanoseconds to seconds
            end_time = reader.end_time * 1e-9    # Convert from nanoseconds to seconds
        return start_time, end_time
    except Exception as e:
        print(f"Error reading bag file {bag_path}: {e}")
        return None, None
    

# Type annotations are optional, but they improve clarity in longer functions.

def estimate_distance(rssi: int, p0: float, n: float, d0: float = 1.0) -> float:
    """
    Estimates the distance based on RSSI using the log-distance path loss model.
    
    Args:
        rssi (int): Received Signal Strength Indicator (dBm).
        p0 (float): RSSI at the reference distance (dBm).
        n (float): Path loss exponent.
        d0 (float, optional): Reference distance in meters. Default is 1.0.
    
    Returns:
        float: Estimated distance in meters.
    """
    distance = d0 * 10 ** ((p0 - rssi) / (10 * n))
    logging.debug(f"Estimating distance: RSSI={rssi}, Distance={distance}m")
    return distance

def euclidean_distance_3d(coord1: Tuple[float, float, float],
                          coord2: Tuple[float, float, float]) -> float:
    """
    Calculates the 3D Euclidean distance between two coordinates, considering altitude.

    Args:
        coord1 (Tuple[float, float, float]): First coordinate (latitude, longitude, altitude).
        coord2 (Tuple[float, float, float]): Second coordinate (latitude, longitude, altitude).

    Returns:
        float: 3D distance in meters.
    """
    horizontal_distance = geodesic((coord1[0], coord1[1]), (coord2[0], coord2[1])).meters
    alt_diff = abs(coord1[2] - coord2[2])
    distance = np.sqrt(horizontal_distance ** 2 + alt_diff ** 2)
    logging.debug(f"Calculating 3D distance: {distance}m")
    return distance


def get_gps_position_at_time(gps_times: List[float],
                             gps_data: List[Tuple[float, float, float]],
                             query_time: float) -> Optional[Tuple[float, float, float]]:
    """
    Finds the closest GPS position to a given query time.

    Args:
        gps_times (List[float]): List of timestamps for GPS data.
        gps_data (List[Tuple[float, float, float]]): List of GPS coordinates (latitude, longitude, altitude).
        query_time (float): The target time to query.

    Returns:
        Optional[Tuple[float, float, float]]: Closest GPS position or None if no data is available.
    """
    if not gps_times:
        return None
    idx = np.argmin(np.abs(np.array(gps_times) - query_time))
    return gps_data[idx]



def read_bag(bag_path: str,
             bag_start_time: float,
             start_interval: float,
             end_interval: float,
             altitude_threshold: float,
             multilateration_topic: str) -> Tuple:
    """
    Read data from a ROS 2 bag file and filter based on specified criteria.

    Args:
        bag_path (str): Path to the bag file.
        bag_start_time (float): Start time of the bag (in seconds).
        start_interval (float): Start of the interval (relative to `bag_start_time`).
        end_interval (float): End of the interval (relative to `bag_start_time`).
        altitude_threshold (float): Minimum altitude to process GPS data.
        multilateration_topic (str): Topic for multilateration data.

    Returns:
        Tuple: Processed data including GPS, RTT, RSSI, and multilateration.
    """
    # Initialize data storage
    gps_data = []
    gps_times = []

    rssi_data_P1 = []
    rssi_times_P1 = []
    rssi_data_X4 = []
    rssi_times_X4 = []

    multilateration_distances_P1 = []
    multilateration_times_P1 = []
    multilateration_distances_X4 = []
    multilateration_times_X4 = []

    rtt_distances_P1 = []
    rtt_distances_times_P1 = []
    rtt_distances_X4 = []
    rtt_distances_times_X4 = []

    P1_coord_estimated = []
    X4_coord_estimated = []

    rssi_values_P1 = []
    rssi_values_X4 = []

    # Initialize typestore
    typestore = get_typestore(Stores.ROS2_HUMBLE)

    # List of GPS times filtered by altitude
    filtered_gps_times = []

    try:
        with Reader(bag_path) as reader:
            for connection, timestamp, rawdata in reader.messages():
                time_relative = (timestamp * 1e-9) - bag_start_time

                # Skip messages outside the time interval
                if time_relative < start_interval or time_relative > end_interval:
                    continue

                # Process GPS data
                if connection.topic == '/FX8/fix':
                    try:
                        msg = typestore.deserialize_cdr(rawdata, connection.msgtype)
                        altitude = msg.altitude

                        # Skip GPS data below the altitude threshold
                        if altitude < altitude_threshold:
                            filtered_gps_times.append(time_relative)
                            continue

                        gps_entry = (msg.latitude, msg.longitude, altitude)
                        gps_data.append(gps_entry)
                        gps_times.append(time_relative)

                    except Exception as e:
                        logging.warning(f"Failed to deserialize GPS message: {e}")
                        continue

                # Process RTT and RSSI data
                elif connection.topic == '/Anchor1F/wifi_rtt_estimation':
                    try:
                        msg = typestore.deserialize_cdr(rawdata, connection.msgtype)
                        parts = msg.data.split(',')
                        if len(parts) < 4:
                            continue

                        # Skip GPS data below the altitude threshold
                        if altitude < altitude_threshold:
                            filtered_gps_times.append(time_relative)
                            continue

                        label = parts[3].strip()
                        estimated_distance = float(parts[0].strip())
                        rssi = int(parts[2].strip())

                        # Skip if the timestamp matches a filtered GPS time
                        if any(abs(time_relative - t) < 0.1 for t in filtered_gps_times):
                            continue

                        estimated_distance_rssi = estimate_distance(rssi, P0, N, D0)

                        if label == 'P1':
                            rtt_distances_P1.append(estimated_distance)
                            rtt_distances_times_P1.append(time_relative)
                            rssi_data_P1.append(estimated_distance_rssi)
                            rssi_times_P1.append(time_relative)
                            rssi_values_P1.append(rssi)
                        elif label == 'X4':
                            rtt_distances_X4.append(estimated_distance)
                            rtt_distances_times_X4.append(time_relative)
                            rssi_data_X4.append(estimated_distance_rssi)
                            rssi_times_X4.append(time_relative)
                            rssi_values_X4.append(rssi)

                    except (ValueError, IndexError) as e:
                        logging.warning(f"Invalid RTT message format: {e}")
                        continue

                # Process multilateration data
                elif connection.topic == multilateration_topic:
                    try:
                        msg = typestore.deserialize_cdr(rawdata, connection.msgtype)
                        parts = msg.data.split(',')
                        if len(parts) < 4:
                            continue

                        lat = float(parts[0].strip())
                        lon = float(parts[1].strip())
                        label = parts[3].strip()
                        alt = 94.70  # Fixed altitude

                        # Skip if the timestamp matches a filtered GPS time
                        if any(abs(time_relative - t) < 0.1 for t in filtered_gps_times):
                            continue

                        robot_position = gps_data[-1]
                        estimated_distance = euclidean_distance_3d(robot_position, (lat, lon, alt))

                        if label == 'P1':
                            multilateration_distances_P1.append(estimated_distance)
                            multilateration_times_P1.append(time_relative)
                            P1_coord_estimated.append((lat, lon, alt))
                        elif label == 'X4':
                            multilateration_distances_X4.append(estimated_distance)
                            multilateration_times_X4.append(time_relative)
                            X4_coord_estimated.append((lat, lon, alt))

                    except (ValueError, IndexError) as e:
                        logging.warning(f"Invalid multilateration message format: {e}")
                        continue

    except FileNotFoundError:
        logging.error(f"Bag file not found at path: {bag_path}")
        return ()

    logging.info(f"Total GPS points discarded: {len(filtered_gps_times)}")
    logging.info(f"Total GPS points processed: {len(gps_times)}")

    return (gps_data, gps_times,
            rssi_data_P1, rssi_times_P1,
            rssi_data_X4, rssi_times_X4,
            multilateration_distances_P1, multilateration_times_P1,
            multilateration_distances_X4, multilateration_times_X4,
            rtt_distances_P1, rtt_distances_times_P1,
            rtt_distances_X4, rtt_distances_times_X4,
            X4_coord_estimated, P1_coord_estimated,
            rssi_values_X4, rssi_values_P1)


def calculate_error(estimated_distances: List[float],
                    real_distances: List[float]) -> List[float]:
    """
    Calculate the error between estimated and real distances.

    Args:
        estimated_distances (List[float]): List of estimated distances.
        real_distances (List[float]): List of real distances.

    Returns:
        List[float]: List of absolute errors.
    """
    errors = [abs(est - real) for est, real in zip(estimated_distances, real_distances)]
    logging.debug(f"Calculated {len(errors)} distance errors.")
    return errors


def ecdf(data: List[float]) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute the Empirical Cumulative Distribution Function (ECDF) of data.

    Args:
        data (List[float]): Input data.

    Returns:
        Tuple[np.ndarray, np.ndarray]: Sorted data and corresponding ECDF values.
    """
    sorted_data = np.sort(data)
    y_vals = np.arange(1, len(sorted_data) + 1) / len(sorted_data)
    return sorted_data, y_vals


def plot_rssi_error(rssi_data_P1: List[float],
                    rssi_times_P1: List[float],
                    rssi_data_X4: List[float],
                    rssi_times_X4: List[float],
                    gps_times: List[float],
                    gps_data: List[Tuple[float, float, float]],
                    real_positions: Tuple[Tuple[float, float, float], Tuple[float, float, float]]) -> Tuple[List[float], List[float]]:
    """
    Plot RSSI distance estimation errors for two positions (P1 and X4).

    Args:
        rssi_data_P1 (List[float]): Estimated distances for P1 based on RSSI.
        rssi_times_P1 (List[float]): Timestamps corresponding to P1 distances.
        rssi_data_X4 (List[float]): Estimated distances for X4 based on RSSI.
        rssi_times_X4 (List[float]): Timestamps corresponding to X4 distances.
        gps_times (List[float]): List of GPS timestamps.
        gps_data (List[Tuple[float, float, float]]): GPS data (latitude, longitude, altitude).
        real_positions (Tuple[Tuple[float, float, float], Tuple[float, float, float]]): Real positions of P1 and X4.

    Returns:
        Tuple[List[float], List[float]]: Errors for P1 and X4 based on RSSI.
    """
    P1_real_position, X4_real_position = real_positions

    # Map RSSI times to GPS positions
    gps_to_P1_rssi = [get_gps_position_at_time(gps_times, gps_data, t) for t in rssi_times_P1]
    gps_to_X4_rssi = [get_gps_position_at_time(gps_times, gps_data, t) for t in rssi_times_X4]

    # Filter out unmatched GPS positions
    gps_to_P1_rssi_filtered = []
    rssi_data_P1_filtered = []
    rssi_times_P1_filtered = []
    for d, pos, t in zip(rssi_data_P1, gps_to_P1_rssi, rssi_times_P1):
        if pos is not None:
            gps_to_P1_rssi_filtered.append(pos)
            rssi_data_P1_filtered.append(d)
            rssi_times_P1_filtered.append(t)

    gps_to_X4_rssi_filtered = []
    rssi_data_X4_filtered = []
    rssi_times_X4_filtered = []
    for d, pos, t in zip(rssi_data_X4, gps_to_X4_rssi, rssi_times_X4):
        if pos is not None:
            gps_to_X4_rssi_filtered.append(pos)
            rssi_data_X4_filtered.append(d)
            rssi_times_X4_filtered.append(t)

    # Calculate real distances at relevant timestamps
    gps_distances_P1_rssi = [
        euclidean_distance_3d(pos, P1_real_position) for pos in gps_to_P1_rssi_filtered
    ]
    gps_distances_X4_rssi = [
        euclidean_distance_3d(pos, X4_real_position) for pos in gps_to_X4_rssi_filtered
    ]

    # Calculate RSSI errors
    rssi_error_P1 = calculate_error(rssi_data_P1_filtered, gps_distances_P1_rssi)
    rssi_error_X4 = calculate_error(rssi_data_X4_filtered, gps_distances_X4_rssi)

    # Create figure for RSSI errors
    fig, ax = plt.subplots(figsize=(12, 8))

    # Plot RSSI errors for P1 and X4
    ax.plot(rssi_times_P1_filtered, rssi_error_P1, label="Distance Error for P1 (RSSI)",
            color='blue', linestyle='-', marker='o')
    ax.plot(rssi_times_X4_filtered, rssi_error_X4, label="Distance Error for X4 (RSSI)",
            color='purple', linestyle='-', marker='x')

    # Configure plot
    ax.set_title('RSSI Distance Estimation Error', fontsize=18)
    ax.set_xlabel('Time (s)', fontsize=16)
    ax.set_ylabel('Error (m)', fontsize=16)
    ax.grid(True)

    legend = ax.legend(fontsize=16)
    legend.set_draggable(True)

    # plt.show()  # Uncomment to display the plot

    return rssi_error_P1, rssi_error_X4

def plot_multilateration_rtt_error(multilateration_distances_P1: List[float],
                                   multilateration_times_P1: List[float],
                                   multilateration_distances_X4: List[float],
                                   multilateration_times_X4: List[float],
                                   rtt_distances_P1: List[float],
                                   rtt_distances_times_P1: List[float],
                                   rtt_distances_X4: List[float],
                                   rtt_distances_times_X4: List[float],
                                   gps_times: List[float],
                                   gps_data: List[Tuple[float, float, float]],
                                   real_positions: Tuple[Tuple[float, float, float], Tuple[float, float, float]]) -> Tuple[List[float], List[float], List[float], List[float]]:

    P1_real_position, X4_real_position = real_positions

    # Align GPS data with RTT and multilateration timestamps.
    gps_to_P1_rtt = [get_gps_position_at_time(gps_times, gps_data, t) for t in rtt_distances_times_P1]
    gps_to_X4_rtt = [get_gps_position_at_time(gps_times, gps_data, t) for t in rtt_distances_times_X4]
    gps_to_P1_multilat = [get_gps_position_at_time(gps_times, gps_data, t) for t in multilateration_times_P1]
    gps_to_X4_multilat = [get_gps_position_at_time(gps_times, gps_data, t) for t in multilateration_times_X4]

    # Filter positions that could not be matched.
    valid_P1_rtt = [(d, pos) for d, pos in zip(rtt_distances_P1, gps_to_P1_rtt) if pos is not None]
    valid_X4_rtt = [(d, pos) for d, pos in zip(rtt_distances_X4, gps_to_X4_rtt) if pos is not None]
    valid_P1_multilat = [(d, pos) for d, pos in zip(multilateration_distances_P1, gps_to_P1_multilat) if pos is not None]
    valid_X4_multilat = [(d, pos) for d, pos in zip(multilateration_distances_X4, gps_to_X4_multilat) if pos is not None]

    # Calculate ground-truth distances at the relevant timestamps.
    gps_distances_P1_rtt = [euclidean_distance_3d(pos, P1_real_position) for _, pos in valid_P1_rtt]
    gps_distances_X4_rtt = [euclidean_distance_3d(pos, X4_real_position) for _, pos in valid_X4_rtt]

    gps_distances_P1_multilat = [euclidean_distance_3d(pos, P1_real_position) for _, pos in valid_P1_multilat]
    gps_distances_X4_multilat = [euclidean_distance_3d(pos, X4_real_position) for _, pos in valid_X4_multilat]

    # Calculate errors.
    rtt_error_P1 = calculate_error([d for d, _ in valid_P1_rtt], gps_distances_P1_rtt)
    rtt_error_X4 = calculate_error([d for d, _ in valid_X4_rtt], gps_distances_X4_rtt)
    multilateration_error_P1 = calculate_error([d for d, _ in valid_P1_multilat], gps_distances_P1_multilat)
    multilateration_error_X4 = calculate_error([d for d, _ in valid_X4_multilat], gps_distances_X4_multilat)

    return rtt_error_P1, rtt_error_X4, multilateration_error_P1, multilateration_error_X4


def calculate_percentile_general(data: np.ndarray, percentile: float) -> float:
        """Calculate the value at the specified percentile."""
        return np.percentile(data, percentile)

def plot_combined_ecdf(em_P1: List[float],
                       em_X4: List[float],
                       rtt_error_P1: List[float],
                       rtt_error_X4: List[float]) -> None:

    def calculate_percentile(data: np.ndarray, percentile: float) -> float:
        """Calculate the value at the specified percentile."""
        return np.percentile(data, percentile)

    # Create the figure and subplots.
    fig, axes = plt.subplots(1, 2, figsize=(20, 6), sharey=True)
    ax_rtt, ax_mlt = axes

    # Define colors and line styles.
    palette = {
        'uav_P1': '#1f77b4',  # Blue
        'uav_X4': '#ff7f0e'   # Orange
    }
    linestyles = {'uav': '-'}
    linewidth = 2.5  # Line width.

    # Offset labels to prevent overlap, alternating by curve and percentile.
    percentiles = [80, 95]
    offsets = {
        'rtt': {
            'uav_P1': {80: 0, 95: 25},
            'uav_X4': {80: 0, 95: -25}
        },
        'mlt': {
            'uav_P1': {80: 5, 95: -45},
            'uav_X4': {80: -7, 95: 30}
        }
    }

    # ===============================
    # Subplot 1: RTT Error ECDF
    # ===============================
    for label, error, color in [
        ('RTT to P1 (detected ' + str(len(rtt_error_P1)) + ' times)', rtt_error_P1, palette['uav_P1']),
        ('RTT to X4 (detected ' + str(len(rtt_error_X4)) + ' times)', rtt_error_X4, palette['uav_X4'])
    ]:
        x, y = ecdf(error)
        ax_rtt.plot(x, y, label=label, color=color, linestyle=linestyles['uav'], linewidth=linewidth)

        # Calculate and mark percentiles.
        for perc in percentiles:
            perc_value = calculate_percentile(np.array(error), perc)
            ax_rtt.axvline(x=perc_value, color=color, linestyle='--', linewidth=1)
            # Select the offset for this curve and percentile.
            if label == 'RTT to P1 (detected ' + str(len(rtt_error_P1)) + ' times)':
                y_offset = offsets['rtt']['uav_P1'][perc]
            elif label == 'RTT to X4 (detected ' + str(len(rtt_error_X4)) + ' times)':
                y_offset = offsets['rtt']['uav_X4'][perc]
            else:
                y_offset = 0  # Default to no offset.

            # Add the arrow annotation.
            ax_rtt.annotate(f'{perc}%: {perc_value:.2f}m',
                           xy=(perc_value, 0.95),
                           xytext=(10, y_offset),  # Adjust horizontal and vertical position.
                           textcoords='offset points',
                           fontsize=12,
                           color=color,
                           arrowprops=dict(arrowstyle='->', color=color))

    # Configure the RTT subplot.
    ax_rtt.set_xlabel('RTT Distance Error (m)', fontsize=15)
    ax_rtt.set_ylabel('Cumulative Probability', fontsize=15)
    #ax_rtt.legend(fontsize=12, loc='lower right')
    ax_rtt.grid(True, linestyle='--', alpha=0.7)

    legend1 = ax_rtt.legend(fontsize=12, loc='upper left')
    legend1.set_draggable(True)


    # ===============================
    # Subplot 2: Multilateration Error ECDF
    # ===============================



    for label, error, color in [
        ('Multilateration to P1 (' + 'located ' + str(len(em_P1)) + ' times)', em_P1, palette['uav_P1']),
        ('Multilateration to X4 (' + 'located ' + str(len(em_X4)) + ' times)', em_X4, palette['uav_X4'])
    ]:
        x, y = ecdf(error)
        ax_mlt.plot(x, y, label=label, color=color, linestyle=linestyles['uav'], linewidth=linewidth)

        # Calculate and mark percentiles.
        for perc in percentiles:
            perc_value = calculate_percentile(np.array(error), perc)
            ax_mlt.axvline(x=perc_value, color=color, linestyle='--', linewidth=1)
            # Select the offset for this curve and percentile.
            if label == 'Multilateration to P1 (' + 'located ' + str(len(em_P1)) + ' times)':
                y_offset = offsets['mlt']['uav_P1'][perc]
            elif label == 'Multilateration to X4 (' + 'located ' + str(len(em_X4)) + ' times)':
                y_offset = offsets['mlt']['uav_X4'][perc]
            else:
                y_offset = 0  # Default to no offset.

            # Add the arrow annotation.
            ax_mlt.annotate(f'{perc}%: {perc_value:.2f}m',
                           xy=(perc_value, 0.95),
                           xytext=(5, y_offset),  # Adjust horizontal and vertical position.
                           textcoords='offset points',
                           fontsize=12,
                           color=color,
                           arrowprops=dict(arrowstyle='->', color=color))

    # Configure the multilateration subplot.
    ax_mlt.set_xlabel('Positioning Error (m)', fontsize=15)
    #ax_mlt.legend(fontsize=12, loc='lower right')
    ax_mlt.grid(True, linestyle='--', alpha=0.7)

    legend2 = ax_mlt.legend(fontsize=12, loc='upper left')
    legend2.set_draggable(True)
    # Adjust the layout and display the plot.
    plt.tight_layout()
    plt.show()


def plot_altitude_uav(gps_data: List[Tuple[float, float, float]],
                     gps_times: List[float],
                     rtt_distances_P1: List[float],
                     rtt_distances_times_P1: List[float],
                     rtt_distances_X4: List[float],
                     rtt_distances_times_X4: List[float],
                     rssi_values_X4: List[int],
                     rssi_values_P1: List[int]) -> None:

    if not gps_data:
        logging.error("No GPS data available after filtering. Skipping plot.")
        return


    P1_realPosition = P1_COORDS
    X4_realPosition = X4_COORDS

    groundT_uavToP1 = [euclidean_distance_3d(gps_value, P1_realPosition) for gps_value in gps_data]
    groundT_uavToX4 = [euclidean_distance_3d(gps_value, X4_realPosition) for gps_value in gps_data]

    # Extract altitudes from GPS data.
    altitudes = [data[2] for data in gps_data]

    # Create the figure and subplots.
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 12))
    plt.subplots_adjust(hspace=0.3, top=0.95)

    # ---------------------
    # Plot 1: UAV Altitude and RSSI Over Time
    # ---------------------
    ax_rssi = ax1.twinx()  # Secondary axis for RSSI.

    # Plot UAV altitude.
    dash_dot_dot = (0, (3, 1, 1, 1, 1, 1))
    ax1.plot(gps_times, altitudes, label='UAV Altitude', color='green', linewidth=2, linestyle=dash_dot_dot)
    ax1.set_ylabel('Altitude (m)', fontsize=14, color='green')
    ax1.tick_params(axis='y', labelsize=12, colors='green')
    ax1.grid(True)
    ax1.spines['left'].set_color('green')

    # Plot RSSI values.
    ax_rssi.scatter(rtt_distances_times_P1, rssi_values_P1, label='Signal detection from P1', marker='*',
                    color='#d62728', edgecolors='k', s=100, alpha=0.7)
    ax_rssi.scatter(rtt_distances_times_X4, rssi_values_X4, label='Signal detection from X4', marker='o',
                    color='#ff9896', edgecolors='k', s=100, alpha=0.7)
    ax_rssi.set_ylabel('RSSI (dBm)', fontsize=14, color='red')
    ax_rssi.tick_params(axis='y', labelsize=12, colors='red')
    ax_rssi.spines['right'].set_color('red')

    # Combine legends.
    handles1, labels1 = ax1.get_legend_handles_labels()
    handles2, labels2 = ax_rssi.get_legend_handles_labels()
    ax1.legend(handles=handles1 + handles2, labels=labels1 + labels2, fontsize=12, loc='upper left')

    # ---------------------
    # Plot 2: Estimated Distance and Ground Truth
    # ---------------------
    ax3 = ax2.twinx()  # Secondary axis for RTT.

    # Plot estimated RTT distances.
    ax2.plot(rtt_distances_times_P1, rtt_distances_P1, label='RTT estimation to P1',
             color='#1f77b4', linewidth=2, linestyle='-')
    ax2.plot(rtt_distances_times_X4, rtt_distances_X4, label='RTT estimation to X4',
             color='#aec7e8', linewidth=2, linestyle='--')

    # Plot ground-truth distances.
    ax3.plot(gps_times, groundT_uavToP1, label='Ground Truth to P1', color='green', linewidth=2, linestyle='-')
    ax3.plot(gps_times, groundT_uavToX4, label='Ground Truth to X4', color='green', linewidth=2, linestyle='--')

    # Configure axes.
    ax2.set_xlabel('Time (s)', fontsize=14)
    ax2.set_ylabel('RTT Distance (m)', fontsize=14, color='blue')
    ax2.tick_params(axis='y', labelcolor='blue', labelsize=12)
    ax2.grid(True, linestyle='--', linewidth=0.5, alpha=0.7)

    ax3.set_ylabel('Ground Truth Distance (m)', fontsize=14, color='green')
    ax3.tick_params(axis='y', labelcolor='green', labelsize=12)

    # Combine legends.
    ax2.legend(fontsize=12, loc='upper left')
    ax3.legend(fontsize=12, loc='upper right')

    # Set the overall title.
    fig.suptitle('UAV Altitude, RSSI, RTT, and Ground Truth', fontsize=18, fontweight='bold')

    # Adjust the layout.
    plt.tight_layout(rect=[0, 0.03, 1, 0.95])

    # Display the plot.
    plt.show()

def plot_estimations(p1_coord_estimated: List[Tuple[float, float, float]],
                    x4_coord_estimated: List[Tuple[float, float, float]]) -> None:
    """
                    Plot P1 and X4 position estimates against their surveyed positions.

    Args:
                        p1_coord_estimated (List[Tuple[float, float, float]]): Coordinate estimates for P1.
                        x4_coord_estimated (List[Tuple[float, float, float]]): Coordinate estimates for X4.
    """
                    # Surveyed coordinates for P1 and X4.
    P1_REAL_POS = (36.71678533, -4.48830800, 94.70)
    X4_REAL_POS = (36.71680367, -4.48832033, 94.70)

    # Extract estimated latitudes and longitudes.
    lat_P1 = [coord[0] for coord in p1_coord_estimated]
    lon_P1 = [coord[1] for coord in p1_coord_estimated]

    lat_X4 = [coord[0] for coord in x4_coord_estimated]
    lon_X4 = [coord[1] for coord in x4_coord_estimated]

    # Degree-to-meter conversion factors.
    LAT_TO_M = 111320  # Meters per degree of latitude.
    LON_TO_M = 89400    # Approximate meters per degree of longitude near 36.7 degrees latitude.

    # Create a figure with two subplots.
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 6))

    # ---------------------
    # Subplot 1: P1 estimates.
    # ---------------------
    ax1.plot(np.array(lon_P1) * LON_TO_M, np.array(lat_P1) * LAT_TO_M, 'o', label='P1 Estimated')
    ax1.plot(P1_REAL_POS[1] * LON_TO_M, P1_REAL_POS[0] * LAT_TO_M, 'x', color='red', label='P1 Ground Truth')
    ax1.set_xlabel("Longitude (m)", fontsize=14)
    ax1.set_ylabel("Latitude (m)", fontsize=14)
    ax1.set_title("Estimations for P1", fontsize=16)
    ax1.legend()
    ax1.grid(True, linestyle='--', alpha=0.7)

    # ---------------------
    # Subplot 2: X4 estimates.
    # ---------------------
    ax2.plot(np.array(lon_X4) * LON_TO_M, np.array(lat_X4) * LAT_TO_M, '*', label='X4 Estimated')
    ax2.plot(X4_REAL_POS[1] * LON_TO_M, X4_REAL_POS[0] * LAT_TO_M, 'x', color='red', label='X4 Ground Truth')
    ax2.set_xlabel("Longitude (m)", fontsize=14)
    ax2.set_ylabel("Latitude (m)", fontsize=14)
    ax2.set_title("Estimations for X4", fontsize=16)
    ax2.legend()
    ax2.grid(True, linestyle='--', alpha=0.7)

    # Adjust the layout and display the plot.
    plt.tight_layout()
    plt.show()
    plt.close(fig)  # Explicitly close the figure to release memory.


def display_results(
    altitude_threshold,
    rssi_data_P1,
    rssi_times_P1,
    rtt_distances_P1,
    rtt_distances_times_P1,
    multilateration_distances_P1,
    multilateration_times_P1,
    rssi_data_X4,
    rssi_times_X4,
    rtt_distances_X4,
    rtt_distances_times_X4,
    multilateration_distances_X4,
    multilateration_times_X4,
    gps_data,
    gps_times,
    multilateration_error_P1,
    multilateration_error_X4,
    rtt_error_P1,
    rtt_error_X4,
    rssi_error_P1_total,
    rssi_error_X4_total,
    gps_distances_P1,
    gps_distances_X4,
    calculate_percentile_general
):
    # Overall heading.
    print(f"\n{'*' * 50}")
    print(f"RESULTS FOR UAV ALTITUDE ABOVE: {altitude_threshold:.2f} METERS")
    print(f"{'*' * 50}\n")

    # Overall results.
    print("UAV SIGNAL DETECTION:")
    print(f"{'-' * 50}")
    print(f"{'Signal Detection':<25} {'P1':<10} {'X4':<10}")
    print(f"{'-' * 50}")
    print(f"{'RSSI Count':<25} {len(rssi_data_P1):<10} {len(rssi_data_X4):<10}")
    print(f"{'RTT Count':<25} {len(rtt_distances_P1):<10} {len(rtt_distances_X4):<10}")
    print(f"{'Multilateration Count':<25} {len(multilateration_distances_P1):<10} {len(multilateration_distances_X4):<10}\n")

    print("UAV GPS DATA:")
    print(f"{'-' * 50}")
    print(f"Total GPS Positions: {len(gps_data):<10}")
    print(f"Total GPS Times: {len(gps_times):<10}\n")

    # Multilateration errors.
    print("MULTILATERATION ERRORS:")
    print(f"{'-' * 50}")
    print(f"{'Statistic':<15} {'P1 (m)':<15} {'X4 (m)':<15}")
    print(f"{'-' * 50}")
    print(f"{'Min':<15} {min(multilateration_error_P1):<15.2f} {min(multilateration_error_X4):<15.2f}")
    print(f"{'Max':<15} {max(multilateration_error_P1):<15.2f} {max(multilateration_error_X4):<15.2f}")
    print(f"{'Mean':<15} {np.mean(multilateration_error_P1):<15.2f} {np.mean(multilateration_error_X4):<15.2f}")
    print(f"{'Median':<15} {np.median(multilateration_error_P1):<15.2f} {np.median(multilateration_error_X4):<15.2f}")
    print(f"{'80th Percentile':<15} {calculate_percentile_general(multilateration_error_P1, 80):<15.2f} {calculate_percentile_general(multilateration_error_X4, 80):<15.2f}")
    print(f"{'95th Percentile':<15} {calculate_percentile_general(multilateration_error_P1, 95):<15.2f} {calculate_percentile_general(multilateration_error_X4, 95):<15.2f}\n")

    # RTT errors.
    print("RTT ERRORS:")
    print(f"{'-' * 50}")
    print(f"{'Statistic':<15} {'P1 (m)':<15} {'X4 (m)':<15}")
    print(f"{'-' * 50}")
    print(f"{'Min':<15} {min(rtt_error_P1):<15.2f} {min(rtt_error_X4):<15.2f}")
    print(f"{'Max':<15} {max(rtt_error_P1):<15.2f} {max(rtt_error_X4):<15.2f}")
    print(f"{'Mean':<15} {np.mean(rtt_error_P1):<15.2f} {np.mean(rtt_error_X4):<15.2f}")
    print(f"{'Median':<15} {np.median(rtt_error_P1):<15.2f} {np.median(rtt_error_X4):<15.2f}")
    print(f"{'80th Percentile':<15} {calculate_percentile_general(rtt_error_P1, 80):<15.2f} {calculate_percentile_general(rtt_error_X4, 80):<15.2f}")
    print(f"{'95th Percentile':<15} {calculate_percentile_general(rtt_error_P1, 95):<15.2f} {calculate_percentile_general(rtt_error_X4, 95):<15.2f}\n")

    # RSSI errors.
    print("RSSI ERRORS:")
    print(f"{'-' * 50}")
    print(f"{'Statistic':<15} {'P1 (m)':<15} {'X4 (m)':<15}")
    print(f"{'-' * 50}")
    print(f"{'Min':<15} {min(rssi_error_P1_total):<15.2f} {min(rssi_error_X4_total):<15.2f}")
    print(f"{'Max':<15} {max(rssi_error_P1_total):<15.2f} {max(rssi_error_X4_total):<15.2f}")
    print(f"{'Mean':<15} {np.mean(rssi_error_P1_total):<15.2f} {np.mean(rssi_error_X4_total):<15.2f}")
    print(f"{'Median':<15} {np.median(rssi_error_P1_total):<15.2f} {np.median(rssi_error_X4_total):<15.2f}\n")

    # Distance statistics.
    print("UAV DISTANCES TO TARGETS:")
    print(f"{'-' * 50}")
    print(f"{'Statistic':<15} {'P1 (m)':<15} {'X4 (m)':<15}")
    print(f"{'-' * 50}")
    print(f"{'Min':<15} {min(gps_distances_P1):<15.2f} {min(gps_distances_X4):<15.2f}")
    print(f"{'Max':<15} {max(gps_distances_P1):<15.2f} {max(gps_distances_X4):<15.2f}")
    print(f"{'Mean':<15} {np.mean(gps_distances_P1):<15.2f} {np.mean(gps_distances_X4):<15.2f}")
    print(f"{'Median':<15} {np.median(gps_distances_P1):<15.2f} {np.median(gps_distances_X4):<15.2f}\n")

    print(f"{'*' * 50}\n\n")

def process_bag(bag_path, bag_start_time, bag_end_time, altitude_threshold, multilateration_topic):
    start_interval = 0
    end_interval = bag_end_time - bag_start_time

    (
        gps_data, gps_times,
        rssi_data_P1, rssi_times_P1,
        rssi_data_X4, rssi_times_X4,
        multilateration_distances_P1, multilateration_times_P1,
        multilateration_distances_X4, multilateration_times_X4,
        rtt_distances_P1, rtt_distances_times_P1,
        rtt_distances_X4, rtt_distances_times_X4,
        X4_coord_estimated, P1_coord_estimated,
        rssi_values_X4, rssi_values_P1
    ) = read_bag(bag_path, bag_start_time, start_interval, end_interval, altitude_threshold, multilateration_topic)

    if not gps_data:
        logging.error("No GPS data found. Skipping this bag.")
        return

    # Compute distances to P1 and X4
    gps_distances_P1 = [euclidean_distance_3d(gps, P1_COORDS) for gps in gps_data]
    gps_distances_X4 = [euclidean_distance_3d(gps, X4_COORDS) for gps in gps_data]

    # Generate plots
    plot_altitude_uav(gps_data, gps_times, rtt_distances_P1, rtt_distances_times_P1,
                      rtt_distances_X4, rtt_distances_times_X4, rssi_values_X4, rssi_values_P1)

    """
    plot_rssi_error(rssi_data_P1, rssi_times_P1, rssi_data_X4, rssi_times_X4,
                    gps_times, gps_data, (P1_COORDS, X4_COORDS))
    """

    rtt_error_P1, rtt_error_X4, multilateration_error_P1, multilateration_error_X4 = plot_multilateration_rtt_error(
        multilateration_distances_P1, multilateration_times_P1,
        multilateration_distances_X4, multilateration_times_X4,
        rtt_distances_P1, rtt_distances_times_P1,
        rtt_distances_X4, rtt_distances_times_X4,
        gps_times, gps_data, (P1_COORDS, X4_COORDS)
    )

    rssi_error_P1_total = calculate_error(rssi_data_P1, gps_distances_P1)
    rssi_error_X4_total = calculate_error(rssi_data_X4, gps_distances_X4)

    
    plot_combined_ecdf(multilateration_error_P1, multilateration_error_X4,
                       rtt_error_P1, rtt_error_X4)

    
    display_results(
    altitude_threshold,
    rssi_data_P1,
    rssi_times_P1,
    rtt_distances_P1,
    rtt_distances_times_P1,
    multilateration_distances_P1,
    multilateration_times_P1,
    rssi_data_X4,
    rssi_times_X4,
    rtt_distances_X4,
    rtt_distances_times_X4,
    multilateration_distances_X4,
    multilateration_times_X4,
    gps_data,
    gps_times,
    multilateration_error_P1,
    multilateration_error_X4,
    rtt_error_P1,
    rtt_error_X4,
    rssi_error_P1_total,
    rssi_error_X4_total,
    gps_distances_P1,
    gps_distances_X4,
    calculate_percentile_general
)


def main():
    repository_root = Path(__file__).resolve().parents[3]
    bags = [
        {
            "bag_path": repository_root / 'data/jemerg24-realTime',
            "multilateration_topic": '/geo_multilateration_fx8_1f'
        },
        {
            "bag_path": repository_root / 'data/jemerg24-filtered',
            "multilateration_topic": '/FX8/multilateration_all'
        }
    ]

    # Both bags contain 368 recorded seconds; landing occurs at second 341 (368 - 27).

    # Keep data from five seconds after takeoff through five seconds before landing: 76 to 336 seconds.



    altitude_threshold = 0
    time_take_off = 71  # Start offset in seconds.
    time_landing = 0   # End offset in seconds.

    for bag in bags:
        logging.info(f"Processing bag: {bag['bag_path']}")
        
        # Read bag start and end times.
        bag_start_time, bag_end_time = get_bag_start_end_time(bag["bag_path"])
        
        if bag_start_time is None or bag_end_time is None: 
            logging.error(f"Skipping bag due to missing start/end times: {bag['bag_path']}")
            continue
        
        # Apply time offsets.
        adjusted_start_time = bag_start_time + time_take_off
        adjusted_end_time = bag_end_time - time_landing
        
        # Validate the adjusted interval.
        if adjusted_start_time >= adjusted_end_time:
            logging.error(f"Invalid time range after applying offsets for bag: {bag['bag_path']}")
            continue
        
        # Process the bag over the adjusted interval.
        process_bag(bag["bag_path"], adjusted_start_time, adjusted_end_time, altitude_threshold, bag["multilateration_topic"])


if __name__ == "__main__":
    main()
