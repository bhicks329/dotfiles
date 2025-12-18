#!/usr/bin/env bash
debug=${1:-false}

# Load help lib if not already loaded.
if [ -z ${libloaded+x} ]; then
  source ./lib.sh
fi;

# Set dotfilesdir var if not declared.
if [ -z ${dotfilesdir+x} ]; then
  dotfilesdir="$(dirname "$(pwd)")"
fi;

botintro "Sourcing directories and files to handle."

# ============================================
# Machine Override System
# ============================================
# Use machine-specific paths if they exist, otherwise use base paths

# Declare array of directories we want to symlink.
# These will use machine overrides if available
declare -a dotfilesdirarray=(
  "$(get_config_path "bin")"
)

# Declare array of directories we want to symlink files from.
# These will use machine overrides if available
declare -a dotfilesfilearray=(
  "$(get_config_path "config/ack")"
  "$(get_config_path "config/asdf")"
  "$(get_config_path "config/bash")"
  "$(get_config_path "config/brew")"
  "$(get_config_path "config/curl")"
  "$(get_config_path "config/editor")"
  "$(get_config_path "config/git")"
  "$(get_config_path "config/iterm2")"
  "$(get_config_path "config/node")"
  "$(get_config_path "config/ruby")"
  "$(get_config_path "config/screen")"
  "$(get_config_path "config/shell")"
  "$(get_config_path "config/tmux")"
  "$(get_config_path "config/vim")"
  "$(get_config_path "config/wget")"
  "$(get_config_path "config/zsh")"
)

success "Directories and files sourced (with machine overrides where applicable)."

# Flag files as loaded
filesloaded=true
