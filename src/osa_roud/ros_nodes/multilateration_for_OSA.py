#!/usr/bin/env python3

import rclpy
from rclpy.node import Node
from sensor_msgs.msg import NavSatFix
from std_msgs.msg import String
import logging
import pyproj
import pandas as pd

import numpy as np
from numpy.linalg import norm, inv

import ast
import math
import os
import threading
import signal
import time
import sys
from flask import Flask, request, jsonify
from rclpy.executors import MultiThreadedExecutor


estimation_count = 0
detection_count = 0


class SetData(Node):
    # Retain this class attribute for compatibility with other modules.
    bsWifiFtm = {}

    def __init__(self):
        super().__init__('set_data_fx8')

        self.mac = os.environ.get('OSA_ANCHOR_MAC', '3c:28:6d:b2:c9:1f')

        self.subscription = self.create_subscription(
            NavSatFix,
            '/FX8/fix',
            self.callback_anchor,
            10
        )

    def callback_anchor(self, msg: NavSatFix):
        # Store the anchor position associated with the MAC address.
        SetData.bsWifiFtm.setdefault(self.mac, {})
        SetData.bsWifiFtm[self.mac]["X"] = msg.longitude
        SetData.bsWifiFtm[self.mac]["Y"] = msg.latitude
        SetData.bsWifiFtm[self.mac]["Z"] = msg.altitude

    @classmethod
    def get_bsWifiFtm(cls):
        return cls.bsWifiFtm


