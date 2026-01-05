#!/usr/bin/env bash

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in "$HOME/."{path,exports,aliases,functions,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Prompt
source "$HOME/.bash_prompt"
#source "$HOME/repos/oh-my-git/prompt.sh"

# Generic colouriser.
GRC=`which grc`;
if [ "$TERM" != dumb ] && [ -n "$GRC" ]; then
  alias colourify="$GRC -es --colour=auto";
  alias configure='colourify ./configure';
  for app in {diff,make,gcc,g++,ping,traceroute}; do
    alias "$app"='colourify '$app;
  done;
fi;

# Case-insensitive globbing (used in pathname expansion).
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it.
shopt -s histappend

# Save multi-line commands as one command.
shopt -s cmdhist

# Autocorrect typos in path names when using `cd`.
shopt -s cdspell

# Autocorrect on directory names to match a glob.
shopt -s dirspell 2> /dev/null

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" 2> /dev/null;
done;
# Load bash-completion@2
if [ -f "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
  source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi

# import homebrew bash-completions
#source $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash
source "$(brew --prefix)/etc/bash_completion.d/brew"
# source "$(brew --prefix)/etc/bash_completion.d/gibo-completion.bash"
source "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"

# kubectl completion
if command -v kubectl &> /dev/null; then
  source <(kubectl completion bash)
  # Enable kubectl completion for all kubectl aliases
  complete -o default -F __start_kubectl k
  complete -o default -F __start_kubectl kg
  complete -o default -F __start_kubectl kd
  complete -o default -F __start_kubectl kdel
  complete -o default -F __start_kubectl kl
  complete -o default -F __start_kubectl klf
  complete -o default -F __start_kubectl kex
  complete -o default -F __start_kubectl ka
  complete -o default -F __start_kubectl kgp
  complete -o default -F __start_kubectl kgd
  complete -o default -F __start_kubectl kgs
  complete -o default -F __start_kubectl kgn
  complete -o default -F __start_kubectl kgns
  complete -o default -F __start_kubectl kpf
  complete -o default -F __start_kubectl kdp
  complete -o default -F __start_kubectl kdd
  complete -o default -F __start_kubectl kds
  complete -o default -F __start_kubectl kgpa
  complete -o default -F __start_kubectl kgda
  complete -o default -F __start_kubectl kgsa
  complete -o default -F __start_kubectl krr
  complete -o default -F __start_kubectl krs
  complete -o default -F __start_kubectl krh
  complete -o default -F __start_kubectl kru
fi

# Enable tab completion for `g` by marking it as an alias for `git`.
complete -o default -o nospace -F _git g;

# awscli completion
if hash awscli 2>/dev/null && [ -f /usr/local/bin/aws_completer ]; then
  complete -C '/usr/local/bin/aws_completer' aws
fi;

# Config SSH to use gpg-agent
# https://ryanlue.com/posts/2017-06-29-gpg-for-ssh-auth
# export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
# gpgconf --launch gpg-agent
#ps -p $SSH_AGENT_PID > /dev/null || eval "$(ssh-agent -s)"

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards.
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" $HOME/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`.
# You could just use `-g` instead, but I like being explicit.
complete -W "NSGlobalDomain" defaults;

# Add `killall` tab completion for common apps.
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTerm2 iTunes SystemUIServer Terminal Twitter" killall;

# z beats cd most of the time. `brew install z`
zpath="$(brew --prefix)/etc/profile.d/z.sh"
[ -s $zpath ] && source $zpath

# Enable history expansion with space.
# e.g. typing !!<space> will replace the !! with your last command
bind Space:magic-space

# asdf
source $(brew --prefix asdf)/libexec/asdf.sh

# pyevnv
if hash pyenv 2>/dev/null; then
  eval "$(pyenv init -)";
fi

if hash pyenv-virtualenv-init 2>/dev/null; then
  eval "$(pyenv virtualenv-init -)";
fi

# rbenv
if hash rbenv 2>/dev/null; then
  eval "$(rbenv init -)";
fi
export PATH="/usr/local/opt/node@16/bin:$PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/opt/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "/opt/anaconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/opt/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# <<< conda initialize <<<

export PATH="/Users/ben/.npm-global/bin:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.bash 2>/dev/null || :

# Ensure /opt/homebrew/bin is first in PATH (after all other modifications)
export PATH="/opt/homebrew/bin:${PATH//:\/opt\/homebrew\/bin/}"

# Ensure asdf shims take precedence over Homebrew for version-managed tools
export PATH="$HOME/.asdf/shims:$PATH"
