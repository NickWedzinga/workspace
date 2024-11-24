typeset -g GIT_BRANCH=""
typeset -g CURRENT_DIR=""

function theme_precmd {
  local TERMWIDTH=$(calculate_terminal_width)

  update_git_state

  # Calculate visible sizes
  local visible_branch=$(strip_formatting "$GIT_BRANCH")
  local directoryLength=$(( ${#CURRENT_DIR} ))
  local branchLength=$(( ${#visible_branch})) 

  # Determine total content width, add 1 since RPROMPT is moved inwards 1 character
  local separators_length=6
  local content_width=$(( directoryLength + branchLength + separators_length + 1 ))
  
  # Calculate filler bar
  PR_FILLBAR=""
  if (( content_width < TERMWIDTH )); then
    local remaining_width=$(( TERMWIDTH - content_width ))
    PR_FILLBAR=$(calculate_filler_bar "$remaining_width")
  fi
}

function update_git_state {
  local git_status branch_name git_root
  local dirty_marker="%F{#ff616e}✱%f"
  git_status=$(git status --porcelain=2 --branch 2>/dev/null)

  if [[ -z "$git_status" ]]; then
    GIT_BRANCH=""
    CURRENT_DIR="${PWD/#$HOME/~}"  # Replace $HOME with ~
    return
  fi

  # Extract the branch name
  branch_name=$(echo "$git_status" | sed -n 's/^# branch.head //p')

  # Checks if contents of git_status matches regex MADRCU which contains [modified, added, deleted, renamed, copied, unresolved]
  if echo "$git_status" | grep -qE '^1 .*([MADRCU?])'; then
    GIT_BRANCH="%F{#b297e7}(${branch_name}${dirty_marker})%f"
  else
    GIT_BRANCH="%F{#b297e7}(${branch_name})%f"
  fi

  git_root=$(git rev-parse --show-toplevel 2>/dev/null)
  local relative_path="${PWD#$git_root}"
  CURRENT_DIR="${git_root##*/}$relative_path"
}

function strip_formatting {
  echo "$1" | sed 's/%{[^}]*\}//g; s/%[FB]{[^}]*}//g; s/%f//g'
}

function calculate_terminal_width {
  echo $(( COLUMNS - ${ZLE_RPROMPT_INDENT:-1} ))
}

function calculate_filler_bar {
  local remaining_width=$1
  local filler_char=${PR_HBAR:-'-'}
  printf '%*s' "$remaining_width" '' | tr ' ' "$filler_char"
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
  PR_LRCORNER="${PR_SHIFT_IN}${altchar[j]:--}${PR_SHIFT_OUT}"
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
${PR_LIGHT_BLUE}%{$reset_color%}${PR_CUSTOM_PURPLE})${PR_CUSTOM_PURPLE}${PR_HBAR}\
${PR_HBAR}\
>${PR_NO_COLOUR} '

# display exitcode on the right when > 0
return_code="%(?..%{$fg[red]%}%? ↵ %{$reset_color%})"
RPROMPT=' $return_code${PR_CUSTOM_PURPLE}${PR_HBAR}${PR_CUSTOM_PURPLE}${PR_HBAR}\
(${PR_CUSTOM_RED}%D{%a,%b%d}${PR_CUSTOM_PURPLE})${PR_HBAR}${PR_CUSTOM_PURPLE}${PR_LRCORNER}${PR_NO_COLOUR}'

PS2='${PR_CUSTOM_PURPLE}${PR_LLCORNER}${PR_HBAR}${PR_CUSTOM_PURPLE}${PR_HBAR}(\
${PR_LIGHT_GREEN}%_${PR_CUSTOM_PURPLE})${PR_CUSTOM_PURPLE}${PR_HBAR}${PR_URCORNER}${PR_NO_COLOUR} '
