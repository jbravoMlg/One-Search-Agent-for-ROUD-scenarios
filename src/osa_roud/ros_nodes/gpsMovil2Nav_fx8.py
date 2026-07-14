#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from std_msgs.msg import Float64MultiArray
from sensor_msgs.msg import NavSatFix, NavSatStatus


class LocationToNavSatFix(Node):
    def __init__(self):
        super().__init__('location_to_navsatfix')

        self.subscription = self.create_subscription(
            Float64MultiArray,
            '/FX8/location',
            self.location_callback,
            10
        )
        self.publisher = self.create_publisher(
            NavSatFix,
            '/FX8/fix',
            10
        )

    def location_callback(self, msg: Float64MultiArray):
        # Expect [lat, lon, alt, ...], with latitude and longitude required.
        if len(msg.data) < 2:
            self.get_logger().warn(
                f'/FX8/location message has fewer than 2 elements: {msg.data}'
            )
            return

        navsatfix_msg = NavSatFix()

        navsatfix_msg.latitude = msg.data[0]
        navsatfix_msg.longitude = msg.data[1]
        navsatfix_msg.altitude = msg.data[2] if len(msg.data) > 2 else 0.0

        # Header
        navsatfix_msg.header.stamp = self.get_clock().now().to_msg()
        navsatfix_msg.header.frame_id = 'atyges_fx8'

        # Use status constants instead of magic numbers.
        navsatfix_msg.status.status = NavSatStatus.STATUS_NO_FIX
        navsatfix_msg.status.service = NavSatStatus.SERVICE_GPS

        self.publisher.publish(navsatfix_msg)

        self.get_logger().info(
            f'Published NavSatFix: lat={navsatfix_msg.latitude}, '
            f'lon={navsatfix_msg.longitude}, alt={navsatfix_msg.altitude}'
        )


def main(args=None):
    rclpy.init(args=args)
    node = LocationToNavSatFix()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
