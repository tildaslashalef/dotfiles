function extract -d "Extract various archive formats"
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.gz' '*.tgz'
                tar -xzvf $argv[1]
            case '*.tar.bz2' '*.tbz2'
                tar -xjvf $argv[1]
            case '*.tar.xz' '*.txz'
                tar -xJvf $argv[1]
            case '*.tar'
                tar -xvf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.rar'
                unrar x $argv[1]
            case '*.7z'
                7z x $argv[1]
            case '*'
                echo "Unknown archive format: $argv[1]"
                return 1
        end
    else
        echo "Error: $argv[1] is not a valid file"
        return 1
    end
end 