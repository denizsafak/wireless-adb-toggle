#!/system/bin/sh
# =============================================================
#  Wireless ADB Toggle - Action Script
#  Triggered by the "Action" button in the Magisk app.
#  Requires Magisk v28.0+
# =============================================================

MODDIR="${0%/*}"
COMMON_SH="$MODDIR/common.sh"

if [ ! -r "$COMMON_SH" ]; then
    echo "[ERR ] Missing common.sh; cannot continue"
    exit 1
fi

. "$COMMON_SH"
init_module_paths "$MODDIR"

require_root() {
    [ "$(id -u 2>/dev/null)" = "0" ]
}

cleanup_lock() {
    rmdir "$LOCK_DIR" 2>/dev/null
}

if ! require_root; then
    log_err "This action must run as root"
    exit 1
fi

LOCK_DIR="$MODDIR/.action.lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    log_warn "Another toggle action is already running. Try again in a moment."
    exit 1
fi
trap cleanup_lock EXIT INT TERM

CURRENT_PORT="$(get_current_port)"
log_info "Current ADB TCP port: ${CURRENT_PORT:--1}"

if [ "$CURRENT_PORT" = "5555" ]; then
    TARGET_PORT="-1"
    TARGET_DESC="$DESC_DISABLED"
    TARGET_LABEL="DISABLED"
else
    TARGET_PORT="5555"
    TARGET_DESC="$DESC_ENABLED"
    TARGET_LABEL="ENABLED on port 5555"
fi

log_info "Switching Wireless ADB state to: $TARGET_LABEL"
if ! setprop service.adb.tcp.port "$TARGET_PORT"; then
    log_err "Failed to set service.adb.tcp.port to $TARGET_PORT"
    exit 1
fi

if ! stop adbd >/dev/null 2>&1; then
    log_warn "Could not stop adbd cleanly; continuing"
fi

if ! start adbd >/dev/null 2>&1; then
    log_err "Failed to start adbd"
    exit 1
fi

NEW_PORT="$(get_current_port)"

if ! update_description_all "$TARGET_DESC"; then
    log_err "Could not update module status text"
fi

if [ "$TARGET_PORT" = "5555" ]; then
    if [ "$NEW_PORT" = "5555" ]; then
        log_ok "Wireless ADB is ENABLED on port 5555"
        log_info "Connect with: adb connect <device-ip>:5555"
    else
        log_warn "ADB property did not return 5555 immediately"
    fi
else
    if [ "$NEW_PORT" = "5555" ]; then
        log_err "Wireless ADB still reports port 5555"
    else
        log_ok "Wireless ADB is DISABLED"
    fi
fi

log_note "You don’t need to enable Wireless Debugging in Developer Options. Running 'adb tcpip 5555' already opens port 5555 for ADB connections. This module essentially performs the same action, so enabling Wireless Debugging in Developer Options is unnecessary."

 
