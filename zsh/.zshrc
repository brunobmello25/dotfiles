DOTFILES_PATH=~/.dotfiles

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="half-life"
plugins=(git zsh-fzf-history-search)
[ -d $ZSH ]  && source $ZSH/oh-my-zsh.sh


# === ALIASES ===
alias cdex="code . && exit"
alias rs="rails s -b 0.0.0.0"
alias rc="rails c"
alias g="git"
alias rsdbg="rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 26162 -- ./bin/rails s -b 0.0.0.0"
alias open="xdg-open"
alias doco="docker-compose"
alias l="ls -lah"
alias v="nvim"
alias lg="lazygit"
alias t="tmux"
alias dsa="docker stop \$(docker ps | cut -d ' ' -f 1 | tail -n +2 | tr '\\n' ' ')"
alias dka="docker rm \$(docker ps -a | grep -v -E 'ra-pg$|ra-redis$' | cut -d ' ' -f 1 | tail -n +2 | tr '\\n' ' ')"
alias dkai="docker rmi \$(docker images)"

alias fp=". $DOTFILES_PATH/zsh_scripts/find-project.sh"
alias trn="$DOTFILES_PATH/zsh_scripts/name-tmux-session.sh"

bindkey -s '^f' 'fp^M'
bindkey -s '^n' 'trn^M'

# === ASDF ===
[ -d ~/.asdf ] && . $HOME/.asdf/asdf.sh

# === SCRIPTS PATH ===
export PATH="/home/brubs/.local/bin:$PATH"

# === JAVA PATH ===
export JAVA_HOME=/usr/lib/jvm/default
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

export JDTLS_HOME=$HOME/.local/lib/jdtls
export GOPATH=$HOME/dev/go

# Driven Config
export DOCKER_BUILDKIT=1

# === GOOGLE CLOUD SDK ===
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/brubs/google-cloud-sdk/path.zsh.inc' ]; then . '/home/brubs/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/brubs/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/brubs/google-cloud-sdk/completion.zsh.inc'; fi

# === GHCUPS ===
if [ -d /home/brubs/.ghcup ]; then . /home/brubs/.ghcup/env; fi # ghcup-env
