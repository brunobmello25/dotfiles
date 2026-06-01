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
zle-keymap-select() {
  if [[ $KEYMAP == vicmd ]]; then
    echo -ne '\e[2 q'  # block (normal mode)
  else
    echo -ne '\e[6 q'  # beam (insert mode)
  fi
}
zle -N zle-keymap-select
zle-line-init() { echo -ne '\e[6 q' }
zle -N zle-line-init
export KEYTIMEOUT=10 # 10 is 100ms

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

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
[ -d $HOME/.local/share/bob ] && export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"

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

# Cedilha fix: IBus lê ~/.XCompose que mapeia dead_acute+c=ç
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus

# === ALIASES ===
alias g="git"
alias open="xdg-open"
alias doco="docker-compose"
alias l="ls -lah"
alias v="nvim"
alias vn="NVIM_APPNAME=nvim2 bob run 0.12.2"
alias lg="lazygit"
alias t="tmux"
alias dsa="echo \"deleting all docker containers\" && docker stop \$(docker ps | cut -d ' ' -f 1 | tail -n +2 | tr '\n' ' ') ; docker rm \$(docker ps -a | cut -d ' ' -f 1 | tail -n +2 | tr '\n' ' ')"
alias myip="curl ifconfig.me"
alias tf="terraform"
alias gcloudtoken="gcloud sql generate-login-token | if [ \"$XDG_SESSION_TYPE\" = \"wayland\" ]; then wl-copy; else xclip -selection clipboard; fi"

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
  print -s "$cmd"
  eval "$cmd"
}

claudeg() {
  local branch git_root worktree name
  read "branch?Nome da branch: "
  [[ -z "$branch" ]] && { echo "No branch name. Exiting."; return 1; }

  git_root=$(git rev-parse --show-toplevel 2>/dev/null)
  [[ -z "$git_root" ]] && { echo "Not inside a git repository"; return 1; }

  # claude troca / por + no nome do diretório do worktree (/ vira subpasta).
  name="${branch//\//+}"
  worktree="$git_root/.claude/worktrees/$name"

  # Cria worktree se ainda não existir
  if [[ ! -d "$worktree" ]]; then
    git worktree add "$worktree" -b "$branch" 2>/dev/null \
      || git worktree add "$worktree" "$branch" \
      || return 1
  fi

  # Usa session id (ex: $3) p/ alvo: nome tem "." que o tmux confunde com window.pane.
  local sid
  sid=$(tmux list-sessions -F '#{session_id} #{session_name}' 2>/dev/null \
    | awk -v n="$name" '$2==n{print $1; exit}')

  if [[ -z "$sid" ]]; then
    sid=$(tmux new-session -d -P -F '#{session_id}' -s "$name" -c "$worktree")
  fi

  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$sid"
  else
    tmux attach -t "$sid"
  fi
}

claudeg-sessions() {
  local git_root worktrees_dir worktree name

  git_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z "$git_root" ]]; then
    echo "Not inside a git repository"
    return 1
  fi

  worktrees_dir="$git_root/.claude/worktrees"
  if [[ ! -d "$worktrees_dir" ]]; then
    echo "No worktrees found at $worktrees_dir"
    return 1
  fi

  for worktree in "$worktrees_dir"/*/; do
    [[ -d "$worktree" ]] || continue
    name=$(basename "$worktree")
    if tmux has-session -t "=$name" 2>/dev/null; then
      echo "Session already exists: $name"
    else
      tmux new-session -d -s "$name" -c "$worktree"
      echo "Created session: $name"
    fi
  done
}

# === LOCAL SETTINGS ===
[ -f ~/.envs ] && source ~/.envs
[ -f $HOME/.isaac-zsh-settings ] && source $HOME/.isaac-zsh-settings

# Atualiza SWAYSOCK automaticamente ao abrir novo shell no Sway
if [ -z "$SWAYSOCK" ] && [ -n "$WAYLAND_DISPLAY" ]; then
    # export SWAYSOCK=$(ls /run/user/$(id -u)/sway-ipc.*.sock 2>/dev/null | head -1)
    for s in /run/user/$(id -u)/sway-ipc.*.sock(N); do export SWAYSOCK=$s; break; done
fi
