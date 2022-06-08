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
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
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

  running "Installing from BrewFile"
  brew bundle install --file brew/.brewfile

  
  # running "brew bundle cleanup"
  # Remove outdated versions from the cellar.
  # brew  cleanup --file brew/.brewfile

  # turn off prevent sleep.
  killall caffeinate
fi;
