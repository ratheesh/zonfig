# zonfig

Zsh configuration based on zimfw — cross-platform (macOS & Linux).

## Installation

```bash
cd zonfig
make install
```

Or manually:

```bash
# Install stow (if not present)
# macOS: brew install stow
# Linux: sudo apt install stow   # Debian/Ubuntu
#        sudo dnf install stow   # Fedora

# Symlink config files
stow -R -v -t $HOME zsh
```

## What it does

- Sets up Zsh with the zimfw plugin manager
- Lazily loads tools (nvm, cargo, virtualenvwrapper, perl, embedded dev toolchains)
- Configures fzf, zoxide, atuin, bat, eza, direnv, and more
- Adapts `ps` flags and Homebrew paths per OS

## Uninstall

```bash
make uninstall
```

## Syntax check

```bash
make lint
```

## LICENSE

MIT
