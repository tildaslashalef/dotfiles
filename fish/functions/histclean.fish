function histclean --description "Clear fish history in all sessions"
    echo "Clearing fish command history in all sessions..."
    
    # Path to fish history file
    set -l history_file ~/.local/share/fish/fish_history
    
    # Check if history file exists
    if test -f $history_file
        # Create backup before clearing (just in case)
        set -l backup_file "$history_file.bak"
        cp -f $history_file $backup_file
        
        # Truncate the history file
        echo -n "" > $history_file
        
        # Clear the current session's history
        history clear
        
        set_color green
        echo "✓ Fish history has been cleared across all sessions"
        echo "  A backup was saved to $backup_file"
        set_color normal
    else
        set_color yellow
        echo "No history file found at $history_file"
        set_color normal
    end
end 