# Contributing to Hyber Alias

Thank you for your interest in contributing to Hyber Alias! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Guidelines](#coding-guidelines)
- [Commit Messages](#commit-messages)
- [Release Process](#release-process)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/alias.git`
3. Create a branch: `git checkout -b feature/your-feature-name`

## How to Contribute

### Reporting Bugs

- Check if the bug has already been reported in [Issues](https://github.com/Cosmaxis/alias/issues)
- If not, create a new issue using the bug report template
- Include as much detail as possible (OS, shell, steps to reproduce)

### Suggesting Features

- Check existing issues for similar suggestions
- Create a new issue using the feature request template
- Explain the use case and expected behavior

### Adding Aliases

To add new aliases:

1. Determine the category (git, k8s, system, or new category)
2. Edit the appropriate file in `aliases/`
3. For new categories, create a new file and update `load.sh`/`load.ps1`

### Improving Documentation

- Fix typos or unclear instructions
- Add examples
- Improve the README or other docs

## Development Setup

### Prerequisites

- Bash 4.0+ (Linux/macOS)
- PowerShell 5.1+ (Windows)
- [ShellCheck](https://www.shellcheck.net/) for linting

### Testing Locally

```bash
# Linux/macOS - Test install
bash install.sh

# Verify aliases loaded
source ~/.alias/load.sh
type gs  # Should show alias

# Test uninstall
bash uninstall.sh
```

```powershell
# Windows - Test install
.\install.ps1

# Verify aliases loaded
. ~\.alias\load.ps1
Get-Command gs  # Should show function

# Test uninstall
.\uninstall.ps1
```

### Linting

```bash
# Install shellcheck
sudo apt install shellcheck  # Ubuntu/Debian
brew install shellcheck      # macOS

# Run linter
shellcheck install.sh uninstall.sh load.sh aliases/*.sh
```

## Coding Guidelines

### Shell Scripts (Bash)

- Use `#!/bin/bash` shebang
- Quote all variables: `"$var"` not `$var`
- Use `[[ ]]` for conditionals
- Add comments for complex logic
- Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

### PowerShell Scripts

- Use approved verbs for function names
- Add `[CmdletBinding()]` for advanced functions
- Use `$PSScriptRoot` for relative paths
- Follow [PowerShell Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines)

### Alias Naming

- Keep aliases short (2-4 characters)
- Use lowercase
- Avoid conflicts with common commands
- Be consistent with existing patterns

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting, no code change
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

Examples:
```
feat(aliases): add docker aliases
fix(install): handle spaces in path
docs(readme): add troubleshooting section
```

## Release Process

### Creating a Release

Releases are automated via GitHub Actions when a tag is pushed. Follow these steps:

1. **Update CHANGELOG.md** with the new version section:
   ```markdown
   ## [x.y.z] - YYYY-MM-DD

   ### Added
   - New feature descriptions

   ### Changed
   - Changed behavior descriptions

   ### Fixed
   - Bug fix descriptions
   ```

2. **Update version links** at the bottom of CHANGELOG.md:
   ```markdown
   [Unreleased]: https://github.com/Cosmaxis/alias/compare/vX.Y.Z...HEAD
   [X.Y.Z]: https://github.com/Cosmaxis/alias/compare/vPREV...vX.Y.Z
   ```

3. **Commit and push** the changes:
   ```bash
   git add CHANGELOG.md
   git commit -m "chore: prepare release vX.Y.Z"
   git push origin main
   ```

4. **Create and push the tag**:
   ```bash
   git tag -a vX.Y.Z -m "vX.Y.Z - Brief description"
   git push origin vX.Y.Z
   ```

5. **CI automatically**:
   - Runs all tests (lint, syntax-check, install tests)
   - Extracts changelog for the version from CHANGELOG.md
   - Creates a GitHub Release with:
     - Title: "Hyber Alias vX.Y.Z"
     - Body: Changelog + Installation instructions + Features list
   - Publishes the release

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):
- **MAJOR** (x.0.0): Breaking changes
- **MINOR** (0.x.0): New features, backward compatible
- **PATCH** (0.0.x): Bug fixes, backward compatible

### Release Checklist

- [ ] CHANGELOG.md updated with version section
- [ ] Version links updated in CHANGELOG.md
- [ ] All CI tests passing on main
- [ ] Tag follows `vX.Y.Z` format
- [ ] Tag message is descriptive

## Pull Request Process

1. **Update documentation** if needed
2. **Add tests** for new functionality
3. **Run linting** and fix any issues
4. **Update CHANGELOG.md** with your changes
5. **Create PR** with a clear description

### PR Checklist

- [ ] Code follows project style guidelines
- [ ] Self-reviewed my code
- [ ] Added comments for complex logic
- [ ] Updated documentation
- [ ] Added entry to CHANGELOG.md
- [ ] All CI checks pass

### Review Process

1. A maintainer will review your PR
2. Address any requested changes
3. Once approved, a maintainer will merge

## Questions?

Feel free to open an issue with the "question" label or reach out to the maintainers.

Thank you for contributing!
