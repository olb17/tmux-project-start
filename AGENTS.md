# Agent Guidelines

## Project Overview
This is a bash script project for tmux session management.

## Testing & Validation
- **Syntax check**: `bash -n sp`
- **ShellCheck**: `shellcheck sp` (if available)
- **Manual test**: `./sp -h` (shows usage), `./sp test_dir`

## Code Style
- Use `#!/bin/bash` shebang (not sh)
- Quote variables: `"$variable"` not `$variable`
- Use `[ ]` for conditions, check exit codes with `$?`
- Indentation: 4 spaces
- Use heredocs for multiline text (see usage function example)
- Add descriptive comments for non-obvious logic
- Error handling: Check command exit codes before proceeding
- Use lowercase for local variables, UPPERCASE for environment variables

## File Structure
- Main script: `sp` (executable)
