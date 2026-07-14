# Dataset

## Raw bag

`data/jemerg24-realTime` contains approximately 368.4 s and 5220 messages. The raw multilateration topic is `/geo_multilateration_fx8_1f`.

## Filtered bag

`data/jemerg24-filtered` contains approximately 368.3 s and 2889 messages. Filtered target topics are `/FX8/multilateration_P1filtered` and `/FX8/multilateration_X4filtered`; the analysis reads their combined representation through `/FX8/multilateration_all`.

## Field evaluation scope

The bags come from one JEMERG XVIII field flight with two static simulated victims. X4 was partially occluded and P1 was heavily occluded. Ground-truth altitude was approximately 94.7 m WGS84.

The `.db3` files and their `metadata.yaml` files must remain together in their respective rosbag directories. Generated KML and figures are excluded from version control.
