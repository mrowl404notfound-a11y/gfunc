#!/usr/bin/env bash
set -euo pipefail

# ── gfunc installer ──────────────────────────────────────────────────────────
# Installs gfunc to ~/.local/bin (or custom prefix)
# Usage:
#   ./install.sh              # Install to ~/.local/bin
#   ./install.sh /usr/local   # Install to /usr/local/bin
#   curl ... | bash           # Pipe install

REPO="YOUR_USERNAME/gfunc"
INSTALL_DIR="${1:-$HOME/.local/bin}"
SCRIPT_NAME="gfunc"

# Colors
RED='\033[91m'
GRN='\033[92m'
YEL='\033[93m'
CYN='\033[96m'
RST='\033[0m'
BLD='\033[1m'

info()  { echo -e "${CYN}▸${RST} $*"; }
ok()    { echo -e "${GRN}✓${RST} $*"; }
warn()  { echo -e "${YEL}⚠${RST} $*"; }
fail()  { echo -e "${RED}✗${RST} $*" >&2; exit 1; }

echo -e "${BLD}── gfunc installer ──${RST}"
echo ""

# ── Check Python ─────────────────────────────────────────────────────────────
info "Checking Python..."
if command -v python3 &>/dev/null; then
    PY_VERSION=$(python3 --version 2>&1 | grep -oP '\d+\.\d+')
    PY_MAJOR=$(echo "$PY_VERSION" | cut -d. -f1)
    PY_MINOR=$(echo "$PY_VERSION" | cut -d. -f2)
    if [ "$PY_MAJOR" -ge 3 ] && [ "$PY_MINOR" -ge 8 ]; then
        ok "Python $PY_VERSION found"
    else
        fail "Python 3.8+ required, found $PY_VERSION"
    fi
else
    fail "Python 3 not found. Install it first: https://python.org"
fi

# ── Check ripgrep (optional) ────────────────────────────────────────────────
info "Checking ripgrep (optional)..."
if command -v rg &>/dev/null; then
    RG_VERSION=$(rg --version | head -1 | grep -oP '[\d.]+')
    ok "ripgrep $RG_VERSION found (fast mode enabled)"
else
    warn "ripgrep not found — gfunc will use Python fallback (slower)"
    echo "    Install: sudo apt install ripgrep  |  brew install ripgrep"
fi

# ── Create install directory ────────────────────────────────────────────────
info "Installing to ${INSTALL_DIR}..."
mkdir -p "$INSTALL_DIR"

# ── Determine source ────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd 2>/dev/null || true)"

if [ -f "$SCRIPT_DIR/$SCRIPT_NAME" ]; then
    # Local install (cloned repo)
    cp "$SCRIPT_DIR/$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
    ok "Copied from local repo"
elif command -v curl &>/dev/null; then
    # Remote install (piped)
    curl -fsSL "https://raw.githubusercontent.com/${REPO}/main/gfunc" \
        -o "$INSTALL_DIR/$SCRIPT_NAME"
    ok "Downloaded from GitHub"
elif command -v wget &>/dev/null; then
    wget -qO "$INSTALL_DIR/$SCRIPT_NAME" \
        "https://raw.githubusercontent.com/${REPO}/main/gfunc"
    ok "Downloaded from GitHub"
else
    fail "Neither curl nor wget found. Install one of them first."
fi

chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
ok "Made executable"

# ── Check PATH ──────────────────────────────────────────────────────────────
if echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    ok "$INSTALL_DIR is in PATH"
else
    warn "$INSTALL_DIR is not in your PATH"
    echo ""
    echo "    Add this to your ~/.bashrc or ~/.zshrc:"
    echo ""
    echo "      export PATH=\"$INSTALL_DIR:\$PATH\""
    echo ""
fi

# ── Verify ──────────────────────────────────────────────────────────────────
echo ""
if command -v gfunc &>/dev/null; then
    echo -e "${GRN}${BLD}✅ gfunc installed successfully!${RST}"
    echo ""
    echo "  Quick start:"
    echo "    gfunc swap .                  # Find swap functions"
    echo "    gfunc --slice deposit src/    # Generate super slice"
    echo "    gfunc --help                  # All options"
else
    echo -e "${YEL}${BLD}⚠ Installed, but 'gfunc' not found in PATH yet.${RST}"
    echo "  Restart your terminal or run: export PATH=\"$INSTALL_DIR:\$PATH\""
fi
echo ""
