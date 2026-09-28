#!/bin/bash
set -e

# =============================================================================
# Hyber Alias Installer
# Cross-platform shell alias manager
# https://github.com/thinhngotony/alias
# =============================================================================

ALIAS_HOME="$HOME/.alias"

# Allow custom repository URL for forks/self-hosting
ALIAS_REPO_URL="${ALIAS_REPO_URL:-https://raw.githubusercontent.com/thinhngotony/alias}"

# Fetch latest version from GitHub releases
VERSION=$(curl -sfS --proto '=https' --connect-timeout 5 --max-time 10 "https://api.github.com/repos/thinhngotony/alias/releases/latest" 2>/dev/null \
    | grep '"tag_name"' | head -1 | sed 's/.*"tag_name" *: *"//;s/".*//' | sed 's/^v//')

if ! printf '%s' "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "Failed to determine the latest release; existing aliases were not changed." >&2
    exit 1
fi

# Install from one immutable release, never from a moving branch.
REPO="${ALIAS_REPO_URL}/v${VERSION}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# Symbols
CHECK="${GREEN}✓${NC}"

# =============================================================================
# Detection
# =============================================================================

detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "linux" ;;
    esac
}

# Detect the user's ACTIVE shell by walking the process tree.
# When run via 'curl | sh' or 'bash install.sh', PPID may not directly
# point to the interactive shell, so we walk ancestors.
detect_active_shell() {
    local pid=$PPID
    local depth=0
    while [ "$pid" -gt 1 ] && [ "$depth" -lt 10 ]; do
        local comm=""
        if [ -f "/proc/$pid/comm" ]; then
            comm=$(cat "/proc/$pid/comm" 2>/dev/null)
        elif command -v ps >/dev/null 2>&1; then
            comm=$(ps -p "$pid" -o comm= 2>/dev/null)
        fi

        case "$comm" in
            fish) echo "fish"; return ;;
            zsh)  echo "zsh";  return ;;
            bash) echo "bash"; return ;;
        esac

        # Move to parent
        if [ -f "/proc/$pid/stat" ]; then
            pid=$(awk '{print $4}' "/proc/$pid/stat" 2>/dev/null || echo 1)
        elif command -v ps >/dev/null 2>&1; then
            pid=$(ps -p "$pid" -o ppid= 2>/dev/null | tr -d ' ')
            [ -z "$pid" ] && pid=1
        else
            break
        fi
        depth=$((depth + 1))
    done

    # Fallback: $SHELL
    case "$SHELL" in
        */zsh)  echo "zsh" ;;
        */fish) echo "fish" ;;
        */bash) echo "bash" ;;
        *)      echo "bash" ;;
    esac
}

# =============================================================================
# Main
# =============================================================================

OS=$(detect_os)
SHELL_TYPE=$(detect_active_shell)

# Detect available shells
HAS_BASH=false
HAS_ZSH=false
HAS_FISH=false
command -v bash >/dev/null 2>&1 && HAS_BASH=true
command -v zsh  >/dev/null 2>&1 && HAS_ZSH=true
command -v fish >/dev/null 2>&1 && HAS_FISH=true

# Header
echo ""
echo -e "${BOLD}Hyber Alias${NC} ${DIM}v${VERSION}${NC}"
echo -e "${DIM}Cross-platform shell alias manager${NC}"
echo ""

# System info
echo -e "${DIM}System${NC}"
echo -e "  OS         ${BOLD}${OS}${NC}"
echo -e "  Shell      ${BOLD}${SHELL_TYPE}${NC}"
echo ""

# Install
echo -e "${DIM}Installing${NC}"

mkdir -p "$ALIAS_HOME/releases" "$ALIAS_HOME/custom"
echo -e "  ${CHECK} Created ${DIM}~/.alias${NC}"

# Safe download helper
_safe_download() {
    local url="$1" dest="$2" label="$3" tmp
    tmp=$(mktemp "$(dirname "$dest")/.download.XXXXXX") || return 1
    if curl -sfS --proto '=https' --connect-timeout 5 --max-time 30 "$url" -o "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
        mv "$tmp" "$dest" && return 0
    fi
    rm -f "$tmp"
    echo -e "  ${RED}✗${NC} Failed to download $label" >&2
    return 1
}

# Fetch a complete release before changing any installed files.
if [ -d "$ALIAS_HOME/.install.lock" ]; then
    lock_mtime=$(stat -c %Y "$ALIAS_HOME/.install.lock" 2>/dev/null || stat -f %m "$ALIAS_HOME/.install.lock" 2>/dev/null)
    now=$(date +%s)
    if [ -n "$lock_mtime" ] && [ "$((now - lock_mtime))" -gt 600 ]; then
        rmdir "$ALIAS_HOME/.install.lock" 2>/dev/null || true
    fi
fi
if ! mkdir "$ALIAS_HOME/.install.lock" 2>/dev/null; then
    echo "Another installation is in progress." >&2
    exit 1
fi
stage=$(mktemp -d "$ALIAS_HOME/releases/.install.XXXXXX") || {
    rmdir "$ALIAS_HOME/.install.lock"
    exit 1
}
trap 'rm -rf "$stage"; rmdir "$ALIAS_HOME/.install.lock" 2>/dev/null' EXIT

_safe_download "$REPO/load.sh" "$stage/load.sh" "loader"
for name in git k8s system secrets ai; do
    _safe_download "$REPO/aliases/$name.sh" "$stage/$name.sh" "$name aliases"
