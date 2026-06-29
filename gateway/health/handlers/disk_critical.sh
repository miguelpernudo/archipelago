#!/bin/sh

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [disk-critical] $*" | tee -a "$LOG"; }

log "Disk critically full, running full cleanup"
apk cache clean 2>/dev/null || true
rm -rf /tmp/* 2>/dev/null || true
rm -rf /var/cache/apk/* 2>/dev/null || true

find /var/log -name '*.log.*' -mtime +7 -delete 2>/dev/null || true

for svc in dnsmasq; do
    if rc-service "$svc" status > /dev/null 2>&1; then
        log "Stopping $svc to free disk resources"
        rc-service "$svc" stop
    fi
done

log "Alerting via wall message"
wall "Pathfinder: Disk critically full, services may have been stopped"
