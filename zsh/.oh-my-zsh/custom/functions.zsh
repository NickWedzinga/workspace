# cd to searchable directory
fd() {
  local selection
  local dir

  # Read directories from `directories.txt` and search within them
  selection=$(cat ~/.oh-my-zsh/custom/directories.txt | while read -r base; do
    base=${base/#\~/$HOME}  # Expand ~ to $HOME
    if [ -d "$base" ]; then
      echo "$base"
      find "$base" \( -name ".git" -o -name "node_modules" -o -name "dist" -o -name "build" -o -name "out" -o -name ".vscode" -o -name ".idea" -o -name "Library" \) -prune -o -print 2>/dev/null
    fi
  done | fzf --height 20% --reverse --prompt="Search for file or directory: ")

  # Determine if selection is a file or directory
  if [ -d "$selection" ]; then
    # If a directory is selected, change to it
    cd "$selection"
  elif [ -f "$selection" ]; then
    # If a file is selected, change to its directory
    dir=$(dirname "$selection")
    cd "$dir"
  else
    echo "No selection was made."
  fi
}

# reset X commits and unstages them, useful for continueing work on WIP commits
greset() {
    local commits=${1:-1}  # Default to 1 commit
    git reset --soft HEAD~"$commits" && git reset
}


wip() {
  local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -n "$git_root" ]]; then
    local source_dir=$(pwd)

    cd "$git_root" || return
    echo "Moved to Git root directory: $git_root"

    git add .
    git commit -m "WIP"
    echo "Changes committed with message: WIP"

    cd "$source_dir" || return
    echo "Moved back to original directory: $source_dir"
  else
    echo "Not inside a Git repository."
  fi
}
