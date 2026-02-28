# Overnight Mayor Cron Job Setup

## Script Location
```
/Users/jamesbeach/Documents/visual-studio-code/github-copilot/gastown/scripts/overnight-mayor.sh
```

## To Schedule for 12:10 AM Tonight

### Option 1: Cron (simpler)
```bash
# Edit crontab
crontab -e

# Add this line (12:10 AM every day):
10 0 * * * /Users/jamesbeach/Documents/visual-studio-code/github-copilot/gastown/scripts/overnight-mayor.sh

# Or one-liner to add it:
(crontab -l 2>/dev/null | grep -v "overnight-mayor"; echo "10 0 * * * /Users/jamesbeach/Documents/visual-studio-code/github-copilot/gastown/scripts/overnight-mayor.sh") | crontab -

# Verify:
crontab -l

# To remove later:
crontab -l | grep -v "overnight-mayor" | crontab -
```

### Option 2: macOS launchd (more reliable, survives reboots)
```bash
# Create plist file
cat > ~/Library/LaunchAgents/com.gastown.overnight-mayor.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.gastown.overnight-mayor</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/jamesbeach/Documents/visual-studio-code/github-copilot/gastown/scripts/overnight-mayor.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>0</integer>
        <key>Minute</key>
        <integer>10</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/Users/jamesbeach/Documents/visual-studio-code/github-copilot/gastown/logs/launchd-stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/jamesbeach/Documents/visual-studio-code/github-copilot/gastown/logs/launchd-stderr.log</string>
</dict>
</plist>
EOF

# Load it
launchctl load ~/Library/LaunchAgents/com.gastown.overnight-mayor.plist

# To unload/disable:
launchctl unload ~/Library/LaunchAgents/com.gastown.overnight-mayor.plist

# To check status:
launchctl list | grep gastown
```

### Option 3: One-time run with `at` command
```bash
# Schedule for specific time tonight
echo "/Users/jamesbeach/Documents/visual-studio-code/github-copilot/gastown/scripts/overnight-mayor.sh" | at 00:10

# List pending jobs:
atq

# Remove a job:
atrm <job_number>
```

## Testing the Script Manually
```bash
# Test run (will start Mayor immediately)
/Users/jamesbeach/Documents/visual-studio-code/github-copilot/gastown/scripts/overnight-mayor.sh

# Check logs
tail -f ~/Documents/visual-studio-code/github-copilot/gastown/logs/overnight-*.log
```

## Monitoring Progress
```bash
# Attach to watch Mayor work
tmux attach -t hq-mayor

# Detach without stopping: Ctrl+B then D

# Check if running
gt mayor status
```

## Notes
- Cron runs in a limited environment - the script sources ~/.zshrc for API keys
- Make sure your Mac doesn't sleep (System Preferences > Energy Saver)
- Claude Code credits reset at midnight Pacific time