class GetData(Node):

    info = {}

    def __init__(self, set_data_instance: SetData):
        super().__init__('get_data_fx8')

        self.set_data_instance = set_data_instance
        self.mac = os.environ.get('OSA_ANCHOR_MAC', '3c:28:6d:b2:c9:1f')

        # Each victim-side transmitter needs an independent observation window.
        # The anchor MAC is common to all requests, so keying these buffers by
        # anchor MAC would mix measurements from different victims.
        self.distances_by_mobile = {}
        self.positions_by_mobile = {}

        self.Mode = 'OLS'

        self.wgs84 = pyproj.CRS('EPSG:4326')
        self.ecef = pyproj.CRS('EPSG:4978')

        logging.basicConfig(
            level=logging.DEBUG,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )

        # Use always_xy=True to preserve (longitude, latitude) ordering.
        self.ecef_transformer = pyproj.Transformer.from_crs(
            self.wgs84, self.ecef, always_xy=True
        )
        self.gps_transformer = pyproj.Transformer.from_crs(
            self.ecef, self.wgs84, always_xy=True
        )

        self.lat = None
        self.lon = None
        self.alt = None
        self.history = {
            'lat': [],
            'lon': [],
            'alt': []
        }

    def show_bs_wifi_ftm(self):
        if self.set_data_instance is not None:
            bsWifiFtm = self.set_data_instance.bsWifiFtm
            print("Current bsWifiFtm value:", bsWifiFtm)
            return bsWifiFtm
        else:
            print("Error: set_data_instance is None")
            return None

    def gps2ecef(self, lon, lat, alt):
        x, y, z = self.ecef_transformer.transform(lon, lat, alt)
        return x, y, z

    def ecef2gps(self, x, y, z):
        lon, lat, alt = self.gps_transformer.transform(x, y, z)
        return lon, lat, alt

    def parse_file(self, filepath):
        if filepath[-3:] == 'csv':
            file = pd.read_csv(filepath, sep=',')
        else:
            file = pd.read_excel(filepath)
        return file

    def hx_ils_2d(self, pos, BS_pos, range_est):
        N = len(BS_pos)
        H = np.zeros((N, 2))
        for j in range(N):
            H[j, 0] = (pos[0] - BS_pos[j, 0]) / range_est[j]
            H[j, 1] = (pos[1] - BS_pos[j, 1]) / range_est[j]
        return H

    def hx_ils_3d(self, pos, BS_pos, range_est):
        N = len(BS_pos)
        H = np.zeros((N, 3))
        for j in range(N):
            H[j, 0] = (pos[0] - BS_pos[j, 0]) / range_est[j]
            H[j, 1] = (pos[1] - BS_pos[j, 1]) / range_est[j]
            H[j, 2] = (pos[2] - BS_pos[j, 2]) / range_est[j]
        return H

    def compute_range(self, pos, BS_pos):
        diff = np.asarray(pos) - BS_pos
        return norm(diff, axis=1)

    def ils_2d(self, BS, distances, Mode=None, gt=None, W=None):
        if Mode is None:
            Mode = self.Mode

        BS = np.asarray(BS, dtype=float)
        distances = np.asarray(distances, dtype=float)

        # Project 3-D ranges to 2-D when anchor heights differ.
        try:
            min_index = np.argmin(BS[:, 2])
            min_height = BS[min_index][2]
            for i, (d_old, bs) in enumerate(zip(distances, BS)):
                projected_distance = math.sin(math.acos((bs[2] - min_height) / d_old)) * d_old
                distances[i] = projected_distance
        except Exception:
            pass

        if len(BS[0]) > 2:
            BS = np.delete(BS, 2, axis=1)

        dist_min = np.where(distances == np.min(distances))
        idx = dist_min[0][0]
        initial_position = (BS[idx][0] + 1.0, BS[idx][1] + 1.0)

        user_position, converged, it_W = self.loop_ils(
            distances, BS, initial_position, Mode, gt=gt, W=W
        )
        return user_position, converged, it_W

    def ils_3d(self, BS, distances, Mode=None, gt=None, W=None):
        if Mode is None:
            Mode = self.Mode

        BS = np.asarray(BS, dtype=float)
        distances = np.asarray(distances, dtype=float)

        dist_min = np.where(distances == np.min(distances))
        idx = dist_min[0][0]
        initial_position = (
            BS[idx][0] + 1.0,
            BS[idx][1] + 1.0,
            BS[idx][2] + 1.0
        )

        user_position, converged, it_W = self.loop_ils(
            distances, BS, initial_position, Mode, gt=gt, W=W
        )
        return user_position, converged, it_W

    def loop_ils(
        self,
        distances,
        BS_pos,
        pos_est,
        Mode=None,
        gt=None,
        W=None,
        eps=1.e-2
    ):
        """
        Run iterative least squares with robust weights.
        """
        if Mode is None:
            Mode = self.Mode

        pos = np.array(pos_est, dtype=float)

        if W is None:
            W = np.eye(len(BS_pos))

        converged = False
        oldMaxHy = 1e10

        for _ in range(40):
            oldPos = pos.copy()
            r_est = self.compute_range(pos, BS_pos)

            if len(pos) == 2:
                H = self.hx_ils_2d(pos, BS_pos, r_est)
            else:
                H = self.hx_ils_3d(pos, BS_pos, r_est)

            y = distances - r_est
            c = 0.7317
            W_ = []

            if Mode == 'OLS':
                W_ = np.ones(len(y))
            elif Mode == 'LAD':
                W_ = 1.0 / np.clip(np.abs(y), 1e-6, None)
            elif Mode == 'Huber':
                for obs in y:
                    if abs(obs) <= c:
                        W_.append(1.0)
                    else:
                        W_.append(c / abs(obs))
            elif Mode == 'Trimmed':
                for obs in y:
                    if abs(obs) <= c:
                        W_.append(1.0)
                    else:
                        W_.append(1e-3)
            elif Mode == 'Tukey':
                for obs in y:
                    if abs(obs) <= c:
                        W_.append((1 - (obs / c) ** 2) ** 2)
                    else:
                        W_.append(1e-3)
            else:
                # Default to ordinary least squares.
                W_ = np.ones(len(y))

            W = np.diag(W_)

            try:
                Hinv = inv((H.T @ W) @ H) @ H.T @ W
            except Exception as e:
                logging.error(f"Error inverting matrix in ILS: {e}")
                return oldPos, False, W

            Hy = Hinv @ y
            pos = pos + Hy

            # Fix altitude to ground truth when requested.
            if gt is not None and len(gt) >= 3 and len(pos) == 3:
                pos[2] = gt[2]

            maxHy = max(abs(Hy))

            if (maxHy < eps) and (maxHy != 0.0):
                converged = True
                break

            if maxHy - oldMaxHy > 0.5:
                # The solution is diverging; return the preceding position.
                return oldPos, True, W

            oldMaxHy = maxHy

        return pos, converged, W

    def distance_calculation(self, P_rx, P_tx, frequency):
        los_exponent = (1 / 17.3) * (P_tx - P_rx - (32.4 + 20 * np.log10(frequency)))
        nlos_exponent = (1 / 38.3) * (P_tx - P_rx - (17.30 + 24.9 * np.log10(frequency)))
        exponent = min(los_exponent, nlos_exponent)
        d = (10 ** exponent)
        return round(d, 3)

    def parse_rtt(self, r, bsWifiFtm, WiFi_excluded=None):
        """
        Parses RTT (Round-Trip Time) information from a data string.

        Args:
            r (str/dict): Input data containing RTT information.
            bsWifiFtm (dict): Base station information containing positions (X, Y, Z).
            WiFi_excluded (list, optional): List of MAC addresses to exclude from parsing.

        Returns:
            tuple: (devices, positions, distances, stdDistance, rssi)
        """
        if WiFi_excluded is None:
            WiFi_excluded = []

        # Parse a dictionary or a string representation of one.
        try:
            data = ast.literal_eval(str(r))
        except Exception as e:
            logging.error(f"Error parsing RTTInfo: {e}")
            return [], [], [], [], {}

        values = data.get('RttInfo', '').split(' ')
        bsWifiFtm = self.set_data_instance.bsWifiFtm  # Retrieve base station info

        devices = []
        distances = []
        positions = []
        stdDistance = []
        rssi = {}
        ranging_results = []

        for i in range(len(values)):
            if f'mac={self.mac}' in values[i]:
                result = {}
                for j in range(i, min(i + 10, len(values))):
                    token = values[j]
                    if 'distanceMm' in token:
                        try:
                            result['distanceMm'] = int(token.split('=')[1].strip(','))
                            distance = float(result['distanceMm']) / 1000.0  # m

                            if self.mac in bsWifiFtm:
                                lon = bsWifiFtm[self.mac]["X"]
                                lat = bsWifiFtm[self.mac]["Y"]
                                alt = bsWifiFtm[self.mac]["Z"]

                                x, y, z = self.gps2ecef(lon, lat, alt)
                                pos = [x, y, z]
                                positions.append(pos)
                                devices.append(self.mac)
                                distances.append(distance)
                            else:
                                logging.warning(
                                    f"MAC address {self.mac} not found in bsWifiFtm."
                                )
                        except Exception as e:
                            logging.error(f"Error parsing distanceMm: {e}")

                    elif 'distanceStdDevMm' in token:
                        try:
                            result['distanceStdDevMm'] = int(
                                token.split('=')[1].strip(',')
                            )
                            stdDistance.append(
                                float(result['distanceStdDevMm']) / 1000.0
                            )
                        except Exception as e:
                            logging.error(f"Error parsing distanceStdDevMm: {e}")

                    elif 'rssi' in token:
                        try:
                            rssi[self.mac] = int(token.split('=')[1].strip(','))
                        except Exception as e:
                            logging.error(f"Error parsing rssi: {e}")

                    elif 'numAttemptedMeasurements' in token:
                        try:
                            result['numAttemptedMeasurements'] = int(
                                token.split('=')[1].strip(',')
                            )
                        except Exception as e:
                            logging.error(
                                f"Error parsing numAttemptedMeasurements: {e}"
                            )

                    elif 'numSuccessfulMeasurements' in token:
                        try:
                            result['numSuccessfulMeasurements'] = int(
                                token.split('=')[1].strip(',')
                            )
                        except Exception as e:
                            logging.error(
                                f"Error parsing numSuccessfulMeasurements: {e}"
                            )

                ranging_results.append(result)

        logging.info(f"Parsed RTT for MAC {self.mac}: {len(devices)} devices found.")
        return devices, positions, distances, stdDistance, rssi

    def positioning_location_error(self, position, gt):
        if len(position) > 2:
            err_ = norm([
                position[0] - gt[0],
                position[1] - gt[1],
                position[2] - gt[2]
            ])
        else:
            err_ = norm([
                position[0] - gt[0],
                position[1] - gt[1]
            ])
        return err_

    def ranging_error(self, gt, bs_pos, dis, dimension):
        if dimension == 3:
            real_distance = norm([
                bs_pos[0] - gt[0],
                bs_pos[1] - gt[1],
                bs_pos[2] - gt[2]
            ])
        else:
            real_distance = norm([
                bs_pos[0] - gt[0],
                bs_pos[1] - gt[1]
            ])
        range_err_ = abs(real_distance - dis)
        return range_err_

    def compute_position(
        self,
        Mode=None,
        RttInfo=None,
        id_mobile=None,
        Timestamp=None,
        groundTruth=None,
        dimension=2
    ):
        global estimation_count

        if Mode is None:
            Mode = self.Mode

        user_position_WiFi = []
        gt = None
        gt_ecef = None

        # Parse ground truth when provided.
        if groundTruth:
            try:
                gt = ast.literal_eval(groundTruth)
            except Exception as e:
                logging.error(f"Error parsing groundTruth: {e}")
                gt = None

        if gt and gt != [None, None, None]:
            try:
                gt_x_ecef, gt_y_ecef, gt_z_ecef = self.ecef_transformer.transform(
                    gt[0], gt[1], gt[2]
                )
                gt_ecef = [gt_x_ecef, gt_y_ecef, gt_z_ecef]
            except Exception as e:
                logging.error(f"Error converting ground truth to ECEF: {e}")
                gt_ecef = None

        info = {
            'user_position_WiFi': '',
            'groundTruth': gt,
            'error_position_WiFi': '',
            'ranging_error': {},
            'WiFi_Info': {},
            'bsWiFi': '',
            'id_mobile': id_mobile,
            'Timestamp': Timestamp
        }

        BS_WiFi = []
        distances_WiFi = []
        ID_WiFi = []
        z_aux = None

        mobile_key = str(id_mobile) if id_mobile is not None else '__default__'
        distance_buffer = self.distances_by_mobile.setdefault(
            mobile_key, CircularBuffer(40)
        )
        position_buffer = self.positions_by_mobile.setdefault(
            mobile_key, CircularBuffer(40)
        )

        logging.debug(
            '-----------------------RTT_INFO............................: '
            + str(RttInfo)
        )

        try:
            # Process only nonempty RttInfo payloads.
            if RttInfo and RttInfo != "{}":
                device_id_wifi, positions_wifi, distances_wifi, stdDistance_wifi, wifi_rssi = \
                    self.parse_rtt(RttInfo, self.set_data_instance.bsWifiFtm)

                if stdDistance_wifi == []:
                    stdDistance_wifi = np.ones(len(distances_wifi))

                for pos, dev, dis, std in zip(
                    positions_wifi,
                    device_id_wifi,
                    distances_wifi,
                    stdDistance_wifi
                ):
                    rssi = wifi_rssi.get(dev, None)

                    if z_aux is None and len(pos) >= 3:
                        z_aux = pos[2]

                    info['WiFi_Info'][dev] = [
                        'Pos:' + str(pos),
                        'Distance:' + str(dis),
                        'distanceStdDevMm:' + str(std),
                        'RSSI:' + str(rssi)
                    ]

                    # Retain every base station for optional 3-D estimation.
                    BS_WiFi.append(pos)
                    distances_WiFi.append(dis)
                    ID_WiFi.append(dev)

                    # Accumulate observations only for the target MAC address.
                    desired_device_id = self.mac
                    if dev == desired_device_id:
                        distance_buffer.append(float(dis))
                        position_buffer.append(pos)

                logging.debug(
                    f'distances_for_mobile[{mobile_key}]: '
                    + str(distance_buffer.get_elements())
                )
                logging.debug(
                    f'positions_for_mobile[{mobile_key}]: '
                    + str(position_buffer.get_elements())
                )

            # Estimate position.
            converged = False
            position_WiFi = None
            position_WiFi_ecef = None

            num_samples = len(distance_buffer)

            if dimension == 2 and num_samples > 2:
                logging.debug(
                    '\n******A N C H O R ----- P O S I T I O N ******: '
                    + str(position_buffer.get_elements())
                )
                logging.debug(
                    '\n******A N C H O R ----- D I S T A N C E S ******: '
                    + str(distance_buffer.get_elements())
                )

                position_WiFi_ecef, converged, it_W = self.ils_2d(
                    position_buffer.get_elements(),
                    distance_buffer.get_elements(),
                    Mode=Mode,
                    gt=gt_ecef
                )

                if z_aux is None and len(position_WiFi_ecef) >= 3:
                    z_aux = position_WiFi_ecef[2]

                if z_aux is None:
                    # Use zero when no altitude is available.
                    z_aux = 0.0

                x = position_WiFi_ecef[0]
                y = position_WiFi_ecef[1]
                z = z_aux

                lon, lat, _ = self.gps_transformer.transform(x, y, z)
                position_WiFi = [lon, lat]

            elif dimension == 3 and len(distances_WiFi) > 3:
                position_WiFi_ecef, converged, it_W = self.ils_3d(
                    BS_WiFi,
                    distances_WiFi,
                    Mode=Mode,
                    gt=gt_ecef
                )

                x = position_WiFi_ecef[0]
                y = position_WiFi_ecef[1]
                z = position_WiFi_ecef[2]
                lon, lat, alt = self.gps_transformer.transform(x, y, z)
                position_WiFi = [lon, lat, alt]
            else:
                converged = False

            if converged and position_WiFi is not None:
                estimation_count += 1
                info['user_position_WiFi'] = position_WiFi

                print('\n****** M U L T I L A T E R A T I O N -- E S T I M A T I O N ******: ')
                print("Estimation : " + str(estimation_count) + "\n")
                print('\n****** I N F O R M A T I O N ******: ' + str(info['user_position_WiFi']))
                print(info)

                time.sleep(0.5)
                print(info)

                if gt_ecef is not None and position_WiFi_ecef is not None:
                    err_ = self.positioning_location_error(position_WiFi_ecef, gt_ecef)
                    info['error_position_WiFi'] = err_

                    for dev in info['WiFi_Info'].keys():
                        wifi_aux = info['WiFi_Info'][dev]

                        pos_string = wifi_aux[0]
                        pos_values = pos_string.split(':')[1][1:-1].split(',')
                        pos_floats = [float(value) for value in pos_values]

                        distance_string = wifi_aux[1]
                        distance_value = float(distance_string.split(':')[1])

                        range_error = self.ranging_error(
                            gt_ecef,
                            pos_floats,
                            distance_value,
                            dimension
                        )

                        info['ranging_error'][dev] = range_error

            return info

        except Exception as e:
            logging.error(f"An error occurred in compute_position: {e}", exc_info=True)
            return None


