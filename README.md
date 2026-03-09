# Memory Monitor Daemon

Monitor system memory and automatically drop caches when usage is higher than expected.

## How It Works

Checks every 30 seconds. If calculated workload (RSS + GPU) is less than 75% of OS-reported memory usage, the daemon drops system caches.

## Install

```bash
./install.sh
```

## Usage

```bash
sudo systemctl status memory_monitor.service
sudo journalctl -u memory_monitor.service -f
```

## Configuration

Environment variables (set before running):

- `INTERVAL` - Check interval in seconds (default: 30)
- `RATIO_PERCENT` - Threshold percentage (default: 75)
- `DROP_MODE` - Cache drop mode 0/1/2/3 (default: 3)
- `COOLDOWN_SEC` - Minimum seconds between cache drops (default: 60)

If `nvidia-smi` is unavailable or temporarily failing, GPU usage is treated as 0 so the daemon keeps running.
