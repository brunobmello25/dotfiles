export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="half-life"
plugins=(git zsh-fzf-history-search direnv)

# History settings - set before Oh My Zsh loads
export HISTSIZE=50000
export SAVEHIST=50000

# Load fzf before Oh My Zsh plugins
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

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

# === FUNCTIONS ===
runmonorepo() {
  local apps=(
    "@monorepo/shop"
    "@monorepo/auth"
    "@monorepo/home"
    "@monorepo/negotiation"
    "@monorepo/pre-matricula"
    "@monorepo/material-auto-onboarding"
    "@monorepo/fidc-confirmation"
    "@monorepo/insurance"
    "@monorepo/messages"
    "@monorepo/meu-isaac"
    "@monorepo/social-media"
    "@monorepo/storybook"
    "@monorepo/student-data-collection"
    "@monorepo/unified-shell"
  )

  local selected=$(printf '%s\n' "${apps[@]}" | fzf -m --prompt="Select apps to run (TAB to select multiple, ENTER to confirm): ")

  if [[ -z "$selected" ]]; then
    echo "No apps selected. Exiting."
    return 1
  fi

  local filters=""
  while IFS= read -r app; do
    filters+="--filter=$app "
  done <<< "$selected"

  local cmd="pnpm dev $filters"
  echo "Running: $cmd"
  eval "$cmd"
}

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

# opencode
if [ -d $HOME/.opencode/bin ]; then
  export PATH=$HOME/.opencode/bin:$PATH
fi

[ -f $HOME/.isaac-zsh-settings ] && source $HOME/.isaac-zsh-settings

# pnpm
export PNPM_HOME="/home/bruno.mello/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