class CircularBuffer:
    def __init__(self, size: int):
        self.size = size
        self.buffer = [None] * size
        self.index = 0

    def append(self, value):
        self.buffer[self.index] = value
        self.index = (self.index + 1) % self.size

    def get_buffer(self):
        return self.buffer

    def get_elements(self):
        # Return only valid elements (not None).
        return [elem for elem in self.buffer if elem is not None]

    def __len__(self):
        # Count valid elements.
        return len(self.get_elements())


class ServerToROS(Node):
    def __init__(self, get_data_instance: GetData):
        super().__init__('getInfo_Fordron_fx8')
        self.get_data_instance = get_data_instance

        self.pub = self.create_publisher(String, 'infoServer_fx8', 1)
        self.pub2 = self.create_publisher(String, 'inputServer_fx8', 1)

        self.app = Flask(__name__)
        self.app.config['MYSQL_HOST'] = 'localhost'
        self.app.config['MYSQL_USER'] = 'root'
        self.app.config['MYSQL_DB'] = 'flask'
        self.app.route('/mobile', methods=['POST'])(self.add_mobile)

        logging.basicConfig(
            level=logging.DEBUG,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        self.logger = rclpy.logging.get_logger("ServerToROS")
        self.info2 = {}

        self.requests_dict = {"requests": []}
        self.last_request = None
        self.get_logger().info('Publishing last request: "%s"' % self.info2)

        self.msg = String()
        self.msg2 = String()

    def run_flask_server(self):
        host = os.environ.get('OSA_FLASK_HOST', '0.0.0.0')
        port = int(os.environ.get('OSA_FLASK_PORT', '5002'))
        self.app.run(host=host, port=port)
        print("Connected to Flask server")

    def stop_server(self):
        os.kill(os.getpid(), signal.SIGINT)

    def add_mobile(self):
        data = request.json

        self.info2 = self.get_data_instance.compute_position(
            'Huber',
            data.get('RttInfo'),
            data.get('id_mobile'),
            data.get('Timestamp'),
            data.get('groundTruth'),
            dimension=2
        )

        self.last_request = data
        self.msg.data = str(self.info2)
        self.msg2.data = str(self.last_request)

        self.pub.publish(self.msg)
        self.pub2.publish(self.msg2)

        self.get_logger().info('Publishing msg WIFI INFO2: "%s"' % self.msg.data)
        return jsonify({'status': 'success', 'data': self.info2}), 200


def flask_main(server_to_ros: ServerToROS):
    rclpy.logging.get_logger("flask_main").info("FLASK MAIN STARTED")
    try:
        print("FLASK: Starting Flask server...")
        server_to_ros.run_flask_server()
    except Exception as e:
        print("FLASK: Exception occurred:", str(e))


def main(args=None):
    rclpy.init(args=args)

    set_data_instance = SetData()
    get_data_instance = GetData(set_data_instance)
    server = ServerToROS(get_data_instance)

    executor = MultiThreadedExecutor(num_threads=3)
    executor.add_node(set_data_instance)
    executor.add_node(get_data_instance)
    executor.add_node(server)

    print("Starting Flask thread...")
    flask_thread = threading.Thread(target=flask_main, args=(server,))
    flask_thread.start()

    try:
        while rclpy.ok():
            executor.spin_once(timeout_sec=1.0)
    except KeyboardInterrupt:
        print("\nStopping servers...")
    finally:
        set_data_instance.destroy_node()
        get_data_instance.destroy_node()
        server.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()
