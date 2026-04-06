#!/system/bin/sh
# Shared helpers for Wireless ADB Toggle scripts.

DESC_ENABLED="✅ Wireless ADB is ENABLED on port 5555. Tap Action to disable wireless debugging."
DESC_DISABLED="❌ Wireless ADB is DISABLED. Tap Action to enable wireless debugging on port 5555."

# Logging helpers: wrap long messages for Magisk log window if possible.
# Set `LOG_WRAP_WIDTH` in scripts to override (default 40 columns).
LOG_WRAP_WIDTH="${LOG_WRAP_WIDTH:-40}"

wrap_text() {
    width="$1"
    if [ -z "$width" ]; then
        width="$LOG_WRAP_WIDTH"
    fi
    if command -v fold >/dev/null 2>&1; then
        fold -s -w "$width"
    elif command -v sed >/dev/null 2>&1; then
        sed "s/.\{${width}\}/&\\n/g"
    else
        cat
    fi
}

log_with_level() {
    level="$1"
    shift
    msg="$*"
    prefix=""
    if [ -n "$LOG_PREFIX" ]; then
        prefix="$LOG_PREFIX "
    fi
    header="$prefix[$level] "
    header_len=${#header}
    printf '%s\n' "$msg" | wrap_text "$LOG_WRAP_WIDTH" | while IFS= read -r line; do
        if [ "${first_line:-1}" -eq 1 ]; then
            printf "%s%s\n" "$header" "$line"
            first_line=0
        else
            printf "%*s%s\n" "$header_len" "" "$line"
        fi
    done
    # Add an empty line after each logical log entry for readability
    printf "\n"
}

log_info() { log_with_level "INFO" "$*"; }
log_warn() { log_with_level "WARN" "$*"; }
log_ok()   { log_with_level "OK"   "$*"; }
log_err()  { log_with_level "ERR"  "$*"; }
log_note() { log_with_level "NOTE" "$*"; }

init_module_paths() {
    MODDIR="$1"
    PROP_FILE="$MODDIR/module.prop"
    MODID="${MODDIR##*/}"
    MODULE_PARENT="$(dirname "$(dirname "$MODDIR")")"
    ALT_PROP_FILE=""

    case "$(basename "$(dirname "$MODDIR")")" in
        modules)
            ALT_PROP_FILE="$MODULE_PARENT/modules_update/$MODID/module.prop"
            ;;
        modules_update)
            ALT_PROP_FILE="$MODULE_PARENT/modules/$MODID/module.prop"
            ;;
    esac
}

escape_sed_replacement() {
    printf '%s' "$1" | sed 's/[\\&#]/\\&/g'
}

set_description_in_file() {
    target_file="$1"
    new_desc="$2"

    if [ ! -f "$target_file" ]; then
        return 1
    fi

    escaped_desc="$(escape_sed_replacement "$new_desc")"
    sed -i "s#^description=.*#description=$escaped_desc#" "$target_file"
}

update_description_all() {
    new_desc="$1"
    updated_count=0

    if set_description_in_file "$PROP_FILE" "$new_desc"; then
        updated_count=$((updated_count + 1))
    fi

    if [ -n "$ALT_PROP_FILE" ] && [ "$ALT_PROP_FILE" != "$PROP_FILE" ]; then
        if set_description_in_file "$ALT_PROP_FILE" "$new_desc"; then
            updated_count=$((updated_count + 1))
        fi
    fi

    [ "$updated_count" -gt 0 ]
}

get_current_port() {
    getprop service.adb.tcp.port 2>/dev/null
}

wait_for_boot_complete() {
    timeout_secs="$1"
    elapsed=0

    while [ "$(getprop sys.boot_completed 2>/dev/null)" != "1" ]; do
        if [ "$elapsed" -ge "$timeout_secs" ]; then
            return 1
        fi
        sleep 2
        elapsed=$((elapsed + 2))
    done

    return 0
}
