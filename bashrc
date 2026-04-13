# ~/.bashrc

# Launch zsh for interactive bash sessions when available.
case $- in
  *i*)
    if command -v zsh >/dev/null 2>&1; then
      exec zsh
    fi
    ;;
esac