done
_safe_download "$REPO/aliases/fish.fish" "$stage/fish.fish" "fish aliases"
chmod +x "$stage/load.sh"

release="$ALIAS_HOME/releases/v$VERSION"
if [ ! -d "$release" ]; then
    mv "$stage" "$release"
else
    for name in load git k8s system secrets ai; do
        if [ ! -s "$release/$name.sh" ]; then
            echo "Installed release is incomplete: $release" >&2
            exit 1
        fi
    done
    [ -s "$release/fish.fish" ]
fi

if [ "$HAS_BASH" = true ] || [ "$HAS_ZSH" = true ]; then
    loader_tmp=$(mktemp "$ALIAS_HOME/load.sh.XXXXXX")
    cp "$release/load.sh" "$loader_tmp"
    chmod +x "$loader_tmp"
    mv "$loader_tmp" "$ALIAS_HOME/load.sh"
    echo -e "  ${CHECK} Downloaded aliases"
fi

# Configure bash
if [ "$HAS_BASH" = true ] && [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "/.alias/load.sh" "$HOME/.bashrc" 2>/dev/null; then
        {
            echo ""
            echo "# Hyber Alias - https://github.com/thinhngotony/alias"
            echo "[ -f ~/.alias/load.sh ] && source ~/.alias/load.sh"
        } >> "$HOME/.bashrc"
        echo -e "  ${CHECK} Configured ${DIM}~/.bashrc${NC}"
    else
        echo -e "  ${CHECK} Already configured ${DIM}~/.bashrc${NC}"
    fi
fi

# Configure zsh
if [ "$HAS_ZSH" = true ] && [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "/.alias/load.sh" "$HOME/.zshrc" 2>/dev/null; then
        {
            echo ""
            echo "# Hyber Alias - https://github.com/thinhngotony/alias"
            echo "[ -f ~/.alias/load.sh ] && source ~/.alias/load.sh"
        } >> "$HOME/.zshrc"
        echo -e "  ${CHECK} Configured ${DIM}~/.zshrc${NC}"
    else
        echo -e "  ${CHECK} Already configured ${DIM}~/.zshrc${NC}"
    fi
fi

# Configure fish
if [ "$HAS_FISH" = true ]; then
    mkdir -p "$HOME/.config/fish/conf.d"
    fish_tmp=$(mktemp "$HOME/.config/fish/conf.d/.hyber-alias.XXXXXX")
    cp "$release/fish.fish" "$fish_tmp"
    mv "$fish_tmp" "$HOME/.config/fish/conf.d/hyber-alias.fish"
    echo -e "  ${CHECK} Configured ${DIM}fish (conf.d)${NC}"
fi

# Save environment
env_tmp=$(mktemp "$ALIAS_HOME/env.sh.XXXXXX")
cat > "$env_tmp" << EOF
export HYBER_VERSION="${VERSION}"
export HYBER_CACHE_LAYOUT="release"
export HYBER_SHELL="${SHELL_TYPE}"
export HYBER_OS="${OS}"
EOF
chmod 600 "$env_tmp"
mv "$env_tmp" "$ALIAS_HOME/env.sh"
rm -f "$ALIAS_HOME/.update-available"
touch "$ALIAS_HOME/.update-check"
echo -e "  ${CHECK} Saved environment"

echo ""

# Success
echo -e "${GREEN}${BOLD}Installation complete${NC}"
echo ""
echo -e "${DIM}Quick start${NC}"
echo ""
echo -e "  ${CYAN}alias-help${NC}     Show all available aliases"
echo -e "  ${CYAN}alias-git${NC}      Git shortcuts (ga, gc, gs, gph...)"
echo -e "  ${CYAN}alias-k8s${NC}      Kubernetes shortcuts (k, kgp, kgs...)"
echo -e "  ${CYAN}alias-add${NC}      Add custom aliases to categories"
echo ""
echo -e "${DIM}Documentation${NC}  https://github.com/thinhngotony/alias"
echo ""

# Print activation for ALL configured shells
echo -e "${BOLD}Activate aliases${NC}"
echo ""

_printed=0
if [ "$HAS_FISH" = true ]; then
    if [ "$SHELL_TYPE" = "fish" ]; then
        echo -e "  Run: ${CYAN}source ~/.config/fish/conf.d/hyber-alias.fish${NC}  ${GREEN}← your shell${NC}"
    else
        echo -e "  fish:  ${DIM}source ~/.config/fish/conf.d/hyber-alias.fish${NC}"
    fi
    _printed=1
fi
if [ "$HAS_BASH" = true ] && [ -f "$HOME/.bashrc" ]; then
    if [ "$SHELL_TYPE" = "bash" ]; then
        echo -e "  Run: ${CYAN}source ~/.bashrc${NC}  ${GREEN}← your shell${NC}"
    else
        echo -e "  bash:  ${DIM}source ~/.bashrc${NC}"
    fi
    _printed=1
fi
if [ "$HAS_ZSH" = true ] && [ -f "$HOME/.zshrc" ]; then
    if [ "$SHELL_TYPE" = "zsh" ]; then
        echo -e "  Run: ${CYAN}source ~/.zshrc${NC}  ${GREEN}← your shell${NC}"
    else
        echo -e "  zsh:   ${DIM}source ~/.zshrc${NC}"
    fi
    _printed=1
fi
if [ "$_printed" -eq 0 ]; then
    echo -e "  Run: ${CYAN}source ~/.bashrc${NC}"
fi

echo ""
echo -e "  Or open a new terminal."
echo ""
