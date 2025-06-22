function histclr --description "Clear fish history in all sessions"
    echo "Clearing fish command history in all sessions..."
    
    # Path to fish history file
    set -l history_file ~/.local/share/fish/fish_history
    
    # Check if history file exists
    if test -f $history_file
        # Truncate the history file
        echo -n "" > $history_file
        
        # Clear the current session's history
        history clear
        
        set_color green
        echo "✓ Fish history has been cleared across all sessions"
        set_color normal
    else
        set_color yellow
        echo "No history file found at $history_file"
        set_color normal
    end
end 