typeset -g GIT_BRANCH=""
typeset -g CURRENT_DIR=""
typeset -g LAST_BRANCH=""
LAST_DIR=""
FILLER_BAR=$(printf '%*s' 1000 '' | tr ' ' "${PR_HBAR:-'-'}")
typeset -g DIR_LENGTH=0
typeset -g BRANCH_LENGTH=0


function theme_precmd {
  local TERMWIDTH
  TERMWIDTH=$(calculate_terminal_width) || {
    echo "Error calculating terminal width."
    return 1
  }

  update_git_state || {
    echo "Error updating git state."
    return 1
  }

  # Use FULL_CURRENT_DIR to reset the path when space allows
  local directoryLength=${#FULL_CURRENT_DIR}
  local branchLength=$BRANCH_LENGTH
  local separators_length=6
  local content_width=$(( directoryLength + branchLength + separators_length + 1 ))

  PR_FILLBAR=""

  # Truncate CURRENT_DIR with ellipsis if it exceeds available width
  if (( content_width > TERMWIDTH )); then
    local available_width=$(( TERMWIDTH - branchLength - separators_length - 4 ))
    if (( available_width > 0 )); then
      local shortened_dir="..${FULL_CURRENT_DIR: -available_width}"
      CURRENT_DIR="$shortened_dir"
      DIR_LENGTH=${#CURRENT_DIR}
    else
      CURRENT_DIR="../"
      DIR_LENGTH=3
    fi
  else
    # Reset to full path if it fits
    CURRENT_DIR="$FULL_CURRENT_DIR"
    DIR_LENGTH=${#CURRENT_DIR}
  fi

  # Recalculate filler bar if there's space
  if (( content_width < TERMWIDTH )); then
    local remaining_width=$(( TERMWIDTH - content_width ))
    PR_FILLBAR="${FILLER_BAR[1,remaining_width]}"
  fi
}

typeset -g LAST_BRANCH=""

function update_git_state {
  local current_dir=$(pwd)
  local current_branch=""

  # Determine the current branch, if in a Git repository
  local git_root branch_name
  git_root=$(git rev-parse --show-toplevel 2>/dev/null)

  if [[ $? -eq 0 ]]; then
    branch_name=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
    current_branch="$branch_name"
  fi

  # Early return if both the directory and branch are unchanged
  if [[ "$current_dir" == "$LAST_DIR" && "$current_branch" == "$LAST_BRANCH" ]]; then
    return
  fi

  # Update LAST_DIR and LAST_BRANCH
  LAST_DIR="$current_dir"
  LAST_BRANCH="$current_branch"

  if [[ -n "$current_branch" ]]; then
    # Update Git branch info
    local dirty_marker="%F{#ff616e}✱%f"
    local is_dirty=$(git diff --quiet || echo "dirty")
    if [[ "$is_dirty" == "dirty" ]]; then
      GIT_BRANCH="%F{#b297e7}(${current_branch}${dirty_marker})%f"
    else
      GIT_BRANCH="%F{#b297e7}(${current_branch})%f"
    fi

    # Compute the full relative path
    if [[ "$PWD" == "$git_root" ]]; then
      relative_path=""
    else
      relative_path="${PWD#$git_root/}"
    fi
    FULL_CURRENT_DIR="${git_root##*/}${relative_path:+/$relative_path}"
  else
    # Not in a Git repository
    GIT_BRANCH=""
    FULL_CURRENT_DIR="${PWD/#$HOME/~}"
  fi

  # Update directory and branch lengths
  local visible_branch=$(strip_formatting "$GIT_BRANCH")
  DIR_LENGTH=${#FULL_CURRENT_DIR}
  BRANCH_LENGTH=${#visible_branch}
}

function strip_formatting {
  echo "$1" | sed 's/%{[^}]*\}//g; s/%[FB]{[^}]*}//g; s/%f//g'
}

function calculate_terminal_width {
  echo $(( COLUMNS - ${ZLE_RPROMPT_INDENT:-1} ))
}

function supports_truecolor {
  [[ "$COLORTERM" == *"truecolor"* ]] && return 0 || return 1
}

function theme_preexec {
  setopt local_options extended_glob
  if [[ "$TERM" = "screen" ]]; then
    local CMD=${1[(wr)^(*=*|sudo|-*)]}
    echo -n "\ek$CMD\e\\"
  fi
}


autoload -U add-zsh-hook
add-zsh-hook precmd  theme_precmd
add-zsh-hook preexec theme_preexec
setopt prompt_subst
autoload zsh/terminfo

PR_NO_COLOUR="%{$terminfo[sgr0]%}"
if supports_truecolor; then
  PR_CUSTOM_RED="%{[38;2;255;97;110m%}"
  PR_CUSTOM_PURPLE="%{[38;2;178;151;231m%}"
else
  PR_CUSTOM_RED="%{$(tput setaf 196)%}"
  PR_CUSTOM_PURPLE="%{$(tput setaf 141)%}"
fi



# Use extended characters to look nicer if supported.
if [[ "${langinfo[CODESET]}" = UTF-8 ]]; then
  PR_SET_CHARSET=""
  PR_HBAR="─"
  PR_ULCORNER="┌"
  PR_LLCORNER="└"
  PR_LRCORNER="┘"
  PR_URCORNER="┐"
else
  typeset -g -A altchar
  set -A altchar ${(s..)terminfo[acsc]}
  # Some stuff to help us draw nice lines
  PR_SET_CHARSET="%{$terminfo[enacs]%}"
  PR_SHIFT_IN="%{$terminfo[smacs]%}"
  PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
  PR_HBAR="${PR_SHIFT_IN}${altchar[q]:--}${PR_SHIFT_OUT}"
  PR_ULCORNER="${PR_SHIFT_IN}${altchar[l]:--}${PR_SHIFT_OUT}"
  PR_LLCORNER="${PR_SHIFT_IN}${altchar[m]:--}${PR_SHIFT_OUT}"
  PR_LRCORNER="%{┘%}"
  PR_URCORNER="${PR_SHIFT_IN}${altchar[k]:--}${PR_SHIFT_OUT}"
fi

# Decide if we need to set titlebar text.
case $TERM in
  xterm*)
    PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
    ;;
  screen)
    PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
    ;;
  *)
    PR_TITLEBAR=""
    ;;
esac

# Decide whether to set a screen title
if [[ "$TERM" = "screen" ]]; then
  PR_STITLE=$'%{\ekzsh\e\\%}'
else
  PR_STITLE=""
fi

# Finally, the prompt.
PROMPT='${PR_SET_CHARSET}${PR_STITLE}${(e)PR_TITLEBAR}\
${PR_CUSTOM_PURPLE}${PR_ULCORNER}${PR_HBAR}${PR_CUSTOM_RED}${CURRENT_DIR}\
${PR_CUSTOM_PURPLE}${GIT_BRANCH}${PR_CUSTOM_PURPLE}${PR_HBAR}${PR_HBAR}${(e)PR_FILLBAR}${PR_HBAR}${PR_CUSTOM_PURPLE}${PR_HBAR}${PR_URCORNER}\

${PR_CUSTOM_PURPLE}${PR_LLCORNER}${PR_CUSTOM_PURPLE}${PR_HBAR}(\
${PR_CUSTOM_RED}%D{%H:%M:%S}\
${PR_CUSTOM_PURPLE})${PR_CUSTOM_PURPLE}${PR_HBAR}\
${PR_HBAR}\
>${PR_NO_COLOUR} '

# display exitcode on the right when > 0
return_code="%(?..%{$fg[red]%}%? ↵ %{$reset_color%})"
RPROMPT=' $return_code${PR_CUSTOM_PURPLE}${PR_HBAR}${PR_CUSTOM_PURPLE}${PR_HBAR}\
(${PR_CUSTOM_RED}%D{%a,%b%d}${PR_CUSTOM_PURPLE})${PR_HBAR}${PR_LRCORNER}'

PS2='${PR_CUSTOM_PURPLE}${PR_LLCORNER}${PR_HBAR}${PR_CUSTOM_PURPLE}${PR_HBAR}(\
${PR_LIGHT_GREEN}%_${PR_CUSTOM_PURPLE})${PR_CUSTOM_PURPLE}${PR_HBAR}${PR_URCORNER}${PR_NO_COLOUR} '
