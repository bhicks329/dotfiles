#!/usr/bin/env zsh

# ZSH Configuration
# This file is sourced on interactive shell startup

# Load machine-specific overrides if they exist
MACHINE_NAME=$(hostname -s)
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi

# Source shared config files
for file in ~/.{path,exports,aliases,functions}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# Enable command auto-correction
setopt CORRECT

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS

# Completion system
autoload -Uz compinit
compinit

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Kubectl completion
if command -v kubectl &> /dev/null; then
  source <(kubectl completion zsh)
fi

# Helm completion
if command -v helm &> /dev/null; then
  source <(helm completion zsh)
fi

# asdf version manager
if [ -f "$HOME/.asdf/asdf.sh" ]; then
  . "$HOME/.asdf/asdf.sh"
fi

# fzf fuzzy finder
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
fi

# Homebrew
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Load Rust cargo if available
if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

# Z directory jumper
if command -v brew &> /dev/null; then
  [ -f $(brew --prefix)/etc/profile.d/z.sh ] && source $(brew --prefix)/etc/profile.d/z.sh
fi

# Prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%F{red}${vcs_info_msg_0_}%f$ '
