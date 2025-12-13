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

# Flags
HAS_SUDO=false
INSTALL_ZSH=true
INSTALL_NEOVIM=true
INSTALL_NNN=true
INSTALL_MC=false  # Not needed on servers

# Helper functions
print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║         🚀 Xrapid's Dotfiles Deployment                      ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
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
    
    if [ "$HAS_SUDO" = true ]; then
        log_info "Updating package lists..."
        sudo apt-get update -qq
        
        # Essential tools
        install_package "git"
        install_package "curl"
        install_package "wget"
        install_package "stow"
        install_package "build-essential"
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
    
    install_package "mc"
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
    # Minimal setup: zsh, nvim, nnn
    # Excludes: ssh, alacritty, kde, mc, broot, tmux (local-only tools)
    local packages=("zsh" "nvim" "nnn")
    
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
    
    log_info "Skipped packages (local-only): ssh, alacritty, kde, mc, broot, tmux"
}

setup_nvim_plugins() {
    log_info "Setting up Neovim plugins..."
    
    if check_command nvim; then
        log_info "Lazy.nvim will auto-install plugins on first run"
        log_success "Run 'nvim' to trigger plugin installation"
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
    echo -e "${GREEN}║         ✓ DEPLOYMENT COMPLETE!                               ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Installed:${NC}"
    check_command zsh && echo -e "  ${GREEN}✓${NC} zsh"
    check_command nvim && echo -e "  ${GREEN}✓${NC} neovim ($(nvim --version | head -1))"
    check_command nnn && echo -e "  ${GREEN}✓${NC} nnn"
    check_command mc && echo -e "  ${GREEN}✓${NC} mc"
    check_command stow && echo -e "  ${GREEN}✓${NC} stow"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "  1. ${YELLOW}Logout and login${NC} to apply shell changes"
    echo -e "  2. ${YELLOW}Run 'nvim'${NC} to install plugins (first launch)"
    echo -e "  3. ${YELLOW}Run 'nnn'${NC} to test file manager"
    echo ""
    echo -e "${CYAN}Configuration:${NC}"
    echo -e "  Dotfiles: ${BLUE}$DOTFILES_DIR${NC}"
    echo -e "  Binaries: ${BLUE}$LOCAL_BIN${NC}"
    echo ""
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
    
    # Setup dotfiles
    clone_dotfiles
    setup_path
    stow_packages
    setup_nvim_plugins
    
    print_summary
}

# Run main
main "$@"
