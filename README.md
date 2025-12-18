# `$HOME sweet ~/`

> **macOS Only** - This dotfiles setup is designed exclusively for macOS and uses macOS-specific tools like Homebrew, mas-cli, and macOS system utilities.

Your dotfiles are how you personalize your system.

These are mine. Built for **macOS**.

## Philosophy

Setting up a new developer machine can be **ad-hoc**, **manual**, and **time-consuming**. This project simplifies that process using easy-to-understand instructions, configuration and scripts specifically tailored for macOS.

> Our goal is to automate at least **80%** of any new **macOS** system setup.

## What's in the box?

Setup and config for bash, curl, git, node, ruby, tmux, vim, brew, apps, asdf, and more - all optimized for **macOS**.

### Highlights

- **Xcode Command Line Tools** with automated install (macOS developer tools)
- **Bash setup**: [aliases](base/config/bash/.aliases), [functions](base/config/bash/.functions), smart prompt, tab completion and more
- **Git configuration**: [aliases](base/config/git/.gitconfig) and custom scripts
- **Vim setup** via [vim-pathogen](https://github.com/tpope/vim-pathogen) and plugins
- **tmux configuration** using [config](base/config/tmux/.tmux.conf) and shortcuts
- **Homebrew package manager** (macOS) to install tools, applications and fonts
- **Mac App Store integration** via mas-cli for installing Mac App Store apps
- **asdf version manager** for managing multiple language versions (Node, Ruby, Python, etc.)
- **Custom scripts in [bin](base/bin)** including git and tmux utilities
- **Machine-specific overrides** to customize configs per machine
- **macOS system defaults** configuration for optimal development setup

## Structure

```
dotfiles/
├── precheck.sh           # Pre-flight check before setup
├── setup.sh              # Main setup script
├── setup/                # Setup scripts
│   ├── lib.sh           # Helper functions
│   ├── files.sh         # Define what to symlink
│   ├── backup.sh        # Backup existing configs
│   ├── brew.sh          # Homebrew setup
│   ├── asdf.sh          # asdf version manager setup
│   ├── node.sh          # Node.js global packages
│   ├── vim.sh           # Vim plugins and setup
│   └── symlinks.sh      # Create symlinks
├── base/                 # Base configuration (deployed to all machines)
│   ├── bin/             # Custom scripts
│   ├── config/          # Config files by topic
│   │   ├── asdf/        # asdf configs
│   │   ├── bash/        # Bash configs
│   │   ├── brew/        # Brewfile
│   │   ├── git/         # Git configs
│   │   ├── vim/         # Vim configs
│   │   └── ...
│   ├── themes/          # Terminal themes
│   └── macos/           # macOS settings
└── machines/            # Machine-specific overrides
    └── <hostname>/      # Mirrors base/ structure
        └── config/      # Override specific configs per machine
```

## Machine-Specific Configuration

The system supports per-machine config overrides. When you run setup, it detects your machine's hostname and checks for overrides in `machines/<hostname>/`.

### How It Works

**Directory-level overrides:**
- Base config: `base/config/bash/` (all bash files)
- Machine override: `machines/my-laptop/config/bash/` (if exists, uses these instead)
- It's all-or-nothing per config directory

**Example:**

If your machine is named "widget":
```bash
# Create machine-specific bash configs
mkdir -p machines/widget/config/bash
cp -r base/config/bash/* machines/widget/config/bash/
# Edit files in machines/widget/config/bash/ as needed
```

Now "widget" will use its own bash configs, while other machines use the base configs.

### When to Use Overrides

Use machine overrides when you need:
- Different git email/signing keys per machine
- Work vs. personal bash aliases
- Different Brewfiles (work machine vs. home machine)
- Machine-specific environment variables

## Install

### Prerequisites

⚠️ **macOS Required** - This setup will **only** work on macOS. It uses:
- Homebrew (macOS package manager)
- mas-cli (Mac App Store command line)
- macOS-specific bash utilities
- macOS system preferences

**Requirements:**
- **macOS** (tested on macOS 12+)
- **Terminal.app** (do NOT run in iTerm initially - use native Terminal.app)
- **Admin access** (sudo privileges required)
- **Internet connection** (for downloading packages)

### Clone the Repository

On your **macOS** machine:

```bash
git clone https://github.com/bhicks329/dotfiles.git ~/source/dotfiles
cd ~/source/dotfiles
```

## Setup Process

### 1. Pre-Check (Recommended)

Run the pre-check script to see what will change:

```bash
./precheck.sh
```

This will:
- Show existing files that would be replaced
- Display diffs for conflicts
- Let you create machine overrides interactively
- Give you a summary before making any changes

### 2. Run Setup

:warning: **Scripts in this project perform automated tasks. Review the code first and use at your own risk!** :warning:

```bash
./setup.sh
```

The setup process will guide you through:

1. **Backup** - Creates `~/backup/dotfiles-backup` with copies of existing config files
2. **Directories** - Creates required directories (e.g., `~/source`, `~/repos`, `~/.ssh`)
3. **Xcode Command Line Tools** - Installs macOS developer tools
4. **Homebrew** - Installs Homebrew (macOS package manager) and packages from Brewfile
5. **asdf** - Sets up asdf version manager and installs Node.js plugin
6. **Node.js** - Installs global npm packages
7. **Vim** - Installs vim plugins via pathogen
8. **Symlinks** - Creates symlinks from `base/` (or `machines/<hostname>/`) to your home directory
9. **Final touches** - macOS Terminal themes, SSH permissions, etc.

## Symlinks

[Symbolic links](https://en.wikipedia.org/wiki/Symbolic_link) allow you to point one location on a system to another. Rather than copy files to `~/`, this project symlinks them.

### Benefits

1. **Edit files in one place** - changes apply to both your system and the repo
2. **Clean user directory** - no git repo in `~/`, no mess
3. **Easy to manage** - add, refresh and unlink using scripts
4. **Version controlled** - track changes to your configs

### How it works

- **Directory symlinks**: `base/bin/` → `~/bin`
- **File symlinks**: Files in `base/config/bash/` → `~/.bashrc`, `~/.bash_profile`, etc.

File types symlinked: `.*`, `*.cfg`, `*.conf` (excluding `.DS_Store`, `.git`, `*.sh`)

## Customization

### Local Config Files

Create "local" config files that are never committed to avoid storing private data:

**`~/.extra`** - Custom bash commands, sourced after all other bash files:

```bash
alias myalias=some-command
export MY_SETTING=VALUE
```

**`~/.path.local`** - Custom PATH entries:

```bash
PATH="/your/path/here:$PATH"
```

**`~/.gitconfig.local`** - Private git config (credentials, signing key):

```ini
[user]
  name = "Your Name"
  email = "your@email.com"
[commit]
  signingkey = YOUR-KEY
```

**`~/.vimrc.local`** - Custom vim configuration

**`~/.tmux.conf.local`** - Custom tmux configuration

**`~/.tool-versions`** - asdf language versions (project-specific or global)

### Adding New Config Directories

To add a new config directory (e.g., for zsh):

1. Create the directory:
   ```bash
   mkdir -p base/config/zsh
   ```

2. Add your config files:
   ```bash
   touch base/config/zsh/.zshrc
   ```

3. Add to [setup/files.sh](setup/files.sh):
   ```bash
   "$(get_config_path "config/zsh")"
   ```

That's it! The files will be auto-discovered and symlinked.

### Adding New Machines

To set up a new machine with custom configs:

1. Run setup on the new machine first (uses base configs)
2. Create machine override directory:
   ```bash
   mkdir -p machines/$(hostname -s)/config/bash
   ```
3. Copy and customize:
   ```bash
   cp base/config/bash/.bashrc machines/$(hostname -s)/config/bash/
   # Edit as needed
   ```
4. Commit and push the machine configs
5. Re-run `./setup.sh` to apply overrides

## macOS System Defaults

macOS has hundreds of system preferences that can be configured via the command line. This dotfiles setup includes a script to set sensible defaults for development.

**What it configures:**
- Finder settings (show hidden files, extensions, etc.)
- Dock preferences
- Keyboard and trackpad settings
- Energy saving preferences
- And much more...

To apply these macOS-specific settings (review the script first!):

```bash
cd ~/source/dotfiles/base/macos && ./.macos
```

:warning: **Only run this if you understand what it does!** This modifies macOS system preferences.

## Maintenance

### Updating Your Dotfiles

```bash
cd ~/source/dotfiles
git pull
./setup.sh  # Re-run to update symlinks if needed
```

### Adding New Tools

1. Add to `base/config/brew/.brewfile` for Homebrew packages (macOS apps and CLI tools)
2. Add Mac App Store apps using `mas` in the Brewfile (e.g., `mas "Xcode", id: 497799835`)
3. Add to `setup/node.sh` for npm global packages
4. Add to `base/config/asdf/.tool-versions` for language versions

## Platform Support

This dotfiles setup is **exclusively for macOS**. It relies on:
- Homebrew (macOS package manager)
- mas-cli (Mac App Store automation)
- macOS-specific paths and utilities
- macOS system preferences APIs

**Not compatible with:**
- Linux (different package managers, paths, and system tools)
- Windows (completely different architecture)
- WSL (Windows Subsystem for Linux)

For Linux/Windows, you would need to fork and significantly modify the setup scripts, Brewfile, and system-specific configurations.

## License

MIT

----

:octocat: There's no place like `$HOME` (on macOS).
