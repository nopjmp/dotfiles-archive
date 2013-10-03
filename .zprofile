[[ -r ~/.profile ]] && . ~/.profile
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx -- -nolisten tcp -dpi 125 vt1 &>/dev/null

