# 🚀 SSH Deploy - Modern Server Environment

One-command setup for a complete, modern development environment on remote Ubuntu/Debian servers.

## ⚡ Quick Start

On your remote server:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/fantomcheg/ssh_deploy/main/deploy.sh)
```

That's it! ✨

---

## 📦 What Gets Installed

### Core Development Tools
- **zsh** - Modern shell with zinit plugin manager
- **powerlevel10k** - Beautiful and fast prompt theme
- **neovim** - Modern text editor with lazy.nvim plugin manager
- **nnn** - Lightning-fast terminal file manager with plugins

### DevOps & Containers
- **docker** - Container platform with Docker Compose
  - Installed from official Docker repository
  - User automatically added to docker group (no sudo needed)
  - Includes docker-compose plugin
- **tmux** - Terminal multiplexer (default config)

### File Managers & Viewers
- **broot** - Tree-view file manager with fuzzy search (like `tree` on steroids)
- **tmux** - Terminal multiplexer (default config)

### System Information
- **fastfetch** - Beautiful system information display (like neofetch but faster)

### Modern CLI Tools
- **fzf** - Fuzzy finder (critical for many shell functions)
- **bat** - `cat` with syntax highlighting and git integration
- **eza** - Modern replacement for `ls` with colors and icons
- **fd** - Fast and user-friendly alternative to `find`
- **zoxide** - Smart `cd` command that learns your habits
- **tree** - Directory tree visualization
- **duf** - Modern `df` alternative with better visualization
- **dust** - Modern `du` alternative for disk usage analysis
- **jq** - Command-line JSON processor
- **ripgrep (rg)** - Extremely fast grep alternative with better defaults
- **mtr** - Network diagnostic tool (combines ping and traceroute)
- **dog** - Modern DNS client (better dig alternative)

All tools work seamlessly together and are configured via dotfiles.

---

## 🚀 Features

- ✅ **One command** setup - just curl and run
- ✅ **Works with or without sudo** - portable installation to `~/.local/bin`
- ✅ **Smart compatibility** - creates symlinks for Ubuntu/Debian package names (fdfind→fd, batcat→bat)
- ✅ **Auto PATH configuration** - adds `~/.local/bin` to your shell
- ✅ **Automatic shell change** to zsh
- ✅ **GNU Stow** for clean dotfile management
- ✅ **Graceful fallbacks** - works even if some tools fail to install
- ✅ **Custom themes** - broot with nnn-style colors, fastfetch with custom layout

---

## 🔧 How deploy.sh Works

The deployment script is organized into modular functions for easy maintenance and understanding.

### Main Flow

```
main() → Installation phases → Setup dotfiles → Post-install
```

### Core Functions

#### 1. **System Detection & Checks**
- `detect_os()` - Checks if running on Ubuntu/Debian
- `check_sudo()` - Detects if sudo is available
- `check_command()` - Verifies if a command exists

#### 2. **Package Installation Functions**

Each tool has its own installation function with smart fallbacks:

##### **install_essential_packages()**
Installs core system packages:
- git, curl, wget (for downloading)
- stow (for dotfiles management)
- build-essential (compilers)
- fzf, bat/batcat, fd-find, tree (modern CLI tools)

##### **install_zsh()**
Installs zsh shell and sets it as default:
- Tries apt package first (if sudo available)
- Falls back to portable installation
- Installs zinit plugin manager
- Auto-changes default shell with `chsh`

##### **install_neovim()**
Installs latest neovim:
- Tries apt package first
- Falls back to AppImage (~/.local/bin/nvim)
- Configured with lazy.nvim plugin manager

##### **install_nnn()**
Installs nnn file manager:
- Tries apt package first
- Falls back to static binary from GitHub
- Includes plugins and custom config

##### **install_tmux()**
Installs tmux terminal multiplexer:
- Installs via apt (requires sudo)
- Uses default configuration
- Skips if no sudo available

##### **install_docker()**
Installs Docker container platform:
- Uses official Docker repository (not snap)
- Installs docker-ce, docker-ce-cli, containerd, docker-compose plugin
- Automatically adds current user to docker group
- Enables and starts docker service
- Runs hello-world test to verify installation
- **Important**: User needs to logout/login for docker group to take effect
- Without sudo: skips installation with warning

Key features:
- No sudo needed for docker commands after logout/login
- Includes docker-compose v2 (plugin)
- Official Docker packages (latest stable)

##### **install_broot()**
Installs broot tree-view file manager:
- Tries apt package first
- Falls back to static binary from GitHub
- Includes custom nnn-style color theme
- Shell integration for `cd` on exit

##### **install_fastfetch()**
Installs fastfetch system info tool:
- Tries apt package first
- Falls back to .deb package download
- Last resort: AppImage from GitHub
- Custom config with Japanese characters (ホスト) and color-coded sections

##### **install_eza()**
Installs eza (modern ls):
- Tries apt package first
- Falls back to GitHub releases binary
- Configured with icons support

##### **install_zoxide()**
Installs zoxide (smart cd):
- Uses official installer script
- Installs to ~/.local/bin/zoxide
- Shell integration in .zshrc

#### 3. **Dotfiles Management**

##### **clone_dotfiles()**
- Clones this repository to ~/ssh_deploy
- Asks before overwriting existing installation

##### **stow_packages()**
Uses GNU Stow to symlink configurations:
- **Stowed**: zsh, nvim, nnn, broot, fastfetch
- **Excluded**: ssh, alacritty, kde, mc, tmux (local/desktop-only)

##### **create_fd_bat_symlinks()**
Creates compatibility symlinks:
- `~/.local/bin/fd` → fdfind (Ubuntu/Debian)
- `~/.local/bin/bat` → batcat (Ubuntu/Debian)

##### **setup_path()**
Configures PATH environment:
- Adds ~/.local/bin to PATH in .zshrc
- Adds to ~/.profile for other shells
- Exports PATH immediately for current session

#### 4. **Post-Install**

##### **setup_nvim_plugins()**
- Informs about lazy.nvim auto-installation
- Plugins install on first `nvim` launch

##### **run_tests()**
Comprehensive testing suite that validates installation:

**Core Tools Tests:**
- zsh, neovim, nnn, stow
- Version checks for each tool

**File Managers & System Monitors Tests:**
- broot, mc, tmux, htop
- Version checks

**Modern CLI Tools Tests:**
- fzf, bat/batcat, eza, fd/fdfind, zoxide, tree
- All with version validation

**DevOps Tools Tests:**
- docker (version check)
- docker daemon running (docker info)
- docker group membership

**System Information Tests:**
- fastfetch (version check)

**Configuration Files Tests:**
- .zshrc exists
- nvim/init.lua exists
- broot/conf.hjson exists
- fastfetch/config.jsonc exists
- mc/ini exists

**Output Format:**
- `✓ PASS` (green) - installed and working
- `✗ FAIL` (red) - installed but test failed
- `⊘ SKIP` (yellow) - not installed (optional)

**Summary:**
- Shows total tests passed
- Shows failed tests (if any)

##### **print_summary()**
- Shows installed tools with versions
- Lists useful commands and aliases
- Provides next steps

### Installation Flags

All tools can be controlled via flags at the top of `deploy.sh`:

```bash
INSTALL_ZSH=true
INSTALL_NEOVIM=true
INSTALL_NNN=true
INSTALL_FZF=true
INSTALL_BAT=true
INSTALL_EZA=true
INSTALL_FD=true
INSTALL_ZOXIDE=true
INSTALL_TREE=true
INSTALL_TMUX=true
INSTALL_BROOT=true
INSTALL_FASTFETCH=true
INSTALL_DOCKER=true
```

Set to `false` to skip installation of specific tools.

**Note on Docker**: Docker installation requires sudo and automatically adds user to docker group. You'll need to logout/login after installation to use docker without sudo.

---

## 📦 What's NOT Included (Privacy & Security)

For security and relevance, the following are **excluded** from this public repository:

- ❌ SSH keys and configs
- ❌ Desktop-specific tools (Alacritty, KDE, Midnight Commander)
- ❌ Personal aliases and scripts
- ❌ Work-related configurations
- ❌ VPN configs and credentials

This keeps the repository **safe for public use** and **server-focused**.

---

## 📝 Manual Installation

If you prefer manual installation:

```bash
# Clone repository
git clone https://github.com/fantomcheg/ssh_deploy.git ~/ssh_deploy
cd ~/ssh_deploy

