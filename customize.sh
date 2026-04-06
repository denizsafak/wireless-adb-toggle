#!/system/bin/sh
# =============================================================
#  Wireless ADB Toggle - Installer
#  Note: Do NOT call exit here (Magisk requirement)
# =============================================================

COMMON_SH="$MODPATH/common.sh"

if [ ! -r "$COMMON_SH" ]; then
    abort "common.sh is missing from the module package"
fi

. "$COMMON_SH"
init_module_paths "$MODPATH"

line() {
    ui_print ""
}

line
ui_print "   Wireless ADB Toggle"
ui_print "   Install script started"
line
ui_print "   Use 'Action' in Magisk to toggle ADB over Wi-Fi"
line

# Make scripts executable
set_perm "$MODPATH/action.sh"  root root 0755
set_perm "$MODPATH/service.sh" root root 0755
set_perm "$MODPATH/common.sh"  root root 0755

# Set the correct description right now based on current state
# so the user sees the real status immediately after install.
CURRENT_PORT="$(get_current_port)"
if [ "$CURRENT_PORT" = "5555" ]; then
    update_description_all "$DESC_ENABLED"
    ui_print "   Current status: ENABLED (port 5555)"
else
    update_description_all "$DESC_DISABLED"
    ui_print "   Current status: DISABLED"
fi

line
ui_print "   Installation complete"
line
