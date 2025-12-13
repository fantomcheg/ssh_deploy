#!/usr/bin/env bash
#
# Test Installation Script
# Tests all installed tools and writes results to log
#

# Don't exit on error - we want to run all tests
set +e

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

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         🧪 Running Installation Tests                         ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

init_logging
log_to_file "Starting installation tests"

passed_tests=0
failed_tests=0

# Simple test function - just checks if command exists
test_tool() {
    local name="$1"
    local command="$2"
    
    echo -n "  Testing $name... "
    log_to_file "Testing $name ($command)"
    
    if which "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        log_to_file "✓ PASS: $name (found at $(which $command 2>/dev/null))"
        passed_tests=$((passed_tests + 1))
    else
        echo -e "${YELLOW}⊘ SKIP${NC} (not installed)"
        log_to_file "⊘ SKIP: $name (not installed)"
    fi
}

# Core tools
echo -e "${CYAN}Core Tools:${NC}"
log_to_file "=== Core Tools ==="
test_tool "zsh" "zsh"
test_tool "neovim" "nvim"
test_tool "nnn" "nnn"
test_tool "stow" "stow"
echo ""

# File managers
echo -e "${CYAN}File Managers & System:${NC}"
log_to_file "=== File Managers & System ==="
test_tool "mc" "mc"
test_tool "tmux" "tmux"
test_tool "htop" "htop"
echo ""

# Modern CLI tools
echo -e "${CYAN}Modern CLI Tools:${NC}"
log_to_file "=== Modern CLI Tools ==="
test_tool "fzf" "fzf"
test_tool "bat" "bat"
test_tool "batcat" "batcat"
test_tool "eza" "eza"
test_tool "fd" "fd"
test_tool "fdfind" "fdfind"
test_tool "zoxide" "zoxide"
test_tool "tree" "tree"
test_tool "duf" "duf"
test_tool "dust" "dust"
test_tool "jq" "jq"
test_tool "rg" "rg"
test_tool "mtr" "mtr"
echo ""

# DevOps tools
echo -e "${CYAN}DevOps Tools:${NC}"
log_to_file "=== DevOps Tools ==="
test_tool "docker" "docker"
echo ""

# Configuration files
echo -e "${CYAN}Configuration Files:${NC}"
log_to_file "=== Configuration Files ==="
echo -n "  Testing .zshrc... "
if [ -f "$HOME/.zshrc" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    log_to_file "✓ PASS: .zshrc exists"
    passed_tests=$((passed_tests + 1))
else
    echo -e "${RED}✗ FAIL${NC}"
    log_to_file "✗ FAIL: .zshrc missing"
    failed_tests=$((failed_tests + 1))
fi

echo -n "  Testing nvim config... "
if [ -f "$HOME/.config/nvim/init.lua" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    log_to_file "✓ PASS: nvim/init.lua exists"
    passed_tests=$((passed_tests + 1))
else
    echo -e "${RED}✗ FAIL${NC}"
    log_to_file "✗ FAIL: nvim/init.lua missing"
    failed_tests=$((failed_tests + 1))
fi

echo -n "  Testing mc config... "
if [ -f "$HOME/.config/mc/ini" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    log_to_file "✓ PASS: mc/ini exists"
    passed_tests=$((passed_tests + 1))
else
    echo -e "${YELLOW}⊘ SKIP${NC} (optional)"
    log_to_file "⊘ SKIP: mc/ini (optional)"
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Tests passed: $passed_tests${NC}"
if [ $failed_tests -gt 0 ]; then
    echo -e "${RED}✗ Tests failed: $failed_tests${NC}"
fi
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

log_to_file "Tests completed: $passed_tests passed, $failed_tests failed"
log_to_file "═══════════════════════════════════════════════════════════════"

echo -e "${CYAN}📋 Test log saved to:${NC} ${YELLOW}$LOG_FILE${NC}"
echo ""
