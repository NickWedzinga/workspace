typeset -g LAST_TEMP_FETCH=0  # Timestamp of the last temperature fetch
typeset -g CACHED_TEMP="N/A"

function fetch_temperature {
  local current_time=$(date +%s)
  local fetch_interval=900

  if (( current_time - LAST_TEMP_FETCH >= fetch_interval )); then
    LAST_TEMP_FETCH=$current_time

    # Fetch the temperature
    local latitude="56.1616"
    local longitude="15.5866"
    local timezone="Europe/Berlin"
    local api_url="https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true&timezone=$timezone"

    # Run curl in the background
    {
      local raw_response=$(curl -s "$api_url")
      
      # Extract the temperature specifically from "current_weather"
      local temperature=$(echo "$raw_response" | grep -o '"current_weather":{"[^}]*' | grep -o '"temperature":[^,]*' | sed -E 's/"temperature"://')

      # Save the temperature to a temporary file if extraction is successful
      if [[ -n "$temperature" ]]; then
        echo "$temperature" > /tmp/cached_temp
      else
        echo "Temperature extraction failed" >> /tmp/fetch_temp_debug.log
      fi
    } &>/dev/null &
  fi

  # Read the cached temperature from file
  if [[ -f /tmp/cached_temp ]]; then
    CACHED_TEMP=$(< /tmp/cached_temp)
  fi

  echo "CACHED=$CACHED_TEMP"
}

function theme_precmd {
  local TERMWIDTH=$(( COLUMNS - ${ZLE_RPROMPT_INDENT:-1} ))

  PR_FILLBAR=""
  PR_PWDLEN=""

  fetch_temperature &>/dev/null

  local promptsize=${#${(%):-------()-}}
  local rubypromptsize=${#${(%)$(ruby_prompt_info)}}
  local pwdsize=${#${(%):-%~}}
  local venvpromptsize=$((${#$(virtualenv_prompt_info)}))

  # Truncate the path if it's too long.
  if (( promptsize + rubypromptsize + pwdsize + venvpromptsize > TERMWIDTH )); then
    (( PR_PWDLEN = TERMWIDTH - promptsize ))
  elif [[ "${langinfo[CODESET]}" = UTF-8 ]]; then
    PR_FILLBAR="\${(l:$(( TERMWIDTH - (promptsize + rubypromptsize + pwdsize + venvpromptsize ) ))::${PR_HBAR}:)}"
  else
    PR_FILLBAR="${PR_SHIFT_IN}\${(l:$(( TERMWIDTH - (promptsize + rubypromptsize + pwdsize + venvpromptsize ) ))::${altchar[q]:--}:)}${PR_SHIFT_OUT}"
  fi
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

ZSH_THEME_GIT_PROMPT_PREFIX=" on ${PR_CUSTOM_PURPLE}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="${PR_CUSTOM_RED}*${PR_NO_COLOUR}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

ZSH_THEME_GIT_PROMPT_ADDED=""
ZSH_THEME_GIT_PROMPT_MODIFIED=""
ZSH_THEME_GIT_PROMPT_DELETED=""
ZSH_THEME_GIT_PROMPT_RENAMED=""
ZSH_THEME_GIT_PROMPT_UNMERGED=""
ZSH_THEME_GIT_PROMPT_UNTRACKED=""

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
${PR_CUSTOM_PURPLE}${PR_ULCORNER}${PR_HBAR}${PR_CUSTOM_PURPLE}(\
${PR_CUSTOM_RED}%${PR_PWDLEN}<...<%~%<<\
${PR_CUSTOM_PURPLE})$(virtualenv_prompt_info)$(ruby_prompt_info)${PR_CUSTOM_PURPLE}${PR_HBAR}${PR_HBAR}${(e)PR_FILLBAR}${PR_HBAR}${PR_CUSTOM_PURPLE}\
${PR_CUSTOM_PURPLE}${PR_HBAR}${PR_URCORNER}\

${PR_CUSTOM_PURPLE}${PR_LLCORNER}${PR_CUSTOM_PURPLE}${PR_HBAR}(\
${PR_CUSTOM_RED}%D{%H:%M:%S}\
${PR_CUSTOM_PURPLE}%{$reset_color%}$(git_prompt_info)$(git_prompt_status)${PR_CUSTOM_PURPLE})${PR_HBAR}\
${PR_CUSTOM_PURPLE}${PR_HBAR}\
>${PR_NO_COLOUR} '

# display exitcode on the right when > 0
return_code="%(?..%{$fg[red]%}%? ↵ %{$reset_color%})"
RPROMPT=' $return_code${PR_CUSTOM_PURPLE}\
(${PR_CUSTOM_RED}%D{%a,%b%d}${PR_CUSTOM_PURPLE} ${PR_HBAR}${PR_CUSTOM_RED} ${CACHED_TEMP}°C${PR_CUSTOM_PURPLE})${PR_HBAR}${PR_CUSTOM_PURPLE}${PR_LRCORNER}${PR_NO_COLOUR}'

PS2='${PR_CYAN}${PR_HBAR}\
${PR_BLUE}${PR_HBAR}(\
${PR_LIGHT_GREEN}%_${PR_BLUE})${PR_HBAR}\
${PR_CYAN}${PR_HBAR}${PR_NO_COLOUR} '
