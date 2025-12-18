#!/usr/bin/env zsh

# ZSH Profile
# This file is sourced on login shells

# Load .profile if it exists (for compatibility)
if [ -f "$HOME/.profile" ]; then
  source "$HOME/.profile"
fi

# Ensure path is set
if [ -f "$HOME/.path" ]; then
  source "$HOME/.path"
fi

# Load exports
if [ -f "$HOME/.exports" ]; then
  source "$HOME/.exports"
fi
