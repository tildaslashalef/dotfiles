# Dotfiles

My personal dotfiles for macOS setup.

## Included Configurations

- 🖥️ **Terminal**: Ghostty
- 📝 **Editor**: Neovim/Vim
- 🐠 **Shell**: Fish
- 🍺 **Package Manager**: Homebrew
- 🔀 **Version Control**: Git
- ✨ **Prompt**: Starship

## Quick Start

```bash
# Install everything
./scripts/setup.sh

# Preview without changes
./scripts/setup.sh --dry-run

# Show help
./scripts/setup.sh --help

# Uninstall
./scripts/setup.sh uninstall
```

## Setup Options

| Option       | Description                              |
| ------------ | ---------------------------------------- |
| `--dry-run`  | Show changes without making them         |
| `--help`     | Show help message                        |
| `uninstall`  | Remove dotfile configurations            |

The setup script:
- Installs Homebrew if needed
- Installs core tools (fish, neovim, git, ghostty)
- Sets up Fish shell (with confirmation)
- Installs dotfiles
- Installs additional packages from Brewfile

## Manual Installation

```bash
# Clone the repository
git clone https://github.com/tildaslashalef/dotfiles.git
cd dotfiles

# Install all configurations
make install

# Or install specific ones
make install-nvim    # Neovim
make install-vim     # Vim
make install-fish    # Fish
make install-ghostty # Ghostty
make install-brew    # Homebrew bundle
make install-git     # Git
make install-starship # Starship prompt

# Uninstall
make uninstall      # Remove all
make uninstall-nvim # Remove specific config
```
