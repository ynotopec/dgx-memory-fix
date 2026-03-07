# Memory Monitor Goal

Drop system cache when workload memory < 75% of OS-reported memory. Runs every 30s as systemd daemon.

Executes:
- `sync`
- `echo 3 > /proc/sys/vm/drop_caches`
