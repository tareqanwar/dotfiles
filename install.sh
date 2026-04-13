#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKIP_RUNTIMES=false
SKIP_AI=false
MINIMAL=false

log() {
  printf '\033[1;32m[dotfiles]\033[0m %s\n' "$1"
}

is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

linux_distro() {
  if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    echo "${ID:-unknown}"
  else
    echo "unknown"
  fi
}

install_packages_ubuntu_like() {
  sudo apt update
  sudo apt install -y \
    curl git zsh ca-certificates fzf ripgrep fd-find unzip zip \
    build-essential software-properties-common

  # git-delta is required by gitconfig pager settings.
  sudo apt install -y git-delta || log "git-delta not found in apt repos; configure delta manually if needed."
}

install_packages_linux() {
  local distro
  distro="$(linux_distro)"

  if [[ "$distro" == "ubuntu" || "$distro" == "debian" || "$distro" == "pop" || "$distro" == "linuxmint" ]]; then
    log "Using apt for ${distro}"
    install_packages_ubuntu_like
    return
  fi

  if command -v apt >/dev/null 2>&1; then
    log "Using apt (fallback)"
    install_packages_ubuntu_like
  elif command -v dnf >/dev/null 2>&1; then
    log "Using dnf"
    sudo dnf install -y curl git zsh fzf ripgrep fd-find unzip zip
    sudo dnf install -y git-delta || log "git-delta package unavailable in dnf repos."
  elif command -v pacman >/dev/null 2>&1; then
    log "Using pacman"
    sudo pacman -Sy --noconfirm curl git zsh fzf ripgrep fd unzip zip
    sudo pacman -Sy --noconfirm git-delta || log "git-delta package unavailable in pacman repos."
  else
    log "No supported package manager found; install dependencies manually."
  fi
}

install_packages_macos() {
  if ! command -v brew >/dev/null 2>&1; then
    log "Homebrew not found. Install from https://brew.sh then re-run."
    return
  fi

  brew update
  brew install git zsh fzf ripgrep fd bat eza zoxide direnv git-delta pyenv
}

install_oh_my_zsh() {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "Installing Oh My Zsh"
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  local custom="$HOME/.oh-my-zsh/custom/plugins"
  mkdir -p "$custom"

  [[ -d "$custom/zsh-syntax-highlighting" ]] || \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom/zsh-syntax-highlighting"

  [[ -d "$custom/zsh-autosuggestions" ]] || \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$custom/zsh-autosuggestions"
}

install_nvm() {
  if [[ ! -d "$HOME/.nvm" ]]; then
    log "Installing nvm"
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  fi
}

install_sdkman() {
  if [[ ! -d "$HOME/.sdkman" ]]; then
    log "Installing SDKMAN"
    curl -fsSL https://get.sdkman.io | bash
  fi
}

install_pyenv_linux() {
  if command -v pyenv >/dev/null 2>&1; then
    return
  fi

  if command -v apt >/dev/null 2>&1; then
    sudo apt install -y make build-essential libssl-dev zlib1g-dev \
      libbz2-dev libreadline-dev libsqlite3-dev wget llvm libncursesw5-dev \
      xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
  fi

  curl https://pyenv.run | bash
}

install_pnpm() {
  if command -v pnpm >/dev/null 2>&1; then
    return
  fi

  if command -v corepack >/dev/null 2>&1; then
    corepack enable
    corepack prepare pnpm@latest --activate
  else
    curl -fsSL https://get.pnpm.io/install.sh | sh -
  fi
}


setup_node_toolchain() {
  export NVM_DIR="$HOME/.nvm"
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # shellcheck disable=SC1090
    source "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm alias default lts/*
    nvm use --lts
  fi

  if command -v corepack >/dev/null 2>&1; then
    corepack enable
  fi
}

