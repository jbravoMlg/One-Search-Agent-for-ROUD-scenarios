# Repository instructions

- Keep the field experiment reproducible from relative repository paths.
- Preserve the distinction between the 40-observation estimator window and the 20-estimate median-filter window.
- The deployed HTTP endpoint invokes the Huber-weighted 2-D iterative least-squares estimator.
- Positioning error means direct horizontal geodesic distance from estimate to surveyed ground truth. Do not use radial-distance differences as localization error.
- ROS 2 runtime nodes target ROS 2 Humble; do not add `rclpy` as a PyPI dependency.
- Keep experiment-specific values in `configs/` or environment variables when practical.
- Do not commit generated figures, KML files, caches, or build artifacts.
- Run the repository tests after modifying estimator, filtering, analysis, or dataset configuration code.
