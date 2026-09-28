# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability, please report it responsibly.

### How to Report

1. **Do NOT** create a public GitHub issue for security vulnerabilities
2. Email the maintainers directly at: [security@cosmaxis.com](mailto:security@cosmaxis.com)
3. Include as much detail as possible:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 7 days
- **Resolution Timeline**: Depends on severity
  - Critical: 24-48 hours
  - High: 7 days
  - Medium: 30 days
  - Low: 90 days

### Responsible Disclosure

- Please give us reasonable time to fix the issue before public disclosure
- We will credit you in the release notes (unless you prefer to remain anonymous)
- We do not currently offer a bug bounty program

## Security Best Practices

### For Users

1. **Verify the source**: Only install from official sources:

   ```sh
   curl -sfS https://alias.cosmaxis.com/install | sh
   ```

2. **Review before running**: You can inspect the install script:

   ```bash
   curl -s https://alias.cosmaxis.com/install | less
   ```

3. **Check file integrity**: After installation, verify files:

   ```bash
   ls -la ~/.alias/
   cat ~/.alias/load.sh
   ```

4. **Custom aliases**: Be careful with custom aliases that run arbitrary commands

### For Contributors

1. Never commit secrets, API keys, or credentials
2. Use ShellCheck to catch common security issues
3. Validate and sanitize all inputs
4. Avoid `eval` and similar dangerous constructs
5. Use quotes around variables to prevent injection

## Known Security Considerations

### Script Execution

This project uses `curl | bash` pattern for installation. While convenient, users should:

- Verify they trust the source
- Optionally download and review before running
- Use HTTPS URLs only

### Permissions

- Scripts run with user permissions (not root)
- No elevated privileges required
- Files are created in user home directory only

## Security Updates

Security updates will be:

- Released as patch versions (e.g., 1.0.1)
- Announced in release notes
- Tagged with `[SECURITY]` in CHANGELOG.md
