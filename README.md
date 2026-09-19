# My dotfiles

Personal configuration files (Ubuntu / GNOME, Wayland).

| Directory | What | Lives at |
|---|---|---|
| `doom/` | Doom Emacs config — `personal.el` is loaded last and holds all personal overrides; `themes/tugmonokai-theme.el` is a port of the Neovim colorscheme | `~/.doom.d/` |
| `nvim/` | Neovim (LazyVim) with the `tugmonokai` colorscheme and lualine theme | `~/.config/nvim/` |
| `ghostty/` | Ghostty terminal config | `~/.config/ghostty/` |
| `tmux/` | tmux config | `~/.tmux.conf` |
| `zsh/` | zsh config (Oh My Zsh, tmux auto-start per Ghostty surface) | `~/.zshrc` |

Other files at the repo root (`lambda-line.el`, `neovim.lua --theme lua`, `vscode-setting.json`) are older standalone snippets.

## Install

Copy or symlink each directory's contents to the path in the table, then for Doom Emacs run `doom sync`.