# Run deployment script
bash deploy.sh
```

---

## 📋 Requirements

- Ubuntu/Debian-based system
- `curl` or `wget`
- Internet connection
- Optional: `sudo` access (for apt packages)

---

## 🎯 Post-Install

After installation:

```bash
# Reload shell
exec zsh

# Test installed tools
which zsh nvim nnn fzf bat eza fd zoxide tree tmux htop duf dust jq rg mtr dog broot fastfetch

# Try useful commands
n              # Launch nnn file manager
br             # Launch broot tree viewer
htop           # Interactive process viewer
df             # Disk usage (duf if installed)
du             # Directory size (dust if installed)
jq             # JSON processor
rg             # Fast grep alternative (ripgrep)
mtr            # Network diagnostic tool
dog            # Modern DNS client
fastfetch      # Show system information
docker ps      # List running containers (after logout/login)
docker run hello-world  # Test docker installation
so             # Reload .zshrc
ls             # eza with icons (if installed)
bat --help     # cat with syntax highlighting
fd -h          # fast find alternative
z <dir>        # zoxide smart cd (after visiting some dirs)

# Open nvim to trigger plugin installation
nvim
```

### 🐳 Docker Post-Install

After installation, Docker is ready but you need to **logout/login** for group membership to take effect:

```bash
# Check if you're in docker group
groups | grep docker

