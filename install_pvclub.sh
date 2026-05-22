#!/usr/bin/env bash
#
# EndeavourOS workstation installer for PV Club offline cybersecurity machines.
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/fantomcheg/ssh_deploy/main/install_pvclub.sh)
#   # If /dev/fd is unavailable:
#   # tmpfile="$(mktemp "$HOME/install_pvclub.XXXXXX.sh")" && \
#   #   curl -fsSL https://raw.githubusercontent.com/fantomcheg/ssh_deploy/main/install_pvclub.sh -o "$tmpfile" && \
#   #   bash "$tmpfile"
#

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

DOTFILES_REPO="https://github.com/fantomcheg/ssh_deploy.git"
DOTFILES_DIR="${SSH_DEPLOY_DIR:-$HOME/ssh_deploy}"
INSTALL_KDE="${PVCLUB_INSTALL_KDE:-true}"
INSTALL_AUR="${PVCLUB_INSTALL_AUR:-true}"
TELEGRAM_MTPROXY_URI="tg://proxy?server=93.77.190.66&port=2443&secret=7koPi9XCIE1vfq3xpvOjjBR5YW5kZXgucnU"

REPO_PACKAGES=(
    chromium
    code
    python-pip
    whois
    bind
    net-tools
    wireshark-qt
    nmap
    zenmap
    gobuster
    hashcat
    hydra
    john
    masscan
    metasploit
    rustscan
    sqlmap
    tcpdump
    wpscan
    zaproxy
)

AUR_PACKAGES=(
    amass
    amneziavpn-bin
    amneziawg-go
    burpsuite
    caido-desktop
    cyberchef-web
    dirbuster
    feroxbuster
    ffuf
    gau
    pamac-all
    waybackurls
    sublime-text-4
    telegram-desktop
)

log_info() {
    echo -e "${BLUE}i${NC} $1"
}

log_success() {
    echo -e "${GREEN}+${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

log_error() {
    echo -e "${RED}x${NC} $1"
}

check_command() {
    command -v "$1" >/dev/null 2>&1
}

detect_endeavouros() {
    if [ ! -r /etc/os-release ]; then
        log_error "Cannot read /etc/os-release"
        exit 1
    fi

    . /etc/os-release
    case "${ID:-unknown}" in
        endeavouros|arch|manjaro)
            ;;
        *)
            if [[ " ${ID_LIKE:-} " != *" arch "* ]]; then
                log_error "PV Club installer expects EndeavourOS or another Arch-based system"
                exit 1
            fi
            ;;
    esac

    log_success "Detected ${PRETTY_NAME:-Arch-based Linux}"
}

require_tools() {
    if ! check_command sudo || ! check_command pacman; then
        log_error "sudo and pacman are required"
        exit 1
    fi

    sudo -v

    if ! check_command git; then
        log_info "Installing git before repository setup"
        sudo pacman -S --needed --noconfirm git
    fi
}

ensure_repo() {
    if [ -d "$DOTFILES_DIR/.git" ]; then
        log_info "Using repository at $DOTFILES_DIR"
        return
    fi

    log_info "Cloning ssh_deploy to $DOTFILES_DIR"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    log_success "Repository cloned"
}

upgrade_system() {
    log_info "Updating EndeavourOS packages"
    sudo pacman -Syu --noconfirm
}

install_repo_packages() {
    log_info "Installing repository workstation and security packages"
    sudo pacman -S --needed --noconfirm "${REPO_PACKAGES[@]}"
    log_success "Repository packages installed"
}

ensure_yay() {
    if check_command yay; then
        return 0
    fi

    log_info "Installing yay for AUR packages"
    if sudo pacman -S --needed --noconfirm yay; then
        log_success "yay installed"
        return 0
    fi

    log_warning "yay is unavailable; skipping AUR packages"
    return 1
}

install_aur_packages() {
    if [ "$INSTALL_AUR" != true ]; then
        log_info "Skipping AUR packages because PVCLUB_INSTALL_AUR=$INSTALL_AUR"
        return
    fi

    ensure_yay || return

    log_info "Installing AUR workstation and security packages"
    if yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"; then
        log_success "AUR packages installed"
    else
        log_warning "Some AUR packages failed; the rest of the setup will continue"
    fi
}

configure_telegram_proxy() {
    if ! check_command telegram-desktop; then
        log_warning "telegram-desktop not found; skipping Telegram proxy launch"
        return
    fi

    log_info "Opening Telegram with the PV Club MTProto proxy link..."
    if check_command xdg-open && xdg-open "$TELEGRAM_MTPROXY_URI" >/dev/null 2>&1; then
        log_success "Telegram proxy link opened"
        return
    fi

    telegram-desktop "$TELEGRAM_MTPROXY_URI" >/dev/null 2>&1 &
    log_success "Telegram started with the proxy link"
}

run_base_deploy() {
    log_info "Running base ssh_deploy setup"
    SSH_DEPLOY_NO_EXEC_ZSH=true bash "$DOTFILES_DIR/deploy.sh"
    log_success "Base dotfiles setup finished"
}

configure_groups() {
    if getent group wireshark >/dev/null 2>&1; then
        log_info "Adding $USER to wireshark group"
        sudo usermod -aG wireshark "$USER"
        log_success "wireshark group membership queued for next login"
    fi
}

configure_hostname() {
    if [ -z "${PVCLUB_HOSTNAME:-}" ]; then
        log_info "Hostname unchanged. Use set_pvclub_hostname.sh or PVCLUB_HOSTNAME=pvclub02."
        return
    fi

    log_info "Setting PV Club hostname to $PVCLUB_HOSTNAME"
    bash "$DOTFILES_DIR/set_pvclub_hostname.sh" "$PVCLUB_HOSTNAME"
}

apply_kde_settings() {
    if [ "$INSTALL_KDE" != true ]; then
        log_info "Skipping KDE settings because PVCLUB_INSTALL_KDE=$INSTALL_KDE"
        return
    fi

    log_info "Applying KDE settings"
    SSH_DEPLOY_DIR="$DOTFILES_DIR" bash "$DOTFILES_DIR/install_kde.sh"
}

print_summary() {
    echo ""
    echo -e "${CYAN}PV Club EndeavourOS setup complete.${NC}"
    echo "Installed the base shell/dotfiles stack plus club workstation security tools."
    echo "Log out and log back in before relying on Docker or Wireshark group access."
    echo "Run nvim once to let plugins finish their first install."
}

main() {
    echo -e "${CYAN}PV Club EndeavourOS Cybersecurity Workstation${NC}"
    echo ""

    detect_endeavouros
    require_tools
    ensure_repo
    upgrade_system
    run_base_deploy
    install_repo_packages
    install_aur_packages
    configure_telegram_proxy
    configure_groups
    configure_hostname
    apply_kde_settings
    print_summary
}

main "$@"
