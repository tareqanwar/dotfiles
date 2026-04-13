# dotfiles

A portable **developer-first** terminal setup for:
- macOS (Homebrew)
- WSL + Ubuntu-family distros (apt)
- other Linux distros
- any terminal with zsh support

## Install

```bash
git clone https://github.com/tareqanwar/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

## Highlights

### Zsh + Prompt
- fast zsh startup with practical defaults
- git-aware prompt with branch, ahead/behind, and dirty flags
- quality completion/keybindings and optional tooling hooks (`fzf`, `zoxide`, `direnv`)
- extra QoL helpers: `croot` (jump to repo root), `fcd` (fuzzy cd), `ports` (list listening ports)

### Git workflow
- clean defaults for modern branching (`main`, rebase pull, prune fetch)
- useful day-to-day aliases for status, logs, and branch visibility

### Runtime/version-manager workflow
This setup is tuned so switching language versions is simple:
- **Node.js:** `nvm`
- **Package manager:** `pnpm` (installed/configured as primary npm ecosystem package manager)
- **Python:** `pyenv`
- **Java:** `sdkman`

Useful shell shortcuts are included:
- `nvmls`, `nvmlts`, `nvmuse`
- `pyp`, `pypl`, `pypsi`, `pyps`
- `jvms`, `juse`, `jins`
- `pn`, `pna`, `pnr`, `pni`, `pnx`
- `upgrade-dev-runtimes` (updates nvm/pnpm/pyenv/sdkman where available)


### AI CLI tooling
Installer now bootstraps:
- **Claude CLI** (`claude`) using the official npm package first (`@anthropic-ai/claude-code`), with native installer fallback
- **Kiro CLI** (`kiro-cli`) using official installer on macOS and fallback distros, and `.deb` install path on Ubuntu/Debian

Convenience aliases:
- `cc` → `claude`
- `ki` → `kiro-cli`

### Other ideas to level this up
- Add `atuin` for shell history sync/search across machines.
- Add `lazygit` for a fast TUI git workflow.
- Add `mise` if you want one manager for node/python/java/tool versions.
- Add `aider` for repo-aware AI pair programming from terminal.

## Installer behavior
- **macOS:** uses Homebrew packages.
- **WSL / Ubuntu / Debian family:** uses `apt` and Ubuntu-style dependencies.
- **Other Linux distros:** falls back to detected package manager (`dnf` / `pacman` / `apt`).

The installer also:
- installs Oh My Zsh + syntax/autosuggestion plugins
- installs nvm, sdkman, pyenv (Linux), and pnpm
- symlinks `.zshrc`, `.bashrc`, and `.gitconfig`
- attempts to set zsh as default shell


## Installer flags
- `./install.sh --minimal` → only base shell + git setup
- `./install.sh --skip-runtimes` → skip nvm/pyenv/sdkman/pnpm
- `./install.sh --skip-ai` → skip Claude/Kiro install
