#!/bin/sh
# =============================================================================
# Hyber Alias Universal Installer
# Auto-detects shell and installs appropriate aliases
# Works from any shell: bash, zsh, fish, sh
# =============================================================================

ALIAS_HOME="$HOME/.alias"

# Allow custom repository URL for forks/self-hosting
ALIAS_REPO_URL="${ALIAS_REPO_URL:-https://raw.githubusercontent.com/thinhngotony/alias}"

# Fetch latest version from GitHub releases
VERSION=$(curl -sfS --proto '=https' --connect-timeout 5 --max-time 10 "https://api.github.com/repos/thinhngotony/alias/releases/latest" 2>/dev/null \
    | grep '"tag_name"' | head -1 | sed 's/.*"tag_name" *: *"//;s/".*//' | sed 's/^v//')

if ! printf '%s' "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    printf 'Failed to determine the latest release; existing aliases were not changed.\n' >&2
    exit 1
fi

# Install from one immutable release, never from a moving branch.
REPO="${ALIAS_REPO_URL}/v${VERSION}"

# Colors (POSIX compatible)
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*) echo "linux" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "linux" ;;
    esac
}

# Detect the user's ACTIVE shell by walking the process tree.
# When run via 'curl | sh', PPID may point to a pipe or subshell,
# so we walk up the ancestor chain to find the first real shell.
detect_active_shell() {
    _pid=$PPID
    _depth=0
    while [ "$_pid" -gt 1 ] && [ "$_depth" -lt 10 ]; do
        _comm=""
        if [ -f "/proc/$_pid/comm" ]; then
            _comm=$(cat "/proc/$_pid/comm" 2>/dev/null)
        elif command -v ps >/dev/null 2>&1; then
            _comm=$(ps -p "$_pid" -o comm= 2>/dev/null)
        fi

        case "$_comm" in
            fish) echo "fish"; return ;;
            zsh)  echo "zsh";  return ;;
            bash) echo "bash"; return ;;
        esac

        # Move to parent: read PPID from /proc/PID/stat (field 4)
        if [ -f "/proc/$_pid/stat" ]; then
            _pid=$(awk '{print $4}' "/proc/$_pid/stat" 2>/dev/null || echo 1)
        elif command -v ps >/dev/null 2>&1; then
            _pid=$(ps -p "$_pid" -o ppid= 2>/dev/null | tr -d ' ')
            [ -z "$_pid" ] && _pid=1
        else
            break
        fi
        _depth=$((_depth + 1))
    done

    # Fallback: $SHELL (login shell)
    _shell_name=$(basename "$SHELL")
    case "$_shell_name" in
        zsh)  echo "zsh" ;;
        fish) echo "fish" ;;
        bash) echo "bash" ;;
        *)    echo "bash" ;;
    esac
}

OS=$(detect_os)
USER_SHELL=$(detect_active_shell)

# Detect which shells are available on this system
HAS_BASH=false
HAS_ZSH=false
HAS_FISH=false
command -v bash >/dev/null 2>&1 && HAS_BASH=true
command -v zsh  >/dev/null 2>&1 && HAS_ZSH=true
command -v fish >/dev/null 2>&1 && HAS_FISH=true

# Safe download helper: downloads to a temp file, then moves atomically
safe_download() {
    _sd_url="$1"
    _sd_dest="$2"
    _sd_label="$3"
    _sd_tmp=$(mktemp "$(dirname "$_sd_dest")/.download.XXXXXX") || return 1

    if curl -sfS --proto '=https' --connect-timeout 5 --max-time 30 "$_sd_url" -o "$_sd_tmp" 2>/dev/null && [ -s "$_sd_tmp" ]; then
        mv "$_sd_tmp" "$_sd_dest" && return 0
    fi
    rm -f "$_sd_tmp"
    printf "      %b✗%b Failed to download %s\n" "$RED" "$NC" "$_sd_label" >&2
    return 1
}

# Header
printf "\n"
printf "                       %b⚡ Hyber Alias%b %bv%s%b\n" "$BOLD" "$NC" "$DIM" "$VERSION" "$NC"
printf "                %bCross-platform shell alias manager%b\n" "$DIM" "$NC"
printf "\n"
printf "%b  ────────────────────────────────────────────────────────────────%b\n" "$DIM" "$NC"
printf "\n"
printf "  %bSystem%b\n" "$BOLD" "$NC"
printf "\n"
printf "      OS         %b%s%b\n" "$BOLD" "$OS" "$NC"
printf "      Shell      %b%s%b\n" "$BOLD" "$USER_SHELL" "$NC"

