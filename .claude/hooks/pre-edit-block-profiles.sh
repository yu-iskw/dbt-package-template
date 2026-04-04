#!/usr/bin/env bash
# PreToolUse hook: block writes to integration_tests/profiles/ (connection credentials).
# Input: Claude tool call JSON on stdin.
# Exits 2 to block the tool call with an explanatory message.
set -euo pipefail

file_path=$(python3 -c "
import json, sys
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('file_path', ''))
" 2>/dev/null || true)

if [[ "$file_path" == *"integration_tests/profiles/"* ]]; then
  echo "BLOCKED: integration_tests/profiles/ contains connection credentials. Edit manually if needed."
  exit 2
fi
