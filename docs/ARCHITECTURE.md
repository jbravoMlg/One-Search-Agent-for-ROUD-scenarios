# Architecture

## Runtime flow

1. `SetData` subscribes to `/FX8/fix` and retains the latest RTK-referenced UAV pose.
2. The Flask `/mobile` endpoint receives RTT reports and a transmitter `id_mobile`.
3. `GetData.compute_position()` stores RTT distances and ECEF UAV poses in independent 40-element circular buffers keyed by `id_mobile`.
4. Starting with three valid observations, the endpoint invokes the two-coordinate Huber-weighted iterative least-squares estimator, with at most 40 iterations.
5. `/geo_multilateration_fx8_1f` carries raw coordinates.
6. `FX8_medianBoth.py` maintains independent 20-estimate latitude and longitude windows for P1 and X4 and publishes filtered coordinates when each window is full.

## Coordinate model

UAV WGS84 coordinates are transformed to ECEF. The current 2-D implementation projects slant ranges using ECEF Z differences, removes Z, and solves for ECEF X/Y before transforming the output back to longitude/latitude. Victim altitude is not estimated.

## Online and offline association

The online implementation pairs an RTT report with the latest UAV pose available at processing time. It does not interpolate GNSS samples. Offline RTT evaluation associates each RTT report with the temporally closest GNSS sample.

## Configuration boundaries

- Hardware MAC and Flask binding are environment-configurable.
- Experiment ground truth, offsets, and audited window sizes are documented in `configs/field_experiment.yaml`.
- ROS topic names remain deployment-specific constants in the runtime nodes and should be converted to ROS parameters in a future ROS package release.

## Operator visualization

The MATLAB SARFIS source is included under `sarfis/`. It consumes mission and ROS 2 information to represent environments, agents, objectives, points of interest, and trajectories for command-and-control decision support. SARFIS is independent from the offline localization analysis. Its default environment requires DEM files that are available from the corresponding author upon reasonable request.

Generated MATLAB project metadata and MEX code/build outputs are not runtime inputs. The active GUI paths do not require MEX artifacts, and the filtered experiment bag is stored under `data/jemerg24-filtered/`.
