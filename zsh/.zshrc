if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall
zstyle :compinstall filename '/home/gregoryjanes/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# User configuration
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Custom commands
init-claude() {
    if [ ! -d "$HOME/dotfiles/claude" ]; then
        echo "Template directory not found at ~/dotfiles/claude"
        return 1
    fi
    
    cp -r "$HOME/dotfiles/claude/CLAUDE.md" . 2>/dev/null || touch CLAUDE.md
    cp -r "$HOME/dotfiles/claude/.claude" . 2>/dev/null || mkdir .claude
    
    echo "✅ Claude templates copied. Ready for project-specific rules."
}

# Exports
export PATH="/usr/local/krb5/bin:$PATH"
export KRB5_CONFIG=/etc/krb5.conf
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
export PATH="/usr/local/texlive/2025/bin/x86_64-linux:$PATH"
export TERM=xterm-256color
export ARISTOTLE_API_KEY=arstl_JITMlFbprZ99UhFXHFsAtgkScvMQSnEhx9MQaL3U71M

# Initialize rbenv
eval "$(rbenv init - --no-rehash zsh)"

# Aliases
alias vim="nvim"
alias vi="nvim"
alias v="nvim"

# FIX: Only try to load Cargo if the file actually exists
# This prevents the "no such file or directory" error output
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

source /usr/share/Modules/init/zsh

# Load Powerlevel10k Theme
source ~/.config/powerlevel10k/powerlevel10k.zsh-theme

# Add local bin to PATH if it exists
if [ -d "$HOME/.local/bin" ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Run fastfetch
# Note: Because this prints to the screen, p10k might still warn you.
# If it does, you can safely ignore it or use `p10k configure` to set "Quiet" mode.
fastfetch
