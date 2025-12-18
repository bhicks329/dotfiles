#!/usr/bin/env bash
debug=${1:-false}

# Load help lib if not already loaded.
if [ -z ${libloaded+x} ]; then
  source ./lib.sh
fi;

# Set install flag to false
brewinstall=false

bot "Install Homebrew and all required apps."

  ask_for_confirmation "\nReady to install apps? (get a coffee, this takes a while)";

# Flag install to go if user approves
if answer_is_yes; then
  ok
  brewinstall=true
else
  cancelled "Homebrew and applications not installed."
fi;

if $brewinstall; then
  # Prevent sleep.
  caffeinate &

  action "Installing Homebrew"
  # Check if brew installed, install if not.
  if ! hash brew 2>/dev/null; then
    # note: if your /usr/local is locked down (like at Google), you can do this to place everything in ~/.homebrew
    # mkdir "$HOME/.homebrew" && curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C $HOME/.homebrew
    # then add this to your path: export PATH=$HOME/.homebrew/bin:$HOME/.homebrew/sbin:$PATH
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    print_result $? 'Install Homebrew.'
  else
    success "Homebrew already installed."
  fi;

  # Add brew to path
  if ! grep -Fqs 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zprofile; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"	

  running "brew update + brew upgrade"
  # Make sure we’re using the latest Homebrew.
  brew update

  # Upgrade any already-installed formulae.
  brew upgrade
  
  # Switch to using brew-installed bash as default shell
#  if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
#    echo '/usr/local/bin/bash' | sudo tee -a /etc/shells;
#    chsh -s /usr/local/bin/bash;
#  fi;

  # Brewfile priority:
  # 1. Machine-specific Brewfile (machines/<hostname>/config/brew/.brewfile)
  # 2. Base Brewfile (base/config/brew/.brewfile)
  MACHINE_BREWFILE="$MACHINE_DIR/config/brew/.brewfile"
  BASE_BREWFILE="$dotfilesdir/base/config/brew/.brewfile"

  if [ -f "$MACHINE_BREWFILE" ]; then
    success "Found machine-specific Brewfile for $MACHINE_NAME"
    running "Installing from: $MACHINE_BREWFILE"
    brew bundle install --file "$MACHINE_BREWFILE"
  elif [ -f "$BASE_BREWFILE" ]; then
    warn "No machine-specific Brewfile found"
    info "Using base Brewfile: $BASE_BREWFILE"
    info "Tip: Run 'brewfile-manager init' to create machine-specific Brewfile"
    running "Installing from base Brewfile"
    brew bundle install --file "$BASE_BREWFILE"
  else
    error "No Brewfile found! Expected at $BASE_BREWFILE"
    cancelled "Skipping brew bundle install"
  fi

  
  # running "brew bundle cleanup"
  # Remove outdated versions from the cellar.
  # brew  cleanup --file brew/.brewfile

  # turn off prevent sleep.
  killall caffeinate
fi;
