# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.6.0] - 2026-09-28

### Changed

- Bash/Zsh shell startup loads pinned aliases locally instead of re-downloading unchanged release files every five minutes.
- Bash/Zsh and PowerShell check release metadata daily in the background and notify users; code updates require re-running the installer.
- Linux/macOS installers stage complete tagged releases and activate them only after all required downloads succeed. Windows installs its loader from the same release tag as its version marker.

### Fixed

- Installers and release checks fall back to GitHub's latest-release redirect when the unauthenticated API is rate-limited; the installer endpoint fails closed rather than serving mutable `main` if neither source resolves.

## [1.5.0] - 2026-09-25

### Added

- Search-based `alias-remove <name>` now finds aliases across cached system modules and custom categories, shows match details, and asks for confirmation.

### Changed

- Alias modules reuse cache entries for five minutes instead of downloading all five files on every shell startup.
- Loader self-update checks are rate-limited to once per hour.

### Fixed

- Interrupted alias-download temp files are cleaned up automatically.

## [1.4.1] - 2026-03-30

### Fixed

- **Critical: interactive shell exits on non-zero commands**: Removed `set -e` from `load.sh` — since the file is sourced (not executed), `ERR_EXIT` leaked into the user's interactive shell, causing terminal tabs to close on harmless non-zero returns from hooks, completions, or pipelines

## [1.4.0] - 2026-03-27

### Security

- **Password no longer visible in process listing**: Changed from `-pass "pass:${password}"` to `-pass "fd:3"` with file descriptor for OpenSSL encryption/decryption
- **PowerShell code injection prevention**: Added dangerous pattern validation before creating dynamic functions
- **HTTPS enforcement**: All curl commands now use `--proto '=https'` to prevent protocol downgrade attacks

### Added

- **Auto-update opt-out**: Set `ALIAS_AUTO_UPDATE=false` environment variable to disable automatic loader updates (for security-conscious users)
- **Custom repository URL**: Set `ALIAS_REPO_URL` environment variable to use a fork or self-hosted mirror

### Fixed

- **macOS compatibility**: Fixed `stat -c` (GNU) to fallback to `stat -f` (BSD) for lock file age detection
- **Race condition**: Improved temp file handling with proper error checking for chmod/mv sequence
- **Worker error handling**: Added `response.ok` check and try/catch with proper 502 error responses
- **Naming consistency**: Standardized fish config filename to `hyber-alias.fish` (was inconsistently `hyper-alias.fish`)
- **Unnecessary sudo**: Removed sudo requirement for secret removal (user owns the files)
- **Legacy secret warning**: Added explicit confirmation before displaying legacy base64 secrets in terminal

### Changed

- Worker now uses 60-second cache TTL instead of no-cache for better CDN efficiency

## [1.3.7] - 2026-03-26

### Changed

- Added `CODE_OF_CONDUCT.md` (Contributor Covenant)
- Removed `TRACKING.md` internal dev document
- Removed hardcoded Cloudflare `account_id` from `wrangler.toml`
- Updated `.gitignore` with `.wrangler/`, `node_modules/`, `*.log`

## [1.3.6] - 2026-03-26

### Fixed

- **zsh compatibility**: replaced bash-only `read -p` with `printf` + `read -r -s` (fixes "no coprocess" error on zsh/macOS)
- **zsh variable leak**: `local` re-declaration inside loop in `alias-secret-list` printed `sname=value` in zsh
- **clipboard fallback**: `alias-secret-get` now checks clipboard tool exit codes; falls back to printing when `pbcopy`/`xclip`/`xsel` fail (SSH/headless)
- **CDN stale cache**: switched from `raw.githubusercontent.com/main` (5-min CDN cache) to tag-based URLs which are immutable on GitHub CDN
- Cloudflare Worker resolves latest release tag for all download URLs
- Removed unused `alias-token` shortcut and all references

### Added

- CI: zsh `read -p` regression guard across all shell scripts
- CI: clipboard fallback verification on headless environments
- CI: `alias-secret-list` variable leak test in zsh
- CI: zsh sourcing and function definition check for secrets

## [1.2.0] - 2026-03-14

### Added

- Built-in AI aliases: `copilotx` (`copilot --allow-all-tools --allow-all-paths`) and `claudex` (`claude --allow-dangerously-skip-permissions --dangerously-skip-permissions`)
- New `alias-ai` help function listing AI shortcuts
- Fish shell now fully supported as first-class shell (install, load, aliases)

### Fixed

- Install command changed from `bash <(curl ...)` (bash-only process substitution) to `curl ... | sh` — works in fish, bash, zsh, sh, and dash
- Version no longer hardcoded; all scripts fetch the latest release tag from the GitHub Releases API at runtime

