### copy the driver file
copy com.gt.grive.plist ~/Library/LaunchAgents/

### install driver
launchctl load ~/Library/LaunchAgents/com.gt.grive.plist

### uninstall driver
launchctl unload ~/Library/LaunchAgents/com.gt.grive.plist

## view logs
tail -f /tmp/grive* 