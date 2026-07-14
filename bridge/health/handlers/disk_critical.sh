#!/bin/sh
# shellcheck disable=SC2154  # inherited via set -a from config.sh

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [disk-critical] $*" | tee -a "$LOG"; }

log "Disk critically full, running full cleanup"
apk cache clean 2>/dev/null || true
rm -rf /tmp/* 2>/dev/null || true
rm -rf /var/cache/apk/* 2>/dev/null || true

find /var/log -name '*.log.*' -mtime +7 -delete 2>/dev/null || true

# dnsmasq removed — DHCP now served by Angler (Kea)

log "Alerting via wall message"
wall "Krill: Disk critically full, services may have been stopped"
