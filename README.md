# My dotfiles

Personal configuration files (Ubuntu / GNOME, Wayland).

| Directory | What | Lives at |
|---|---|---|
| `doom/` | Doom Emacs config — `personal.el` is loaded last and holds all personal overrides; `themes/ghostty-theme.el` uses Monokai blue/green accents, lavender strings, white comments and an icy blue-black background; previous themes are retained | `~/.doom.d/` |
| `nvim/` | Neovim (LazyVim) with the `tugmonokai` colorscheme and lualine theme | `~/.config/nvim/` |
| `ghostty/` | Ghostty terminal config | `~/.config/ghostty/` |
| `tmux/` | tmux config | `~/.tmux.conf` |
| `zsh/` | zsh config (Oh My Zsh, tmux auto-start per Ghostty surface) | `~/.zshrc` |

Other files at the repo root (`lambda-line.el`, `neovim.lua --theme lua`, `vscode-setting.json`) are older standalone snippets.

## Install

Copy or symlink each directory's contents to the path in the table, then for Doom Emacs run `doom sync`.

## Terminal Emacs in Ghostty

Install `bin/emacs` as `~/.local/bin/emacs` (executable, before `/usr/bin` in PATH). `emacs --nw`, `emacs -nw`, and `emacs --no-window-system` run in the invoking terminal or tmux pane. The launcher only normalizes `--nw` to `-nw` and passes arguments to `/usr/bin/emacs`; it never launches another terminal window.

In graphical Emacs, `SPC t T` toggles 88%/100% opacity. Terminal opacity is managed by the terminal itself; the Emacs palette does not change Ghostty settings.

## Top search panel

`doom/search-ui.el` uses the installed Vertico buffer extension to show file/project search input and results at the top. Evil `/` and `?` use a compact top input panel with native history, incremental search, and `n`/`N`. Works in GUI and terminal Emacs. Enter accepts; Escape or `C-g` cancels.
