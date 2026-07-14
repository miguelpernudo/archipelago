#!/bin/sh
# shellcheck disable=SC2154  # inherited via set -a from config.sh

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [service-critical] $*" | tee -a "$LOG"; }

log "Multiple services down, restarting all"
for svc in hostapd; do
    rc-service "$svc" restart
done

log "Bouncing wlan0 interface"
ip link set wlan0 down
sleep 1
ip link set wlan0 up
