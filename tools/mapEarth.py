import rclpy
from rclpy.node import Node
from sensor_msgs.msg import NavSatFix
import os

# KML file used to store the real-time position.
KML_FILE = "robot_position.kml"

class GPSKMLUpdater(Node):
    def __init__(self, topic_name):
        super().__init__('gps_kml_updater')

        # Subscribe to the GPS topic.
        self.subscription = self.create_subscription(
            NavSatFix,
            topic_name,
            self.update_kml,
            10  # QoS depth; adjust as needed.
        )

        self.get_logger().info(f"Subscribed to topic: {topic_name}")
        self.update_kml(NavSatFix())  # Initialize the file with neutral values.

    def update_kml(self, msg):
        """Generate a KML file containing the robot's current position."""
        latitude = msg.latitude if msg.latitude else 0.0
        longitude = msg.longitude if msg.longitude else 0.0
        altitude = msg.altitude if msg.altitude else 0.0

        kml_content = f"""<?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2">
            <Placemark>
                <name>Robot</name>
                <Point>
                    <coordinates>{longitude},{latitude},{altitude}</coordinates>
                </Point>
            </Placemark>
        </kml>"""

        with open(KML_FILE, "w") as f:
            f.write(kml_content)
        self.get_logger().info(f"KML updated: {latitude}, {longitude}")

def main():
    rclpy.init()

    topic_name = "/FX8/fix"  # This topic must be available on the ROS 2 network.
    node = GPSKMLUpdater(topic_name)

    try:
        rclpy.spin(node)  # Keep the node active and listening for messages.
    except KeyboardInterrupt:
        node.get_logger().info("Node stopped.")
    finally:
        node.destroy_node()
        rclpy.shutdown()

if __name__ == '__main__':
    main()
