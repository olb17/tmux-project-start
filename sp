#!/bin/bash

# Function to display usage
usage() {
    cat << 'EOF'
sp - Manage tmux sessions for your projects

USAGE:
    sp <directory_name>
    sp -h|--help

DESCRIPTION:
    Creates or joins a tmux session named after the given directory.
    Works seamlessly whether you're inside or outside a tmux session.

BEHAVIOR:
    • If session doesn't exist:
      - Creates a new tmux session named <directory_name>
      - Sets working directory to ~/code/<directory_name>
      - Executes ~/code/<directory_name>/.start_tmux.sh if it exists
      - Attaches to the session (or switches if already in tmux)

    • If session already exists:
      - Simply joins the existing session
      - Does NOT re-run the startup script

EXAMPLES:
    sp my_project    # Create or join "my_project" session
    sp backend       # Create or join "backend" session

NOTES:
    • Avoids nested tmux sessions by using switch-client when inside tmux
    • Startup script path: ~/code/<directory_name>/.start_tmux.sh
    • Startup script is only executed when creating a NEW session

EOF
}

# Check for help flag
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    exit 0
fi

# Get the directory name from argument or fzf
if [ $# -eq 0 ]; then
    # No argument provided, use fzf to select from ~/code
    if ! command -v fzf &> /dev/null; then
        echo "Error: fzf is not installed" >&2
        echo "Please install fzf or provide a directory name" >&2
        echo "Use -h or --help for usage information" >&2
        exit 1
    fi
    
    # Get list of directories in ~/code and let user select with fzf
    my_dir=$(ls -1 "$HOME/code" 2>/dev/null | fzf --prompt="Select project: " --height=40% --reverse)
    
    # Check if user cancelled fzf (Ctrl+C or Esc)
    if [ -z "$my_dir" ]; then
        echo "No project selected" >&2
        exit 1
    fi
else
    my_dir="$1"
fi
session_name="$my_dir"

# Check if target session exists
tmux has-session -t "$session_name" 2>/dev/null

if [ $? != 0 ]; then
    # Session doesn't exist, create it
    echo "Creating new tmux session: $session_name"
    
    # Create new session detached in the project directory
    project_dir="$HOME/code/$my_dir"
    tmux new-session -d -s "$session_name" -c "$project_dir"
    
    # Check if startup script exists and execute it
    startup_script="$project_dir/.start_tmux.sh"
    if [ -f "$startup_script" ]; then
        echo "Executing startup script: $startup_script"
        tmux send-keys -t "$session_name" "bash $startup_script" C-m
    fi
fi

# Switch or attach depending on whether we're inside tmux
if [ -n "$TMUX" ]; then
    # We're inside tmux, switch to the session
    echo "Switching to tmux session: $session_name"
    tmux switch-client -t "$session_name"
else
    # We're not inside tmux, attach to the session
    echo "Attaching to tmux session: $session_name"
    tmux attach-session -t "$session_name"
fi
