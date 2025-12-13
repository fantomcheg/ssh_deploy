# 🚀 SSH Deploy - Modern Server Environment

One-command setup for a complete, modern development environment on remote Ubuntu/Debian servers.

## ⚡ Quick Start

On your remote server:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/fantomcheg/ssh_deploy/main/deploy.sh)
```

That's it! ✨

## ✅ What Gets Installed

### Core Tools
- **zsh** - Modern shell with zinit plugin manager
- **powerlevel10k** - Beautiful and fast prompt theme
- **neovim** - Modern text editor with plugin support
- **nnn** - Fast terminal file manager

### Modern CLI Tools
- **fzf** - Fuzzy finder (critical for many shell functions)
- **bat** - cat with syntax highlighting and git integration
- **eza** - Modern replacement for ls with colors and icons
- **fd** - Fast and user-friendly alternative to find
- **zoxide** - Smart cd command that learns your habits
- **tree** - Directory tree visualization

All tools work seamlessly together and are configured via dotfiles.

## 🚀 Features

- ✅ **One command** setup - just curl and run
- ✅ **Works with or without sudo** - portable installation to `~/.local/bin`
- ✅ **Smart compatibility** - creates symlinks for Ubuntu/Debian package names (fdfind→fd, batcat→bat)
- ✅ **Auto PATH configuration** - adds `~/.local/bin` to your shell
- ✅ **Automatic shell change** to zsh
- ✅ **GNU Stow** for clean dotfile management
- ✅ **Graceful fallbacks** - works even if some tools fail to install

## 📦 What's NOT Included (Privacy & Security)

For security and relevance, the following are **excluded** from this public repository:

- ❌ SSH keys and configs
- ❌ Desktop-specific tools (Alacritty, KDE, Midnight Commander, Broot)
- ❌ Personal aliases and scripts
- ❌ Work-related configurations
- ❌ VPN configs and credentials

This keeps the repository **safe for public use** and **server-focused**.

## 📝 Manual Installation

If you prefer manual installation:

```bash
# Clone repository
git clone https://github.com/fantomcheg/ssh_deploy.git ~/ssh_deploy
cd ~/ssh_deploy

# Run deployment script
bash deploy.sh
```

## 📋 Requirements

- Ubuntu/Debian-based system
- `curl` or `wget`
- Internet connection
- Optional: `sudo` access (for apt packages)

## 🎯 Post-Install

After installation:

```bash
# Reload shell
exec zsh

# Test installed tools
which zsh nvim nnn fzf bat eza fd zoxide tree

# Try useful commands
n           # Launch nnn file manager
so          # Reload .zshrc
ls          # eza with icons (if installed)
bat --help  # cat with syntax highlighting
fd -h       # fast find alternative
z <dir>     # zoxide smart cd (after visiting some dirs)

# Open nvim to trigger plugin installation
nvim
```

### 🔥 Useful Aliases

The `.zshrc` includes these aliases:

- `n` - nnn file manager
- `so` - source ~/.zshrc (reload config)
- `ls`, `la`, `ll`, `lt` - eza with various options
- `fd` - works with fdfind or fd binary
- `bat` - works with batcat or bat binary

## 🔧 Configuration Locations

- **Dotfiles**: `~/ssh_deploy/`
- **Binaries**: `~/.local/bin/`
- **Configs**: `~/.config/`
- **Zsh config**: `~/.zshrc`

## 🛠️ Troubleshooting

### Missing tools after install

If `zoxide`, `fd`, or `bat` are not found:

```bash
# Run the fix script
bash ~/ssh_deploy/install_missing.sh

# Reload shell
exec zsh
```

### Update configuration

```bash
cd ~/ssh_deploy
git pull
stow -R zsh nvim nnn
exec zsh
```

## 📄 License

MIT

## 👤 Author

[fantomcheg](https://github.com/fantomcheg)
