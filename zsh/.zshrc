export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="half-life"
plugins=(git zsh-fzf-history-search)
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
alias cl="clear"
bindkey -s '^f' "tmux-sessionizer\n"

# === ASDF ===
if [ -d ~/.asdf ]; then
  . $HOME/.asdf/asdf.sh

  # export GOPATH=$(asdf where golang)/go
  # export PATH=$PATH:$GOPATH/bin
  export ASDF_GOLANG_MOD_VERSION_ENABLED=true
  . ~/.asdf/plugins/golang/set-env.zsh
fi

# === secret env vars ===
if [ -f ~/.envs ]; then
  source ~/.envs
fi

if [ -d ~/.platformio ]; then
  export PATH=$HOME/.platformio/penv/bin:$PATH
fi

# === SCRIPTS PATH ===
[ -d ~/.local/scripts ] && export PATH="$HOME/.local/scripts:$PATH"

export LANG=en_US.UTF-8
export LOCALE=en_US.UTF-8

export EDITOR="nvim"

export PATH=/usr/lib/ccache:$PATH
export PATH=$PATH:$HOME/.local/bin

if command -v direnv 2>&1 >/dev/null
then
  eval "$(direnv hook zsh)"
fi

if [[ "$(uname)" == "Darwin" ]] && [[ -d "$HOME/.config/zsh" ]] && [[ -f "$HOME/.config/zsh/mac-specific-settings.sh" ]]; then
  source "$HOME/.config/zsh/mac-specific-settings.sh"
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/brubs/dev/work/backoffice/google-cloud-sdk/path.zsh.inc' ]; then . '/home/brubs/dev/work/backoffice/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/brubs/dev/work/backoffice/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/brubs/dev/work/backoffice/google-cloud-sdk/completion.zsh.inc'; fi
