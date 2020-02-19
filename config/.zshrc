# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

#Start tmux
#if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
#  exec tmux
#fi


# Set f2 to edit zshrc
bindkey -s "\eOQ" "vi ~/.zshrc \n"

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
ZSH_THEME="powerlevel10k/powerlevel10k"

POWERLEVEL9K_MODE='nerdfont-complete'

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status
    background_jobs
    dir_writable
    virtualenv
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
POWERLEVEL9K_VI_INSERT_MODE_STRING='<<<'
POWERLEVEL9K_VI_COMMAND_MODE_STRING='>>>'


plugins=(
    command-not-found
)

source $ZSH/oh-my-zsh.sh

if type nvim > /dev/null 2>&1; then
  #progressivly more lazy
  alias vi='nvim'
  alias v='nvim'
fi
