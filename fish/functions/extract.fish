function extract -d "Extract various archive formats"
    # Show help if no arguments or help flag is provided
    if test (count $argv) -eq 0; or test "$argv[1]" = "--help"; or test "$argv[1]" = "-h"
        echo "Usage: extract [file...]"
        echo "Extract various archive formats."
        echo "Supported formats: tar.gz, tgz, tar.bz2, tbz2, tar.xz, txz, tar, zip, rar, 7z, gz, bz2, xz, Z, deb"
        return 0
    end

    set -l success_count 0
    set -l failed_count 0
    
    for file in $argv
        if not test -f $file
            echo "Error: '$file' is not a valid file"
            set failed_count (math $failed_count + 1)
            continue
        end
        
        echo "📦 Extracting: $file"
        set -l target_dir (string replace -r '\.(tar\.gz|tgz|tar\.bz2|tbz2|tar\.xz|txz|tar|zip|rar|7z|gz|bz2|xz|Z|deb)$' '' $file)
        
        # Create a directory for the extraction if it doesn't exist
        if not test -d $target_dir
            mkdir -p $target_dir
        end
        
        pushd $target_dir
        
        switch $file
            case '*.tar.gz' '*.tgz'
                tar -xzf ../$file
            case '*.tar.bz2' '*.tbz2'
                tar -xjf ../$file
            case '*.tar.xz' '*.txz'
                tar -xJf ../$file
            case '*.tar'
                tar -xf ../$file
            case '*.zip'
                unzip -q ../$file
            case '*.rar'
                if type -q unrar
                    unrar x ../$file
                else
                    echo "⚠️  unrar command not found. Please install unrar."
                    set failed_count (math $failed_count + 1)
                    popd
                    rmdir $target_dir
                    continue
                end
            case '*.7z'
                if type -q 7z
                    7z x ../$file
                else
                    echo "⚠️  7z command not found. Please install p7zip."
                    set failed_count (math $failed_count + 1)
                    popd
                    rmdir $target_dir
                    continue
                end
            case '*.gz'
                gunzip -c ../$file > (basename $file .gz)
            case '*.bz2'
                bunzip2 -c ../$file > (basename $file .bz2)
            case '*.xz'
                unxz -c ../$file > (basename $file .xz)
            case '*.Z'
                uncompress ../$file
            case '*.deb'
                if type -q ar
                    ar x ../$file
                else
                    echo "⚠️  ar command not found. Cannot extract deb package."
                    set failed_count (math $failed_count + 1)
                    popd
                    rmdir $target_dir
                    continue
                end
            case '*'
                echo "⚠️  Unknown archive format: $file"
                set failed_count (math $failed_count + 1)
                popd
                rmdir $target_dir
                continue
        end
        
        popd
        
        # Check if extraction was successful
        if test $status -eq 0
            echo "✅ Successfully extracted $file to $target_dir/"
            set success_count (math $success_count + 1)
        else
            echo "❌ Failed to extract $file"
            set failed_count (math $failed_count + 1)
            # Cleanup empty directory
            if test -d $target_dir; and test (count (ls -A $target_dir)) -eq 0
                rmdir $target_dir
            end
        end
    end
    
    # Summary
    if test (count $argv) -gt 1
        echo "📊 Summary: Extracted $success_count file(s), failed $failed_count file(s)"
    end
    
    # Return appropriate status code
    if test $failed_count -eq 0
        return 0
    else
        return 1
    end
end 