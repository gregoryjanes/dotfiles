# User configuration
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
neofetch

# Created by `pipx` on 2024-10-26 17:53:43
export PATH="$PATH:/Users/gregoryjanes/.local/bin"
export PATH="/Users/gregoryjanes/.local/share/nvim/lazy/vim-tidal/bin:$PATH"
export PATH="/usr/local/krb5/bin:/usr/local/ossh/bin:$PATH"
export KRB5_CONFIG=/etc/krb5.conf

eval "$(rbenv init - --no-rehash zsh)"

alias python="python3"

alias vim="nvim"

export TERM=xterm-256color

. "$HOME/.cargo/env"

# >>> Added by Spyder >>>
alias uninstall-spyder=/Users/gregoryjanes/Library/spyder-6/uninstall-spyder.sh
# <<< Added by Spyder <<<
source ~/.config/powerlevel10k/powerlevel10k.zsh-theme
source ${HOME}/.ghcup/env
