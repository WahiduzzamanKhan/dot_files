# >>> local variables >>>
local brew_path="/opt/homebrew/bin"
local brew_opt_path="/opt/homebrew/opt"
local nvm_path="$HOME/.nvm"
local dot_path="$HOME/Work/Personal/dot_files"
# <<< local variables <<<

# >>> nvm >>>
export NVM_DIR="${nvm_path}"
[ -s "${brew_opt_path}/nvm/nvm.sh" ] && \. "${brew_opt_path}/nvm/nvm.sh"  # This loads nvm
[ -s "${brew_opt_path}/nvm/etc/bash_completion.d/nvm" ] && \. "${brew_opt_path}/nvm/etc/bash_completion.d/nvm"
# <<< nvm <<<

# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "wintermi/zsh-starship"
plug "zap-zsh/supercharge"
#plug "zsh-users/zsh-syntax-highlighting"
plug "zsh-users/zsh-autosuggestions"
plug "wintermi/zsh-lsd"
plug "zdharma-continuum/history-search-multi-word"
plug "zdharma-continuum/fast-syntax-highlighting"

# Load and initialise completion system
autoload -Uz compinit
compinit

# Aliases
alias kssh="kitten ssh"
alias cat="bat"

# Custom commands to run when shell starts
