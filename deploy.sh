#!/usr/bin/env bash
#
# Xrapid's Dotfiles Deployment Script
# One command to set up your environment on any Ubuntu/Debian server
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/fantomcheg/dotfiles/main/scripts/deploy.sh)
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration  
DOTFILES_REPO="https://github.com/fantomcheg/ssh_deploy.git"
DOTFILES_DIR="$HOME/ssh_deploy"
LOCAL_BIN="$HOME/.local/bin"
LOCAL_SHARE="$HOME/.local/share"

# Logging
LOG_FILE="$HOME/ssh_deploy_install.log"
LOG_DIR="$(dirname "$LOG_FILE")"

# Flags
HAS_SUDO=false
INSTALL_ZSH=true
INSTALL_NEOVIM=true
INSTALL_NNN=true
INSTALL_MC=false  # Not needed on servers
INSTALL_FZF=true
INSTALL_BAT=true
INSTALL_EZA=true
INSTALL_FD=true
INSTALL_ZOXIDE=true
INSTALL_TREE=true
INSTALL_TMUX=true
INSTALL_FASTFETCH=true
INSTALL_DOCKER=true
INSTALL_MC=true  # Midnight Commander with custom theme
INSTALL_HTOP=true
INSTALL_DUF=true
INSTALL_DUST=true
INSTALL_JQ=true
INSTALL_RIPGREP=true
INSTALL_MTR=true

# Helper functions
init_logging() {
    # Create log file
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "═══════════════════════════════════════════════════════════════" > "$LOG_FILE"
    echo "SSH Deploy Installation Log" >> "$LOG_FILE"
    echo "Date: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
    echo "User: $USER" >> "$LOG_FILE"
    echo "Hostname: $(hostname)" >> "$LOG_FILE"
    echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)" >> "$LOG_FILE"
    echo "═══════════════════════════════════════════════════════════════" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}

log_to_file() {
    local level="$1"
    shift
    local message="$@"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
}

print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║         🚀 Xrapid's Dotfiles Deployment                      ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    log_to_file "INFO" "Starting deployment"
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
    log_to_file "INFO" "$1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
    log_to_file "SUCCESS" "$1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    log_to_file "WARNING" "$1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
    log_to_file "ERROR" "$1"
}

check_command() {
    command -v "$1" >/dev/null 2>&1
}

check_sudo() {
    if sudo -n true 2>/dev/null; then
        HAS_SUDO=true
        log_success "sudo available"
    else
        log_warning "No sudo access - will use portable versions"
        HAS_SUDO=false
    fi
}

detect_os() {
    log_info "Detecting OS..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
        log_success "Detected: $PRETTY_NAME"
    else
        log_error "Cannot detect OS"
        exit 1
    fi
}

install_package() {
    local package=$1
    if check_command "$package"; then
        log_success "$package already installed"
        return 0
    fi
    
    if [ "$HAS_SUDO" = true ]; then
        log_info "Installing $package..."
        case $OS in
            ubuntu|debian)
                sudo apt-get install -y "$package" 2>/dev/null && log_success "$package installed" || log_warning "$package installation failed"
                ;;
            *)
                log_warning "Unsupported OS for automatic installation"
                return 1
                ;;
        esac
    else
        log_warning "Cannot install $package without sudo"
        return 1
    fi
}

