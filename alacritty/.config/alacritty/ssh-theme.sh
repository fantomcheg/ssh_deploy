# source из ~/.zshrc
# emulate -L zsh 2>/dev/null || true  # Закомментировано - блокирует доступ к $ALACRITTY_SOCKET

# --- Найти сокет Alacritty (env → tmux → find) ---
_alac_socket() {
  # 1) из окружения текущего процесса
  if [ -n "$ALACRITTY_SOCKET" ] && [ -S "$ALACRITTY_SOCKET" ]; then
    printf '%s\n' "$ALACRITTY_SOCKET"; return
  fi
  # 2) из глобального окружения tmux
  if command -v tmux >/dev/null 2>&1 && tmux has-session 2>/dev/null; then
    local line sock
    line="$(tmux show-environment ALACRITTY_SOCKET 2>/dev/null | grep -v "^-" | tail -n1)"
    sock="${line#ALACRITTY_SOCKET=}"
    if [ -n "$sock" ] && [ -S "$sock" ]; then printf '%s\n' "$sock"; return; fi
  fi
  # 3) fallback: найти самый "свежий" сокет Alacritty*
  local s
  s="$(
    { find "/run/user/$UID" -type s -name 'Alacritty*.sock' -printf '%T@ %p\n' 2>/dev/null;
      find "/tmp"            -type s -name 'Alacritty*.sock' -printf '%T@ %p\n' 2>/dev/null; } |
    sort -nr | awk 'NR==1{$1="";sub(/^ /,"");print}'
  )"
  [ -n "$s" ] && printf '%s\n' "$s"
}

# --- Применить тему (каждый ключ отдельным аргументом 'k=v') ---
_alac_apply_theme() {
  local sock="$1"; shift
  [ -n "$sock" ] && [ -S "$sock" ] || return 0
  alacritty msg -s "$sock" config "$@" >/dev/null 2>&1 || true
}

# --- Полные палитры (массивы аргументов) ---
DRACULA_ARGS=(
  'colors.primary.background="#282a36"' 'colors.primary.foreground="#f8f8f2"'
  'colors.normal.black="#000000"'  'colors.normal.red="#ff5555"'
  'colors.normal.green="#50fa7b"'  'colors.normal.yellow="#f1fa8c"'
  'colors.normal.blue="#bd93f9"'   'colors.normal.magenta="#ff79c6"'
  'colors.normal.cyan="#8be9fd"'   'colors.normal.white="#bbbbbb"'
  'colors.bright.black="#555555"'  'colors.bright.red="#ff5555"'
  'colors.bright.green="#50fa7b"'  'colors.bright.yellow="#f1fa8c"'
  'colors.bright.blue="#caa9fa"'   'colors.bright.magenta="#ff79c6"'
  'colors.bright.cyan="#8be9fd"'   'colors.bright.white="#ffffff"'
)

CYBER_ARGS=(
  'colors.draw_bold_text_with_bright_colors=true'
  'colors.primary.background="#000b1e"' 'colors.primary.foreground="#0abdc6"'
  'colors.normal.black="#123e7c"'   'colors.normal.red="#ff0000"'
  'colors.normal.green="#d300c4"'   'colors.normal.yellow="#f57800"'
  'colors.normal.blue="#123e7c"'    'colors.normal.magenta="#711c91"'
  'colors.normal.cyan="#0abdc6"'    'colors.normal.white="#d7d7d5"'
  'colors.bright.black="#1c61c2"'   'colors.bright.red="#ff0000"'
  'colors.bright.green="#d300c4"'   'colors.bright.yellow="#f57800"'
  'colors.bright.blue="#00ff00"'    'colors.bright.magenta="#711c91"'
  'colors.bright.cyan="#0abdc6"'    'colors.bright.white="#d7d7d5"'
  'colors.dim.black="#1c61c2"'      'colors.dim.red="#ff0000"'
  'colors.dim.green="#d300c4"'      'colors.dim.yellow="#f57800"'
  'colors.dim.blue="#123e7c"'       'colors.dim.magenta="#711c91"'
  'colors.dim.cyan="#0abdc6"'       'colors.dim.white="#d7d7d5"'
)

# --- Ручные переключатели (по желанию) ---
dracula-theme()   { _alac_apply_theme "$ALACRITTY_SOCKET" "${DRACULA_ARGS[@]}"; }
cyberpunk-theme() { _alac_apply_theme "$ALACRITTY_SOCKET" "${CYBER_ARGS[@]}"; }

# --- Общий раннер вокруг SSH ---
_ssh_with_theme() {
  local sock="$ALACRITTY_SOCKET"
  _alac_apply_theme "$sock" "${CYBER_ARGS[@]}"
  _restore() { 
    _alac_apply_theme "$sock" "${DRACULA_ARGS[@]}"
  }
  trap _restore EXIT INT TERM
  command "$@"
  local rc=$?
  _restore
  trap - EXIT INT TERM
  return $rc
}

# --- Обёртки SSH (заменяют старые алиасы) ---
unalias guyver punklab punkration 2>/dev/null || true
unset -f guyver punklab punkration 2>/dev/null || true

# Обёртка для обычного ssh - ОТКЛЮЧЕНА, чтобы не ломать обычные ssh команды
# Используйте конкретные алиасы (rtlabs, punklab и т.д.) для автоматической смены темы
# ssh() {
#   _ssh_with_theme command ssh "$@"
# }

rtlabs() {
  _ssh_with_theme ssh -l xrapid 51.250.101.29 -i "$HOME/.ssh/yacloud" "$@"
}
punklab() {
  _ssh_with_theme ssh -i "$HOME/.ssh/yacloud" xrapid@51.250.54.110 "$@"
}
punkration() {
  # Через proxy v2raya (SOCKS5 на 127.0.0.1:20170)
  _ssh_with_theme ssh -o ProxyCommand="nc -X 5 -x 127.0.0.1:20170 %h %p" root@212.109.222.78 "$@"
}
appseclabs() {
  _ssh_with_theme ssh -i ~/.ssh/yacloud xrapid@51.250.123.111 "$@"
}

# --- Обёртка для LFTP ---
lftp() {
  _ssh_with_theme /usr/bin/lftp "$@"
}
