#!/bin/bash
#adjusts volume of currently selected application window
#arguments are "up" and "down"
#bind to Super+VolUp/Down or whatever
#TODO: cycling through outputs with pacmd move-sink-input $sink $output

if [ $# -ne 1 ]; then
	exit 1
fi

padata=$(pacmd list-sink-inputs)
sink=$(echo "$padata" | awk -v pid=$(xprop -id $(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5) _NET_WM_PID | awk '{print $3}') '$1 == "index:" {idx = $2}; $1 == "application.process.id" && $3 == "\"" pid "\"" {print idx; exit}')

case "$1" in
	up) adjustment="+10%";;
	down) adjustment="-10%";;
	*) exit 2;;
esac

if [[ "$sink" =~ ^-?[0-9]+$ ]]; then
	volume=$(echo "$padata" | awk -v sink=$sink '$1 == "index:" {idx = $2}; $1 == "volume:" && idx == sink {print $3; exit}' | sed 's/[^0-9]//g')
	if ( [ "$1" = up ] && [ $(($volume+10)) -gt 100 ] ); then
		adjustment="100%"
	fi
	echo "pactl set-sink-input-volume $sink $adjustment"
	pactl set-sink-input-volume $sink $adjustment
fi
