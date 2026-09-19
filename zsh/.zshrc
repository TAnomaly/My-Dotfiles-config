# ─────────────────────────────────────────────────────────────
#  ~/.zshrc  — Ghostty + tmux + Oh My Zsh
# ─────────────────────────────────────────────────────────────

# Early PATH (OMZ / plugins before interactive polish)
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export PATH="$HOME/.emacs.d/bin:$HOME/.config/doom/bin:$PATH"
export PATH="$HOME/go/bin:$HOME/.grok/bin:$HOME/.opencode/bin:$HOME/.kimi-code/bin:$PATH"
export PATH="$PATH:$HOME/.lmstudio/bin"
export BUN_INSTALL="$HOME/.bun"
[ -d "$BUN_INSTALL/bin" ] && export PATH="$BUN_INSTALL/bin:$PATH"

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

# Theme boş: altta özel kompakt prompt
ZSH_THEME=""

# Case-insensitive completion, hyphen-aware
CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="true"

# Update nudge only (don't block shell)
zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 14

COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="yyyy-mm-dd"

# Plugins (syntax-highlighting EN SONDA olmalı)
plugins=(
  git
  sudo
  extract
  command-not-found
  colored-man-pages
  history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ── History ────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY          # timestamp
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt GLOB_DOTS
setopt COMPLETE_IN_WORD

# ── Colors / ls ────────────────────────────────────────────
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b 2>/dev/null)" || true
fi
# eza varsa daha güzel liste; yoksa renkli ls
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -lah --group-directories-first --icons=auto --git'
  alias la='eza -a --group-directories-first --icons=auto'
  alias lt='eza -lahT --level=2 --icons=auto --git'
  alias l='eza -1 --group-directories-first'
else
  alias ls='ls --color=auto'
  alias ll='ls -alFh --color=auto'
  alias la='ls -A --color=auto'
  alias l='ls -CF --color=auto'
fi
alias grep='grep --color=auto'
alias diff='diff --color=auto'

# ── Kompakt ama canlı prompt ───────────────────────────────
# Örnek:  󰉋 proj  󰘬 main*  ❯
#         ↳ dizin  ↳ git     ↳ durum (yeşil/kırmızı)
autoload -Uz colors && colors
autoload -Uz vcs_info
setopt PROMPT_SUBST

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{green}+%f'
zstyle ':vcs_info:*' unstagedstr '%F{yellow}*%f'
zstyle ':vcs_info:git:*' formats ' %F{magenta}󰘬%f %F{blue}%b%u%c%f'
zstyle ':vcs_info:git:*' actionformats ' %F{magenta}󰘬%f %F{blue}%b%f %F{red}|%a%f%u%c'

# Sanal ortam / nvm kısa ipucu
_prompt_venv() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    print -n "%F{yellow}(${VIRTUAL_ENV:t})%f "
  fi
}

_prompt_exit() {
  # son komut exit code (0 değilse)
  echo "%(?..%F{red}✗%?%f )"
}

precmd() { vcs_info }

# Sol: exit · venv · 󰉋 dir · git · ok
PROMPT='$(_prompt_exit)$(_prompt_venv)%F{cyan}󰉋%f %F{cyan}%c%f${vcs_info_msg_0_} %(?:%F{green}:%F{red})❯%f '
# Sağ: saat (hafif gri) — sık prompt, bilginin bir kısmı sağda
RPROMPT='%F{240}%D{%H:%M}%f'

# Autosuggestion rengi (koyu monokai arka plan)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# History substring search (ok tuşları)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# ── Editor / pager ─────────────────────────────────────────
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LESS='-R -F -X'
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# ── NVM ────────────────────────────────────────────────────
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# ── Aliases ────────────────────────────────────────────────
alias zshconfig='$EDITOR ~/.zshrc'
alias zshreload='source ~/.zshrc && echo "zsh reloaded ✓"'
alias ghosttyconfig='$EDITOR ~/.config/ghostty/config.ghostty'
alias tmuxconfig='$EDITOR ~/.tmux.conf'
alias doomconfig='$EDITOR ~/.doom.d/config.el'
alias doompersonal='$EDITOR ~/.doom.d/personal.el'
alias doomsync='doom sync && echo "doom sync ✓"'
alias e='emacsclient -nw -a ""'
alias eg='emacsclient -c -a ""'
alias nvchad='NVIM_APPNAME=nvchad nvim'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias g='git'
alias gs='git status -sb'
alias gd='git diff'
alias gl='git log --oneline --graph -20'
alias gp='git push'
alias ga='git add'
alias gc='git commit'
alias ports='ss -tulpn 2>/dev/null || netstat -tulpn 2>/dev/null'
alias path='print -l $path'
alias please='sudo $(fc -ln -1)'
alias cls='clear'
alias mkdir='mkdir -p'
# Hızlı dizinler
alias dl='cd ~/Downloads'
alias docs='cd ~/Documents'
alias conf='cd ~/.config'

# bat varsa man/cat güzelleştir
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never --style=plain'
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --paging=never --style=plain'
fi

# fzf (varsa)
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=bg+:#2D2A2E,fg:#F8F8F2,hl:#FF6188,hl+:#A6E22E'
  [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && . /usr/share/doc/fzf/examples/key-bindings.zsh
  [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && . /usr/share/doc/fzf/examples/completion.zsh
fi

# zoxide (akıllı cd)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# ── tmux auto-start ────────────────────────────────────────
# Her Ghostty yüzeyi (split/tab/window) kendi tmux client'ıdır. Sabit bir
# session adına attach etmek hepsini AYNI session'a bağlar: tmux o zaman aynı
# window'u aynalar ve boyutu en küçük client'a kilitler.
#
# Doğru davranış: bağlı OLMAYAN (detached) bir session varsa ona bağlan —
# böylece kapatılan/kopan iş kaybolmaz; yoksa yeni ve bağımsız bir session aç.
if [[ -z "$TMUX" && -o interactive && -z "$ZSH_NO_TMUX" ]]; then
  # attached=0 olan ilk session; hiç session yoksa çıktı boş
  _tmux_bos=$(tmux ls -F '#{session_name} #{session_attached}' 2>/dev/null \
              | awk '$2==0 {print $1; exit}')
  if [[ -n "$_tmux_bos" ]]; then
    exec tmux attach -t "$_tmux_bos"
  else
    exec tmux new -s "w$$"
  fi
fi
