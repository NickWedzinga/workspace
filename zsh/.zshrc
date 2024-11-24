export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="nerolislab"

eval $(/opt/homebrew/bin/brew shellenv)

COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"

source $ZSH/oh-my-zsh.sh
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
eval $(thefuck --alias)
eval "$(navi widget zsh)"
source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