install_essential_packages() {
    log_info "Installing essential packages..."
    log_to_file "INFO" "=== Starting essential packages installation ==="
    
    if [ "$HAS_SUDO" = true ]; then
        log_info "Updating package lists (this may take a minute)..."
        log_to_file "INFO" "Running: sudo apt-get update"
        
        local update_output
        if update_output=$(sudo apt-get update 2>&1); then
            # Show last few lines to user
            echo "$update_output" | grep -E "Hit:|Get:|Ign:|Err:" | tail -5
            log_success "Package lists updated"
            log_to_file "SUCCESS" "Package lists updated successfully"
            log_to_file "OUTPUT" "$update_output"
        else
            log_warning "Failed to update package lists (check log for details)"
            log_to_file "ERROR" "apt-get update failed"
            log_to_file "OUTPUT" "$update_output"
        fi
        
        # Essential tools
        install_package "git"
        install_package "curl"
        install_package "wget"
        install_package "stow"
        install_package "build-essential"
        
        # Additional modern CLI tools
        if $INSTALL_FZF; then
            install_package "fzf"
        fi
        
        if $INSTALL_BAT; then
            # bat is sometimes named batcat on Ubuntu/Debian
            install_package "bat" || install_package "batcat"
        fi
        
        if $INSTALL_FD; then
            # fd-find on Ubuntu/Debian
            install_package "fd-find"
        fi
        
        if $INSTALL_TREE; then
            install_package "tree"
        fi
        
        if $INSTALL_TMUX; then
            install_package "tmux"
        fi
        
        if $INSTALL_MC; then
            install_package "mc"
        fi
        
        if $INSTALL_HTOP; then
            install_package "htop"
        fi
        
        if $INSTALL_DUF; then
            install_package "duf"
        fi
        
        if $INSTALL_DUST; then
            install_package "dust"
        fi
        
        if $INSTALL_JQ; then
            install_package "jq"
        fi
        
        if $INSTALL_RIPGREP; then
            install_package "ripgrep"
        fi
        
        if $INSTALL_MTR; then
            install_package "mtr"
        fi
        
        # eza and zoxide might not be in default repos, will handle separately
    fi
}

install_dust_portable() {
    log_info "Installing dust from GitHub releases..."
    log_to_file "INFO" "=== Installing dust (portable binary) ==="
    mkdir -p "$LOCAL_BIN"
    
    local dust_url="https://github.com/bootandy/dust/releases/download/v1.1.1/dust-v1.1.1-x86_64-unknown-linux-musl.tar.gz"
    log_to_file "INFO" "Downloading from: $dust_url"
    
    echo -n "  Downloading... "
    local download_output
    if download_output=$(curl -fsSL --progress-bar "$dust_url" -o /tmp/dust.tar.gz 2>&1); then
        echo "✓"
        log_to_file "SUCCESS" "Downloaded dust successfully"
        log_to_file "OUTPUT" "$download_output"
        
        echo -n "  Extracting... "
        log_to_file "INFO" "Extracting archive..."
        local extract_output
        if extract_output=$(tar -xzf /tmp/dust.tar.gz -C /tmp 2>&1); then
            echo "✓"
            log_to_file "SUCCESS" "Extracted successfully"
            log_to_file "OUTPUT" "$extract_output"
            
            if [ -f /tmp/dust-v1.1.1-x86_64-unknown-linux-musl/dust ]; then
                mv /tmp/dust-v1.1.1-x86_64-unknown-linux-musl/dust "$LOCAL_BIN/" 2>&1 | tee -a "$LOG_FILE"
            elif [ -f /tmp/dust ]; then
                mv /tmp/dust "$LOCAL_BIN/" 2>&1 | tee -a "$LOG_FILE"
            fi
            
            chmod +x "$LOCAL_BIN/dust" 2>&1 | tee -a "$LOG_FILE"
            rm -rf /tmp/dust* 2>&1 | tee -a "$LOG_FILE"
            
            log_success "dust installed to $LOCAL_BIN/dust"
            log_to_file "SUCCESS" "dust installed successfully to $LOCAL_BIN/dust"
            return 0
        else
            echo "✗"
            log_to_file "ERROR" "Extraction failed: $extract_output"
        fi
    else
        echo "✗"
        log_warning "Failed to download dust"
        log_to_file "ERROR" "Download failed: $download_output"
        return 1
    fi
}

install_zsh() {
    if ! $INSTALL_ZSH; then
        return
    fi
    
    log_info "Setting up zsh..."
    
    if ! check_command zsh; then
        install_package "zsh"
    else
        log_success "zsh already installed"
    fi
    
    # Change default shell
    if check_command zsh && [ "$HAS_SUDO" = true ]; then
        if [ "$SHELL" != "$(which zsh)" ]; then
            log_info "Changing default shell to zsh..."
            sudo chsh -s "$(which zsh)" "$USER" && log_success "Default shell changed to zsh"
        fi
    fi
}

