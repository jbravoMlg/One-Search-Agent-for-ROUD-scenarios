#!/usr/bin/env python3

import logging
import ast

import rclpy
from rclpy.node import Node
from std_msgs.msg import String


class EstimationsToRosTopics(Node):
    def __init__(self):
        super().__init__('info_server_fx8')

        # Configure logging without disrupting configuration from another module.
        logging.basicConfig(
            level=logging.DEBUG,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)

        # Subscribe to the topic that publishes the "info" dictionary.
        self.caller = self.create_subscription(
            String,
            'infoServer_fx8',
            self.call_to_server,
            10
        )

        self.setup_publishers()

    def setup_publishers(self):
        self.get_logger().debug("**** Publishers setup ****")

        # Per-anchor distance estimate.
        self.pub1 = self.create_publisher(
            String,
            'Anchor1F/wifi_rtt_estimation',
            10
        )
        # Geographic position estimate.
        self.pub8 = self.create_publisher(
            String,
            'geo_multilateration_fx8_1f',
            10
        )

    def call_to_server(self, msg: String):
        self.get_logger().debug(
            "**** Received message from infoServer topic: %s", msg.data
        )

        try:
            self.get_logger().debug("**** Processing message...")

            # Parse the dictionary encoded in msg.data.
            info_str = msg.data
            info = ast.literal_eval(info_str)

            if not isinstance(info, dict):
                raise ValueError("Parsed message is not a dictionary")

            # ---- 'WiFi_Info' field ----
            wifi_info = info.get('WiFi_Info', {})
            if not isinstance(wifi_info, dict):
                wifi_info = {}

            # MAC address of anchor 1F.
            anchor_mac = "3c:28:6d:b2:c9:1f"
            anchor_data = wifi_info.get(anchor_mac)

            # Use id_mobile as the label when available, otherwise Timestamp.
            label = info.get('id_mobile') or info.get('Timestamp') or ""

            # Publish distance and RSSI data for anchor 1F.
            if anchor_data is not None and isinstance(anchor_data, list) and len(anchor_data) >= 4:
                # anchor_data = ['Pos:...', 'Distance:...', 'distanceStdDevMm:...', 'RSSI:...']
                try:
                    distance = anchor_data[1].split(":", 1)[1]
                    std_dev = anchor_data[2].split(":", 1)[1]
                    rssi = anchor_data[3].split(":", 1)[1]
                except Exception as e:
                    self.get_logger().error(
                        f"Error parsing anchor_data fields: {anchor_data} -> {e}"
                    )
                    distance = std_dev = rssi = "N/A"

                self.get_logger().info("**** Registering a detection from anchor 1F ****")
                self.get_logger().debug("WiFi_Info VALUES: %s", wifi_info)

                msg1 = String()
                # Format: distance,std_dev,rssi,label
                msg1.data = f"{distance},{std_dev},{rssi},{label}"
                self.pub1.publish(msg1)

            # ---- 'user_position_WiFi' field ----
            user_position = info.get('user_position_WiFi')

            if isinstance(user_position, (list, tuple)) and len(user_position) > 1:
                # compute_position stores position_WiFi as [lon, lat].
                lon = str(user_position[0])
                lat = str(user_position[1])

                msg8 = String()
                # Format: lat,long,alt,label (altitude is zero here).
                msg8.data = f"{lat},{lon},0,{label}"
                self.pub8.publish(msg8)

            else:
                self.get_logger().warning(
                    "There is a lack of detections... "
                    "There is no new data from the multilateration algorithm."
                )

        except Exception as e:
            self.get_logger().error(f"Error processing data: {e}", exc_info=True)

    def run(self):
        print("Sending distance estimations to ROS topics...\n")
        rclpy.spin(self)


if __name__ == '__main__':
    try:
        rclpy.init()
        node = EstimationsToRosTopics()
        node.run()
    except KeyboardInterrupt:
        pass
    finally:
        if rclpy.ok():
            rclpy.shutdown()
