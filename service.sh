#!/system/bin/sh
# =============================================================
#  Wireless ADB Toggle - Service Script
#  Runs at boot to sync the description with the real ADB state.
# =============================================================

MODDIR="${0%/*}"
COMMON_SH="$MODDIR/common.sh"

if [ ! -r "$COMMON_SH" ]; then
    echo "[service] Missing common.sh; cannot continue"
    exit 1
fi

LOG_PREFIX="[service]"
. "$COMMON_SH"
init_module_paths "$MODDIR"

# Wait for full boot
if ! wait_for_boot_complete 180; then
    log_info "Boot completion not observed within timeout; syncing status anyway"
fi

CURRENT_PORT="$(get_current_port)"

if [ "$CURRENT_PORT" = "5555" ]; then
    if update_description_all "$DESC_ENABLED"; then
        log_info "Status synced: ENABLED (5555)"
    else
        log_info "Status synced in memory, but description update failed"
    fi
else
    if update_description_all "$DESC_DISABLED"; then
        log_info "Status synced: DISABLED"
    else
        log_info "Status synced in memory, but description update failed"
    fi
fi
