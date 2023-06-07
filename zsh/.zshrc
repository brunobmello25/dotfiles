DOTFILES_PATH=~/.dotfiles

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="half-life"
plugins=(git zsh-fzf-history-search)
[ -d $ZSH ]  && source $ZSH/oh-my-zsh.sh

# === ALIASES ===
alias g="git"
alias open="xdg-open"
alias doco="docker-compose"
alias l="ls -lah"
alias v="nvim"
alias lg="lazygit"
alias t="tmux"
alias dsa="docker stop \$(docker ps | cut -d ' ' -f 1 | tail -n +2 | tr '\\n' ' ') ; docker rm \$(docker ps -a | cut -d ' ' -f 1 | tail -n +2 | tr '\\n' ' ')"
alias tks="tmux kill-server"

bindkey -s '^f' "tmux-sessionizer\n"

# === ASDF ===
[ -d ~/.asdf ] && . $HOME/.asdf/asdf.sh

# === SCRIPTS PATH ===
[ -d ~/.local/bin ] && export PATH="$HOME/.local/bin:$PATH"
[ -d ~/.local/scripts ] && export PATH="$HOME/.local/scripts:$PATH"

export LANG=en_US.UTF-8
export LOCALE=en_US.UTF-8

# === JAVA PATH ===
export JAVA_HOME=/usr/lib/jvm/default
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
alias myip="curl ifconfig.me"

export JDTLS_HOME=$HOME/.local/lib/jdtls

# Driven Config
export DOCKER_BUILDKIT=1

export EDITOR="nvim"

# === GOOGLE CLOUD SDK ===
# The next line updates PATH for the Google Cloud SDK.
if [ -f '$HOME/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '$HOME/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/google-cloud-sdk/completion.zsh.inc'; fi

# === GHCUPS ===
if [ -d $HOME/.ghcup ]; then . $HOME/.ghcup/env; fi # ghcup-env

[ -d ~/.private-aliases ] && . ~/.private-aliases/aliases.sh

export PATH=$PATH:$HOME/ardupilot/Tools/autotest
export PATH=/usr/lib/ccache:$PATH
