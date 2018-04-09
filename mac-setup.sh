#!/usr/bin/env bash

# List of items for installation

brews=(
  azure-cli
  aws-shell
  coreutils
  git-credential-manager
  git-extras
  dnsmasq
  findutils
  fzf
  fontconfig
  git-flow
  gnupg
  grep
  go
  htop
  iftop
  legit
  lnav
  lynx
  mackup
  mas
  moreutils
  mtr
  nmap
  node
  openssh
  p7zip
  python
  python3
  screen
  tcptrace
  tcpreplay
  tcpflow
  thefuck
  tmux
  trash
  tree
  wifi-password
  xpdf
  zsh-autosuggestions
  zsh-syntax-highlighting
)

casks=(
  adobe-acrobat-reader
  alfred
  bartender
  bettertouchtool
  blockblock
  charles
  cleanmymac
  diffmerge
  docker
  dropbox
  filezilla
  firefox
  gitkraken
  google-chrome
  handbrake
  hyper
  knockknock
  iterm2
  java
  launchrocket
  lastpass
  microsoft-office
  microsoft-azure-storage-explorer
  muzzle
	onedrive
  parallels
  powershell
  private-internet-access
  quicklook-json
  quicklook-csv
  skype
  skype-for-business
  slack
  sourcetree
  spotify
  steam
  sublime-text
  suspicious-package
  textexpander
  transmission
  vagrant
  vlc
  virtualbox
  visual-studio-code
  whatsapp
  zoomus
)


fonts=(
  font-source-code-pro
  font-sourcecodepro-nerd-font
)

vscode=(
  lukehoban.Go
  msazurermtools.azurerm-vscode-tools
  ms-vscode.azurecli
  ms-vscode.azure-account
  eamodio.gitlens
  ms-vsts.team
  shyykoserhiy.vscode-spotify
)

git_configs=(
  "branch.autoSetupRebase always"
  "color.ui auto"
  "core.autocrlf input"
  "core.pager cat"
  "credential.helper osxkeychain"
  "merge.ff false"
  "pull.rebase true"
  "push.default simple"
  "rebase.autostash true"
  "rerere.autoUpdate true"
  "rerere.enabled true"
  "user.name bhicks329"
  "user.email bhicks329@gmail.com"
)

######################################## End of app list ########################################
set +e
set -x

function prompt {
  echo -p "Hit Enter to $1 ..."
}

function install {
  cmd=$1
  shift
  for pkg in $@;
  do
    exec="$cmd $pkg"
    if ${exec} ; then
      echo "Installed $pkg"
    else
      echo "Failed to execute: $exec"
    fi
  done
}

if test ! $(which brew); then
  prompt "Install Xcode"
  xcode-select --install

  prompt "Install Homebrew"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  prompt "Update Homebrew"
  brew update
  brew upgrade
fi

echo "Setting the hostname"
sudo scutil --set HostName smackbook

#
# @Todo - Setup GPG Keys for sigining Git Commits
#

#
# Powershell 6 workaround
#

 brew install curl --with-openssl --with-gssapi

# Install Java
prompt "Install Java"
brew cask install java

# Install brews
prompt "Install packages"
brew info ${brews[@]}
install 'brew install' ${brews[@]}

# Install homebrew cask
prompt "Installing homebrew cask"
brew tap caskroom/cask

# Install software
prompt "Install software"
brew tap caskroom/versions
brew cask info ${casks[@]}
install 'brew cask install' ${casks[@]}

# Install VS Code Extensions
prompt "Install VS Code Extensions"
install 'code --install-extension' ${vscode[@]}

# Install Fonts
prompt "Install Fonts"
brew tap caskroom/fonts
install 'brew cask install' ${fonts[@]}
brew tap bramstein/webfonttools
brew install sfnt2woff
brew install sfnt2woff-zopfli
brew install woff2

# Install brew apps with specific flags
brew install gnu-sed --with-default-names
brew install wget --with-iri
brew install vim --with-override-system-vi

prompt "Set git defaults"
for config in "${git_configs[@]}"
do
  git config --global ${config}
done
# @Todo Need to setup GPG Keys
#gpg --keyserver hkp://pgp.mit.edu --recv ${gpg_key}


echo "Installing Lastpass "
'/usr/local/Caskroom/lastpass/latest/LastPass Installer/LastPass Installer.app'

echo "Installing App Store Items"
echo "Install Magnet"
mas install 441258766

#Install Zsh & Oh My Zsh
echo "Installing Oh My ZSH..."
curl -L http://install.ohmyz.sh | sh

echo "Setting up Oh My Zsh theme..."
#cd  /Users/bradparbs/.oh-my-zsh/themes
#curl https://gist.githubusercontent.com/bradp/a52fffd9cad1cd51edb7/raw/cb46de8e4c77beb7fad38c81dbddf531d9875c78/brad-muse.zsh-theme > brad-muse.zsh-theme


#Install Zsh & Oh My Zsh
echo "Installing Oh My ZSH..."
curl -L http://install.ohmyz.sh | sh

echo "Setting up Oh My Zsh theme..."
#cd  /Users/bradparbs/.oh-my-zsh/themes
#curl https://gist.githubusercontent.com/bradp/a52fffd9cad1cd51edb7/raw/cb46de8e4c77beb7fad38c81dbddf531d9875c78/brad-muse.zsh-theme > brad-muse.zsh-theme

echo "Setting up Zsh plugins..."
cd ~/.oh-my-zsh/custom/plugins
git clone git://github.com/zsh-users/zsh-syntax-highlighting.git

# Install Bash 4.
# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before
# running `chsh`.
brew install bash
brew install bash-completion2

if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells;
  chsh -s /usr/local/bin/bash;
fi;

#echo "Setting ZSH as shell..."
#chsh -s /bin/zsh

#echo "Copying dotfiles from Github"
#cd ~
#git clone git@github.com:bradp/dotfiles.git .dotfiles
#cd .dotfiles
#sh symdotfiles


prompt "Cleanup"
brew cleanup
brew cask cleanup

killall Finder

echo "Done!"

#@TODO install vagrant and sites folder
