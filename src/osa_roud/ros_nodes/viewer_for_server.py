#!/usr/bin/env python3
import sys
import rclpy
from rclpy.node import Node
from std_msgs.msg import String

class InfoViewerNode(Node):
    def __init__(self, topic_name: str):
        super().__init__('info_viewer_node')
        self.subscription = self.create_subscription(
            String,
            topic_name,
            self.listener_callback,
            10
        )

    def listener_callback(self, msg: String):
        self.get_logger().info('Received message on %s: "%s"' % (self.subscription.topic_name, msg.data))


def main(args=None):
    rclpy.init(args=args)

    # Default to /infoServer_fx8 when no topic argument is provided.
    topic = sys.argv[1] if len(sys.argv) > 1 else '/infoServer_fx8'
    node = InfoViewerNode(topic)

    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
