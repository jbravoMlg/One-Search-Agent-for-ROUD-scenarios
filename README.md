# One Search Agent for ROUD Scenarios

This repository contains the One Search Agent (OSA) localization prototype for Remote Outdoor Unstructured and Disaster (ROUD) scenarios. It provides the runtime nodes, offline analysis tools, dataset configuration, and MATLAB SARFIS visualization source needed to inspect and reuse the implementation.

The codebase covers:

- one UAV-mounted Wi-Fi FTM anchor and RTK-GNSS pose source;
- independent 40-observation RTT–pose windows per transmitter identifier;
- 2-D iterative least squares with Huber residual weights;
- independent 20-estimate median filters for latitude and longitude;
- direct horizontal geodesic positioning-error evaluation;
- the raw and filtered JEMERG XVIII rosbags used by the offline analysis;
- the MATLAB SARFIS decision-support and visualization source code.

## Repository layout

- `src/osa_roud/ros_nodes/`: ROS 2 runtime and support nodes.
- `analysis/analysis_tool.py`: offline rosbag analysis and metric computation.
- `data/`: raw and filtered bags for the included field evaluation.
- `configs/field_experiment.yaml`: field experiment and algorithm parameters.
- `sarfis/`: MATLAB SARFIS GUI, visualization, DEM, GPX, and ROS 2 helpers.
- `tools/`: auxiliary rosbag and KML utilities.
- `docs/REPRODUCING_RESULTS.md`: reproducible analysis procedure and reference outputs.
- `docs/ARCHITECTURE.md`: runtime data flow and implementation boundaries.
- `tests/`: regression checks for repository structure and critical algorithm settings.

## Quick start: offline analysis

Python 3.10 or newer is recommended.

1. Create a virtual environment:

    `python3 -m venv .venv`

2. Install the analysis dependencies:

    `.venv/bin/python -m pip install -r requirements-analysis.txt`

3. Verify the checkout:

    `.venv/bin/python -m pytest -q`

4. Run the default analysis from the repository root:

    `MPLBACKEND=Agg .venv/bin/python analysis/analysis_tool.py`

The defaults use the two included bags, surveyed coordinates, 71 s take-off offset, 10 s landing offset, and the complete analysis interval. To run all configured altitude subsets, use:

`./tools/run_altitude_sweep.sh`

The sweep script automatically uses `.venv/bin/python` when it exists. Set `PYTHON` to use a different interpreter.

To compare the stored 2-D estimates with offline recomputed 2-D and unconstrained 3-D Huber ILS estimates, run:

`.venv/bin/python analysis/compare_offline_2d_3d.py`

See `docs/REPRODUCING_RESULTS.md` for interpretation and expected values.

## ROS 2 runtime

Runtime nodes target **ROS 2 Humble**. Source the ROS installation before launching individual nodes and install the packages in `requirements-runtime.txt` into the ROS-compatible Python environment. `rclpy` and ROS message packages are supplied by ROS 2 and are intentionally not declared as PyPI dependencies.

The main server accepts these environment variables:

- `OSA_ANCHOR_MAC`: FTM anchor MAC; defaults to the JEMERG XVIII device.
- `OSA_FLASK_HOST`: Flask bind address; defaults to `0.0.0.0`.
- `OSA_FLASK_PORT`: Flask port; defaults to `5002`.

The deployed `/mobile` endpoint invokes `compute_position('Huber', ...)`. The estimator stores positions and distances independently by `id_mobile`.

## Important metric distinction

Localization error is the geodesic distance from each estimated latitude/longitude to surveyed ground truth. It is **not** the difference between UAV-to-estimate and UAV-to-ground-truth ranges. RTT range error is evaluated separately.

## Dataset

The included bags were recorded during JEMERG XVIII. The filtered bag contains outputs produced by a 20-estimate sliding median. Dataset details are in `docs/DATASET.md`.

The field-experiment DEM files and demonstration videos are available from the corresponding author upon reasonable request. They are intentionally not included because of their size and release constraints. Expected DEM filenames and placement are documented in `sarfis/DEM files/README.md`.

## SARFIS visualization

The MATLAB SARFIS source is included under `sarfis/`. Run `start_sarfis` from that directory in MATLAB after obtaining and placing the requested DEM files. See `sarfis/README.md` for requirements, included components, and known limitations.

## Scope

The current estimator publishes longitude and latitude only. Its ECEF-based 2-D range projection is an experimental approximation, not a rigorous local ENU or full 3-D solver. The experiment contains one flight and two static simulated victims; results should be interpreted as field evidence within that operational envelope.

## Repository status

Public repository:

`https://github.com/jbravoMlg/One-Search-Agent-for-ROUD-scenarios`

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

The work underlying this repository has been accepted for publication in IEEE Systems Journal.