install_neovim_portable() {
    log_info "Installing portable Neovim..."
    
    mkdir -p "$LOCAL_BIN"
    
    # Download latest stable nvim AppImage
    local nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"
    local nvim_path="$LOCAL_BIN/nvim"
    
    if wget -q "$nvim_url" -O "$nvim_path" 2>/dev/null; then
        chmod +x "$nvim_path"
        log_success "Neovim portable installed to $nvim_path"
    else
        log_warning "Failed to download Neovim AppImage"
        return 1
    fi
}

install_neovim() {
    if ! $INSTALL_NEOVIM; then
        return
    fi
    
    log_info "Setting up Neovim..."
    
    if check_command nvim; then
        log_success "Neovim already installed"
        return
    fi
    
    # Try package manager first
    if [ "$HAS_SUDO" = true ]; then
        if install_package "neovim"; then
            return
        fi
    fi
    
    # Fall back to portable version
    install_neovim_portable
}

install_nnn_portable() {
    log_info "Installing portable nnn..."
    
    mkdir -p "$LOCAL_BIN"
    
    # Try to download pre-built static binary
    local nnn_url="https://github.com/jarun/nnn/releases/latest/download/nnn-static-x86_64.tar.gz"
    local temp_dir=$(mktemp -d)
    
    if wget -q "$nnn_url" -O "$temp_dir/nnn.tar.gz" 2>/dev/null; then
        tar -xzf "$temp_dir/nnn.tar.gz" -C "$temp_dir"
        mv "$temp_dir/nnn-static" "$LOCAL_BIN/nnn"
        chmod +x "$LOCAL_BIN/nnn"
        rm -rf "$temp_dir"
        log_success "nnn portable installed to $LOCAL_BIN/nnn"
    else
        log_warning "Failed to download nnn static binary"
        rm -rf "$temp_dir"
        return 1
    fi
}

install_nnn() {
    if ! $INSTALL_NNN; then
        return
    fi
    
    log_info "Setting up nnn..."
    
    if check_command nnn; then
        log_success "nnn already installed"
        return
    fi
    
    # Try package manager first
    if [ "$HAS_SUDO" = true ]; then
        if install_package "nnn"; then
            return
        fi
    fi
    
    # Fall back to portable version
    install_nnn_portable
}

install_mc() {
    if ! $INSTALL_MC; then
        return
    fi
    
    log_info "Setting up Midnight Commander..."
    
    if check_command mc; then
        log_success "mc already installed"
        return
    fi
    
    # Install via package manager
    if [ "$HAS_SUDO" = true ]; then
        install_package "mc"
    else
        log_warning "mc requires sudo to install"
    fi
}

install_eza() {
    if ! $INSTALL_EZA; then
        return
    fi
    
    log_info "Setting up eza..."
    
    if check_command eza; then
        log_success "eza already installed"
        return
    fi
    
    # Try package manager first (might be in newer repos)
    if [ "$HAS_SUDO" = true ]; then
        if install_package "eza" 2>/dev/null; then
            log_success "eza installed via apt"
            return
        fi
    fi
    
    # Install from GitHub releases (portable)
    log_info "Installing eza from GitHub releases..."
    local eza_url="https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"
    local temp_dir=$(mktemp -d)
    
    if wget -q "$eza_url" -O "$temp_dir/eza.tar.gz" 2>/dev/null; then
        tar -xzf "$temp_dir/eza.tar.gz" -C "$temp_dir"
        mkdir -p "$LOCAL_BIN"
        mv "$temp_dir/eza" "$LOCAL_BIN/"
        chmod +x "$LOCAL_BIN/eza"
        rm -rf "$temp_dir"
        log_success "eza installed to $LOCAL_BIN/eza"
    else
        log_warning "Failed to install eza - will use fallback (exa/ls)"
        rm -rf "$temp_dir"
    fi
}

install_zoxide() {
    if ! $INSTALL_ZOXIDE; then
        return
    fi
    
    log_info "Setting up zoxide..."
    
    if check_command zoxide; then
        log_success "zoxide already installed"
        return
    fi
    
    # Install using the official installer script
    log_info "Installing zoxide from official installer..."
    mkdir -p "$LOCAL_BIN"
    if curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash; then
        log_success "zoxide installed to $LOCAL_BIN/zoxide"
    else
        log_warning "Failed to install zoxide"
    fi
}

