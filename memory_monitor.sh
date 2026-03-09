#!/usr/bin/env bash
set -euo pipefail

INTERVAL="${INTERVAL:-30}"
RATIO_PERCENT="${RATIO_PERCENT:-75}"
DROP_MODE="${DROP_MODE:-3}"
COOLDOWN_SEC="${COOLDOWN_SEC:-60}"

last_drop=0

get_gpu_kb() {
  if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo 0
    return 0
  fi

  # If the NVIDIA driver/GPU is unavailable (e.g. reset in progress),
  # nvidia-smi may return non-zero. Treat that as "no measurable GPU usage"
  # so the daemon keeps running instead of crashing.
  local smi_out
  if ! smi_out=$(nvidia-smi --query-compute-apps=used_gpu_memory --format=csv,noheader,nounits 2>/dev/null); then
    echo 0
    return 0
  fi

  awk '{s+=$1} END {print (s+0)*1024}' <<<"$smi_out"
}

while true; do
  # 1. Get OS "Used" metric (in KB)
  used_os_kb=$(free -k | awk 'NR==2 {print $3}')

  # 2. Get RSS sum (in KB)
  rss_kb=$(ps -e -o rss= | awk '{s+=$1} END {print s+0}')

  # 3. Get GPU memory sum (converted to KB)
  gpu_kb=$(get_gpu_kb)

  used_calc_kb=$((rss_kb + gpu_kb))

  now=$(date +%s)

  # 4. Exact formula: if (RSS + GPU) < 75% of OS_USED
  #    and cooldown elapsed, then drop caches
  if (( used_calc_kb * 100 < used_os_kb * RATIO_PERCENT && now - last_drop >= COOLDOWN_SEC )); then
    sync
    echo "$DROP_MODE" > /proc/sys/vm/drop_caches
    last_drop=$now
  fi

  sleep "$INTERVAL"
done
