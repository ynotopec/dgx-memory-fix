#!/usr/bin/env bash
set -euo pipefail

INTERVAL="${INTERVAL:-30}"
RATIO_PERCENT="${RATIO_PERCENT:-75}"
DROP_MODE="${DROP_MODE:-3}"

while true; do
  # 1. Get OS "Used" metric (in KB)
  used_os_kb=$(free -k | awk 'NR==2 {print $3}')

  # 2. Get RSS sum (in KB)
  rss_kb=$(ps -e -o rss= | awk '{s+=$1} END {print s+0}')

  # 3. Get GPU memory sum (converted to KB)
  gpu_kb=$(nvidia-smi --query-compute-apps=used_gpu_memory --format=csv,noheader,nounits 2>/dev/null | awk '{s+=$1} END {print (s+0)*1024}')

  used_calc_kb=$((rss_kb + gpu_kb))

  # 4. Exact formula: if (RSS + GPU) < 75% of OS_USED
  if (( used_calc_kb * 100 < used_os_kb * RATIO_PERCENT )); then
    sync
    echo "$DROP_MODE" > /proc/sys/vm/drop_caches
  fi

  sleep "$INTERVAL"
done
