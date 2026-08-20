# Security Policy

## Reporting Vulnerabilities

If you discover a security vulnerability, please report it responsibly by emailing the maintainers directly instead of opening a public issue.

## Security Considerations

### Installer Scripts

The `install.sh` and `install.ps1` scripts download skill files from GitHub. Users should be aware of the following:

- **Verify the source** before running `curl | bash`. Always inspect the script first or clone the repo and run locally.
- Skill names and file paths from GitHub API responses are validated against path traversal attacks (only alphanumeric, hyphens, and underscores are allowed in skill names).
- Downloaded files are not cryptographically verified. For maximum security, clone the repository and install from the local copy.

### Recommended Installation (Most Secure)

```bash
# Clone and inspect first, then install locally
git clone https://github.com/Qiscus-Integration/integration-skills.git
cd integration-skills
# Review the code, then:
./install.sh
```

### For Contributors

Before submitting a PR, verify:

- [ ] No `.env` files, API keys, tokens, or credentials are included
- [ ] No hardcoded internal URLs, IPs, or hostnames
- [ ] File paths in scripts are sanitized against traversal (`..`, absolute paths)
- [ ] No use of `eval`, `exec`, or unsanitized string interpolation in scripts
- [ ] Template files do not contain real configuration values
