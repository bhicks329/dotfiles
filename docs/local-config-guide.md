# Local Configuration Guide

This dotfiles repository uses "local config" files to keep personal and sensitive information out of version control while still maintaining a portable setup.

## Quick Reference

| File | Purpose | When to Create |
|------|---------|---------------|
| `~/.gitconfig.local` | Personal git settings (name, email, signing key) | **Required** - Create on every new system |
| `~/.extra` | Custom bash aliases, functions, exports | Optional - For machine-specific customization |
| `~/.path.local` | Custom PATH additions | Optional - If you need extra directories in PATH |
| `~/.vimrc.local` | Personal vim settings | Optional - To extend vim config |
| `~/.tmux.conf.local` | Personal tmux settings | Optional - To extend tmux config |

## Required: Git Configuration

After setting up dotfiles, you **must** create `~/.gitconfig.local` with your personal information:

```bash
cat > ~/.gitconfig.local << 'EOF'
[user]
  name = Your Name
  email = your.email@example.com

[github]
  user = your-github-username

[credential]
  helper = osxkeychain

# Optional: GPG signing
# [commit]
#   gpgsign = true
# [user]
#   signingkey = YOUR-GPG-KEY-ID
EOF
```

This file is loaded by [git/.gitconfig](../git/.gitconfig) via the `[Include]` directive.

## Optional: Bash Customization

Create `~/.extra` for machine-specific bash customization:

```bash
cat > ~/.extra << 'EOF'
# Custom aliases
alias myproject="cd ~/projects/my-special-project"
alias prod-ssh="ssh user@production-server.com"

# Custom functions
my_function() {
  echo "This only exists on this machine"
}

# Environment variables
export MY_SPECIAL_VAR="value"
export SOME_API_KEY="secret-key-here"

# Company-specific tools
export COMPANY_AWS_PROFILE="work-profile"
EOF
```

This file is sourced by [bash/.bash_profile](../bash/.bash_profile) if it exists.

## Optional: Custom PATH

Create `~/.path.local` to add directories to your PATH:

```bash
cat > ~/.path.local << 'EOF'
# Add custom bin directory
PATH="/Users/ben/my-tools/bin:$PATH"

# Add local scripts
PATH="$PATH:/Users/ben/scripts"

# Company tooling
PATH="/opt/company-tools/bin:$PATH"
EOF
```

## Re-authenticating After Setup

After running the dotfiles setup on a new machine, you'll need to re-authenticate various tools:

### Cloud Providers
```bash
# AWS
aws configure

# Google Cloud
gcloud auth login
gcloud auth application-default login

# Azure
az login
```

### Development Tools
```bash
# GitHub CLI
gh auth login

# Firebase
firebase login

# Docker Hub (if needed)
docker login
```

### SSH & GPG
```bash
# Generate new SSH key or copy from secure backup
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Import GPG keys from backup
gpg --import /path/to/backup/private-key.asc
```

### SOPS/Age Keys
If using SOPS for secrets management:
- Restore age keys from secure backup to `~/.config/sops/age/keys.txt`
- Or generate new keys and re-encrypt your secrets

## What Gets Committed vs Ignored

### ✅ Committed (Safe to Share)
- Base configurations (bash, git, vim, tmux, etc.)
- Application configs without credentials
- Scripts and utilities in `bin/`
- `.config/iterm2/` (themes and preferences)
- `.config/fish/config.fish` (if you use fish shell)
- `.config/configstore/nodemon.json`

### ❌ Ignored (Local Only)
- **All credentials and API tokens**
- Cloud provider configs (`.aws/`, `.config/gcloud/`, `.azure/`)
- Authentication tokens (`.config/gh/`, `.config/firebase/`)
- SSH keys and GPG keys
- SOPS/age encryption keys
- Local override files (`.extra`, `.gitconfig.local`, etc.)
- Machine-specific caches and logs

See [.gitignore](../.gitignore) for the complete list.

## Best Practices

1. **Never commit secrets** - Use `.gitconfig.local` and `.extra` for sensitive data
2. **Document dependencies** - If you add a new tool, document auth steps here
3. **Use Mackup for app settings** - Let Mackup handle app preferences via Dropbox/iCloud
4. **Keep it portable** - Don't hardcode paths specific to one machine
5. **Regular backups** - Backup your local config files and keys separately from dotfiles

## Troubleshooting

**Git commands show wrong user:**
- Check `~/.gitconfig.local` exists and contains your `[user]` section
- Run `git config user.name` and `git config user.email` to verify

**Custom aliases not working:**
- Ensure `~/.extra` exists and is executable
- Source it manually: `source ~/.extra`
- Check for syntax errors: `bash -n ~/.extra`

**Tools can't authenticate:**
- Run the re-authentication commands above
- Check that credentials aren't being blocked by `.gitignore`
- Verify tool configs are in the expected locations

## See Also

- [README.md](../README.md) - Main documentation
- [Package Contents](package-contents.md) - What gets installed
- [Getting Started](getting-started.md) - Usage tips
