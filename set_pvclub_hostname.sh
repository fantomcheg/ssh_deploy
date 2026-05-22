#!/usr/bin/env bash
#
# Set a PV Club workstation hostname.
#
# Examples:
#   ./set_pvclub_hostname.sh pvclub02
#   ./set_pvclub_hostname.sh --next
#   ./set_pvclub_hostname.sh --next pbclub
#

set -euo pipefail

DEFAULT_PREFIX="${PVCLUB_HOST_PREFIX:-pvclub}"
HOST_MIN="${PVCLUB_HOST_MIN:-1}"
HOST_MAX="${PVCLUB_HOST_MAX:-99}"

usage() {
    cat <<'EOF'
Usage:
  set_pvclub_hostname.sh <hostname>
  set_pvclub_hostname.sh --next [prefix]

Examples:
  set_pvclub_hostname.sh pvclub02
  set_pvclub_hostname.sh pbclub03
  set_pvclub_hostname.sh --next
  set_pvclub_hostname.sh --next pvclub

The --next check is best-effort: it queries local name resolution and ping for
<name> and <name>.local before selecting the first apparently free suffix.
EOF
}

check_command() {
    command -v "$1" >/dev/null 2>&1
}

validate_hostname() {
    local hostname="$1"

    if [ "${#hostname}" -gt 63 ] || [[ ! "$hostname" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]; then
        echo "Invalid hostname: $hostname" >&2
        echo "Use letters, digits and dashes only; do not start or end with a dash." >&2
        exit 1
    fi
}

host_seen() {
    local name="$1"

    if check_command getent; then
        getent ahostsv4 "$name" >/dev/null 2>&1 && return 0
        getent ahostsv4 "$name.local" >/dev/null 2>&1 && return 0
    fi

    if check_command ping; then
        ping -c 1 -W 1 "$name" >/dev/null 2>&1 && return 0
        ping -c 1 -W 1 "$name.local" >/dev/null 2>&1 && return 0
    fi

    return 1
}

find_next_hostname() {
    local prefix="$1"
    local number candidate

    validate_hostname "$prefix"

    for ((number = HOST_MIN; number <= HOST_MAX; number++)); do
        printf -v candidate '%s%02d' "$prefix" "$number"
        if ! host_seen "$candidate"; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    echo "No apparently free hostname found for prefix $prefix in $HOST_MIN..$HOST_MAX" >&2
    exit 1
}

set_hostname() {
    local hostname="$1"

    validate_hostname "$hostname"

    if host_seen "$hostname"; then
        echo "Warning: $hostname already resolves or answers on the local network." >&2
        echo "Continuing because an explicit hostname was provided." >&2
    fi

    if ! check_command hostnamectl || ! check_command sudo; then
        echo "hostnamectl and sudo are required to set the static hostname." >&2
        exit 1
    fi

    sudo hostnamectl set-hostname "$hostname"
    echo "Hostname set to $hostname"
    echo "Re-login or reboot if applications still show the old name."
}

main() {
    local hostname

    case "${1:-}" in
        -h|--help|'')
            usage
            return 0
            ;;
        --next)
            hostname="$(find_next_hostname "${2:-$DEFAULT_PREFIX}")"
            echo "Selected apparently free hostname: $hostname"
            set_hostname "$hostname"
            ;;
        *)
            if [ "$#" -ne 1 ]; then
                usage >&2
                exit 1
            fi
            set_hostname "$1"
            ;;
    esac
}

main "$@"