install_tmux() {
    if ! $INSTALL_TMUX; then
        return
    fi
    
    log_info "Setting up tmux..."
    
    if check_command tmux; then
        log_success "tmux already installed"
        return
    fi
    
    # Install via package manager (default config)
    if [ "$HAS_SUDO" = true ]; then
        install_package "tmux"
    else
        log_warning "tmux requires sudo to install"
    fi
}

install_fastfetch() {
    if ! $INSTALL_FASTFETCH; then
        return
    fi
    
    log_info "Setting up fastfetch..."
    
    if check_command fastfetch; then
        log_success "fastfetch already installed"
        return
    fi
    
    # Try package manager first (available on newer Ubuntu/Debian)
    if [ "$HAS_SUDO" = true ]; then
        if install_package "fastfetch" 2>/dev/null; then
            log_success "fastfetch installed via apt"
            return
        fi
    fi
    
    # Install from GitHub releases (tar.gz archive)
    log_info "Installing fastfetch from GitHub releases..."
    local temp_dir=$(mktemp -d)
    local fastfetch_version="2.30.1"  # Stable version known to work
    local fastfetch_url="https://github.com/fastfetch-cli/fastfetch/releases/download/${fastfetch_version}/fastfetch-linux-amd64.tar.gz"
    
    if wget -q "$fastfetch_url" -O "$temp_dir/fastfetch.tar.gz" 2>/dev/null; then
        cd "$temp_dir"
        tar -xzf fastfetch.tar.gz
        
        # Find the binary in extracted archive
        if [ -f "fastfetch-linux-amd64/usr/bin/fastfetch" ]; then
            mkdir -p "$LOCAL_BIN"
            cp "fastfetch-linux-amd64/usr/bin/fastfetch" "$LOCAL_BIN/"
            chmod +x "$LOCAL_BIN/fastfetch"
            log_success "fastfetch installed to $LOCAL_BIN/fastfetch"
        else
            log_warning "fastfetch binary not found in archive"
        fi
        
        cd - > /dev/null
        rm -rf "$temp_dir"
    else
        log_warning "Failed to download fastfetch"
        rm -rf "$temp_dir"
    fi
}

install_docker() {
    if ! $INSTALL_DOCKER; then
        return
    fi
    
    log_info "Setting up Docker..."
    
    if check_command docker; then
        log_success "Docker already installed"
        # Still check and add user to docker group
        if groups | grep -q docker; then
            log_success "User already in docker group"
        else
            log_warning "User not in docker group, trying to add..."
            if [ "$HAS_SUDO" = true ]; then
                sudo usermod -aG docker "$USER"
                log_success "User added to docker group - logout/login required to apply"
            else
                log_warning "No sudo - cannot add user to docker group"
            fi
        fi
        return
    fi
    
    if [ "$HAS_SUDO" != true ]; then
        log_warning "Docker requires sudo to install"
        return
    fi
    
    log_info "Installing Docker from official repository..."
    
    # Install prerequisites
    sudo apt-get update -qq
    sudo apt-get install -y ca-certificates curl gnupg lsb-release 2>/dev/null
    
    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    if [ -f /etc/apt/keyrings/docker.gpg ]; then
        sudo rm /etc/apt/keyrings/docker.gpg
    fi
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Add Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    sudo apt-get update -qq
    if sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null; then
        log_success "Docker installed successfully"
        
        # Start and enable Docker service
        sudo systemctl enable docker 2>/dev/null
        sudo systemctl start docker 2>/dev/null
        
        # Add current user to docker group
        log_info "Adding user to docker group..."
        sudo usermod -aG docker "$USER"
        log_success "User added to docker group"
        log_warning "You need to logout/login for docker group to take effect"
        
        # Test docker (with sudo since group not yet active)
        if sudo docker run --rm hello-world >/dev/null 2>&1; then
            log_success "Docker test successful"
        else
            log_warning "Docker installed but test failed"
        fi
    else
        log_error "Failed to install Docker"
    fi
}

