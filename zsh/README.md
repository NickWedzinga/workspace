# Z shell

Z shell (or zsh) is a customizable shell often used with Oh My Zsh. Zsh is the default shell on macOS starting from Catalina (10.15).

We recommend using it together with [Oh My Zsh][omz] along with the plugins, aliases, functions and themes described within this README. Please install Oh My Zsh [here][omz] before continueing further down.

We provide the Zsh config we use [here][zshrc], we recommend you override your .zshrc with this file. Don't forget to source the .zshrc after changing any of these settings to update the shell.

## Themes

🚧
TODO: Add custom theme
🚧

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

<!-- Links -->

[omz]: https://ohmyz.sh/
[zshrc]: ./.zshrc
