#!/usr/bin/env bash

echo "Setting the hostname"
sudo scutil --set HostName smackbook

echo "Installing xcode-stuff"


# Check for Homebrew,
# Install if we don't have it
if test ! $(which brew); then
  prompt "Install Xcode"
  xcode-select --install

  prompt "Install Homebrew"
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Update Homebrew"
  brew update
  brew upgrade
fi

echo "Installing Git..."
brew install git

echo "Git config"

git config --global user.name "Ben Hicks"
git config --global user.email bhicks329@gmail.com


echo "Installing brew git utilities..."
brew install git-extras
brew install legit
brew install git-flow

# Install brew apps with specific flags
brew install gnu-sed --with-default-names
brew install wget --with-iri
brew install gnupg
brew install vim --with-override-system-vi
brew install grep
brew install openssh
brew install screen
brew tap bramstein/webfonttools
brew install sfnt2woff
brew install sfnt2woff-zopfli
brew install woff2

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils

# Install some other useful utilities like `sponge`.
brew install moreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils

# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names

# Install Bash 4.
# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before
# running `chsh`.
brew install bash
brew install bash-completion2


if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells;
  chsh -s /usr/local/bin/bash;
fi;

echo "Installing other brew stuff..."
apps=(
  azure-cli
  aws-shell
  dnsmasq
  findutils
  fzf
  fontconfig
  go
  htop
  iftop
  lnav
  lynx
  mackup
  mas
  moreutils
  mtr
  nmap
  node
  p7zip
  python
  python3
  tcptrace
  tcpreplay
  tcpflow
  thefuck
  tmux
  trash
  tree
  wifi-password
  xpdf
)
brew install --appdir="/Applications" ${apps[@]}

#@TODO install our custom fonts and stuff

echo "Cleaning up brew"
brew cleanup

echo "Installing homebrew cask"
brew tap caskroom/cask

#echo "Copying dotfiles from Github"
#cd ~
#git clone git@github.com:bradp/dotfiles.git .dotfiles
#cd .dotfiles
#sh symdotfiles


echo "Installing Lastpass from the app store"
mas install 926036361

#Install Zsh & Oh My Zsh
echo "Installing Oh My ZSH..."
curl -L http://install.ohmyz.sh | sh

echo "Setting up Oh My Zsh theme..."
#cd  /Users/bradparbs/.oh-my-zsh/themes
#curl https://gist.githubusercontent.com/bradp/a52fffd9cad1cd51edb7/raw/cb46de8e4c77beb7fad38c81dbddf531d9875c78/brad-muse.zsh-theme > brad-muse.zsh-theme

echo "Setting up Zsh plugins..."
cd ~/.oh-my-zsh/custom/plugins
git clone git://github.com/zsh-users/zsh-syntax-highlighting.git

echo "Setting ZSH as shell..."
chsh -s /bin/zsh

# Casks
casks=(
  adobe-acrobat-reader
  alfred
  bartender
  bettertouchtool
  charles
  cleanmymac
  diffmerge
  docker
  dropbox
  filezilla
  firefox
  google-chrome
  handbrake
  hyper
  iterm2
  launchrocket
  lastpass
  microsoft-office
  muzzle
  parallels12
  private-internet-access
  quicklook-json
  quicklook-csv
  skype
  skype-for-business
  slack
  sourcetree
  spotify
  steam
  sublime-text2
  suspicious-package
  textexpander
  transmission
  vagrant
  vlc
  virtualbox
  visual-studio-code
  zoomus
)

# Install apps to /Applications
# Default is: /Users/$user/Applications
echo "installing apps with Cask..."
brew cask install --appdir="/Applications" ${casks[@]}

brew cask cleanup
brew cleanup

echo "Please setup and sync Dropbox, and then run this script again."
read -p "Press [Enter] key after this..."


killall Finder


echo "Done!"

#@TODO install vagrant and sites folder
