#!/bin/bash
# Set up Claude config and kernel dev environment on a fresh machine.
#
# Usage: ./setup.sh [/path/to/linux/kernel]
#   Default kernel path: ~/dev/linux
#
# Prerequisites:
#   - Claude Code CLI installed
#   - Git installed
#   - review-prompts cloned (see below)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KERNEL_PATH="${1:-$HOME/dev/linux}"
CLAUDE_DIR="$HOME/.claude"

echo "==> Setting up Claude config"
echo "    Kernel path: $KERNEL_PATH"

# ~/.claude/settings.json
cp "$SCRIPT_DIR/claude/settings.json" "$CLAUDE_DIR/settings.json"
echo "    Installed settings.json"

# ~/.claude/commands/ (slash commands)
mkdir -p "$CLAUDE_DIR/commands"
cp "$SCRIPT_DIR/claude/commands/"*.md "$CLAUDE_DIR/commands/"
echo "    Installed slash commands"

# ~/.claude/skills/kernel/
mkdir -p "$CLAUDE_DIR/skills/kernel"
cp "$SCRIPT_DIR/claude/skills/kernel/SKILL.md" "$CLAUDE_DIR/skills/kernel/SKILL.md"
echo "    Installed kernel skill"

# Memory directory path is derived from the kernel path:
#   /home/user/dev/linux -> -home-user-dev-linux
MEM_KEY=$(echo "$KERNEL_PATH" | sed 's|/|-|g')
MEM_DIR="$CLAUDE_DIR/projects/$MEM_KEY/memory"
mkdir -p "$MEM_DIR"
cp "$SCRIPT_DIR/claude/memory/"*.md "$MEM_DIR/"
echo "    Installed memory files -> $MEM_DIR"

echo ""
echo "==> Shell scripts"
echo "    Copy build-matrix.sh, build.sh, checkpatch-series.sh,"
echo "    check-series.sh, llvm.sh to your kernel tree manually, e.g.:"
echo "    cp $SCRIPT_DIR/*.sh $KERNEL_PATH/"

echo ""
echo "==> review-prompts"
REVIEW_PROMPTS_DIR="$(dirname "$KERNEL_PATH")/../dev/review-prompts"
if [ ! -d "$HOME/dev/review-prompts/.git" ]; then
    echo "    Clone with:"
    echo "    git clone https://github.com/masoncl/review-prompts ~/dev/review-prompts"
else
    echo "    Already present at ~/dev/review-prompts"
fi

echo ""
echo "==> Done. Open a new Claude Code session in $KERNEL_PATH to verify."
