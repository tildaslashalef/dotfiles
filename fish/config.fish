# ==========================================================
# Fish Shell Configuration
# ==========================================================

# ===== Core Environment =====

# Environment variables
set -gx EDITOR nvim
set -gx VISUAL $EDITOR
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# Don't override TERM if it's already set properly by terminal
# This allows Ghostty to use its native terminal type
if not set -q TERM; or test "$TERM" = "dumb"
    set -gx TERM xterm-256color
end

# Shell behavior
set fish_greeting ""                 # Don't show greeting
fish_vi_key_bindings 

set -g fish_history fish
set -gx HISTSIZE 10000
set -gx HISTFILESIZE 10000
set -g fish_history_merge_sessions 1  # Merge history across sessions

# Gruvbox Dark color adjustments
set -g fish_color_normal normal
set -g fish_color_command green --bold
set -g fish_color_param blue
set -g fish_color_quote yellow
set -g fish_color_redirection cyan
set -g fish_color_end green
set -g fish_color_error red --bold
set -g fish_color_selection white --bold --background=brblack
set -g fish_color_search_match bryellow --background=brblack
set -g fish_color_operator cyan
set -g fish_color_escape yellow --bold
set -g fish_color_autosuggestion brblack
set -g fish_pager_color_prefix white --bold --underline
set -g fish_pager_color_description yellow
set -g fish_pager_color_progress brwhite --background=cyan

# ===== Path Configuration =====

# Homebrew paths
if test -d /opt/homebrew/bin
    fish_add_path /opt/homebrew/bin
    fish_add_path /opt/homebrew/sbin
end

# User paths
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/bin

# ===== Development Environments =====

# Go configuration
if type -q go
    set -gx GOROOT /opt/homebrew/opt/go/libexec
    set -gx GOPATH $HOME/.golang
    fish_add_path $GOPATH/bin
    
    # Create Go directory structure if needed
    if not test -d $GOPATH
        mkdir -p $GOPATH/{bin,src,pkg}
    end
end

# Bun configuration
if test -d /opt/homebrew/opt/bun
    fish_add_path /opt/homebrew/opt/bun/bin
    
    # Enable Bun completions if available
    if test -f /opt/homebrew/opt/bun/share/fish/vendor_completions.d/bun.fish
        source /opt/homebrew/opt/bun/share/fish/vendor_completions.d/bun.fish
    end
end

# Python configuration
if type -q python
    # Use Homebrew's Python as default
    if test -d /opt/homebrew/opt/python/libexec/bin
        fish_add_path /opt/homebrew/opt/python/libexec/bin
    end
    
    # Virtual environments directory
    set -gx PYTHON_VENVS_DIR $HOME/.venvs
    
    # Create, activate, or switch to a virtual environment
    function pyvenv
        if test (count $argv) -lt 1
            echo "Usage: pyvenv <env_name> [python_version]"
            return 1
        end
        
        set venv_name $argv[1]
        set venv_path $PYTHON_VENVS_DIR/$venv_name
        
        # Create virtual environment if it doesn't exist
        if not test -d $venv_path
            mkdir -p $PYTHON_VENVS_DIR
            
            if type -q uv
                echo "Creating virtual environment '$venv_name' with uv..."
                uv venv $venv_path
            else
                echo "Creating virtual environment '$venv_name' with standard venv..."
                python -m venv $venv_path
            end
        end
        
        # Activate the environment
        source $venv_path/bin/activate.fish
        echo "Activated virtual environment: $venv_name"
    end
    
    # Package management with uv
    if type -q uv
        function pip
            echo "Using uv for faster Python package management"
            uv pip $argv
        end
    end
end

# ===== Shell Appearance & Integration =====

# Ghostty terminal integration
if test -d "/Applications/Ghostty.app"
    set -gx GHOSTTY_SHELL_INTEGRATION_XDG_DIR /Applications/Ghostty.app/Contents/Resources/ghostty/shell-integration
end

# Starship prompt
if type -q starship
    starship init fish | source
end

# ===== Modern CLI Tools =====

if type -q eza
    # Enhance existing eza aliases
    alias ll='eza -la --group-directories-first --git'
    alias lt='eza --tree --level=2 --group-directories-first'
    alias llt='eza -la --tree --level=2 --group-directories-first'
end

if type -q bat
    alias cat='bat'
    set -gx BAT_THEME "gruvbox-dark"
end

if type -q fd
    alias find='fd'
end

if type -q zoxide
    zoxide init fish | source
    alias cd='z'
end

if type -q fzf
    set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border --info=inline"
    # Initialize fzf for fish
    fzf --fish | source
end

# ===== Utility Functions =====

function cp_safe
    command cp -iv $argv
end

function mv_safe
    command mv -iv $argv
end

function rm_safe
    command rm -iv $argv
end


# ===== Aliases =====

abbr -a dev "cd ~/Code"

# Safety aliases
alias cp="cp_safe"
alias mv="mv_safe"
alias rm="rm_safe"

# General aliases
alias vim='nvim'
alias vi='nvim'
alias g='git'

# Git abbreviations
abbr -a gst 'git st'       # Status with branch info
abbr -a gc 'git commit'   # Commit
abbr -a gco 'git co'      # Checkout or create branch
abbr -a gb 'git br'       # List branches
abbr -a gd 'git diff'     # Diff
abbr -a gds 'git ds'      # Diff staged
abbr -a gl 'git lg'       # Pretty log
abbr -a gpush 'git gpush'     # Push to origin
abbr -a gpull 'git gpull'    # Pull from origin
abbr -a ga 'git add'      # Add
abbr -a gaa 'git add -A'  # Add all
abbr -a gsw 'git sw'      # Switch to/create branch
abbr -a greb 'git reb'    # Interactive rebase with the given number of latest commits

alias mkdir='mkdir -p'

# Kubernetes aliases
alias k='kubectl'
alias kctx='kubectx'
alias kns='kubens'
alias kgp='k get pods'
alias kgpw='k get pods -o wide' # get pods with wide output
alias kge="k get events --sort-by='.metadata.creationTimestamp'" # get events sorted by creation timestamp
alias kgew="k get events --watch" # get events and watch for changes
alias kdp='k describe pod'
alias kdelpf='k delete pod --grace-period=0 --force' # delete pod with force
alias kex='k exec -it'
alias klf='k logs -f'
alias ktp='k top pod'
alias ktps='k top pod --sort-by=cpu'
alias ktpm='k top pod --sort-by=memory'


# ===== Local Configuration =====

# Load sensitive configuration not pushed to the repo
if test -f $HOME/.config/fish/local.fish
    source $HOME/.config/fish/local.fish
end 