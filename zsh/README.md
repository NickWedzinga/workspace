# Z shell

Z shell (or zsh) is a customizable shell often used with Oh My Zsh. Zsh is the default shell on macOS starting from Catalina (10.15).

We recommend using it together with [Oh My Zsh][omz] along with the plugins, aliases, functions and themes described within this README. Please install Oh My Zsh [here][omz] before continueing further down.

We provide the Zsh config we use [here][zshrc], we recommend you override your .zshrc with this file. Don't forget to source the .zshrc after changing any of these settings to update the shell.

## Themes

We have implemented our own theme called nerolislab.zsh-theme, you can find it [here](./.oh-my-zsh/custom/nerolislab.zsh-theme) in this repository. Place this under ~/.oh-my-zsh/custom/ and either use our .zshrc or change `ZSH_THEME` to `nerolislab` in your own .zshrc.

This theme includes the following in a prettified format:

- current directory
- current working git branch
- current branch dirty state (any uncommitted changes)
- current timestamp
- day of the week
- date
- current temperature

_NOTE; for the temperature to be accurate you need to update the latitude and longitude in the nerolislab.zsh-theme_

```bash
# Tokyo, Japan
local latitude="35.689487"
local longitude="139.691711"
```

## Plugins

You can find many more plugins in the [awesome zsh plugins](https://github.com/unixorn/awesome-zsh-plugins#plugins) repository, but the ones below are the ones we recommend.

Create a `plugins.zsh` under `~.oh-my-zsh/custom/`. Add the following in the file:

```bash
plugins=(git zsh-autosuggestions you-should-use z thefuck)
```

Some of these require specific installations, you can find those instructions below along with information about each plugin.

### git

Install: This plugin is pre-installed in .oh-my-zsh.

This plugin adds useful aliases related to git actions such as `gst`instead of `git status`. You can see all the alises by running `alias`.

### [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

Install: This plugin is not installed by default and needs to be installed by you. This will install it in your `.oh-my-zsh/custom/plugins/` directory which gets picked up by default.

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

In order for the highlight to wrap every widget it needs to be sourced last in the zshrc.
You can either just use our [.zshrc][zshrc] or add it manually to your own .zshrc with:

```bash
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

```

This plugin adds useful syntax highlighting to your commands as you type them, like red for aliases that are not recognized and green for ones that are. Among many other highlights.

### [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)

Install: This plugin is not installed by default and needs to be installed by you. This will install it in your `.oh-my-zsh/custom/plugins/` directory which gets picked up by default.

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

This plugin adds autosuggestions and autocompletion to your commands. When you start typing a command that has been frequently used in your history you will get a suggestion which can be completed by pressing right arrow (→) on your keyboard.

### [you-should-use](https://github.com/MichaelAquilina/zsh-you-should-use)

Install: This plugin is not installed by default and needs to be installed by you. This will install it in your `.oh-my-zsh/custom/plugins/` directory which gets picked up by default.

```bash
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
```

This plugin will let you know if your command could have been optimized by using aliases that it found.

### [fzf](https://github.com/junegunn/fzf)

Install: This plugin is not installed by default and needs to be installed by you.

```bash
brew install fzf
```

This plugin adds fuzzy finder which lets your quickly search and select items from a list using fuzzy matching. We use this together with functions to navigate directories instead of the default `cd`, but you can use it for much more. More information about the fuzzy cd function in [Functions](#functions).

### [navi](https://github.com/denisidoro/navi)

Install: This plugin is not installed by default and needs to be installed by you.

```bash
brew install navi
```

To get the zsh widget you will need to add the following to your .zshrc, so either just use our [.zshrc][zshrc] or add this yourself:

```bash
eval "$(navi widget zsh)"

```

Navi is an interactive cheat sheet tool that lets you browse and use different commands. You're able to define your own cheet sheets.

### [The Fuck](https://github.com/nvbn/thefuck)

Install: This plugin is not installed by default and needs to be installed by you.

```bash
brew install thefuck
```

You will need to add the following to your .zshrc, so either just use our [.zshrc][zshrc] or add this yourself:

```bash
eval $(thefuck --alias --enable-experimental-instant-mode)
# You can use whatever you want as an alias, like for Mondays:
eval $(thefuck --alias FUCK --enable-experimental-instant-mode)
```

This lets you quickly fix and rerun commands in case of a misspelled word.

```bash
git brnch
fuck
git branch
```

### [zsh-bat](https://github.com/fdellwing/zsh-bat)

Install: This plugin is not installed by default and needs to be installed by you.

```bash
brew install bat
```

This plugin lets you preview files with bat instead of cat. Now you can just preview files with: `bat example.txt`

## Functions

Create a `functions.zsh` under `.oh-my-zsh/custom/functions.zsh` if you haven't already. Add the following functions to your `functions.zsh`.

### fd

We have implemented a fuzzy find function that let's you navigate to any directory or file on your system by searching with sub-strings. The function will only search in pre-defined directories as to avoid directories that you would never want to visit.

Add this in your `functions.zsh`:

```bash
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
```

You can either create and add searchable directories yourself or use the [adddir alias](#adddir). If you decide to create it yourself then place it in `.oh-my-zsh/custom/directories.txt` and add a line for each directory, using absolute paths.

Instead of using `cd` you can now use `fd` to bring up an in-line console that let's you search for directories and files.

### greset

We have implemented a git function that let's you reset a custom amount of commits and unstages those changes. This is especially useful for squashing commits, or resuming work on WIP commits.

Add this in your `functions.zsh`:

```bash
greset() {
    local commits=${1:-1}  # Default to 1 commit
    git reset --soft HEAD~"$commits" && git reset
}
```

You can use this like:
`greset` which will default to 1 commit
`greset 3` which would reset your last 3 commits

## Aliases

Create a `aliases.zsh` under `.oh-my-zsh/custom/aliases.zsh` if you haven't already. Add the following aliases to your `aliases.zsh`.

### adddir

This alias let's you quickly add the current directory to `directories.txt` using `pwd` for use with the [fuzzy find cd](#fd) function listed above.

```bash
alias adddir='find "$(pwd)" \( $(build_exclude_filter) \) -o -type d -print | sort -u >> ~/.oh-my-zsh/custom/directories.txt && sort -u ~/.oh-my-zsh/custom/directories.txt -o ~/.oh-my-zsh/custom/directories.txt && echo "Added $(pwd) to directories.txt" && source ~/.zshrc'
```

Running `adddir` will grab the absolute path of the current directory, add it to `directories.txt`, sort the file, print the added directory and reload your `.zshrc`.

### git aliases

The [git](#git) plugin already adds a lot of git aliases, but these are some other ones that we recommend. Add these to your `aliases.zsh`.

```bash
alias gpu='git push -u origin $(git rev-parse --abbrev-ref HEAD)'
alias gforce='git push --force-with-lease'
alias gmend='git commit --amend --no-edit'
```

`gpu` let's you quickly push up a new branch, this creates a branch on the remote origin matching your current branch name and pushes the code.

`gforce` is useful for force-pushing amended commits using `force-with-lease`. Please be careful about force pushing.

`gmend` let's you `git --amend` your last commit with no commit message changes.

### navigation

```bash
alias ll='ls -la'
```

`ll` let's you quickly list all files in the current directory with more information using `ls -la`.

<!-- Links -->

[omz]: https://ohmyz.sh/
[zshrc]: ./.zshrc
