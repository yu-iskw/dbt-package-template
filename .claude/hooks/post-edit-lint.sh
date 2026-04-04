#!/usr/bin/env bash
# PostToolUse hook: run pre-commit on the edited file for lintable extensions.
# Input: Claude tool call JSON on stdin.
# Always exits 0 (informational only — never blocks Claude).
set -euo pipefail

file_path=$(python3 -c "
import json, sys
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('file_path', ''))
" 2>/dev/null || true)

if [[ -z "$file_path" ]]; then
  exit 0
fi

# Only lint files with these extensions
case "$file_path" in
  *.sql|*.yml|*.yaml|*.md|*.sh|*.json) ;;
  *) exit 0 ;;
esac

# Run pre-commit on the specific file; show output but never block
uv run --group dev pre-commit run --files "$file_path" 2>&1 || true
