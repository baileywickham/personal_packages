
# Profiling (uncomment to profile startup time)
# zmodload zsh/zprof

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

#Start tmux
#if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
#  exec tmux
#fi

# if [[ "$(awk -F=  '{ print $2 }' /etc/os-release | head -n 1 | tr -d \")" == "Linux Mint" ]]; then
#     export LOCATION="mint"
# fi
# if [[ "$(awk -F=  '{ print $2 }' /etc/os-release | head -n 1 | tr -d \")" == "Ubuntu" ]]; then
#     export LOCATION="ubuntu"
# fi
# export LOCATION="mint"


# Set f2 to edit zshrc
bindkey -s "\eOQ" "vi ~/.zshrc \n"

# Oh-My-Zsh performance optimizations
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"

export ZSH=$HOME/.oh-my-zsh

source $HOME/.env
source $HOME/.aliases

ex () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.zst)   tar xaf $1   ;;
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
      *.xz)        unxz $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
    command-not-found
    direnv
)

source $ZSH/oh-my-zsh.sh

if command_exists nvim; then
  #progressivly more lazy
  alias vi='nvim'
  alias v='nvim'
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Optimized completion initialization (only rebuild once per day)
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
bindkey "\e[1;5D" backward-word
bindkey "\e[1;5C" forward-word


if command_exists direnv; then
    eval "$(direnv hook zsh)"
fi

if command_exists temporal; then
    source <(temporal completion zsh)
fi

# pnpm
export PNPM_HOME="/Users/baileywickham/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh

export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

if command_exists fzf; then
    source <(fzf --zsh)
fi

source /Users/baileywickham/workspace/platform/bin/wt-completion.bash

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export JAVA_HOME=/opt/homebrew/opt/openjdk
# Docker CLI completions
fpath=(/Users/baileywickham/.docker/completions $fpath)
