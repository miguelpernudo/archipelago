#!/bin/sh
# shellcheck disable=SC2154  # inherited via set -a from config.sh

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [net-critical] $*" | tee -a "$LOG"; }

log "Persistent network failure, bouncing interface"
IFACE="eth0"
ip link set "$IFACE" down
sleep 2
ip link set "$IFACE" up

log "Restarting networking stack"
rc-service networking restart
rc-service hostapd restart
