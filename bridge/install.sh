#!/bin/sh

# This script configures the services so that 
# Krill acts as an access point.
# Alpine Linux is expected (openrc and apk).

set -e

[ "$(id -u)" -eq 0 ] || { echo "This script must be run as root."; exit 1; }

# shellcheck disable=SC2154
trap 'ret=$?; [ $ret -ne 0 ] && echo "  [ERROR] Script failed with code $ret." >&2' EXIT

# shellcheck disable=SC2164  # && pwd inside $() handles cd failure
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[1/4] Installing packages..."
apk update

apk add --no-cache hostapd iw logrotate gettext tcpdump wget

echo "[2/4] Setting up configuration files..."
mkdir -p /etc/hostapd /etc/network

[ -f "$REPO_DIR/secrets.env" ] || { echo "  [ERROR] Missing secrets.env. Copy secrets.env.example and edit it."; exit 1; }
# shellcheck source=/dev/null
. "$REPO_DIR/secrets.env"
: "${RADIUS_SECRET:?}" "${DEVICE_IP:?}" "${GATEWAY:?}"
export RADIUS_SECRET DEVICE_IP GATEWAY

envsubst < "$REPO_DIR/etc/hostapd/hostapd.conf" > /etc/hostapd/hostapd.conf
envsubst < "$REPO_DIR/etc/network/interfaces" > /etc/network/interfaces
cp "$REPO_DIR/etc/logrotate.d/krill" /etc/logrotate.d/krill
cp "$REPO_DIR/etc/tc.qos"         /etc/tc.qos
chmod +x /etc/tc.qos

# Check wlan0 state.
echo "[3/4] Checking wlan0..."
if ! ip link show wlan0 > /dev/null 2>&1; then
    echo "  [ERROR] wlan0 not found. Check your wireless interface."
    exit 1
fi
if ip link show wlan0 | grep -q "DOWN"; then
    echo "wlan0 down, setting up..."
    ip link set wlan0 up
else
    echo "wlan0 up"
fi

rc-update add networking boot

# Services will fail if the host didn't have an IP.
ip addr add "${DEVICE_IP}/24" dev eth0 2>/dev/null || echo "  eth0 IP already assigned"
ip addr add 192.168.2.1/24 dev wlan0 2>/dev/null || echo "  wlan0 IP already assigned"

echo "[4/4] Enabling and starting services..."
for svc in hostapd crond; do
    rc-update add "$svc" default > /dev/null 2>&1 || true
    rc-service "$svc" start > /dev/null 2>&1 || true
done

# Krill-specific services
cp "$REPO_DIR/etc/init.d/krill-tc" /etc/init.d/krill-tc
chmod +x /etc/init.d/krill-tc
rc-update add krill-tc default > /dev/null 2>&1 || true
rc-service krill-tc start > /dev/null 2>&1 || true

# Configure OpenRC to restart services if they crash.
for svc in hostapd krill-tc; do
    touch /etc/conf.d/"$svc"
    if ! grep -q "rc_crash_action" /etc/conf.d/"$svc" 2>/dev/null; then
        echo 'rc_crash_action="restart"' >> /etc/conf.d/"$svc"
    fi
done

echo "    Installing health checks..."
mkdir -p /usr/local/lib/krill
cp -r "$REPO_DIR/health"/* /usr/local/lib/krill/
ln -sf /usr/local/lib/krill/health.sh /usr/local/bin/krill-health

# Run health check every 5 minutes without overwriting existing crontab.
crontab -l 2>/dev/null | { cat; echo "*/5 * * * * /usr/local/bin/krill-health"; } | crontab - 2>/dev/null || true

trap - EXIT

echo ""
echo "[SUCCESS] Krill setup complete!"
echo "          Run 'iw dev wlan0 info' to verify status."