# Show which shells we'll configure
_shells_list=""
if [ "$HAS_BASH" = true ]; then _shells_list="bash"; fi
if [ "$HAS_ZSH" = true ]; then
    if [ -n "$_shells_list" ]; then _shells_list="$_shells_list, zsh"; else _shells_list="zsh"; fi
fi
if [ "$HAS_FISH" = true ]; then
    if [ -n "$_shells_list" ]; then _shells_list="$_shells_list, fish"; else _shells_list="fish"; fi
fi
printf "      Configure  %b%s%b\n" "$DIM" "$_shells_list" "$NC"

printf "\n"
printf "%b  ────────────────────────────────────────────────────────────────%b\n" "$DIM" "$NC"
printf "\n"
printf "  %bInstalling%b\n" "$BOLD" "$NC"
printf "\n"

# Create directories
mkdir -p "$ALIAS_HOME/releases" "$ALIAS_HOME/custom"
printf "      %b✓%b Created ~/.alias\n" "$GREEN" "$NC"

# Fetch a complete release before changing any installed files.
if [ -d "$ALIAS_HOME/.install.lock" ]; then
    lock_mtime=$(stat -c %Y "$ALIAS_HOME/.install.lock" 2>/dev/null || stat -f %m "$ALIAS_HOME/.install.lock" 2>/dev/null)
    now=$(date +%s)
    if [ -n "$lock_mtime" ] && [ "$((now - lock_mtime))" -gt 600 ]; then
        rmdir "$ALIAS_HOME/.install.lock" 2>/dev/null || true
    fi
fi
if ! mkdir "$ALIAS_HOME/.install.lock" 2>/dev/null; then
    printf 'Another installation is in progress.\n' >&2
    exit 1
fi
stage=$(mktemp -d "$ALIAS_HOME/releases/.install.XXXXXX") || {
    rmdir "$ALIAS_HOME/.install.lock"
    exit 1
}
trap 'rm -rf "$stage"; rmdir "$ALIAS_HOME/.install.lock" 2>/dev/null' EXIT

safe_download "$REPO/load.sh" "$stage/load.sh" "loader" || exit 1
for name in git k8s system secrets ai; do
    safe_download "$REPO/aliases/$name.sh" "$stage/$name.sh" "$name aliases" || exit 1
done
safe_download "$REPO/aliases/fish.fish" "$stage/fish.fish" "fish aliases" || exit 1
chmod +x "$stage/load.sh"

release="$ALIAS_HOME/releases/v$VERSION"
if [ ! -d "$release" ]; then
    mv "$stage" "$release" || exit 1
else
    # A repeated install of the same immutable tag uses the existing snapshot.
    for name in load git k8s system secrets ai; do
        if [ ! -s "$release/$name.sh" ]; then
            printf 'Installed release is incomplete: %s\n' "$release" >&2
            exit 1
        fi
    done
    [ -s "$release/fish.fish" ] || exit 1
fi

if [ "$HAS_BASH" = true ] || [ "$HAS_ZSH" = true ]; then
    loader_tmp=$(mktemp "$ALIAS_HOME/load.sh.XXXXXX") || exit 1
    cp "$release/load.sh" "$loader_tmp" && chmod +x "$loader_tmp" && mv "$loader_tmp" "$ALIAS_HOME/load.sh" || exit 1
    printf "      %b✓%b Downloaded aliases\n" "$GREEN" "$NC"
fi

