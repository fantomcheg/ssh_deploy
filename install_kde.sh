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
WALLPAPER_ASSET_PATH="$HOME/.local/share/wallpapers/pvclub/pvclub.PNG"
WALLPAPER_PATH="$WALLPAPER_ASSET_PATH"
PLASMA_SHELL_WAS_RUNNING=false

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

stop_plasma_shell() {
    if ! pgrep -x plasmashell >/dev/null 2>&1; then
        return
    fi

    PLASMA_SHELL_WAS_RUNNING=true
    log_info "Stopping plasmashell before replacing panel layout..."

    if check_command kquitapp6; then
        kquitapp6 plasmashell >/dev/null 2>&1 || true
    elif check_command qdbus6; then
        qdbus6 org.kde.plasmashell /MainApplication quit >/dev/null 2>&1 || true
    fi

    local attempt
    for attempt in 1 2 3 4 5; do
        pgrep -x plasmashell >/dev/null 2>&1 || break
        sleep 1
    done

    if pgrep -x plasmashell >/dev/null 2>&1 && check_command killall; then
        killall plasmashell >/dev/null 2>&1 || true
        sleep 1
    fi

    if pgrep -x plasmashell >/dev/null 2>&1; then
        log_warning "plasmashell is still running; old panel state may be written back"
    else
        log_success "plasmashell stopped"
    fi
}

start_plasma_shell() {
    if [ "$PLASMA_SHELL_WAS_RUNNING" != true ]; then
        return
    fi

    if pgrep -x plasmashell >/dev/null 2>&1; then
        log_success "plasmashell already running"
        return
    fi

    if check_command plasmashell; then
        log_info "Starting plasmashell with the PV Club panel layout..."
        plasmashell --replace >/dev/null 2>&1 &
        disown 2>/dev/null || true
        log_success "plasmashell start requested"
    else
        log_warning "plasmashell not found; log out and back in to load the panel layout"
    fi
}

copy_kde_settings() {
    log_info "Copying KDE settings package..."
    if cp -a "$KDE_DIR/." "$HOME/"; then
        log_success "KDE settings copied"
    else
        log_error "Failed to copy KDE settings"
        exit 1
    fi
}

get_pictures_dir() {
    local pictures_dir=""

    if check_command xdg-user-dir; then
        pictures_dir=$(xdg-user-dir PICTURES 2>/dev/null || true)
    fi

    if [ -n "$pictures_dir" ] && [ "$pictures_dir" != "$HOME" ]; then
        printf '%s\n' "$pictures_dir"
    else
        printf '%s\n' "$HOME/Изображения"
    fi
}

copy_wallpaper_to_pictures() {
    local pictures_dir

    if [ ! -f "$WALLPAPER_ASSET_PATH" ]; then
        log_warning "PV Club wallpaper asset is missing at $WALLPAPER_ASSET_PATH"
        return
    fi

    pictures_dir=$(get_pictures_dir)
    WALLPAPER_PATH="$pictures_dir/pvclub.PNG"

    log_info "Copying PV Club wallpaper to $pictures_dir..."
    if mkdir -p "$pictures_dir" && cp -f "$WALLPAPER_ASSET_PATH" "$WALLPAPER_PATH"; then
        log_success "PV Club wallpaper copied to $WALLPAPER_PATH"
    else
        WALLPAPER_PATH="$WALLPAPER_ASSET_PATH"
        log_warning "Failed to copy wallpaper to Pictures; using $WALLPAPER_PATH"
    fi
}

apply_wallpaper() {
    local applets_config="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

    if [ ! -f "$WALLPAPER_PATH" ]; then
        log_warning "PV Club wallpaper is missing at $WALLPAPER_PATH"
        return
    fi

    if [ -f "$applets_config" ]; then
        log_info "Replacing saved desktop wallpaper path with the installed PV Club asset..."
        sed -i "s|^Image=.*pvclub\\.PNG\$|Image=$WALLPAPER_PATH|" "$applets_config"
    fi

    if check_command plasma-apply-wallpaperimage; then
        log_info "Applying PV Club desktop wallpaper..."
        if plasma-apply-wallpaperimage "$WALLPAPER_PATH" >/dev/null 2>&1; then
            log_success "Desktop wallpaper applied"
        else
            log_warning "Failed to apply desktop wallpaper automatically"
        fi
    else
        log_warning "plasma-apply-wallpaperimage is unavailable; using copied KDE wallpaper settings"
    fi

    if check_command kwriteconfig6; then
        log_info "Persisting PV Club wallpaper paths in KDE configs..."
        kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
            --group Containments \
            --group 46 \
            --group Wallpaper \
            --group org.kde.image \
            --group General \
            --key Image "$WALLPAPER_PATH"
        kwriteconfig6 --file kscreenlockerrc \
            --group Greeter \
            --group Wallpaper \
            --group org.kde.image \
            --group General \
            --key Image "$WALLPAPER_PATH"
        kwriteconfig6 --file kscreenlockerrc \
            --group Greeter \
            --group Wallpaper \
            --group org.kde.image \
            --group General \
            --key PreviewImage "$WALLPAPER_PATH"
        log_success "Desktop and lock screen wallpaper paths applied"
    else
        log_warning "kwriteconfig6 is unavailable; lock screen wallpaper was not configured"
    fi
}

apply_empty_session() {
    if ! check_command kwriteconfig6; then
        log_warning "kwriteconfig6 is unavailable; empty Plasma session mode was not configured"
        return
    fi

    log_info "Configuring Plasma to start with an empty session..."
    kwriteconfig6 --file ksmserverrc \
        --group General \
        --key loginMode emptySession
    log_success "Empty Plasma session mode applied"
}

apply_kde_settings() {
    if [ ! -d "$KDE_DIR" ]; then
        log_warning "No kde package found in $DOTFILES_DIR"
        log_warning "This usually means $DOTFILES_DIR is an old clone without the new KDE package."
        log_warning "Fix: cd $DOTFILES_DIR && git pull --ff-only origin main"
        return 0
    fi

    stop_plasma_shell
    trap start_plasma_shell EXIT
    backup_existing_kde_files
    copy_kde_settings

    copy_wallpaper_to_pictures
    apply_wallpaper
    apply_empty_session
    start_plasma_shell
    trap - EXIT

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
    apply_kde_settings
}

main "$@"
