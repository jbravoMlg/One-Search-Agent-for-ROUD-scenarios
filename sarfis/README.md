# SARFIS MATLAB application

SARFIS is the MATLAB decision-support and visualization interface used with the One Search Agent experiment. It represents the environment, robotic agents, objectives, points of interest, planned trajectories, and ROS 2 waypoint data.

## Included source

- `Matlab functions/GUI/`: GUIDE interface, callbacks, and visualization helpers;
- `Matlab functions/DEM/`: XYZ reading and terrain gridding;
- `Matlab functions/GPX/`: GPX export and geographic/UTM conversion;
- `start_sarfis.m`: portable path setup and GUI launcher.

Generated MATLAB project metadata, generated MEX C/build outputs, and duplicate rosbag data are intentionally excluded. The filtered bag is already available under the repository-level `data/` directory. No MEX binary is required by the active GUI paths.

## Starting SARFIS

From MATLAB, with this directory as the current directory or on the MATLAB path, run:

`start_sarfis`

The launcher adds the source directories to the MATLAB path, creates the ignored session directory, checks for the default DEM, and starts `GUI.m`/`GUI.fig`.

## Requirements

- MATLAB with support for GUIDE-generated figures;
- a graphical desktop session;
- ROS Toolbox only when using `representarWaypointsROS.m` with ROS 2;
- the experiment DEM files for the default environment.

The DEMs and demonstration videos are available from the corresponding author upon reasonable request. Placement and expected filenames are documented in `DEM files/README.md`.

## Known limitations

- The GUI loads a specific experiment DEM by default.
- Runtime MATLAB validation is not performed in the Python test suite.
- The ROS waypoint helper waits up to 10 seconds for a `std_msgs/Float32MultiArray` message on `/kml_path`.
