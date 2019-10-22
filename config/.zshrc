# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

#Start tmux
#if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
#  exec tmux
#fi
#
export TERM="xterm-256color"

# Set f2 to edit zshrc
bindkey -s "\eOQ" "vi ~/.zshrc \n"

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export SSH_KEY_PATH="~/.ssh/rsa_id"

export ZSH=$HOME/.oh-my-zsh

source ~/.bailey_shell

ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


#source ~/.powerlevel9k/powerlevel9k.zsh-theme
ZSH_THEME="powerlevel9k/powerlevel9k"

POWERLEVEL9K_MODE='nerdfont-complete'

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status
    background_jobs
    dir_writable
)
POWERLEVEL9K_HOME_ICON=''
POWERLEVEL9K_HOME_SUB_ICON=''
POWERLEVEL9K_FOLDER_ICON=''
POWERLEVEL9K_ETC_ICON=''
POWERLEVEL9K_VCS_GIT_HOOKS=(
    #vcs-detect-changes
    git-aheadbehind
    git-stash
    git-remotebranch
    git-tagname
)


plugins=(
    command-not-found
)

source $ZSH/oh-my-zsh.sh

if type nvim > /dev/null 2>&1; then
  #progressivly more lazy
  alias vi='nvim'
  alias v='nvim'
fi

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/home/y/workspace/builds/cquery/build/release/bin:$PATH"
export PATH=$PATH:/usr/local/go/bin
export GO111MODULE=on
