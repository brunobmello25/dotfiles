export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="half-life"
plugins=(git zsh-fzf-history-search direnv)
[ -d $ZSH ] && source $ZSH/oh-my-zsh.sh

# === ALIASES ===
alias g="git"
alias open="xdg-open"
alias doco="docker-compose"
alias l="ls -lah"
alias v="nvim"
alias lg="lazygit"
alias t="tmux"
alias dsa="echo \"deleting all docker containers\" && docker stop \$(docker ps | cut -d ' ' -f 1 | tail -n +2 | tr '\\n' ' ') ; docker rm \$(docker ps -a | cut -d ' ' -f 1 | tail -n +2 | tr '\\n' ' ')"
alias myip="curl ifconfig.me"
alias tf="terraform"
bindkey -s '^f' "tmux-sessionizer\n"

if [[ -f "$HOME/.local/bin/mise" ]]; then
  eval "$(~/.local/bin/mise activate zsh)"

  if command -v dotnet >/dev/null 2>&1; then
    DOTNET_EXEC_PATH=$(which dotnet)
    export PATH="$PATH:$HOME/.dotnet/tools"
  fi
elif [ -d ~/.asdf ]; then
  . $HOME/.asdf/asdf.sh

  export ASDF_GOLANG_MOD_VERSION_ENABLED=true

  [ -d ~/.asdf/plugins/golang ] && . ~/.asdf/plugins/golang/set-env.zsh
fi

# === secret env vars ===
if [ -f ~/.envs ]; then
  source ~/.envs
fi

if [ -d ~/.local/lib/qmk_toolchains_linuxX64/bin ]; then
  export PATH=$PATH:~/.local/lib/qmk_toolchains_linuxX64/bin
fi

if [ -d ~/.platformio ]; then
  export PATH=$HOME/.platformio/penv/bin:$PATH
fi

if [ -f ~/.config/emacs/bin/doom ]; then
  export PATH=$PATH:~/.config/emacs/bin
fi

# Doom emacs
[ -d ~/.config/emacs/bin ] && export PATH=$PATH:~/.config/emacs/bin

# === SCRIPTS PATH ===
[ -d ~/.local/scripts ] && export PATH="$HOME/.local/scripts:$PATH"

export LANG=en_US.UTF-8
export LOCALE=en_US.UTF-8

export EDITOR="nvim"

export PATH=/usr/lib/ccache:$PATH
export PATH=$PATH:$HOME/.local/bin

# The next line updates PATH for the Google Cloud SDK.
if [ -f '$HOME/dev/work/backoffice/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/dev/work/backoffice/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '$HOME/dev/work/backoffice/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/dev/work/backoffice/google-cloud-sdk/completion.zsh.inc'; fi


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# opencode
if [ -d $HOME/.opencode/bin ]; then
  export PATH=$HOME/.opencode/bin:$PATH
fi