# =============================================================================
# Configure bash
# =============================================================================
if [ "$HAS_BASH" = true ] && [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "/.alias/load.sh" "$HOME/.bashrc" 2>/dev/null; then
        printf "\n# Hyber Alias - https://github.com/thinhngotony/alias\n" >> "$HOME/.bashrc"
        printf "[ -f ~/.alias/load.sh ] && source ~/.alias/load.sh\n" >> "$HOME/.bashrc"
        printf "      %b✓%b Configured %b~/.bashrc%b\n" "$GREEN" "$NC" "$DIM" "$NC"
    else
        printf "      %b✓%b Already configured %b~/.bashrc%b\n" "$GREEN" "$NC" "$DIM" "$NC"
    fi
fi

# =============================================================================
# Configure zsh
# =============================================================================
if [ "$HAS_ZSH" = true ] && [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "/.alias/load.sh" "$HOME/.zshrc" 2>/dev/null; then
        printf "\n# Hyber Alias - https://github.com/thinhngotony/alias\n" >> "$HOME/.zshrc"
        printf "[ -f ~/.alias/load.sh ] && source ~/.alias/load.sh\n" >> "$HOME/.zshrc"
        printf "      %b✓%b Configured %b~/.zshrc%b\n" "$GREEN" "$NC" "$DIM" "$NC"
    else
        printf "      %b✓%b Already configured %b~/.zshrc%b\n" "$GREEN" "$NC" "$DIM" "$NC"
    fi
fi

# =============================================================================
# Configure fish (install even if not the primary shell, as long as fish exists)
# =============================================================================
if [ "$HAS_FISH" = true ]; then
    mkdir -p "$HOME/.config/fish/conf.d"
    fish_tmp=$(mktemp "$HOME/.config/fish/conf.d/.hyber-alias.XXXXXX") || exit 1
    cp "$release/fish.fish" "$fish_tmp" && mv "$fish_tmp" "$HOME/.config/fish/conf.d/hyber-alias.fish" || exit 1
    printf "      %b✓%b Configured %bfish (conf.d)%b\n" "$GREEN" "$NC" "$DIM" "$NC"
fi

# =============================================================================
# Save environment
# =============================================================================
env_tmp=$(mktemp "$ALIAS_HOME/env.sh.XXXXXX") || exit 1
cat > "$env_tmp" << ENVEOF
export HYBER_VERSION="${VERSION}"
export HYBER_CACHE_LAYOUT="release"
export HYBER_SHELL="${USER_SHELL}"
export HYBER_OS="${OS}"
ENVEOF
chmod 600 "$env_tmp" && mv "$env_tmp" "$ALIAS_HOME/env.sh" || exit 1
rm -f "$ALIAS_HOME/.update-available"
touch "$ALIAS_HOME/.update-check"
printf "      %b✓%b Saved environment\n" "$GREEN" "$NC"

printf "\n"
printf "%b  ────────────────────────────────────────────────────────────────%b\n" "$DIM" "$NC"
printf "\n"
printf "  %b%b✓ Installation complete%b\n" "$GREEN" "$BOLD" "$NC"
printf "\n"
printf "  %bQuick start%b\n" "$BOLD" "$NC"
printf "\n"
printf "      %balias-help%b     Show all available aliases\n" "$CYAN" "$NC"
printf "      %balias-git%b      Git shortcuts\n" "$CYAN" "$NC"
printf "      %balias-k8s%b      Kubernetes shortcuts\n" "$CYAN" "$NC"
printf "\n"
printf "  %b📚 Docs%b  https://github.com/thinhngotony/alias\n" "$DIM" "$NC"
printf "\n"
printf "%b  ────────────────────────────────────────────────────────────────%b\n" "$DIM" "$NC"
printf "\n"
printf "  %bActivate aliases%b\n" "$BOLD" "$NC"
printf "\n"

# Print activation for ALL configured shells so the user always sees the right one
_printed=0
if [ "$HAS_FISH" = true ]; then
    if [ "$USER_SHELL" = "fish" ]; then
        printf "      Run: %bsource ~/.config/fish/conf.d/hyber-alias.fish%b  %b← your shell%b\n" "$CYAN" "$NC" "$GREEN" "$NC"
    else
        printf "      fish:  %bsource ~/.config/fish/conf.d/hyber-alias.fish%b\n" "$DIM" "$NC"
    fi
    _printed=1
fi
if [ "$HAS_BASH" = true ] && [ -f "$HOME/.bashrc" ]; then
    if [ "$USER_SHELL" = "bash" ]; then
        printf "      Run: %bsource ~/.bashrc%b  %b← your shell%b\n" "$CYAN" "$NC" "$GREEN" "$NC"
    else
        printf "      bash:  %bsource ~/.bashrc%b\n" "$DIM" "$NC"
    fi
    _printed=1
fi
if [ "$HAS_ZSH" = true ] && [ -f "$HOME/.zshrc" ]; then
    if [ "$USER_SHELL" = "zsh" ]; then
        printf "      Run: %bsource ~/.zshrc%b  %b← your shell%b\n" "$CYAN" "$NC" "$GREEN" "$NC"
    else
        printf "      zsh:   %bsource ~/.zshrc%b\n" "$DIM" "$NC"
    fi
    _printed=1
fi
if [ "$_printed" -eq 0 ]; then
    printf "      Run: %bsource ~/.bashrc%b\n" "$CYAN" "$NC"
fi

printf "\n"
printf "      Or open a new terminal.\n"
printf "\n"
