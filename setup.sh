#!/usr/bin/env bash

# Aaron's dotfiles: $HOME sweet ~/
# https://github.com/aaronbates/dotfiles
# ======================================
# Idempotent setup script for dotfiles:

# Prep
# 1. Backup
# 2. Directories
# 3. Xcode CLI
# 4. Homebrew
# 5. Symlinks
# 6. Misc.

debug=${1:-false} # default debug param.  
source ./setup/lib.sh # load help lib.

# ----
# Prep
# ----
echo -e "\n\e[1m\$HOME sweet /~\n\e[0m"

defaultdotfilesdir="$HOME/dotfiles"
dotfilesdir=$(pwd)

# ============================================
# Machine Override System
# ============================================
# Detect machine name and set up overrides
MACHINE_NAME=${DOTFILES_MACHINE:-$(hostname -s)}
MACHINE_DIR="$dotfilesdir/machines/$MACHINE_NAME"

bot "Detecting machine configuration..."
echo -e "Machine hostname: \e[1m$(hostname -s)\e[0m"
if [ -n "${DOTFILES_MACHINE:-}" ]; then
  echo -e "Machine profile override (DOTFILES_MACHINE): \e[1m$MACHINE_NAME\e[0m"
else
  echo -e "Machine profile: \e[1m$MACHINE_NAME\e[0m"
fi

# Function to get the correct path (machine override or base)
# Usage: get_config_path "config/bash" returns either machines/widget/config/bash or base/config/bash
get_config_path() {
  local config_dir=$1
  local machine_override="$MACHINE_DIR/$config_dir"
  local base_path="$dotfilesdir/base/$config_dir"

  if [ -d "$machine_override" ]; then
    echo "$machine_override"
  else
    echo "$base_path"
  fi
}

# Check if machine profile exists
if [ -d "$MACHINE_DIR" ]; then
  success "Found machine profile: $MACHINE_DIR"

  # List available overrides
  echo -e "\nMachine-specific overrides:"
  for dir in bash git brew vim tmux shell editor; do
    if [ -d "$MACHINE_DIR/$dir" ]; then
      echo -e "  ✓ $dir/ (using machine override)"
    fi
  done
  echo ""
else
  warn "No machine profile found for '$MACHINE_NAME'"
  warn "Using base configuration only."
  echo -e "\nTo create a machine profile:"
  echo -e "  mkdir -p machines/$MACHINE_NAME"
  echo -e "  # Add overrides in machines/$MACHINE_NAME/bash, machines/$MACHINE_NAME/brew, etc.\n"
fi

# Export for use in other scripts
export MACHINE_NAME
export MACHINE_DIR
export -f get_config_path

#if is_git_repository; then
# git pull origin master # pull repo.
#fi;

warn "\e[1mEnsure your mac system is fully up-to-date and only\e[0m"
warn "\e[1mrun this script in terminal.app (NOT in iTerm)\e[0m"
warn "=> \e[1mCTRL+C now to abort\e[0m or \e[1mENTER\e[0m to continue."
tput bel
read -n 1

# Introduction
awesome_header

botintro "This script sets up new machines, \e[1m*use with caution*\e[0m. For more information, please see [https://github.com/aaronbates/dotfiles]."
echo -e "\nPress \e[1mENTER\e[0m to continue."
read -n 1

bot "OK, what we're going to do:\n"

actioninfo "1. Backup directories and files we'll be touching."
actioninfo "2. Create required directories."
actioninfo "3. Install Xcode Command Line Tools."
actioninfo "4. Install Homebrew and all required apps."
actioninfo "5. Create symlinks for directories and files."
actioninfo "6. Final touches."

botintro "To start we'll need your password.\n"

tput bel

ask_for_confirmation "Ready?";
if answer_is_yes; then
  ok "\e[1mLet's go.\e[0m"
else
  cancelled "\e[1mExit.\e[0m"
  exit -1;
fi;

#exit -1

# Ask for the administrator password upfront.
ask_for_sudo

# Source directories and files to handle.
source ./setup/files.sh

# Install all available macos updates.
#action "Installing Mac updates:\n"
sudo softwareupdate -ia

# ---------
# 1. Backup
# ---------
botintro "\e[1mSTEP 2: BACKUP\e[0m"
source ./setup/backup.sh

# --------------
# 2. Directories
# --------------
botintro "\e[1mSTEP 2: DIRECTORIES\e[0m"
source ./setup/directories.sh

# ------------
# 3. Xcode CLI
# ------------
botintro "\e[1mSTEP 3: XCODE CLI\e[0m"
source ./setup/xcodecli.sh

# -----------
# 4. Homebrew
# -----------
botintro "\e[1mSTEP 4: HOMEBREW\e[0m"
source ./setup/brew.sh

# brew is required to continue, exit out otherwise.
if ! $brewinstall;  then
  cancelled "\e[1mCannot proceed. Exit.\e[0m"
  exit -1
fi;

# asdf setup
source ./setup/asdf.sh

# Node setup
source ./setup/node.sh

# vim setup
source ./setup/vim.sh

# -----------
# 5. Symlinks
# -----------
botintro "\e[1mSTEP 5: SYMLINKS\e[0m"
source ./setup/symlinks.sh

# --------
# 6. Misc.
# --------
botintro "\e[1mSTEP 6: Final touches\e[0m"
source ./setup/misc.sh

# Wrap-up.

botintro "\e[1mFINISHED\e[0m -- That's it for the automated process."
bot "If you want to do more, take a look at the Going Further section:"
bot "https://github.com/aaronbates/dotfiles#going-further"

echo -e "\np.s. don't forget to sync your dropbox and get mackup running.\n"
# EOF
