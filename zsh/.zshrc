DOTFILES_PATH=~/.dotfiles

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
alias dsa="docker stop \$(docker ps | cut -d ' ' -f 1 | tail -n +2 | tr '\\n' ' ') ; docker rm \$(docker ps -a | cut -d ' ' -f 1 | tail -n +2 | tr '\\n' ' ')"
alias myip="curl ifconfig.me"
alias vpnconnect="warp-cli connect"
alias vpndisconnect="warp-cli disconnect"
alias vpnstatus="curl https://www.cloudflare.com/cdn-cgi/trace/"
bindkey -s '^f' "tmux-sessionizer\n"

# === ASDF ===
if [ -d ~/.asdf ]; then
  . $HOME/.asdf/asdf.sh
  export GOPATH=~/.asdf/installs/golang/1.18/packages
  export PATH=$PATH:$GOPATH/bin
fi

# === SCRIPTS PATH ===
[ -d ~/.local/scripts ] && export PATH="$HOME/.local/scripts:$PATH"

export LANG=en_US.UTF-8
export LOCALE=en_US.UTF-8

export EDITOR="nvim"

export PATH=$PATH:$HOME/ardupilot/Tools/autotest
export PATH=/usr/lib/ccache:$PATH
export PATH=$PATH:$HOME/.local/bin

eval "$(direnv hook zsh)"

if [[ "$(uname)" == "Darwin" ]] && [[ -d "$HOME/.config/zsh" ]] && [[ -f "$HOME/.config/zsh/mac-specific-settings.sh" ]]; then
  source "$HOME/.config/zsh/mac-specific-settings.sh"
fi
