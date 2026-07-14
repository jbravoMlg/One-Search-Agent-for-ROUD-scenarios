from rosbags.rosbag2 import Reader, Writer
from rosbags.typesys import get_typestore, Stores
import argparse

def filter_rosbag(input_bag, output_bag, topics_to_keep):
    """Reads an input rosbag2 file and writes a new rosbag2 file containing only specified topics."""
    typestore = get_typestore(Stores.ROS2_HUMBLE)  # Use ROS2_FOXY when processing Foxy bags.

    with Reader(input_bag) as reader:
        with Writer(output_bag, version=8) as writer:
            connections_map = {}
            for conn in reader.connections:
                if conn.topic in topics_to_keep:
                    connections_map[conn.topic] = writer.add_connection(
                        conn.topic, conn.msgtype, typestore=typestore  # Pass `typestore` explicitly.
                    )

            for conn, timestamp, rawdata in reader.messages():
                if conn.topic in topics_to_keep:
                    msg = typestore.deserialize_cdr(rawdata, conn.msgtype)
                    writer.write(
                        connections_map[conn.topic],
                        timestamp,
                        typestore.serialize_cdr(msg, conn.msgtype)
                    )

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Filter topics from a ROS 2 bag file.")
    parser.add_argument("input_bag", type=str, help="Path to the input ROS 2 bag file.")
    parser.add_argument("output_bag", type=str, help="Path to the output ROS 2 bag file.")
    parser.add_argument("--topics", nargs='+', required=True, help="List of topics to keep in the output bag.")

    args = parser.parse_args()
    filter_rosbag(args.input_bag, args.output_bag, args.topics)

