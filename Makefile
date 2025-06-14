.PHONY: all install-nvim uninstall-nvim install-vim uninstall-vim install-fish uninstall-fish install-ghostty uninstall-ghostty install-brew uninstall-brew install-git uninstall-git install-starship uninstall-starship

all: install-nvim install-vim install-fish install-ghostty install-brew install-git install-starship

# Neovim configuration
install-nvim:
	@echo "Installing Neovim configuration..."
	mkdir -p ~/.config
	ln -sf $(CURDIR)/nvim ~/.config/nvim
	@echo "Neovim configuration installed."

uninstall-nvim:
	@echo "Uninstalling Neovim configuration..."
	rm -f ~/.config/nvim
	@echo "Neovim configuration uninstalled."

# Vim configuration
install-vim:
	@echo "Installing Vim configuration..."
	ln -sf $(CURDIR)/vim/vimrc ~/.vimrc
	@echo "Vim configuration installed."

uninstall-vim:
	@echo "Uninstalling Vim configuration..."
	rm -f ~/.vimrc
	@echo "Vim configuration uninstalled."

# Fish configuration
install-fish:
	@echo "Installing Fish configuration..."
	mkdir -p ~/.config
	ln -sf $(CURDIR)/fish ~/.config/fish
	@echo "Fish configuration installed."

uninstall-fish:
	@echo "Uninstalling Fish configuration..."
	rm -f ~/.config/fish
	@echo "Fish configuration uninstalled."

# Ghostty configuration
install-ghostty:
	@echo "Installing Ghostty configuration..."
	mkdir -p ~/.config
	ln -sf $(CURDIR)/ghostty ~/.config/ghostty
	@echo "Ghostty configuration installed."

uninstall-ghostty:
	@echo "Uninstalling Ghostty configuration..."
	rm -f ~/.config/ghostty
	@echo "Ghostty configuration uninstalled."

# Homebrew configuration
install-brew:
	@echo "Installing Homebrew bundle..."
	ln -sf $(CURDIR)/homebrew/Brewfile ~/Brewfile
	@echo "Homebrew bundle installed. Run 'brew bundle' to install packages."

uninstall-brew:
	@echo "Uninstalling Homebrew bundle..."
	rm -f ~/Brewfile
	@echo "Homebrew bundle uninstalled."

# Git configuration
install-git:
	@echo "Installing Git configuration..."
	ln -sf $(CURDIR)/git/gitconfig ~/.gitconfig
	ln -sf $(CURDIR)/git/gitignore ~/.gitignore
	ln -sf $(CURDIR)/git/pr_template.md ~/.pr_template.md
	ln -sf $(CURDIR)/git/themes.gitconfig ~/.themes.gitconfig
	@echo "Git configuration installed."

uninstall-git:
	@echo "Uninstalling Git configuration..."
	rm -f ~/.gitconfig
	rm -f ~/.gitignore
	rm -f ~/.pr_template.md
	rm -f ~/.themes.gitconfig
	@echo "Git configuration uninstalled."

# Starship configuration
install-starship:
	@echo "Installing Starship configuration..."
	mkdir -p ~/.config
	ln -sf $(CURDIR)/starship/starship.toml ~/.config/starship.toml
	@echo "Starship configuration installed."

uninstall-starship:
	@echo "Uninstalling Starship configuration..."
	rm -f ~/.config/starship.toml
	@echo "Starship configuration uninstalled."

# Install all configurations
install: install-nvim install-vim install-fish install-ghostty install-brew install-git install-starship

# Uninstall all configurations
uninstall: uninstall-nvim uninstall-vim uninstall-fish uninstall-ghostty uninstall-brew uninstall-git uninstall-starship