# === Oh My ZSH ===
export ZSH="/home/brubs/.oh-my-zsh"

ZSH_THEME="robbyrussell"
plugins=(git)

source $ZSH/oh-my-zsh.sh

# === ALIASES ===
alias cdex="code . && exit"
alias rs="rails s -b 0.0.0.0"
alias rc="rails c"
alias g="git"
alias rsdbg="rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 26162 -- ./bin/rails s -b 0.0.0.0"
alias open="xdg-open"
alias doco="docker-compose"
alias v="nvim"
alias l="ls -lah"

alias t="tmux"
alias tks="tmux kill-session -t"
alias tksa="tmux kill-server"

plugins=(
  zsh-autosuggestions
)

# === ASDF ===
. $HOME/.asdf/asdf.sh

# eval `dircolors $HOME/.dir_colors/dircolors`

# added by pipx (https://github.com/pipxproject/pipx)
export PATH="/home/brubs/.local/bin:$PATH"

export JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

