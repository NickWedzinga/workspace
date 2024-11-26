alias gpu='git push -u origin $(git rev-parse --abbrev-ref HEAD)'
alias gforce='git push --force-with-lease'
alias gmend='git commit --amend --no-edit'

alias ll='ls -la'

# Alias to add the current directory to ~/.directories.txt
alias adddir='find "$(pwd)" \( $(build_exclude_filter) \) -o -type d -print | sort -u >> ~/.oh-my-zsh/custom/directories.txt && sort -u ~/.oh-my-zsh/custom/directories.txt -o ~/.oh-my-zsh/custom/directories.txt && echo "Added $(pwd) to directories.txt" && source ~/.zshrc'
