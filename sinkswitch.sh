#!/bin/bash
#Move the output stream of the current window to a different Pulseaudio output sink
#Uses Zenity for UI

padata=$(pacmd list-sink-inputs)
insink=$(echo "$padata" | awk -v pid=$(xprop -id $(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5) _NET_WM_PID | awk '{print $3}') '$1 == "index:" {idx = $2}; $1 == "application.process.id" && $3 == "\"" pid "\"" {print idx; exit}')
outsinks=$(pactl list short sinks)
windowclass=$(xprop -id $(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5) WM_CLASS | awk '{print $NF}' | sed 's/^"//;s/"$//')

selection=$(zenity --list --title "Pick a sink" --text "Application: $windowclass" --column Index --column Sink --column State $(echo "$outsinks" | awk '{print $1 " " $2 " " $7}') | cut -d '|' -f1)


if ([[ "$insink" =~ ^-?[0-9]+$ ]] && [[ "$selection" =~ ^-?[0-9]+$ ]]); then
	echo "pactl move-sink-input $insink $selection"
	pactl move-sink-input $insink $selection
else
	echo "No input sink"
fi
