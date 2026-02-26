# ZSH Theme - Preview: https://gyazo.com/8becc8a7ed5ab54a0262a470555c3eed.png
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"



# use extended color palette if available.
if [[ "${terminfo[colors]}" -ge 256 ]]; then
    turquoise="%F{73}"
    orange="%F{179}"
    purple="%F{140}"
    red="%F{167}"
    limegreen="%F{107}"
else
    turquoise="%F{cyan}"
    orange="%F{yellow}"
    purple="%F{magenta}"
    red="%F{hotpink}"
    limegreen="%F{green}"
fi


if [[ $UID -eq 0 ]]; then
    local user_host='%{$terminfo[bold]$fg[red]%}%n @ %m%{$reset_color%}'
    local user_symbol='#'
else
    local user_host='%B%{$fg[green]%}%n %{$reset_color%}@ %b%{$orange%}%m %{$reset_color%}in'
    local user_symbol='$'
fi

local current_dir='%{$terminfo[bold]$fg[blue]%}%~%{$reset_color%}'
local git_branch='$(git_prompt_info)%{$reset_color%}'


PROMPT="${user_host} ${current_dir} ${git_branch}
%B${user_symbol}%b "

RPS1="%B${return_code}%b"


ZSH_THEME_GIT_PROMPT_PREFIX="%{$purple%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="›%{$reset_color%}"
