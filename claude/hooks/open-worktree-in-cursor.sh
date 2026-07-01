#!/bin/bash
# Opens the worktree directory in Cursor after EnterWorktree creates it.
# Receives JSON on stdin from Claude Code's PostToolUse hook.

INPUT=$(cat)
WORKTREE_PATH=$(echo "$INPUT" | jq -r '.tool_input.cwd // .session.cwd // empty' 2>/dev/null)

# If we couldn't extract a path from the input, try the tool result
if [ -z "$WORKTREE_PATH" ]; then
  WORKTREE_PATH=$(echo "$INPUT" | jq -r '.tool_result.cwd // empty' 2>/dev/null)
fi

# Fallback: use the current working directory from the session
if [ -z "$WORKTREE_PATH" ]; then
  WORKTREE_PATH=$(echo "$INPUT" | jq -r '.session.cwd // empty' 2>/dev/null)
fi

if [ -n "$WORKTREE_PATH" ] && [ -d "$WORKTREE_PATH" ]; then
  cursor "$WORKTREE_PATH" &
fi

exit 0
