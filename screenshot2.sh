#!/bin/bash
# requires maim and xclip
# note: xclip doesn't work well inside scripts, install a clipboard manager like xfce4-clipman and set it to run automatically on session startup

filename=~/Pictures/screenshots/$(date +%b%d%y::%H%M%S)
case $1 in
    crop)   filename=$filename-crop.png
            maim -Bs "$filename"
            xclip -selection clipboard -t image/png -i < "$filename"
            echo took a cropped screenshot;;
    window) filename=$filename-window.png
            maim -Bi $(xdotool getactivewindow) "$filename"
            xclip -selection clipboard -t image/png -i < "$filename"
            echo took a window screenshot;;
    *)      filename=$filename-full.png
            maim -B "$filename"
            xclip -selection clipboard -t image/png -i < "$filename"
            echo took a fullscreen screenshot;;
esac

