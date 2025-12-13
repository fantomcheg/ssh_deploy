# 🚀 SSH Deploy - Server Environment Setup

One-command setup for your development environment on remote servers.

## Quick Start

On your remote Ubuntu/Debian server, run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/fantomcheg/ssh_deploy/main/deploy.sh)
```

That's it! ✨

## What Gets Installed

### Core Tools
- **zsh** - Modern shell with configuration
- **neovim** - Text editor with full plugin setup
- **nnn** - Terminal file manager

### Features
- ✅ Auto-detects sudo availability
- ✅ Falls back to portable versions if no sudo:
  - nvim AppImage → `~/.local/bin/`
  - nnn static binary → `~/.local/bin/`
- ✅ Clones this repository
- ✅ Stows configurations using GNU Stow
- ✅ Configures PATH
- ✅ Changes default shell to zsh

## What's NOT Included

For security and privacy, the following are excluded:
- ❌ SSH keys (use your private dotfiles for this)
- ❌ Desktop tools (alacritty, KDE configs, etc.)
- ❌ tmux (to avoid nested tmux conflicts)

## Manual Installation

If you prefer manual installation:

```bash
# Clone repository
git clone https://github.com/fantomcheg/ssh_deploy.git
cd ssh_deploy

# Run deployment script
./deploy.sh
```

## Requirements

- Ubuntu/Debian-based system
- curl or wget
- Internet connection

## Post-Install

After installation:

1. **Logout and login** to apply shell changes
2. **Run `nvim`** - plugins will install automatically on first launch
3. **Run `nnn`** to test the file manager

## Configuration Locations

- Dotfiles: `~/ssh_deploy/`
- Binaries: `~/.local/bin/`
- Configs: `~/.config/`

## License

MIT

## Author

[fantomcheg](https://github.com/fantomcheg)