# If not shown, logout and login again
exit

# After re-login, test docker without sudo
docker ps
docker run hello-world

# Docker Compose is available as a plugin
docker compose version
```

### 🔥 Useful Aliases

The `.zshrc` includes these aliases:

- `n` - nnn file manager
- `br` - broot tree view (if launcher is installed)
- `so` - source ~/.zshrc (reload config)
- `ls`, `la`, `ll`, `lt` - eza with various options
- `fd` - works with fdfind or fd binary
- `bat` - works with batcat or bat binary
- `df` - aliased to duf (if installed)
- `du` - aliased to dust (if installed)

### 🐳 Docker Usage

Docker is configured for **no-sudo usage**:

```bash
# After logout/login, these work without sudo
docker ps
docker run -d nginx
docker compose up -d
docker images
docker logs <container>

# Docker Compose v2 (plugin)
docker compose version
docker compose up
docker compose down
```

**Note**: If docker commands require sudo, you need to logout/login to activate docker group membership.

### 📸 Broot Features

Broot is configured with:
- **nnn-style color scheme** (matching your file manager)
- **Keyboard shortcuts** inherited from `.config/broot/verbs.hjson`
- **Special paths** configured (ignores `/media`, `/mnt`, `~/.cache`)
- **Shell integration** - `br` changes directory on exit

### 🎨 Fastfetch Features

Fastfetch is configured with:
- **Custom layout** with Japanese characters (ホスト = Host)
- **Color-coded sections**:
  - Magenta (紫) - OS/System
  - Green (緑) - Disk/Terminal/Shell
  - Yellow (黄) - Hardware (CPU/GPU/RAM)
- **Box drawing characters** for beautiful tree-style output

---

## 🔧 Configuration Locations

- **Dotfiles**: `~/ssh_deploy/`
- **Binaries**: `~/.local/bin/`
- **Configs**: `~/.config/`
- **Zsh config**: `~/.zshrc`
- **Broot config**: `~/.config/broot/conf.hjson`
- **Broot skin**: `~/.config/broot/skins/nnn-style.hjson`
- **Fastfetch config**: `~/.config/fastfetch/config.jsonc`

---

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
stow -R zsh nvim nnn broot fastfetch
exec zsh
```

### Broot launcher not working

If `br` doesn't work, install the shell launcher:

```bash
broot --install
exec zsh
```

### Fastfetch not showing

Make sure it's in PATH:

```bash
export PATH="$HOME/.local/bin:$PATH"
which fastfetch
```

---

## 📚 Additional Resources

- [Broot Documentation](https://dystroy.org/broot/)
- [Fastfetch Documentation](https://github.com/fastfetch-cli/fastfetch)
- [nnn Documentation](https://github.com/jarun/nnn)
- [zoxide Documentation](https://github.com/ajeetdsouza/zoxide)
- [powerlevel10k](https://github.com/romkatv/powerlevel10k)

---

## 📄 License

MIT

## 👤 Author

[fantomcheg](https://github.com/fantomcheg)
