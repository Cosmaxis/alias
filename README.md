<p align="center">
  <img src="https://img.shields.io/badge/platforms-Linux%20%7C%20macOS%20%7C%20Windows-blue" alt="Platforms">
  <img src="https://img.shields.io/badge/shells-Bash%20%7C%20Zsh%20%7C%20Fish%20%7C%20PowerShell-green" alt="Shells">
  <img src="https://img.shields.io/github/license/thinhngotony/alias" alt="License">
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen" alt="PRs Welcome">
</p>

<h1 align="center">Hyber Alias</h1>

<p align="center">
  <strong>One command. All your shell aliases. Everywhere.</strong>
</p>

<p align="center">
  A cross-platform shell alias manager that installs a curated set of<br>
  productivity aliases for Git, Kubernetes, and system operations.
</p>

---

## Quick Start

**Linux / macOS (Bash, Zsh, Fish, sh)**

```sh
curl -sfS https://alias.hyberorbit.com/install | sh
```

**Windows PowerShell**

```powershell
iwr -useb https://alias.hyberorbit.com/install.ps1 | iex
```

> Open a new terminal after install, or run your shell activation command (e.g. `source ~/.bashrc`, `source ~/.zshrc`, or `source ~/.config/fish/conf.d/hyber-alias.fish`).

**Verify installation:**

```bash
alias | grep -E "^g|^k"
```

You should see aliases like `ga`, `gb`, `gs`, `k`, `kgp`, etc.

