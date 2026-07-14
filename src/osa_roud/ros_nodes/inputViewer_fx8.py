import rclpy
from rclpy.node import Node
from std_msgs.msg import String  # The message is expected to be a String

class InfoViewerNode(Node):

    def __init__(self):
        super().__init__('input_viewer_node')
        self.subscription = self.create_subscription(
            String,
            '/inputServer_fx8',
            self.listener_callback,
            10
        )
        self.subscription  # prevent unused variable warning

    def listener_callback(self, msg):
        self.get_logger().info('Received message: "%s"' % msg.data)


def main(args=None):
    rclpy.init(args=args)
    node = InfoViewerNode()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()