install_claude_cli() {
  if command -v claude >/dev/null 2>&1; then
    return
  fi

  # Anthropic docs list npm as the primary install path.
  if command -v npm >/dev/null 2>&1; then
    log "Installing Claude Code CLI via npm"
    npm install -g @anthropic-ai/claude-code
    return
  fi

  # Fallback: native installer (currently beta in official docs).
  log "npm not found; using Claude native installer fallback"
  curl -fsSL https://claude.ai/install.sh | bash
}

install_kiro_cli() {
  if command -v kiro-cli >/dev/null 2>&1; then
    return
  fi

  if [[ "$(uname -s)" == "Darwin" ]]; then
    log "Installing Kiro CLI for macOS"
    curl -fsSL https://cli.kiro.dev/install | bash
    return
  fi

  if [[ "$(uname -s)" == "Linux" ]]; then
    local distro
    distro="$(linux_distro)"

    if [[ "$distro" == "ubuntu" || "$distro" == "debian" ]]; then
      log "Installing Kiro CLI .deb package for ${distro}"
      local deb_path
      deb_path="$(mktemp /tmp/kiro-cli.XXXXXX.deb)"
      curl --proto '=https' --tlsv1.2 -sSf         'https://desktop-release.q.us-east-1.amazonaws.com/latest/kiro-cli.deb'         -o "$deb_path"
      sudo dpkg -i "$deb_path" || sudo apt-get install -f -y
      rm -f "$deb_path"
      return
    fi

    log "Installing Kiro CLI via generic installer"
    curl -fsSL https://cli.kiro.dev/install | bash
  fi
}


install_local_tunnel() {
  if command -v lt >/dev/null 2>&1; then
    return
  fi

  if command -v npm >/dev/null 2>&1; then
    log "Installing localtunnel (open-source/free local tunnel CLI)"
    npm install -g localtunnel
  else
    log "npm not found; skipped localtunnel install. Install Node.js first."
  fi
}

symlink_files() {
  ln -sfn "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
  ln -sfn "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
  ln -sfn "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"
  mkdir -p "$HOME/.config"
}

set_default_shell() {
  if command -v zsh >/dev/null 2>&1 && [[ "$SHELL" != "$(command -v zsh)" ]]; then
    log "Setting zsh as default shell"
    chsh -s "$(command -v zsh)" || log "Could not change shell automatically; run chsh manually."
  fi
}


usage() {
  cat <<USAGE
Usage: ./install.sh [options]

Options:
  --minimal         Install only base shell + git setup
  --skip-runtimes   Skip nvm/pyenv/sdkman/pnpm setup
  --skip-ai         Skip Claude/Kiro CLI installs
  -h, --help        Show this help message
USAGE
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --minimal)
        MINIMAL=true
        SKIP_RUNTIMES=true
        SKIP_AI=true
        ;;
      --skip-runtimes)
        SKIP_RUNTIMES=true
        ;;
      --skip-ai)
        SKIP_AI=true
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        usage
        exit 1
        ;;
    esac
    shift
  done
}

main() {
  case "$(uname -s)" in
    Darwin)
      log "Detected macOS"
      install_packages_macos
      ;;
    Linux)
      if is_wsl; then
        log "Detected WSL"
      else
        log "Detected Linux"
      fi
      install_packages_linux
      ;;
    *)
      log "Unsupported OS. Continuing with symlink/setup only."
      ;;
  esac

  install_oh_my_zsh

  if [[ "$SKIP_RUNTIMES" == "false" ]]; then
    install_nvm
    install_sdkman

    if [[ "$(uname -s)" == "Linux" ]]; then
      install_pyenv_linux
    fi

    setup_node_toolchain
    install_pnpm
    install_local_tunnel
  fi

  if [[ "$SKIP_AI" == "false" ]]; then
    install_claude_cli
    install_kiro_cli
  fi
  symlink_files
  set_default_shell

  log "Done. Restart terminal or run: source ~/.zshrc"
}

parse_args "$@"
main
