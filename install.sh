#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
  printf '\033[1;32m[dotfiles]\033[0m %s\n' "$1"
}

is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

install_packages_linux() {
  if command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y curl git zsh ca-certificates fzf ripgrep fd-find unzip
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y curl git zsh fzf ripgrep fd-find unzip
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm curl git zsh fzf ripgrep fd unzip
  else
    log "No supported package manager found; install dependencies manually."
  fi
}

install_packages_macos() {
  if ! command -v brew >/dev/null 2>&1; then
    log "Homebrew not found. Install from https://brew.sh then re-run."
    return
  fi
  brew install git zsh fzf ripgrep fd bat eza zoxide direnv git-delta
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
  symlink_files
  set_default_shell

  log "Done. Restart terminal or run: source ~/.zshrc"
}

main "$@"
