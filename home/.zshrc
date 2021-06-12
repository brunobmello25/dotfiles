export ZSH="/home/brubs/.oh-my-zsh"

ZSH_THEME="robbyrussell"
plugins=(git)

source $ZSH/oh-my-zsh.sh

# === ALIASES ===
alias cdex="code . && exit"
alias rs="rails s -b 0.0.0.0"
alias rc="rails c"
alias g="git"
alias rsdbg="rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 26162 -- ./bin/rails s"
alias open="xdg-open"
alias doco="docker-compose"
alias vim="nvim"
alias ra="cd ~/www/respondeai/respondeai"
alias rac="cd ~/www/respondeai/content"
alias ras="cd ~/www/respondeai/seo"
alias l="ls -lah"

# === ASDF ===
. $HOME/.asdf/asdf.sh

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
#export PATH="$PATH:$HOME/.rvm/bin"

#export ANDROID_HOME=$HOME/Android/Sdk
#export PATH=$PATH:$ANDROID_HOME/emulator
#export PATH=$PATH:$ANDROID_HOME/tools
#export PATH=$PATH:$ANDROID_HOME/tools/bin
#export PATH=$PATH:$ANDROID_HOME/platform-tools

