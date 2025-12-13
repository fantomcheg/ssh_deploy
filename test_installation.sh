#!/usr/bin/env bash
#
# Test Installation Script
# Tests all installed tools and writes results to log
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="$HOME/ssh_deploy_test.log"

# Initialize logging
init_logging() {
    echo "═══════════════════════════════════════════════════════════════" > "$LOG_FILE"
    echo "SSH Deploy Installation Tests" >> "$LOG_FILE"
    echo "Date: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
    echo "User: $USER" >> "$LOG_FILE"
    echo "Hostname: $(hostname)" >> "$LOG_FILE"
    echo "═══════════════════════════════════════════════════════════════" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}

log_to_file() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@" >> "$LOG_FILE"
}

check_command() {
    command -v "$1" >/dev/null 2>&1
}

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         🧪 Running Installation Tests                         ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

init_logging
log_to_file "Starting installation tests"

passed_tests=0
failed_tests=0

# Test function with timeout and logging
test_tool() {
    local name="$1"
    local command="$2"
    local test_command="$3"
    
    echo -n "Testing $name... "
    log_to_file "Testing $name ($command)"
    
    if check_command "$command"; then
        # Run test command if provided (with timeout)
        if [ -n "$test_command" ]; then
            log_to_file "Running: $test_command"
            if timeout 3 bash -c "$test_command" >> "$LOG_FILE" 2>&1; then
                echo -e "${GREEN}✓ PASS${NC}"
                log_to_file "✓ PASS: $name"
                ((passed_tests++))
            else
                echo -e "${RED}✗ FAIL${NC} (timeout or error)"
                log_to_file "✗ FAIL: $name (timeout or error)"
                ((failed_tests++))
            fi
        else
            echo -e "${GREEN}✓ PASS${NC}"
            log_to_file "✓ PASS: $name (command exists)"
            ((passed_tests++))
        fi
    else
        echo -e "${YELLOW}⊘ SKIP${NC} (not installed)"
        log_to_file "⊘ SKIP: $name (not installed)"
    fi
}

# Core tools
echo -e "${CYAN}Core Tools:${NC}"
log_to_file "=== Core Tools ==="
test_tool "zsh" "zsh" "zsh --version"
test_tool "neovim" "nvim" "nvim --version"
test_tool "nnn" "nnn" "nnn -V"
test_tool "stow" "stow" "stow --version"
echo ""

# File managers
echo -e "${CYAN}File Managers & System:${NC}"
log_to_file "=== File Managers & System ==="
test_tool "broot" "broot" "broot --version"
test_tool "mc" "mc" "mc --version"
test_tool "tmux" "tmux" "tmux -V"
test_tool "htop" "htop" "htop --version"
echo ""

# Modern CLI tools
echo -e "${CYAN}Modern CLI Tools:${NC}"
log_to_file "=== Modern CLI Tools ==="
test_tool "fzf" "fzf" "fzf --version"
test_tool "bat" "bat" "bat --version"
test_tool "batcat" "batcat" "batcat --version"
test_tool "eza" "eza" "eza --version"
test_tool "fd" "fd" "fd --version"
test_tool "fdfind" "fdfind" "fdfind --version"
test_tool "zoxide" "zoxide" "zoxide --version"
test_tool "tree" "tree" "tree --version"
test_tool "duf" "duf" "duf --version"
test_tool "dust" "dust" "dust --version"
test_tool "jq" "jq" "jq --version"
test_tool "ripgrep" "rg" "rg --version"
test_tool "mtr" "mtr" "mtr --version"
test_tool "dog" "dog" "dog --version"
echo ""

# DevOps tools
echo -e "${CYAN}DevOps Tools:${NC}"
log_to_file "=== DevOps Tools ==="
test_tool "docker" "docker" "docker --version"
if check_command docker; then
    echo -n "Testing docker daemon... "
    log_to_file "Testing docker daemon"
    if timeout 5 sudo docker info >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        log_to_file "✓ PASS: docker daemon running"
        ((passed_tests++))
    else
        echo -e "${RED}✗ FAIL${NC} (daemon not running)"
        log_to_file "✗ FAIL: docker daemon not running"
        ((failed_tests++))
    fi
    
    echo -n "Testing docker group... "
    log_to_file "Testing docker group membership"
    if groups | grep -q docker; then
        echo -e "${GREEN}✓ PASS${NC} (user in group)"
        log_to_file "✓ PASS: user in docker group"
        ((passed_tests++))
    else
        echo -e "${YELLOW}⊘ PENDING${NC} (need logout/login)"
        log_to_file "⊘ PENDING: docker group (need logout/login)"
    fi
fi
echo ""

# System tools
echo -e "${CYAN}System Information:${NC}"
log_to_file "=== System Information ==="
test_tool "fastfetch" "fastfetch" "fastfetch --version"
echo ""

# Configuration files
echo -e "${CYAN}Configuration Files:${NC}"
log_to_file "=== Configuration Files ==="
echo -n "Testing .zshrc... "
if [ -f "$HOME/.zshrc" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    log_to_file "✓ PASS: .zshrc exists"
    ((passed_tests++))
else
    echo -e "${RED}✗ FAIL${NC}"
    log_to_file "✗ FAIL: .zshrc missing"
    ((failed_tests++))
fi

echo -n "Testing nvim config... "
if [ -f "$HOME/.config/nvim/init.lua" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    log_to_file "✓ PASS: nvim/init.lua exists"
    ((passed_tests++))
else
    echo -e "${RED}✗ FAIL${NC}"
    log_to_file "✗ FAIL: nvim/init.lua missing"
    ((failed_tests++))
fi

echo -n "Testing broot config... "
if [ -f "$HOME/.config/broot/conf.hjson" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    log_to_file "✓ PASS: broot/conf.hjson exists"
    ((passed_tests++))
else
    echo -e "${YELLOW}⊘ SKIP${NC}"
    log_to_file "⊘ SKIP: broot/conf.hjson (optional)"
fi

echo -n "Testing fastfetch config... "
if [ -f "$HOME/.config/fastfetch/config.jsonc" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    log_to_file "✓ PASS: fastfetch/config.jsonc exists"
    ((passed_tests++))
else
    echo -e "${YELLOW}⊘ SKIP${NC}"
    log_to_file "⊘ SKIP: fastfetch/config.jsonc (optional)"
fi

echo -n "Testing mc config... "
if [ -f "$HOME/.config/mc/ini" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    log_to_file "✓ PASS: mc/ini exists"
    ((passed_tests++))
else
    echo -e "${YELLOW}⊘ SKIP${NC}"
    log_to_file "⊘ SKIP: mc/ini (optional)"
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Tests passed: $passed_tests${NC}"
if [ $failed_tests -gt 0 ]; then
    echo -e "${RED}Tests failed: $failed_tests${NC}"
fi
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

log_to_file "Tests completed: $passed_tests passed, $failed_tests failed"
log_to_file "═══════════════════════════════════════════════════════════════"

echo -e "${CYAN}📋 Test log saved to:${NC} ${YELLOW}$LOG_FILE${NC}"
echo ""
