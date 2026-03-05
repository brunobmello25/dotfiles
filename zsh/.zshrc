# === ZSH OPTIONS ===
setopt AUTO_CD
setopt GLOB_DOTS

# === COMPLETION ===
autoload -Uz compinit
if [[ -n "$HOME/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# === HISTORY ===
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY

# === KEY BINDINGS ===
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# === PROMPT ===
autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '!'
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats ' (%F{yellow}%b%f%F{red}%u%c%f)'
zstyle ':vcs_info:git:*' actionformats ' (%F{yellow}%b%f|%F{red}%a%u%c%f)'

setopt PROMPT_SUBST
PROMPT='%F{green}%n@%m%f %F{blue}%~%f${vcs_info_msg_0_} %# '

# === FZF ===
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zsh-fzf-history-search
ZSH_FZF_HISTORY_SEARCH_PLUGIN="$HOME/.local/share/zsh/plugins/zsh-fzf-history-search"
if [ ! -d "$ZSH_FZF_HISTORY_SEARCH_PLUGIN" ]; then
  git clone https://github.com/joshskidmore/zsh-fzf-history-search "$ZSH_FZF_HISTORY_SEARCH_PLUGIN"
fi
source "$ZSH_FZF_HISTORY_SEARCH_PLUGIN/zsh-fzf-history-search.zsh"

# === DIRENV ===
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# === RUNTIME VERSION MANAGERS ===
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

# === PATH ===
export PATH=/usr/lib/ccache:$PATH
export PATH=$PATH:$HOME/.local/bin
[ -d ~/.local/scripts ] && export PATH="$HOME/.local/scripts:$PATH"
[ -d ~/.local/lib/qmk_toolchains_linuxX64/bin ] && export PATH=$PATH:~/.local/lib/qmk_toolchains_linuxX64/bin
[ -d ~/.config/emacs/bin ] && export PATH=$PATH:~/.config/emacs/bin
[ -d $HOME/.opencode/bin ] && export PATH=$HOME/.opencode/bin:$PATH

# pnpm
export PNPM_HOME="/home/bruno.mello/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Google Cloud SDK
if [ -f "$HOME/dev/work/backoffice/google-cloud-sdk/path.zsh.inc" ]; then
  . "$HOME/dev/work/backoffice/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/dev/work/backoffice/google-cloud-sdk/completion.zsh.inc" ]; then
  . "$HOME/dev/work/backoffice/google-cloud-sdk/completion.zsh.inc"
fi

# === ENVIRONMENT ===
export LANG=en_US.UTF-8
export LOCALE=en_US.UTF-8
export EDITOR="nvim"

# === ALIASES ===
alias g="git"
alias open="xdg-open"
alias doco="docker-compose"
alias l="ls -lah"
alias v="nvim"
alias lg="lazygit"
alias t="tmux"
alias dsa="echo \"deleting all docker containers\" && docker stop \$(docker ps | cut -d ' ' -f 1 | tail -n +2 | tr '\n' ' ') ; docker rm \$(docker ps -a | cut -d ' ' -f 1 | tail -n +2 | tr '\n' ' ')"
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

# === LOCAL SETTINGS ===
[ -f ~/.envs ] && source ~/.envs
[ -f $HOME/.isaac-zsh-settings ] && source $HOME/.isaac-zsh-settings
