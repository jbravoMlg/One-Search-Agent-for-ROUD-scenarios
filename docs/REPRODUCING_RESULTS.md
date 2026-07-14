# Reproducing the field results

## Inputs

The analysis uses:

- `data/jemerg24-realTime`: raw RTT, GNSS, RSSI, and raw multilateration outputs;
- `data/jemerg24-filtered`: 20-estimate median-filtered multilateration outputs;
- P1 ground truth: `36.71678533, -4.48830800, 94.70`;
- X4 ground truth: `36.71680367, -4.48832033, 94.70`;
- take-off offset: 71 s;
- landing offset: 10 s.

These values are recorded in `configs/field_experiment.yaml` and are defaults in `analysis/analysis_tool.py`.

## Environment

Use Python 3.10+ and install `requirements-analysis.txt`. Set `MPLBACKEND=Agg` for non-interactive runs.

## Commands

Run all three altitude subsets:

`./tools/run_altitude_sweep.sh`

Equivalent direct commands use `--alt-threshold 0`, `105`, and `115`. If `--bag` is omitted, the analysis uses the included raw and filtered bags through repository-relative paths.

For an offline comparison between stored 2-D estimates, recomputed 2-D Huber ILS, and unconstrained 3-D Huber ILS, run:

`.venv/bin/python analysis/compare_offline_2d_3d.py`

## Reference values

| Subset | Target | RTT mean / P95 (m) | Raw mean / P95 (m) | Filtered mean / P95 (m) |
|---|---|---:|---:|---:|
| Complete interval | X4 | 7.43 / 20.12 | 12.72 / 30.06 | 7.60 / 20.38 |
| Complete interval | P1 | 10.39 / 21.87 | 20.42 / 45.80 | 13.30 / 25.76 |
| Above 105 m WGS84 | X4 | 8.04 / 21.12 | 13.86 / 33.30 | 8.43 / 20.40 |
| Above 105 m WGS84 | P1 | 7.97 / 21.62 | 20.08 / 45.91 | 11.99 / 19.41 |
| Above 115 m WGS84 | X4 | 4.88 / 5.71 | 16.54 / 30.65 | 6.41 / 16.52 |
| Above 115 m WGS84 | P1 | 4.90 / 6.17 | 25.40 / 147.36 | 12.48 / 34.10 |

Raw/filtered multilateration sample counts are X4 183/164 and P1 181/162 for the complete interval; X4 137/118 and P1 141/123 above 105 m; and X4 49/35 and P1 75/60 above 115 m.

## Metric definition

For an estimated coordinate $\hat{p}$ and surveyed target coordinate $p_{GT}$, horizontal positioning error is the direct geodesic distance $d_g(\hat{p},p_{GT})$. RTT range error is evaluated independently as the absolute difference between measured range and GNSS-derived 3-D UAV–target range.

## Interpretation

Altitude subsets are descriptive. They have different sample counts and virtual-anchor geometries and do not establish a monotonic causal altitude–accuracy relationship.