create_fd_bat_symlinks() {
    log_info "Setting up fd and bat symlinks..."
    
    # Create fd symlink if fdfind exists
    if check_command fdfind && ! check_command fd; then
        mkdir -p "$LOCAL_BIN"
        ln -sf "$(which fdfind)" "$LOCAL_BIN/fd"
        log_success "fd symlink created (fdfind → fd)"
    fi
    
    # Create bat symlink if batcat exists
    if check_command batcat && ! check_command bat; then
        mkdir -p "$LOCAL_BIN"
        ln -sf "$(which batcat)" "$LOCAL_BIN/bat"
        log_success "bat symlink created (batcat → bat)"
    fi
}

clone_dotfiles() {
    log_info "Cloning dotfiles repository..."
    
    if [ -d "$DOTFILES_DIR" ]; then
        log_warning "Dotfiles directory already exists"
        read -p "Remove and re-clone? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$DOTFILES_DIR"
        else
            log_info "Skipping clone, using existing directory"
            return 0
        fi
    fi
    
    if git clone "$DOTFILES_REPO" "$DOTFILES_DIR"; then
        log_success "Dotfiles cloned to $DOTFILES_DIR"
    else
        log_error "Failed to clone dotfiles"
        exit 1
    fi
}

stow_packages() {
    log_info "Deploying dotfiles with stow..."
    
    cd "$DOTFILES_DIR" || exit 1
    
    # Only essential packages for server environment
    # Minimal setup: zsh, nvim, nnn + fastfetch + mc
    # Excludes: ssh, alacritty, kde, tmux, broot (local/desktop-only tools)
    local packages=("zsh" "nvim" "nnn")
    
    # Add optional packages if installed
    $INSTALL_FASTFETCH && [ -d "fastfetch" ] && packages+=("fastfetch")
    $INSTALL_MC && [ -d "mc" ] && packages+=("mc")
    
    for package in "${packages[@]}"; do
        if [ -d "$package" ]; then
            log_info "Stowing $package..."
            if stow -R "$package" 2>/dev/null; then
                log_success "$package stowed"
            else
                log_warning "$package stow failed (might be conflicts)"
            fi
        fi
    done
    
    log_info "Skipped packages (local-only): ssh, alacritty, kde, tmux, broot"
}

setup_nvim_plugins() {
    log_info "Setting up Neovim plugins..."
    
    if check_command nvim; then
        log_info "Lazy.nvim will auto-install plugins on first run"
        log_success "Run 'nvim' to trigger plugin installation"
    fi
}

run_tests() {
    log_info "Running installation tests..."
    
    # Check if test script exists
    if [ -f "$DOTFILES_DIR/test_installation.sh" ]; then
        log_info "Executing test_installation.sh..."
        bash "$DOTFILES_DIR/test_installation.sh"
    else
        log_warning "Test script not found, skipping tests"
    fi
}

setup_path() {
    log_info "Setting up PATH..."
    
    # Add ~/.local/bin to PATH if not already there
    if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
        echo '' >> "$HOME/.profile"
        echo '# Added by dotfiles deployment' >> "$HOME/.profile"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
        log_success "Added ~/.local/bin to PATH in ~/.profile"
    fi
    
    export PATH="$LOCAL_BIN:$PATH"
}