If the install endpoint is unavailable, open the [latest tagged release](https://github.com/thinhngotony/alias/releases/latest) and run its `install-universal.sh` (Linux/macOS) or `install.ps1` (Windows). Do not install a moving `main` installer against an older tagged release.

---

## Why Hyber Alias?

| Feature            | Description                                      |
| ------------------ | ------------------------------------------------ |
| **Zero Config**    | Auto-detects OS, shell, and environment          |
| **Cross-Platform** | Linux, macOS, Windows, WSL, Docker, Kubernetes   |
| **Instant Setup**  | Installs in under 5 seconds                      |
| **Offline Startup** | Sources installed aliases locally; checks for releases daily without blocking the shell |
| **Customizable**   | Add your own aliases that persist across updates |
| **Offline Ready**  | Works without internet after first install       |
| **Discoverable**   | Type `alias-` + TAB for category autocomplete    |
| **Secure**         | AES-256-CBC encrypted secret storage             |

---

## Quick Reference

Type `alias-` then press **TAB** for autocomplete:

```bash
alias-help      # Show all categories
alias-git       # Git aliases
alias-k8s       # Kubernetes aliases
alias-system    # System aliases
alias-ai        # AI coding agent aliases
alias-add       # Add custom alias to category
alias-remove    # Search and remove an alias
alias-list      # List custom categories
```

---

## Aliases Reference

### Git

| Alias          | Command                      | Description                                   |
| :------------- | :--------------------------- | :-------------------------------------------- |
| `ga`           | `git add .`                  | Stage all changes                             |
| `gb`           | `git branch`                 | List branches                                 |
| `gc <msg>`     | `git commit -m <msg>`        | Commit with message (use `gcm` on PowerShell) |
| `gd`           | `git diff`                   | Show unstaged changes                         |
| `glog`         | `git log --oneline -n 20`    | Recent commits                                |
| `gph <branch>` | `git push origin <branch>`   | Push to remote                                |
| `gpl <branch>` | `git pull origin <branch>`   | Pull from remote                              |
| `gs`           | `git status`                 | Working tree status                           |
| `gsw <branch>` | `git switch <branch>`        | Switch branches                               |
| `gauto`        | Stage, commit "Backup", push | Quick backup                                  |

### Kubernetes

| Alias       | Command                          | Description         |
| :---------- | :------------------------------- | :------------------ |
| `k`         | `kubectl`                        | Shorthand           |
| `ka <file>` | `kubectl apply -f <file>`        | Apply manifest      |
| `kd`        | `kubectl delete`                 | Delete resource     |
| `kdesc`     | `kubectl describe`               | Describe resource   |
| `ke`        | `kubectl exec -it`               | Exec into container |
| `kg`        | `kubectl get`                    | Get resources       |
| `kgp`       | `kubectl get pods`               | List pods           |
| `kgs`       | `kubectl get services`           | List services       |
| `kl`        | `kubectl logs`                   | View logs           |
| `kctx`      | `kubectl config current-context` | Current context     |
| `kns <ns>`  | Set namespace                    | Switch namespace    |

### System

| Alias    | Command             | Description     |
| :------- | :------------------ | :-------------- |
| `ll`     | `ls -lah`           | Detailed list   |
| `la`     | `ls -A`             | List all        |
| `cls`    | `clear`             | Clear screen    |
| `reload` | Reload shell config | Refresh aliases |
| `home`   | `cd ~`              | Go home         |
| `..`     | `cd ..`             | Up one level    |
| `...`    | `cd ../..`          | Up two levels   |

### AI

| Alias      | Command                                                                      | Description               |
| :--------- | :--------------------------------------------------------------------------- | :------------------------ |
| `copilotx` | `copilot --allow-all-tools --allow-all-paths`                                | Full access Copilot agent |
| `claudex`  | `claude --allow-dangerously-skip-permissions --dangerously-skip-permissions` | Full access Claude agent  |

---

## Secure Secret Storage

Store sensitive tokens and credentials with AES-256-CBC encryption:

```bash
# Store a secret (prompts for encryption password)
alias-secret-add my-token "your-api-token"

# Retrieve a secret (prompts for decryption password, copies to clipboard if available)
alias-secret-get my-token

# List all stored secrets
alias-secret-list

# Remove a secret (secure deletion)
alias-secret-remove my-token
```

Secrets are encrypted at rest using OpenSSL AES-256-CBC with PBKDF2 key derivation. Files are stored in `~/.alias/.secrets/` with `600` permissions.

---

## Custom Aliases

Add your own aliases in `~/.alias/custom/`. They persist across updates.

### Using alias-add (Recommended)

Create organized custom categories with the built-in commands:

```bash
# Add alias to a category
alias-add ai claudex "claude --dangerously-skip-permissions"
alias-add ai gpt "chatgpt --model gpt-4"

# View category aliases
alias-ai

# List all custom categories
alias-list
```

### Removing aliases

```bash
# Search cached system aliases and custom categories
alias-remove gpt

# Choose a numbered match, or cancel with q

# Skip the search when the category is known
alias-remove ai gpt
```

The search shows each match's definition, category, and source file before asking for confirmation. Removing a system alias edits the installed release locally; a newer release restores it.

### Manual Creation

<details>
<summary><strong>Linux / macOS</strong></summary>

Create a `.sh` file:

```bash
cat > ~/.alias/custom/docker.sh << 'EOF'
alias dc='docker-compose'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dps='docker ps'
EOF
```

</details>

<details>
<summary><strong>Windows PowerShell</strong></summary>

Create a `.ps1` file:

```powershell
@'
function dc { docker-compose $args }
function dcu { docker-compose up -d $args }
function dcd { docker-compose down $args }
function dps { docker ps $args }
'@ | Out-File ~\.alias\custom\docker.ps1
```

</details>

---

## How It Works

```
1. Installer downloads the loader and all alias modules from one immutable release tag.
2. It activates the release after every download succeeds and adds the loader to the shell config.
3. Bash/Zsh startup sources local modules only; Bash/Zsh and PowerShell check for new releases once a day in the background and show a notice when one is found.
4. Custom aliases in ~/.alias/custom/ are loaded last.
```

**Directory structure after install:**

```
~/.alias/
├── load.sh       # Loader (Linux/macOS)
├── load.ps1      # Loader (Windows)
├── env.sh        # Active release version
├── releases/     # Complete, versioned Linux/macOS alias modules
├── cache/        # Legacy cache, used until the next installer upgrade
├── custom/       # Your custom aliases (*.sh)
└── .secrets/     # Encrypted secrets (AES-256-CBC)
```

---

## Security

Hyber Alias follows security best practices:

- **Input validation**: Custom category and alias names are restricted to alphanumeric characters, hyphens, and underscores. Search-only support for built-in dotted aliases never uses the name as a path.
- **Encrypted secrets**: Secrets are stored using AES-256-CBC encryption with PBKDF2 key derivation via OpenSSL (not base64).
- **Staged releases**: Linux/macOS installers download every tagged file before switching the active Bash/Zsh version; a failed download leaves the installed version intact.
- **Rate-limited checks**: Bash/Zsh and PowerShell check release metadata at most daily without downloading executable code at shell startup.
- **Symlink protection**: Custom alias loading skips symbolic links to prevent symlink attacks.
- **Secure deletion**: Secret removal uses `shred` when available for secure file erasure.
- **No `exec` in installers**: Installation scripts print activation instructions instead of forcing shell replacement.

---

## Updating

Installed aliases never refresh during shell startup. Bash/Zsh and PowerShell show an update notice after a daily background release check; Fish does not check automatically. To upgrade, re-run the installer:

```sh
# Linux/macOS
curl -sfS https://alias.hyberorbit.com/install | sh
```

```powershell
# Windows PowerShell
iwr -useb https://alias.hyberorbit.com/install.ps1 | iex
```

Set `ALIAS_AUTO_UPDATE=false` to disable background release checks on Bash/Zsh and PowerShell. Existing aliases remain available offline.

---

## Uninstall

**Linux / macOS**

```sh
curl -sfS https://alias.hyberorbit.com/uninstall | sh
```

**Windows PowerShell**

```powershell
iwr -useb https://alias.hyberorbit.com/uninstall.ps1 | iex
```

---

## Troubleshooting

<details>
<summary><strong>Windows: "Running scripts is disabled"</strong></summary>

PowerShell blocks scripts by default. Fix:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

Then reinstall.

</details>

<details>
<summary><strong>Windows: Aliases not working</strong></summary>

Open a new PowerShell window, or run:

```powershell
. ~\.alias\load.ps1
```

</details>

<details>
<summary><strong>Windows: Garbled characters</strong></summary>

Cosmetic issue with UTF-8. Install still works. Latest version uses ASCII-only output.

</details>

<details>
<summary><strong>Linux/macOS: Aliases not working</strong></summary>

```bash
source ~/.bashrc  # or ~/.zshrc
```

Or open a new terminal.

</details>

<details>
<summary><strong>Clean reinstall</strong></summary>

**Linux/macOS:**

```sh
curl -sfS https://alias.hyberorbit.com/uninstall | sh
curl -sfS https://alias.hyberorbit.com/install | sh
```

**Windows:**

```powershell
iwr -useb https://alias.hyberorbit.com/uninstall.ps1 | iex
iwr -useb https://alias.hyberorbit.com/install.ps1 | iex
```

</details>

<details>
<summary><strong>Alias conflicts</strong></summary>

Some aliases (e.g., `gc`) override PowerShell built-ins. Use full command name if needed: `Get-Content` instead of `gc`.

</details>

---

## Requirements

| Platform | Requirement                                     |
| -------- | ----------------------------------------------- |
| Linux    | Bash, Zsh, or Fish, `curl`, `openssl`           |
| macOS    | Bash, Zsh, or Fish, `curl`, `openssl`           |
| Windows  | PowerShell 5.1+ (built-in on Windows 10/11)     |

---

## Contributing

Contributions welcome! Please read our contributing guidelines.

1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-alias`)
3. Commit changes (`git commit -m 'Add new alias'`)
4. Push to branch (`git push origin feature/new-alias`)
5. Open a Pull Request

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

<p align="center">
  <sub>Built with care by <a href="https://hyberorbit.com">Hyber Orbit</a></sub>
</p>
