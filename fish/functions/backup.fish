function backup -d "Create a backup copy of a file or directory"
    set timestamp (date +"%Y%m%d_%H%M%S")
    
    for item in $argv
        if test -e $item
            set backup_name "$item.$timestamp.bak"
            cp -r $item $backup_name
            echo "Created backup: $backup_name"
        else
            echo "Error: $item does not exist"
        end
    end
end 