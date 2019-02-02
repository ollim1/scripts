#!/bin/bash
if [ "$#" -eq 0 ]; then
	echo "-n -> nice -n 20"
	echo "-s disable scaling"
	echo "-a burn ass subs into stream, escaped filenames not working (ass only)"
	echo "-t burn other subs into stream, escaped filenames not working (no vobsub)"
	echo "-w width, -h height"
	echo "-o filename"
	echo "-p pixel format"
	echo "-b beginning (secs)"
	echo "-l length (secs)"
	exit 1
fi

for last in "$@"; do true; done
if echo "$last" | grep -v ^- > /dev/null; then
	source="$last"
else
	echo "insert filename as last argument"
	exit 1
fi

dest=~/Desktop/$(echo "$source" | sed 's/.*\///').mkv
pixfmt=yuv420p
scale="scale=1280:720"


while getopts a:b:l:nst:w:h:o:p: OPT; do
	case "$OPT" in
		a) subs="ass=$OPTARG";;
		b) startpos="$OPTARG";;
		l) endpos="$OPTARG";;
		n) nice="nice -n 20";;
		s) scale=;;
		t) subs="subtitles=$OPTARG";;
		w) w="$OPTARG";;
		h) h="$OPTARG";;
		o) dest="$OPTARG";;
		p) pixfmt="$OPTARG";;
	esac
done

opts="-vcodec libx264 -pix_fmt $pixfmt -crf 24 -profile:v high422"

if [ "$h" -eq "$h" ] && [ "$w" -eq "$w" ]; then
	scale="scale=$w:$h"
fi

if [ "$startpos" -eq "$startpos" ]; then
	ss="-ss $startpos"
fi

if [ "$endpos" -eq "$endpos" ]; then
	t="-t $endpos"
fi

if [ "$subs" ] || [ "$scale" ]; then
	filter="-filter_complex "
	if [ "$subs" ]; then
		filter="$filter$subs,"
	fi
	if [ "$scale" ]; then
		filter="$filter$scale"
	fi
	filter="${filter##,}"
fi

echo -e "\e[1m$nice ffmpeg $ss $t -i \"$source\" $filter $opts -acodec copy \"$dest\"\e[0m"
$nice ffmpeg $ss $t -i "$source" $filter $opts -acodec copy "$dest"
