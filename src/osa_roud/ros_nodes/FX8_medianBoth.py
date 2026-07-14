#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from std_msgs.msg import String
from collections import deque
import numpy as np


class MedianCalculatorNode(Node):
    def __init__(self):
        super().__init__('median_calculator')

        self.subscription = self.create_subscription(
            String,
            '/geo_multilateration_fx8_1f',
            self.listener_callback,
            10
        )

        self.publisher_P1 = self.create_publisher(
            String,
            '/FX8/multilateration_P1filtered',
            10
        )
        self.publisher_X4 = self.create_publisher(
            String,
            '/FX8/multilateration_X4filtered',
            10
        )

        window_size = 20
        # Independent buffers for each tag.
        self.latitudes = {
            'P1': deque(maxlen=window_size),
            'X4': deque(maxlen=window_size),
        }
        self.longitudes = {
            'P1': deque(maxlen=window_size),
            'X4': deque(maxlen=window_size),
        }

    def listener_callback(self, msg: String):
        """
        Expect messages in the following format:
        lat,lon,alt,tag
        where tag is either 'P1' or 'X4'.
        """
        try:
            data_str = msg.data.strip()
            parts = data_str.split(',')

            if len(parts) < 4:
                raise ValueError(f'Not enough data points in message: {parts}')

            latitude = float(parts[0])
            longitude = float(parts[1])
            tag = parts[3].strip()  # Remove whitespace and line breaks.

            if tag not in self.latitudes:
                # Ignore tags that are not relevant to this filter.
                self.get_logger().debug(
                    f'Ignoring tag "{tag}" in message: {msg.data}'
                )
                return

            self.latitudes[tag].append(latitude)
            self.longitudes[tag].append(longitude)

            if tag == 'P1':
                self.calculate_and_publish_median('P1', self.publisher_P1)
            elif tag == 'X4':
                self.calculate_and_publish_median('X4', self.publisher_X4)

        except (IndexError, ValueError) as e:
            self.get_logger().error(
                f'Failed to parse message: {msg.data} with error: {e}'
            )

    def calculate_and_publish_median(self, tag: str, publisher):
        lats = self.latitudes[tag]
        lons = self.longitudes[tag]

        # Calculate a median only after the window is full.
        if len(lats) == lats.maxlen and len(lons) == lons.maxlen:
            median_latitude = float(np.median(lats))
            median_longitude = float(np.median(lons))

            self.get_logger().info(
                f'Received {tag}: lat={lats[-1]}, lon={lons[-1]}'
            )
            self.get_logger().info(
                f'Median {tag}: lat={median_latitude}, lon={median_longitude}'
            )

            msg = String()
            # lat,lon,alt,tag (alt=0)
            msg.data = f'{median_latitude},{median_longitude},0,{tag}'
            publisher.publish(msg)

            self.get_logger().info(
                f'Published Median Data {tag}: {msg.data}'
            )


def main(args=None):
    rclpy.init(args=args)
    node = MedianCalculatorNode()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
