#!/usr/bin/env bash
#
# Optional KDE/Plasma settings installer for ssh_deploy
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/fantomcheg/ssh_deploy/main/install_kde.sh)
#   # If /dev/fd error on Arch/EndeavourOS:
#   # tmpfile="$(mktemp "$HOME/install_kde.XXXXXX.sh")" && curl -fsSL https://raw.githubusercontent.com/fantomcheg/ssh_deploy/main/install_kde.sh -o "$tmpfile" && bash "$tmpfile"
#

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

DOTFILES_REPO="https://github.com/fantomcheg/ssh_deploy.git"
DOTFILES_DIR="${SSH_DEPLOY_DIR:-$HOME/ssh_deploy}"
KDE_DIR="$DOTFILES_DIR/kde"
BACKUP_ROOT="$HOME/.local/state/ssh_deploy"

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

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        case "$OS" in
            arch|endeavouros|manjaro) ;;
            *) [[ " ${ID_LIKE:-} " == *" arch "* ]] && OS="arch" ;;
        esac
    else
        OS="unknown"
    fi
}

ensure_repo() {
    if [ -d "$DOTFILES_DIR/.git" ]; then
        log_info "Using existing repository at $DOTFILES_DIR"

        if check_command git; then
            log_info "Updating repository to get the latest KDE package..."
            if git -C "$DOTFILES_DIR" pull --ff-only origin main >/dev/null 2>&1; then
                log_success "Repository updated"
            else
                log_warning "Failed to update existing repository automatically"
                log_warning "If KDE package is missing, run: cd $DOTFILES_DIR && git pull --ff-only origin main"
            fi
        fi
        return
    fi

    log_info "Cloning repository to $DOTFILES_DIR..."
    if git clone "$DOTFILES_REPO" "$DOTFILES_DIR"; then
        log_success "Repository cloned"
    else
        log_error "Failed to clone repository"
        exit 1
    fi
}

ensure_stow() {
    if check_command stow; then
        log_success "stow already installed"
        return
    fi

    detect_os
    if ! check_command sudo; then
        log_error "stow is required. Install it manually and rerun this script."
        exit 1
    fi

    log_info "Installing stow..."
    case "${OS:-unknown}" in
        ubuntu|debian)
            sudo apt-get update -qq
            sudo apt-get install -y stow
            ;;
        arch|endeavouros|manjaro)
            sudo pacman -S --noconfirm --needed stow
            ;;
        *)
            log_error "Unsupported OS for automatic stow installation: ${OS:-unknown}"
            exit 1
            ;;
    esac

    log_success "stow installed"
}

backup_existing_kde_files() {
    local timestamp
    timestamp=$(date '+%Y%m%d-%H%M%S')
    local backup_dir="$BACKUP_ROOT/kde-backup-$timestamp"
    local backed_up=false

    mkdir -p "$BACKUP_ROOT"

    while IFS= read -r src; do
        local rel target
        rel="${src#$KDE_DIR/}"
        target="$HOME/$rel"

        if [ ! -e "$target" ] && [ ! -L "$target" ]; then
            continue
        fi

        if [ -L "$target" ] && [ "$(readlink -f "$target" 2>/dev/null)" = "$(readlink -f "$src" 2>/dev/null)" ]; then
            continue
        fi

        mkdir -p "$(dirname "$backup_dir/$rel")"
        mv "$target" "$backup_dir/$rel"
        log_info "Backed up $target"
        backed_up=true
    done < <(find "$KDE_DIR" -type f | sort)

    if [ "$backed_up" = true ]; then
        log_success "Existing KDE files backed up to $backup_dir"
    else
        log_success "No conflicting KDE files needed backup"
    fi
}

apply_kde_settings() {
    if [ ! -d "$KDE_DIR" ]; then
        log_warning "No kde package found in $DOTFILES_DIR"
        log_warning "This usually means $DOTFILES_DIR is an old clone without the new KDE package."
        log_warning "Fix: cd $DOTFILES_DIR && git pull --ff-only origin main"
        return 0
    fi

    backup_existing_kde_files

    log_info "Applying KDE settings with stow..."
    if stow -d "$DOTFILES_DIR" -t "$HOME" -R kde; then
        log_success "KDE settings applied"
    else
        log_error "Failed to apply KDE settings"
        exit 1
    fi

    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "  1. Log out and back in to let Plasma reload changed settings."
    echo "  2. If some panels/themes don't update, restart Plasma manually."
    echo "  3. If needed, previous files are in ~/.local/state/ssh_deploy/"
}

main() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              Optional KDE Settings Installer                 ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    ensure_repo
    ensure_stow
    apply_kde_settings
}

main "$@"
