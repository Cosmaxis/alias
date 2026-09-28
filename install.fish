#!/usr/bin/env fish
# =============================================================================
# Hyber Alias Installer - Fish Shell
# =============================================================================

set ALIAS_HOME "$HOME/.alias"

# Fetch latest version from GitHub releases
set VERSION (curl -sfS --proto '=https' --connect-timeout 5 --max-time 10 "https://api.github.com/repos/thinhngotony/alias/releases/latest" 2>/dev/null \
    | grep '"tag_name"' | head -1 | sed 's/.*"tag_name" *: *"//;s/".*//' | sed 's/^v//')
if not string match -rq '^[0-9]+\.[0-9]+\.[0-9]+$' -- "$VERSION"
    set release_url (curl -fsSL --proto '=https' --proto-redir '=https' --connect-timeout 5 --max-time 10 \
        -o /dev/null -w '%{url_effective}' "https://github.com/thinhngotony/alias/releases/latest" 2>/dev/null)
    set VERSION (string replace -r '^.*/releases/tag/v([0-9]+\.[0-9]+\.[0-9]+)$' '$1' -- "$release_url")
end
if not string match -rq '^[0-9]+\.[0-9]+\.[0-9]+$' -- "$VERSION"
    echo "Failed to determine the latest release; existing aliases were not changed." >&2
    exit 1
end
set REPO "https://raw.githubusercontent.com/thinhngotony/alias/v$VERSION"

# Header
echo ""
echo "                       ⚡ Hyber Alias v$VERSION"
echo "                Cross-platform shell alias manager"
echo ""
echo "  ────────────────────────────────────────────────────────────────"
echo ""
echo "  System"
echo "      OS         "(uname -s)
echo "      Shell      fish"
echo "      Config     ~/.config/fish/config.fish"
echo ""
echo "  ────────────────────────────────────────────────────────────────"
echo ""
echo "  Installing"
echo ""

# Create directories
mkdir -p $ALIAS_HOME
mkdir -p ~/.config/fish/conf.d
echo "      ✓ Created directories"

# Download to a temporary file before replacing the installed aliases.
set alias_tmp (mktemp ~/.config/fish/conf.d/.hyber-alias.XXXXXX)
if not curl -sfS --proto '=https' --connect-timeout 5 --max-time 30 "$REPO/aliases/fish.fish" -o "$alias_tmp" 2>/dev/null; or not test -s "$alias_tmp"
    rm -f "$alias_tmp"
    echo "      ✗ Failed to download"
    exit 1
end
if not mv "$alias_tmp" ~/.config/fish/conf.d/hyber-alias.fish
    rm -f "$alias_tmp"
    echo "      ✗ Failed to install aliases"
    exit 1
end
echo "      ✓ Downloaded aliases"

# Save the version after the aliases have been installed.
set env_tmp (mktemp "$ALIAS_HOME/env.fish.XXXXXX")
or exit 1
printf 'set -gx HYBER_VERSION "%s"\nset -gx HYBER_SHELL "fish"\n' "$VERSION" > "$env_tmp"
or begin
    rm -f "$env_tmp"
    exit 1
end
mv "$env_tmp" "$ALIAS_HOME/env.fish"
or begin
    rm -f "$env_tmp"
    exit 1
end
echo "      ✓ Saved environment"

echo ""
echo "  ────────────────────────────────────────────────────────────────"
echo ""
echo "  ✓ Installation complete"
echo ""
echo "  Quick start"
echo ""
echo "      alias-help     Show all available aliases"
echo "      alias-git      Git shortcuts"
echo "      alias-k8s      Kubernetes shortcuts"
echo ""
echo "  📚 Docs  https://github.com/thinhngotony/alias"
echo ""

# Reload
source ~/.config/fish/conf.d/hyber-alias.fish
