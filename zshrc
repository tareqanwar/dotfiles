# ~/.zshrc — portable developer shell (macOS, Linux, WSL)

# ---------- Environment ----------
export EDITOR="${EDITOR:-nvim}"
export VISUAL="$EDITOR"
export PAGER="less -FRX"
export LESS="-R"
if [[ -z "${LANG:-}" ]]; then
  if locale -a 2>/dev/null | grep -qi '^en_US\.utf-8$'; then
    export LANG="en_US.UTF-8"
  elif locale -a 2>/dev/null | grep -qi '^C\.UTF-8$'; then
    export LANG="C.UTF-8"
  fi
fi

# Add common user bins once
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/.bin"
  "$HOME/bin"
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  "/usr/local/bin"
  "/usr/local/sbin"
  $path
)
export PATH

# ---------- Platform detection ----------
case "$(uname -s)" in
  Darwin) export PLATFORM="macos" ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      export PLATFORM="wsl"
    else
      export PLATFORM="linux"
    fi
    ;;
  *) export PLATFORM="unknown" ;;
esac

# ---------- Oh My Zsh ----------
export ZSH="$HOME/.oh-my-zsh"
if [[ -d "$ZSH" ]]; then
  ZSH_THEME=""
  plugins=(
    git
    colored-man-pages
    command-not-found
    sudo
    z
    zsh-autosuggestions
    zsh-syntax-highlighting
  )
  DISABLE_AUTO_UPDATE="true"
  DISABLE_MAGIC_FUNCTIONS="true"
  source "$ZSH/oh-my-zsh.sh"
fi

# ---------- History ----------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=200000
SAVEHIST=200000
setopt EXTENDED_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS
setopt SHARE_HISTORY INC_APPEND_HISTORY APPEND_HISTORY
setopt AUTO_CD INTERACTIVE_COMMENTS
setopt NO_BEEP

# ---------- Completion ----------
autoload -Uz compinit
compinit -d "$HOME/.zcompdump"
zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# ---------- Key bindings ----------
bindkey -e
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[3~' delete-char

# ---------- Prompt with Git details ----------
autoload -Uz colors && colors
setopt PROMPT_SUBST

_git_prompt() {
  command git rev-parse --is-inside-work-tree &>/dev/null || return

  local branch status flags ahead behind
  branch=$(command git symbolic-ref --short HEAD 2>/dev/null || command git rev-parse --short HEAD 2>/dev/null)
  status=$(command git status --porcelain --branch 2>/dev/null)

  [[ "$status" == *"ahead "*  ]] && ahead="↑"
  [[ "$status" == *"behind "* ]] && behind="↓"
  [[ -n $(command git diff --name-only 2>/dev/null) ]] && flags+="*"
  [[ -n $(command git diff --cached --name-only 2>/dev/null) ]] && flags+="+"
  [[ "$status" == *"??"* ]] && flags+="?"

  echo "%F{magenta} ${branch}${ahead}${behind}${flags}%f"
}

PROMPT='%F{cyan}%n@%m%f %F{blue}%~%f $(_git_prompt)
%(?.%F{green}.%F{red})❯%f '

# ---------- Sensible aliases ----------
alias reload='source ~/.zshrc'
alias c='clear'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias e='$EDITOR'

# modern CLI fallbacks
command -v eza >/dev/null 2>&1 && alias ls='eza --group-directories-first --icons=auto'
command -v bat >/dev/null 2>&1 && alias cat='bat --style=plain'

# ---------- Git shortcuts ----------
alias gs='git status -sb'
alias ga='git add -A'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gswc='git switch -c'
alias gl='git log --graph --pretty=format:"%C(yellow)%h%Creset %C(cyan)%ad%Creset %C(green)%an%Creset %C(auto)%d%Creset %s" --date=short'
alias gll='git log --graph --decorate --oneline --all'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --rebase --autostash'
alias gb='git branch -vv'
alias gd='git diff'
alias gdc='git diff --cached'

# ---------- Useful functions ----------
mkcd() { mkdir -p "$1" && cd "$1"; }
extract() {
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.bz2)     bunzip2 "$1" ;;
    *.rar)     unrar x "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.tar)     tar xf "$1" ;;
    *.tbz2)    tar xjf "$1" ;;
    *.tgz)     tar xzf "$1" ;;
    *.zip)     unzip "$1" ;;
    *.Z)       uncompress "$1" ;;
    *.7z)      7z x "$1" ;;
    *) echo "Don't know how to extract '$1'" ;;
  esac
}

# ---------- Tooling init (optional) ----------
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"



# ---------- QoL helpers ----------
# Jump to git repo root quickly.
croot() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || return
  cd "$root"
}

# Fuzzy-cd into a directory under the current tree.
fcd() {
  command -v fzf >/dev/null 2>&1 || return
  local dir
  dir=$(find . -type d -not -path '*/\.*' 2>/dev/null | fzf) || return
  cd "$dir"
}

# Show ports currently in LISTEN state.
alias ports='lsof -nP -iTCP -sTCP:LISTEN'


# Local tunneling helper (localtunnel)
tunnel() {
  if [[ -z "$1" ]]; then
    echo "Usage: tunnel <port> [subdomain]"
    return 1
  fi

  if [[ -n "$2" ]]; then
    lt --port "$1" --subdomain "$2"
  else
    lt --port "$1"
  fi
}

# ---------- Runtime version managers ----------
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

export PYENV_ROOT="$HOME/.pyenv"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
fi

if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# ---------- Language/package manager shortcuts ----------
alias nvmls='nvm ls'
alias nvmlts='nvm install --lts'
alias nvmuse='nvm use --lts'
alias pyp='pyenv versions'
alias pypl='pyenv install --list'
alias pypsi='pyenv install'
alias pyps='pyenv shell'
alias jvms='sdk list java'
alias juse='sdk use java'
alias jins='sdk install java'
alias pn='pnpm'
alias pna='pnpm add'
alias pnr='pnpm remove'
alias pni='pnpm install'
alias pnx='pnpm dlx'


# AI coding CLIs
alias cc='claude'
alias ki='kiro-cli'

# One-command upgrader for the common runtime managers
upgrade-dev-runtimes() {
  command -v nvm >/dev/null 2>&1 && nvm install --lts --reinstall-packages-from=current
  command -v pnpm >/dev/null 2>&1 && pnpm self-update || true
  command -v pyenv >/dev/null 2>&1 && pyenv update || true
  command -v sdk >/dev/null 2>&1 && sdk selfupdate force && sdk update || true
}

# ---------- WSL quality of life ----------
if [[ "$PLATFORM" == "wsl" ]]; then
  alias open='explorer.exe'
fi
