#!/bin/bash

# Setup script for dotfiles

set -e

# Help options
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: ./setup.sh [options]"
    echo "Options:"
    echo "  --dry-run    Show what would be done without making any changes"
    echo "  --help       Show this help message"
    echo "  uninstall    Remove dotfile configurations"
    exit 0
fi

# Uninstall option
if [[ "$1" == "uninstall" ]]; then
    echo "This will remove dotfile configurations. Continue? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        make uninstall
        echo "Dotfiles uninstalled"
    fi
    exit 0
fi

# Parse other options
DRY_RUN=false

for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            echo "Running in dry-run mode. No changes will be made."
            ;;
    esac
done

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    if $DRY_RUN; then
        echo "[DRY RUN] Would install Homebrew"
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for the current session
        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
else
    echo "Homebrew is already installed."
    echo "Updating Homebrew..."
    if $DRY_RUN; then
        echo "[DRY RUN] Would update Homebrew"
    else
        brew update
    fi
fi


# Install core dependencies first
echo "Installing core dependencies..."
if $DRY_RUN; then
    echo "[DRY RUN] Would install: fish neovim git make ghostty"
else
    brew install fish neovim git make || { echo "Failed to install core dependencies"; exit 1; }
fi

# Set up Fish as default shell if it's not already
if ! grep -q "$(which fish)" /etc/shells; then
    echo "Adding Fish to /etc/shells..."
    if $DRY_RUN; then
        echo "[DRY RUN] Would add Fish to /etc/shells"
    else
        echo "$(which fish)" | sudo tee -a /etc/shells || { echo "Failed to add Fish to /etc/shells"; exit 1; }
    fi
fi

if [[ "$SHELL" != "$(which fish)" ]]; then
    if $DRY_RUN; then
        echo "[DRY RUN] Would prompt to change default shell to Fish"
    else
        read -p "Set Fish as default shell? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            chsh -s "$(which fish)" || { echo "Failed to change default shell"; exit 1; }
            echo "Shell changed to Fish. Will take effect after restart."
        else
            echo "Shell unchanged."
        fi
    fi
fi

# Run make to set up all configurations
echo "Setting up dotfiles..."
if $DRY_RUN; then
    echo "[DRY RUN] Would run: make install"
else
    make install || { echo "Failed to install dotfiles"; exit 1; }
fi

# Check for Brewfile existence
if [ ! -f ~/Brewfile ]; then
    echo "Warning: Brewfile not found at ~/Brewfile"
    if [ -f "$PWD/homebrew/Brewfile" ]; then
        if $DRY_RUN; then
            echo "[DRY RUN] Would prompt to use default Brewfile"
            echo "[DRY RUN] Would copy $PWD/homebrew/Brewfile to ~/Brewfile"
            # In dry run, assume yes for demonstration purposes
            INSTALL_PACKAGES=true
        else
            read -p "Use default Brewfile from repo? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                cp "$PWD/homebrew/Brewfile" ~/Brewfile
                echo "Copied default Brewfile to home directory."
            else
                echo "Skipping additional package installation."
                INSTALL_PACKAGES=false
            fi
        fi
    else
        echo "No default Brewfile found. Skipping additional package installation."
        INSTALL_PACKAGES=false
    fi
fi

# Install additional Homebrew packages
if [ "${INSTALL_PACKAGES:-true}" = true ]; then
    echo "Installing Homebrew packages..."
    if $DRY_RUN; then
        echo "[DRY RUN] Would run: brew bundle --file=~/Brewfile"
    else
        brew bundle --file=~/Brewfile || echo "Some packages failed to install."
    fi
fi

# Verify installation
echo "Verifying installation..."
echo "✓ Dotfiles installation completed"

if command -v fish &>/dev/null; then
    echo "✓ Fish shell is installed"
else
    echo "⚠ Fish shell may not be installed correctly"
fi

if command -v nvim &>/dev/null; then
    echo "✓ Neovim is installed"
else
    echo "⚠ Neovim may not be installed correctly"
fi

if command -v ghostty &>/dev/null; then
    echo "✓ Ghostty is installed"
else
    echo "⚠ Ghostty may not be installed correctly"
fi

if command -v starship &>/dev/null; then
    echo "✓ Starship is installed"
else
    echo "⚠ Starship may not be installed correctly"
fi

if command -v git &>/dev/null; then
    echo "✓ Git is installed"
else
    echo "⚠ Git may not be installed correctly"
fi

echo "Setup complete! Please restart your terminal." 