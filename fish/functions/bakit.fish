function bakit -d "Create a backup copy of a file or directory"
    # Parse arguments and set defaults
    set -l compress false
    set -l dest_dir ""
    set -l verbose true
    set -l items

    # Process options
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case -h --help
                echo "Usage: bakit [options] file1 [file2...]"
                echo ""
                echo "Options:"
                echo "  -c, --compress    Create compressed backup (.tar.gz)"
                echo "  -d, --dest DIR    Place backups in specified directory"
                echo "  -q, --quiet       Suppress output messages"
                echo "  -h, --help        Show this help message"
                echo ""
                echo "Examples:"
                echo "  bakit config.txt                # Creates config.txt.20230401_120000.bak"
                echo "  bakit -c important_folder       # Creates compressed backup"
                echo "  bakit -d ~/backups file.txt     # Stores backup in ~/backups directory"
                return 0
            case -c --compress
                set compress true
            case -d --dest
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set dest_dir $argv[$i]
                    # Create destination directory if it doesn't exist
                    if not test -d $dest_dir
                        mkdir -p $dest_dir
                        or begin
                            echo "Error: Could not create destination directory: $dest_dir"
                            return 1
                        end
                    end
                else
                    echo "Error: No destination directory specified after -d/--dest"
                    return 1
                end
            case -q --quiet
                set verbose false
            case '*'
                set -a items $argv[$i]
        end
        set i (math $i + 1)
    end

    # Check if we have files to backup
    if test (count $items) -eq 0
        echo "Error: No files specified for backup"
        echo "Use 'bakit --help' for usage information"
        return 1
    end

    set timestamp (date +"%Y%m%d_%H%M%S")
    set -l success_count 0
    set -l failed_count 0
    
    for item in $items
        if test -e $item
            # Get absolute paths to handle the backup correctly
            set -l item_abs_path (realpath $item)
            set -l item_name (basename $item_abs_path)
            set -l item_dir (dirname $item_abs_path)
            
            if test -n "$dest_dir"
                set backup_path (realpath "$dest_dir")/"$item_name.$timestamp"
            else
                set backup_path "$item_abs_path.$timestamp"
            end
            
            if test $compress = true
                # Create compressed backup
                set backup_name "$backup_path.tar.gz"
                
                if test -d $item_abs_path
                    # Use directory's parent to avoid "Can't add archive to itself" error
                    pushd $item_dir
                    tar -czf $backup_name $item_name
                    set tar_status $status
                    popd
                else
                    # For files, use the parent directory as well
                    pushd $item_dir
                    tar -czf $backup_name $item_name
                    set tar_status $status
                    popd
                end
                
                if test $tar_status -eq 0
                    set success_count (math $success_count + 1)
                    test $verbose = true; and echo "✅ Created compressed backup: $backup_name"
                else
                    set failed_count (math $failed_count + 1)
                    test $verbose = true; and echo "❌ Failed to create compressed backup of $item"
                end
            else
                # Create regular backup copy
                set backup_name "$backup_path.bak"
                
                if cp -r $item_abs_path $backup_name
                    set success_count (math $success_count + 1)
                    test $verbose = true; and echo "✅ Created backup: $backup_name"
                else
                    set failed_count (math $failed_count + 1)
                    test $verbose = true; and echo "❌ Failed to create backup of $item"
                end
            end
        else
            set failed_count (math $failed_count + 1)
            test $verbose = true; and echo "❌ Error: $item does not exist"
        end
    end
    
    # Print summary for multiple items
    if test (count $items) -gt 1; and test $verbose = true
        echo "📊 Summary: $success_count backup(s) created, $failed_count failed"
    end
    
    # Return success if all backups succeeded
    if test $failed_count -eq 0
        return 0
    else
        return 1
    end
end 