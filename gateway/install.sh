#!/bin/sh

# This script configures the services so that 
# Pathfinder acts as an access point.
# Alpine Linux is expected (openrc and apk).

set -e

[ "$(id -u)" -eq 0 ] || { echo "This script must be run as root."; exit 1; }

# shellcheck disable=SC2154
trap 'ret=$?; [ $ret -ne 0 ] && echo "  [ERROR] Script failed with code $ret." >&2' EXIT

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[1/7] Installing packages..."

# This enables the community repo, required for dnscrypt-proxy.
sed -i 's|#http://dl-cdn.alpinelinux.org/alpine/\(v[0-9.]*\)/community|http://dl-cdn.alpinelinux.org/alpine/\1/community|' /etc/apk/repositories
apk update

apk add --no-cache hostapd dnsmasq dnscrypt-proxy nftables iw logrotate gettext tcpdump wget

# This is crucial for routing to work, 
# it forwards packets from wlan0 to eth0.
echo "[2/7] Configuring IP forwarding..."
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-forwarding.conf
sysctl -p /etc/sysctl.d/99-forwarding.conf > /dev/null

echo "[3/7] Setting up configuration files..."
mkdir -p /etc/hostapd /etc/dnscrypt-proxy /etc/network

[ -f "$REPO_DIR/secrets.env" ] || { echo "  [ERROR] Missing secrets.env. Copy secrets.env.example and edit it."; exit 1; }
. "$REPO_DIR/secrets.env"
: "${WPA_PASSPHRASE:?}" "${DEVICE_IP:?}" "${GATEWAY:?}"
export WPA_PASSPHRASE DEVICE_IP GATEWAY

envsubst < "$REPO_DIR/etc/hostapd/hostapd.conf" > /etc/hostapd/hostapd.conf
envsubst < "$REPO_DIR/etc/network/interfaces" > /etc/network/interfaces
cp "$REPO_DIR/etc/dnsmasq.conf" /etc/dnsmasq.conf
cp "$REPO_DIR/etc/dnscrypt-proxy/dnscrypt-proxy.toml" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
cp "$REPO_DIR/etc/nftables.nft"               /etc/nftables.nft
cp "$REPO_DIR/etc/logrotate.d/dnscrypt-proxy" /etc/logrotate.d/dnscrypt-proxy
cp "$REPO_DIR/etc/logrotate.d/pathfinder"     /etc/logrotate.d/pathfinder
cp "$REPO_DIR/etc/tc.qos"                     /etc/tc.qos
chmod +x /etc/tc.qos

echo "[4/7] Installing blocklist..."
wget -q -O /etc/dnscrypt-proxy/blocked-names.txt https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/pro.txt || echo "  [WARNING] Blocklist download failed."

if [ ! -s /etc/dnscrypt-proxy/blocked-names.txt ]; then
    echo "  [WARNING] Blocklist file is empty. Continuing without it."
fi

# Check wlan0 state.
echo "[5/7] Checking wlan0..."
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

echo "[6/7] Enabling and starting services..."
for svc in hostapd dnsmasq dnscrypt-proxy nftables crond; do
    rc-update add "$svc" default > /dev/null 2>&1 || true
    rc-service "$svc" start > /dev/null 2>&1 || true
done

# Pathfinder-specific services
cp "$REPO_DIR/etc/init.d/pathfinder-tc" /etc/init.d/pathfinder-tc
chmod +x /etc/init.d/pathfinder-tc
rc-update add pathfinder-tc default > /dev/null 2>&1 || true
rc-service pathfinder-tc start > /dev/null 2>&1 || true

# Give dnscrypt-proxy time to load the blocklist before testing it.
sleep 2
test_domain="doubleclick.net"
if nslookup "$test_domain" 127.0.0.1 > /dev/null 2>&1; then
    echo "  [WARNING] $test_domain resolved. Blocklist may not be filtering."
else
    echo "  Blocklist test: $test_domain blocked correctly."
fi

# Configure OpenRC to restart services if they crash.
for svc in hostapd dnsmasq dnscrypt-proxy nftables pathfinder-tc; do
    touch /etc/conf.d/"$svc"
    if ! grep -q "rc_crash_action" /etc/conf.d/"$svc" 2>/dev/null; then
        echo 'rc_crash_action="restart"' >> /etc/conf.d/"$svc"
    fi
done

echo "[7/7] Installing health checks..."
mkdir -p /usr/local/lib/pathfinder
cp -r "$REPO_DIR/health"/* /usr/local/lib/pathfinder/
ln -sf /usr/local/lib/pathfinder/health.sh /usr/local/bin/pathfinder-health

# Run health check every 5 minutes without overwriting existing crontab.
crontab -l 2>/dev/null | { cat; echo "*/5 * * * * /usr/local/bin/pathfinder-health"; } | crontab - 2>/dev/null || true

trap - EXIT

echo ""
echo "[SUCCESS] Pathfinder setup complete!"
echo "          Run 'iw dev wlan0 info' to verify status."
