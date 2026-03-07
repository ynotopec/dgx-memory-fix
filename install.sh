#!/bin/bash

echo "Installing Memory Cache Monitor Daemon..."

dependency_check() {
    for dep in sudo; do
        if ! command -v $dep &> /dev/null; then
            echo "ERROR: Required dependency '$dep' is not installed"
            exit 1
        fi
    done
    echo "All dependencies checked."
}

dependency_check

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SCRIPT="${SCRIPT_DIR}/memory_monitor.sh"
SERVICE="${SCRIPT_DIR}/memory_monitor.service"

if [ ! -f "$SCRIPT" ]; then
    echo "Error: memory_monitor.sh not found"
    exit 1
fi

if [ ! -f "$SERVICE" ]; then
    echo "Error: memory_monitor.service not found"
    exit 1
fi

chmod +x "$SCRIPT"

echo "Copying script to /usr/local/bin..."
sudo cp "$SCRIPT" /usr/local/bin/memory_monitor.sh

SYSTEMD_DIR="/etc/systemd/system"

echo "Copying service file to systemd..."
sudo cp "$SERVICE" "$SYSTEMD_DIR/"

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Enabling memory_monitor service to start on boot..."
sudo systemctl enable memory_monitor.service

echo "Starting memory_monitor service..."
if sudo systemctl start memory_monitor.service; then
    echo "✓ Service started successfully"
else
    echo "✗ Service failed to start"
    exit 1
fi

echo ""
echo "Checking service status..."
sudo systemctl status memory_monitor.service --no-pager

echo ""
echo "Installation complete!"
echo "The service will run every 30 seconds and drop caches when conditions are met."
echo "View logs with: sudo journalctl -u memory_monitor.service -f"
