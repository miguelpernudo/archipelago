#!/bin/sh
# shellcheck disable=SC2154  # inherited via set -a from config.sh

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [disk-warn] $*" | tee -a "$LOG"; }

log "Cleaning apk cache and /tmp"
apk cache clean 2>/dev/null || true
find /tmp -mindepth 1 -delete 2>/dev/null || true
