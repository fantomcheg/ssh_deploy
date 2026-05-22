pvclub_splash() {
  [[ -o interactive ]] || return 0
  [[ -t 1 ]] || return 0
  [[ "${TERM:-}" == "dumb" ]] && return 0
  [[ "${PVCLUB_SPLASH:-on}" == "off" ]] && return 0

  local reset=$'\033[0m'
  local bold=$'\033[1m'
  local cyan=$'\033[38;5;45m'
  local blue=$'\033[38;5;39m'
  local green=$'\033[38;5;118m'
  local magenta=$'\033[38;5;201m'
  local red=$'\033[38;5;196m'
  local yellow=$'\033[38;5;220m'
  local gray=$'\033[38;5;245m'
  local host="${HOST:-$(hostname 2>/dev/null)}"
  local kernel="$(uname -r 2>/dev/null)"
  local now="$(date '+%Y-%m-%d %H:%M' 2>/dev/null)"
  local os="unknown"
  local cpu="unknown"
  local ram="unknown"
  local uptime="unknown"
  local ip_addr="offline"
  local user_name="${USER:-$(id -un 2>/dev/null)}"
  local icon_user=""
  local icon_host="󰒋"
  local icon_os=""
  local icon_kernel=""
  local icon_cpu=""
  local icon_ram=""
  local icon_uptime="󰔟"
  local icon_lan="󰩠"
  local icon_time="󰥔"
  local icon_red="󰈸"
  local icon_blue="󰌾"
  local icon_lab="󰙨"
  local icon_access="󰌆"
  local icon_offline="󰲛"
  local icon_trace="󰆧"

  if [[ -r /etc/os-release ]]; then
    os="$(. /etc/os-release 2>/dev/null; printf '%s' "${PRETTY_NAME:-$NAME}")"
  fi

  if [[ -r /proc/cpuinfo ]]; then
    cpu="$(awk -F': ' '/model name/ { print $2; exit }' /proc/cpuinfo 2>/dev/null)"
    cpu="$(printf '%s' "$cpu" | sed \
      -e 's/ with Radeon Graphics//g' \
      -e 's/^AMD Ryzen /Ryzen /' \
      -e 's/Intel(R) Core(TM) /Intel /' \
      -e 's/Intel(R) /Intel /' \
      -e 's/(R)//g' \
      -e 's/(TM)//g')"
  fi

  if [[ -r /proc/meminfo ]]; then
    ram="$(awk '
      /MemTotal/ { total=$2 }
      /MemAvailable/ { avail=$2 }
      END {
        if (total > 0) {
          used=total-avail
          printf "%.1f / %.1f GiB", used/1048576, total/1048576
        }
      }
    ' /proc/meminfo 2>/dev/null)"
  fi

  if command -v uptime >/dev/null 2>&1; then
    uptime="$(uptime -p 2>/dev/null)"
    uptime="${uptime#up }"
    uptime="${uptime/ hours/h}"
    uptime="${uptime/ hour/h}"
    uptime="${uptime/ minutes/m}"
    uptime="${uptime/ minute/m}"
    uptime="${uptime//, / }"
  fi

  if command -v ip >/dev/null 2>&1; then
    ip_addr="$(ip -o -4 addr show scope global 2>/dev/null | awk '{ split($4, a, "/"); print a[1]; exit }')"
    [[ -n "$ip_addr" ]] || ip_addr="offline"
  fi

  printf '\n'
  printf '%s' "$green"
  printf '  %s\n' '╭────────────────────────────────────────────────────────────────╮'
  printf '  %s' '│'
  printf '%s' "$cyan"
  printf '    ____ _    _   ____ _     _   _ ____  ⣀⡠⢤⡀                   '
  printf '%s\n' "$green│"
  printf '  %s' '│'
  printf '%s' "$cyan"
  printf '   |  _ \ \  / / / ___| |   | | | | __ )  ⢀⡴⠟⠃⠀⠀⠙⣄              '
  printf '%s\n' "$green│"
  printf '  %s' '│'
  printf '%s' "$cyan"
  printf '   | |_) \ \/ / | |   | |   | | | |  _ \  ⣠⠋⠀⠀⠀⠀⠀⠀⠘⣆            '
  printf '%s\n' "$green│"
  printf '  %s' '│'
  printf '%s' "$cyan"
  printf '   |  __/ \  /  | |___| |___| |_| | |_) |  ⢠⠾⢛⠒⠀⠀⠀⠀⠀⠀⠀⢸⡆        '
  printf '%s\n' "$green│"
  printf '  %s' '│'
  printf '%s' "$cyan"
  printf '   |_|     \/    \____|_____|\___/|____/  ⣿⣶⣄⡈⠓⢄⠠⡀⠀⠀⠀⣄⣷         '
  printf '%s\n' "$green│"
  printf '  %s%s%s\n' '│' '                                                                ' '│'
  printf '  %s' '│'
  printf '%s' "$gray"
  printf '    [ '
  printf '%s' "$red"
  printf '%s RED TEAM' "$icon_red"
  printf '%s' "$gray"
  printf ' / '
  printf '%s' "$blue"
  printf '%s BLUE TEAM' "$icon_blue"
  printf '%s' "$gray"
  printf ' / '
  printf '%s' "$green"
  printf '%s LOCAL LAB' "$icon_lab"
  printf '%s' "$gray"
  printf ' ]                  '
  printf '%s\n' "$green│"
  printf '  %s\n' '├────────────────────────────────────────────────────────────────┤'
  printf '  %s' '│'
  printf '%s%s  %s user%s  %-17s %s%s node%s   %-16s           %s\n' "$yellow" "$bold" "$icon_user" "$reset" "$user_name" "$yellow" "$icon_host" "$reset" "$host" "$green│"
  printf '  %s' '│'
  printf '%s  %s os%s    %-17s %s%s kernel%s %-16.16s           %s\n' "$blue" "$icon_os" "$reset" "$os" "$blue" "$icon_kernel" "$reset" "$kernel" "$green│"
  printf '  %s' '│'
  printf '%s  %s cpu%s   %-17.17s %s%s ram%s    %-16s           %s\n' "$blue" "$icon_cpu" "$reset" "$cpu" "$blue" "$icon_ram" "$reset" "$ram" "$green│"
  printf '  %s' '│'
  printf '%s  %s lan%s   %-17s %s%s time%s   %-16s           %s\n' "$blue" "$icon_lan" "$reset" "$ip_addr" "$blue" "$icon_time" "$reset" "$now" "$green│"
  printf '  %s\n' '├────────────────────────────────────────────────────────────────┤'
  printf '  %s' '│'
  printf '%s' "$magenta"
  printf '   %s AUTH  %s OFFLINE  %s UP %-8.8s  %s /dev/null                ' "$icon_access" "$icon_offline" "$icon_uptime" "$uptime" "$icon_trace"
  printf '%s\n' "$green│"
  printf '  %s\n' '╰────────────────────────────────────────────────────────────────╯'
  printf '%s\n' "$reset"
}

pvclub_splash
