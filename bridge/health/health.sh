#!/bin/sh
# shellcheck disable=SC2154  # set -a exports config.sh vars to child procs
set -u

# shellcheck disable=SC2164  # && pwd inside $() handles cd failure
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

set -a
# shellcheck disable=SC1091  # resolved at runtime via SCRIPT_DIR
. "$SCRIPT_DIR/config.sh"
set +a

mkdir -p "$STATE_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"
}

run_check() {
    name=$1
    check=$2
    warn_handler=$3
    critical_handler=$4
    state_file="$STATE_DIR/${name}.count"

    sh "$check"
    status=$?

    if [ "$status" -eq 0 ]; then
        echo 0 > "$state_file"
        return
    fi

    if [ "$status" -eq 2 ]; then
        log "CRITICAL [$name]: immediate action"
        sh "$critical_handler"
        return
    fi

    count=$(cat "$state_file" 2>/dev/null || echo 0)
    count=$((count + 1))
    echo "$count" > "$state_file"
    log "WARN [$name]: failure count $count/$FAILURE_LIMIT"

    if [ "$count" -ge "$FAILURE_LIMIT" ]; then
        log "WARN [$name]: failure limit reached, escalating"
        sh "$critical_handler"
    else
        sh "$warn_handler"
    fi
}

CHECKS="$SCRIPT_DIR/checks"
HANDLERS="$SCRIPT_DIR/handlers"

### DISK
run_check "disk" \
    "$CHECKS/disk.sh" \
    "$HANDLERS/disk_warn.sh" \
    "$HANDLERS/disk_critical.sh"

### SERVICE
run_check "service" \
    "$CHECKS/service.sh" \
    "$HANDLERS/service_warn.sh" \
    "$HANDLERS/service_critical.sh"

### NETWORK
run_check "net" \
    "$CHECKS/net.sh" \
    "$HANDLERS/net_warn.sh" \
    "$HANDLERS/net_critical.sh"
