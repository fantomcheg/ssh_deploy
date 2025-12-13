#!/usr/bin/env bash
# Quick script to install missing CLI tools on existing deployment

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

LOCAL_BIN="$HOME/.local/bin"

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

check_command() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Installing Missing CLI Tools                         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Install zoxide
if ! check_command zoxide; then
    log_info "Installing zoxide..."
    if curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash; then
        log_success "zoxide installed to ~/.local/bin/"
    else
        log_warning "Failed to install zoxide"
    fi
else
    log_success "zoxide already installed"
fi

# Create fd alias if using fdfind
if check_command fdfind && ! check_command fd; then
    log_info "Creating fd symlink for fdfind..."
    mkdir -p "$LOCAL_BIN"
    ln -sf "$(which fdfind)" "$LOCAL_BIN/fd"
    log_success "fd symlink created"
else
    log_success "fd already available"
fi

# Create bat alias if using batcat
if check_command batcat && ! check_command bat; then
    log_info "Creating bat symlink for batcat..."
    mkdir -p "$LOCAL_BIN"
    ln -sf "$(which batcat)" "$LOCAL_BIN/bat"
    log_success "bat symlink created"
else
    log_success "bat already available"
fi

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         ✓ Installation Complete!                             ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next step:${NC} exec zsh"
echo ""