### Changed

- Removed hardcoded `v1.1.0` from all script headers and function bodies
- Loaders now read `HYBER_VERSION` from env files written by the installer
- Updated shells badge to include Fish

## [1.1.0] - 2026-01-20

### Added

- Custom category management: `alias-add`, `alias-remove`, `alias-list`
- Users can now create custom alias categories (e.g., `alias-ai` with `claudex`, `gpt`)
- Self-update mechanism for loader script (auto-updates on shell start)
- Version tracking in loader scripts

### Fixed

- Fixed `alias-help` not available for users who installed older versions
- Loader script now auto-updates to get new features without reinstalling

### Example

```bash
# Add custom AI aliases
alias-add ai claudex "claude --dangerously-skip-permissions"
alias-add ai gpt "chatgpt --model gpt-4"
alias-ai  # Show all AI aliases
```

## [1.0.3] - 2025-12-29

### Fixed

- Fixed aliases not loading on first shell open after installation
- Install script now pre-downloads aliases to cache during installation
- Increased download timeout from 2s to 5s for slower connections

## [1.0.2] - 2025-12-29

### Fixed

- Fixed installation failing due to Cloudflare bot protection blocking curl requests
- Changed default installation URLs from Cloudflare worker to GitHub raw URLs for reliability

## [1.0.1] - 2025-12-16

### Fixed

- Fixed shell detection to use user's login shell (`$SHELL`) instead of current script shell
- Fixed zsh glob pattern error when `~/.alias/custom/` directory is empty
- Installation now correctly detects zsh on macOS when run via `bash <(curl ...)`

## [1.0.0] - 2025-12-11

### Changed

- Renamed `gc` to `gcm` on PowerShell to avoid conflict with `Get-Content` built-in alias
- Made `reload` alias dynamic (detects zsh vs bash)
- Disabled Cloudflare edge caching for instant updates

### Fixed

- Fixed `gauto` alias to not depend on alias expansion
- Fixed PowerShell functions to pass-through additional arguments
- Fixed loader to handle download failures gracefully
- Fixed CI pipeline (PowerShell syntax check, cross-platform tests)

### Added

- GitHub Actions CI/CD pipeline with cross-platform testing
- Issue templates (bug report, feature request)
- Pull request template
- CONTRIBUTING.md with development guidelines
- SECURITY.md with vulnerability reporting policy

## [1.0.0-rc.1] - 2024-12-11

### Added

- Initial release candidate
- One-command install for Linux, macOS, and Windows
- Git aliases: `ga`, `gb`, `gc`, `gd`, `gs`, `gph`, `gpl`, `gsw`, `glog`, `gauto`
- Kubernetes aliases: `k`, `ka`, `kd`, `kg`, `kgp`, `kgs`, `kl`, `ke`, `kctx`, `kns`
- System aliases: `ll`, `la`, `cls`, `reload`, `home`, `..`, `...`
- Custom alias support via `~/.alias/custom/`
- Auto-update on shell start
- Offline fallback with local cache
- One-command uninstall
- Cross-platform support (Linux, macOS, Windows, WSL, Docker, Kubernetes)
- Bash, Zsh, and PowerShell support

### Technical

- Cloudflare Worker for install script delivery
- GitHub Actions CI/CD pipeline
- ShellCheck linting for bash scripts
- PowerShell syntax validation

## Installation

```sh
# Linux/macOS
curl -sfS https://alias.cosmaxis.com/install | sh

# Windows PowerShell
iwr -useb https://alias.cosmaxis.com/install.ps1 | iex
```

[Unreleased]: https://github.com/Cosmaxis/alias/compare/v1.6.0...HEAD
[1.6.0]: https://github.com/Cosmaxis/alias/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/Cosmaxis/alias/compare/v1.4.1...v1.5.0
[1.4.0]: https://github.com/Cosmaxis/alias/compare/v1.3.7...v1.4.0
[1.3.7]: https://github.com/Cosmaxis/alias/compare/v1.3.6...v1.3.7
[1.3.6]: https://github.com/Cosmaxis/alias/compare/v1.2.0...v1.3.6
[1.2.0]: https://github.com/Cosmaxis/alias/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/Cosmaxis/alias/compare/v1.0.3...v1.1.0
[1.0.3]: https://github.com/Cosmaxis/alias/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/Cosmaxis/alias/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/Cosmaxis/alias/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/Cosmaxis/alias/compare/v1.0.0-rc.1...v1.0.0
[1.0.0-rc.1]: https://github.com/Cosmaxis/alias/releases/tag/v1.0.0-rc.1