print_summary() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         ✓ Deployment Complete!                               ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Installed:${NC}"
    check_command zsh && echo -e "  ${GREEN}✓${NC} zsh (with zinit + powerlevel10k)"
    check_command nvim && echo -e "  ${GREEN}✓${NC} neovim"
    check_command nnn && echo -e "  ${GREEN}✓${NC} nnn"
    check_command tmux && echo -e "  ${GREEN}✓${NC} tmux"
    check_command htop && echo -e "  ${GREEN}✓${NC} htop"
    check_command fastfetch && echo -e "  ${GREEN}✓${NC} fastfetch (system info)"
    check_command fzf && echo -e "  ${GREEN}✓${NC} fzf"
    check_command bat && echo -e "  ${GREEN}✓${NC} bat" || check_command batcat && echo -e "  ${GREEN}✓${NC} batcat (use 'bat' alias)"
    check_command eza && echo -e "  ${GREEN}✓${NC} eza"
    check_command fd && echo -e "  ${GREEN}✓${NC} fd" || check_command fdfind && echo -e "  ${GREEN}✓${NC} fdfind (use 'fd' alias)"
    check_command zoxide && echo -e "  ${GREEN}✓${NC} zoxide"
    check_command tree && echo -e "  ${GREEN}✓${NC} tree"
    check_command duf && echo -e "  ${GREEN}✓${NC} duf (better df)"
    check_command dust && echo -e "  ${GREEN}✓${NC} dust (better du)"
    check_command jq && echo -e "  ${GREEN}✓${NC} jq (JSON processor)"
    check_command rg && echo -e "  ${GREEN}✓${NC} ripgrep (better grep)"
    check_command mtr && echo -e "  ${GREEN}✓${NC} mtr (network diagnostic)"
    check_command stow && echo -e "  ${GREEN}✓${NC} stow"
    check_command docker && echo -e "  ${GREEN}✓${NC} docker"
    check_command mc && echo -e "  ${GREEN}✓${NC} mc (Midnight Commander)"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "  1. ${YELLOW}Logout and login${NC} to apply shell changes (or run: exec zsh)"
    echo -e "  2. ${YELLOW}Run 'nvim'${NC} to auto-install plugins (first launch)"
    echo -e "  3. ${YELLOW}Try commands:${NC} n (nnn), br (broot), fastfetch"
    echo ""
    echo -e "${CYAN}Configuration:${NC}"
    echo -e "  Dotfiles: ${BLUE}$DOTFILES_DIR${NC}"
    echo -e "  Binaries: ${BLUE}$LOCAL_BIN${NC}"
    echo ""
    echo -e "${CYAN}Useful aliases:${NC}"
    echo -e "  ${YELLOW}n${NC}   - nnn file manager"
    echo -e "  ${YELLOW}mc${NC}  - Midnight Commander (with cd-on-exit)"
    echo -e "  ${YELLOW}so${NC}  - reload .zshrc"
    echo -e "  ${YELLOW}ls${NC}  - eza (modern ls)"
    echo -e "  ${YELLOW}bat${NC} - cat with syntax highlighting"
    echo ""
    echo -e "${CYAN}System info:${NC}"
    echo -e "  Run ${YELLOW}fastfetch${NC} to see beautiful system information"
    echo ""
    
    # Docker specific notes
    if check_command docker; then
        echo -e "${CYAN}Docker:${NC}"
        echo -e "  ${GREEN}✓${NC} Docker installed"
        if groups | grep -q docker; then
            echo -e "  ${GREEN}✓${NC} User in docker group - ready to use"
        else
            echo -e "  ${YELLOW}⚠${NC} User added to docker group"
            echo -e "  ${RED}➜${NC} Run ${YELLOW}exec zsh${NC} or logout/login to activate docker group"
        fi
        echo ""
    fi
    
    # Log file location
    echo ""
    echo -e "${CYAN}📋 Installation log:${NC} ${YELLOW}$LOG_FILE${NC}"
    echo -e "${CYAN}If you encountered issues, share this log for troubleshooting.${NC}"
    echo ""
    
    log_to_file "INFO" "Summary printed. Log file: $LOG_FILE"
}

# Main execution
main() {
    print_banner
    
    detect_os
    check_sudo
    
    log_info "Starting deployment..."
    echo ""
    
    # Installation phases
    install_essential_packages
    install_zsh
    install_neovim
    install_nnn
    install_mc
    install_eza
    install_zoxide
    install_tmux
    install_fastfetch
    install_docker
    
    # Install portable versions if apt failed
    if ! check_command dust; then
        install_dust_portable
    fi
    
    # Setup dotfiles
    clone_dotfiles
    setup_path
    stow_packages
    
    # Create symlinks for fd/bat after stow
    create_fd_bat_symlinks
    
    setup_nvim_plugins
    
    # Run tests
    run_tests
    
    print_summary
    
    # Auto-switch to zsh after everything is done
    if check_command zsh; then
        echo ""
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  🚀 Switching to zsh shell automatically...                  ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        log_to_file "INFO" "Auto-switching to zsh shell"
        exec zsh
    fi
}

# Run main
main "$@"
