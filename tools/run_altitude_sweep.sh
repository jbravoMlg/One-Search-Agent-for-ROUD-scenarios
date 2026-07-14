#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PYTHON=${PYTHON:-}
if [ -z "$PYTHON" ]; then
  if [ -x "$ROOT/.venv/bin/python" ]; then
    PYTHON="$ROOT/.venv/bin/python"
  else
    PYTHON=python3
  fi
fi
export MPLBACKEND=${MPLBACKEND:-Agg}

for threshold in 0 105 115; do
  echo "=== Altitude threshold ${threshold} m WGS84 ==="
  "$PYTHON" "$ROOT/analysis/analysis_tool.py" \
    --alt-threshold "$threshold" \
    --takeoff-offset 71 \
    --landing-offset 10
done
