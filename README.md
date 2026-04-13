# dotfiles

A portable **developer-first** shell setup for:
- macOS
- Linux
- WSL
- any terminal with zsh support

It ships with:
- fast, readable zsh prompt with **git branch/status indicators**
- practical git defaults and aliases for modern workflows
- cross-platform install script
- sane history, completion, and navigation defaults

## Install

```bash
git clone https://github.com/tareqanwar/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

## What you get

### Zsh
- portable path setup for Linux/macOS/Homebrew
- strong completion + keybindings
- optional tooling hooks (`fzf`, `zoxide`, `direnv`)
- git-aware prompt:
  - current branch
  - ahead/behind marker
  - unstaged/staged/untracked flags

### Git
- `main` as default branch for new repos
- pull via rebase + autostash
- auto-prune on fetch
- conflict style `zdiff3`
- rerere enabled for easier repeated conflict resolution
- useful aliases (`s`, `lg`, `tree`, `br`, `up`, etc.)

## Notes
- If you don’t use `nvim`, update `[core] editor` in `gitconfig`.
- Optional tools like `delta`, `eza`, `bat`, `zoxide` are auto-used when installed.
- For work/personal split config, use `~/.gitconfig-work` (already wired in via `includeIf`).
