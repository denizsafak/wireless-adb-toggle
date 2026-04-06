# wireless-adb-toggle

A simple Magisk module that turns Wireless ADB on or off from the Magisk **Action** button.

## What It Does
When you tap **Action**:

The Action button acts as a toggle: tapping it enables Wireless ADB if it's currently disabled, or disables it if it's currently enabled.

- **Enable**: it sets ADB to TCP port `5555` and restarts ADB.
- **Disable**: it turns TCP ADB off and restarts ADB.

So it is basically doing the equivalent of:

- `setprop service.adb.tcp.port 5555` (enable) or `-1` (disable)
- then restarting `adbd`

## How To Use

1. Install the module zip in Magisk.
2. Reboot your device.
3. Open Magisk, find **Wireless ADB Toggle**.
4. Tap **Action** to switch ON/OFF.
5. If enabled, connect from PC:
	- `adb connect <phone-ip>:5555`

## Updates

Updates are configured through GitHub releases. Magisk can check for new versions automatically.

If you are publishing a new version:

1. Increase `version` and `versionCode` in `module.prop`.
2. Update `update.json` and `CHANGELOG.md`.
3. Upload release asset as `wireless-adb-toggle.zip`.
