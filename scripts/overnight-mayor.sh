#!/bin/bash
# Overnight Mayor - Start Gastown Mayor to work on fractasy
# Scheduled via launchd/cron to run when Claude Code credits refresh

set -e

# Load environment (API keys, PATH)
source ~/.zshrc 2>/dev/null || source ~/.bashrc 2>/dev/null || true

# Ensure we're in the right directory
cd /Users/jamesbeach/Documents/visual-studio-code/github-copilot/gastown

# Log file for debugging
LOG_FILE="$HOME/Documents/visual-studio-code/github-copilot/gastown/logs/overnight-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$(dirname "$LOG_FILE")"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Overnight Mayor Starting at $(date) ==="

# Check if Mayor is already running
if tmux has-session -t hq-mayor 2>/dev/null; then
    echo "Mayor session already exists, killing it first..."
    gt mayor stop 2>/dev/null || tmux kill-session -t hq-mayor 2>/dev/null || true
    sleep 2
fi

# Send instructions to Mayor via mail before starting
echo "Sending work instructions to Mayor mailbox..."
cat > mayor/mail/overnight-work.md << 'EOF'
# Overnight Work Session

You have been started automatically to continue work on the **fractasy** project.

## Priority Tasks

1. **fr-kzw** - PNG/SVG export service (P2)
   - Create `lib/services/export/export_service.dart`
   - Implement PNG export using Flutter's image APIs
   - Implement SVG export for vector output
   - Wire up to the stub dialogs in `home_screen.dart`

2. **fr-svv** - Fix Flutter deprecation warnings (P3)

## Instructions

1. Run `gt prime` to load full context
2. Check `bd ready` for available work
3. Work on fractasy rig: `cd fractasy/crew/james`
4. Create polecats as needed for parallel work
5. Commit and push changes regularly
6. If you hit rate limits, save state and exit cleanly

## Constraints

- This is an unattended session - make autonomous decisions
- Prioritize completing fr-kzw (export feature)
- Run `flutter analyze` before committing
- Push all work to origin before session ends

Good luck! 🚀
EOF

echo "Starting Mayor with Claude..."
gt mayor start

# Give Mayor time to initialize and read mail
sleep 10

# Send the work prompt directly to the tmux session
echo "Injecting work prompt..."
tmux send-keys -t hq-mayor "Read the mail in mayor/mail/overnight-work.md and begin working on the fractasy project. Start with gt prime, then tackle fr-kzw (PNG/SVG export)." Enter

echo "=== Mayor started successfully at $(date) ==="
echo "Check progress with: tmux attach -t hq-mayor"
echo "Or view logs: tail -f $LOG_FILE"
