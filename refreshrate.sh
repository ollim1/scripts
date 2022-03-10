#!/bin/bash
# changes refresh rates of all displays to $1 or makes the refresh rates of
# secondary displays match the primary display as specified in xrandr

rrates=$(xrandr | awk \
    '$2 == "connected" {port = $1; if ($3 == "primary") {primary = port}};\
    {\
        if ($1 == "1920x1080") {\
            for(i = 1; i < NF; i++) {\
                if ($i~/\*/) {\
                    if (port == primary) {\
                        print port, gensub(/\*.*/, "", "g", $i), "primary"
                    } else {\
                        print port, gensub(/\*.*/, "", "g", $i)\
                    }\
                }\
            }\
        }\
    }'
)
maindisp=$((grep primary | awk '{print $1}') <<< ${rrates})

if [ ${1} ]; then
    for disp in $(awk '{print $1}' <<< ${rrates}); do
        xrandr --output ${disp} --mode 1920x1080 --rate ${1}
    done
else
    # switch secondary display(s) to main display refresh rate
    mainrr=$((grep ${maindisp} | awk '{print $2}') <<< ${rrates})
    echo "the rate of display ${maindisp} is ${mainrr}"
    echo ${rrates} |
        while read line; do
            disp=$(awk '{print $1}' <<< ${line})
            rr=$(awk '{print $2}' <<< ${line})
            if [ ${disp} != ${maindisp} ] && [ ${rr} != ${mainrr} ]; then
                echo "changing rate of display ${disp} from ${rr} to ${mainrr}"
                xrandr --output ${disp} --mode 1920x1080 --rate ${mainrr}
            fi
        done
fi
