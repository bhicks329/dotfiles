#!/usr/bin/env bash

# Setup vim and packages
debug=${1:-false}

# Load help lib if not already loaded.
if [ -z ${libloaded+x} ]; then
  source ./lib.sh
fi;

# Set dotfilesdir var if it doesn't exist.
if [ -z ${dotfilesdir+x} ]; then
  dotfilesdir="$(dirname "$(pwd)")"
fi;

# Check if vim is installed.
if vim --version 2>/dev/null; then
  botintro "Setting up vim and packages."

  # Declare array of vim directories to create.
  declare -a createvimdirarray=(
    "$HOME/.vim"
    "$HOME/.vim/autoload"
    "$HOME/.vim/bundle"
    "$HOME/.vim/colors"
    "$HOME/.vim/swaps"
    "$HOME/.vim/backups"
    "$HOME/.vim/undo"
  )


  action "Creating vim directories"
  # Send array to make_directories function.
  make_directories ${createvimdirarray[@]}

  if $dirsuccess; then
    success "vim directories created."
  else
    error "Errors when creating vim directories, please check and resolve."
    cancelled "\033[1mCannot proceed. Exit.\033[0m"
    exit -1
  fi;

  # Install pathogen: https://github.com/tpope/vim-pathogen
  action "Installing pathogen."
  curl -LSso "$HOME/.vim/autoload/pathogen.vim" "https://tpo.pe/pathogen.vim"

  # Install bundle plugins (using pathogen)
  cd "$HOME/.vim/bundle"
  if [ ! -d "$HOME/.vim/bundle/vim-colors-solarized" ]; then
    git clone https://github.com/altercation/vim-colors-solarized.git # solarized
  else
    success "vim-colors-solarized already installed."
  fi
  if [ ! -d "$HOME/.vim/bundle/vim-sensible" ]; then
    git clone https://github.com/tpope/vim-sensible.git # vim sensible
  else
    success "vim-sensible already installed."
  fi
  if [ ! -d "$HOME/.vim/bundle/nerdtree" ]; then
    git clone https://github.com/scrooloose/nerdtree.git # nerdtree
  else
    success "nerdtree already installed."
  fi
  if [ ! -d "$HOME/.vim/bundle/ctrlp.vim" ]; then
    git clone https://github.com/ctrlpvim/ctrlp.vim.git # ctrlp
  else
    success "ctrlp.vim already installed."
  fi
  cd "$dotfilesdir"

  # fin.
else
  echo "WARNING: vim not found.";
fi;
