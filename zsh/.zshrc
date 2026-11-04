# User configuration
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
neofetch

# Created by `pipx` on 2024-10-26 17:53:43
export PATH="$PATH:/Users/gregoryjanes/.local/bin"
export PATH="/Users/gregoryjanes/.local/share/nvim/lazy/vim-tidal/bin:$PATH"
export PATH="/usr/local/krb5/bin:/usr/local/ossh/bin:$PATH"
export KRB5_CONFIG=/etc/krb5.conf

# Research paths. Override per-machine in ~/.zshrc.local (HPC: point VORTEX_DATA at scratch).
export VORTEX_CODE="$HOME/003-code"
export VORTEX_DATA="$HOME/006-data"
export VORTEX_LATEX="$HOME/005-latex"
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

eval "$(rbenv init - --no-rehash zsh)"

alias python="python3"

alias vim="nvim"

# Colored ls (macOS ls is plain without this): folders blue, links purple, executables red.
# -F also marks folders with a trailing / so they stand out even without color.
export CLICOLOR=1
alias ls="ls -F"

# Let kitty set TERM (xterm-kitty: true color, undercurl). Remote hosts may not know
# xterm-kitty, so fall back to a universal TERM just for ssh. Inside kitty the window
# also goes opaque while connected (remote vim can't do transparency) and back after.
# ponytail: opacity is per kitty OS window; leaving one of two ssh tabs restores it early
ssh() {
  [[ -n $KITTY_LISTEN_ON ]] && kitten @ set-background-opacity --match id:$KITTY_WINDOW_ID 1 2>/dev/null
  { TERM=xterm-256color command ssh "$@" } always {
    [[ -n $KITTY_LISTEN_ON ]] && kitten @ set-background-opacity --match id:$KITTY_WINDOW_ID --toggle 1 2>/dev/null
  }
}

. "$HOME/.cargo/env"

# >>> Added by Spyder >>>
alias uninstall-spyder=/Users/gregoryjanes/Library/spyder-6/uninstall-spyder.sh
# <<< Added by Spyder <<<
source ~/.config/powerlevel10k/powerlevel10k.zsh-theme
source ${HOME}/.ghcup/env

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/Users/gregoryjanes/.juliaup/bin' $path)
export PATH
# Tab completion for juliaup and julia channel selection
[ -f "/Users/gregoryjanes/.julia/juliaup/completions/zsh.zsh" ] && source "/Users/gregoryjanes/.julia/juliaup/completions/zsh.zsh"

# <<< juliaup initialize <<<

# Register the active venv as a Jupyter kernel so Molten's <leader>ji finds it
mkkernel() {
  [[ -z $VIRTUAL_ENV ]] && { echo "activate a venv first"; return 1; }
  local name=${VIRTUAL_ENV:t}
  [[ $name == .venv || $name == venv ]] && name=${VIRTUAL_ENV:h:t}
  uv pip install -q ipykernel && python3 -m ipykernel install --user --name ${name:l}
}

# Copy Claude config (CLAUDE.md + skills) into a project directory
claude-init() {
  local target="${1:-.}"
  mkdir -p "$target/.claude/skills"
  cp ~/000-dotfiles/templates/CLAUDE.md "$target/CLAUDE.md"
  cp -r ~/000-dotfiles/claude/.claude/skills/. "$target/.claude/skills/"
}

# Copy Gemini config (GEMINI.md + skills) into a project directory
gemini-init() {
  local target="${1:-.}"
  mkdir -p "$target/.gemini/skills"
  cp ~/000-dotfiles/templates/GEMINI.md "$target/GEMINI.md"
  cp -r ~/000-dotfiles/gemini/.gemini/skills/. "$target/.gemini/skills/"
}


# Added by Antigravity CLI installer
export PATH="/Users/gregoryjanes/.local/bin:$PATH"
