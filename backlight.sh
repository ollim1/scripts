#!/bin/bash
# better backlight control for Thinkpad T480

backlightFile=/sys/class/backlight/intel_backlight/brightness
currentValue="$(cat $backlightFile)"
if [ ! "$currentValue" -eq "$currentValue" ]; then
    echo invalid value in backlight file
    exit 0;
fi
# calculated using the formula round(5*1.886756^n), change if needed
# table=(5 9 18 34 63 120 226 426 803 1515)
table=(5 9 18 34 63 120 226 310 426 585 803 1103 1515)
# alternative formula round(5*2^(n*(log(303)/log(2))/14)), 0 <= n <= 14
# table=(5 8 11 17 26 38 58 87 131 197 296 445 670 1007 1515)
usage="USAGE:
-u       increase brightness
-d       lower brightness
-v VALUE set brightness to VALUE
-h       print this message
for -u and -d the current value is rounded to the closest value on the table
(${table[@]}) before a movement by index
TODO:    just cut off the lookup after the closest value has been crossed
TODO:    an option to modify brightness by exponent instead of a table lookup;
         leaving in the original functionality because misaligned adjustments
         are annoying"

lo=10000;
loIdx=-1;
i=0;
while [ "$i" -lt ${#table[@]} ]; do
    diff=$(($currentValue - ${table[$i]}))
    diff=$([ $diff -lt 0 ] && echo $((-$diff)) || echo $diff)
    if [ $diff -le $lo ]; then
        lo=$diff;
        loIdx=$i;
    fi
    let i++;
done

while getopts "dhuv:" ARG; do
    case "$ARG" in
        "u") 
            if [ ! "$loIdx" -lt 0 ]; then
                i=$(($loIdx + 1))
                if [ "$i" -le $((${#table[@]} - 1)) ]; then
                    echo echo "${table[$i]}" \> "$backlightFile"
                    echo "${table[$i]}" > "$backlightFile"
                fi
            else
                echo "error: loIdx"
                exit 1
            fi
            ;;
        "d") 
            if [ ! "$loIdx" -lt 0 ]; then
                i=$(($loIdx - 1))
                if [ "$i" -ge 0 ]; then
                    echo echo "${table[$i]}" \> "$backlightFile"
                    echo "${table[$i]}" > "$backlightFile"
                fi
            else
                echo "error: loIdx"
                exit 1
            fi
            ;;
        "v")
            if ([ "$OPTARG" -le ${table[$((${#table[@]} - 1))]} ] &&
                [ "$OPTARG" -ge ${table[0]} ]); then
                echo echo "$OPTARG" \> "$backlightFile"
                echo "$OPTARG" > "$backlightFile"
            else
                echo "Invalid value \"$OPTARG\"; must be an integer between ${table[0]} and ${table[$((${#table[@]} - 1))]}"
                exit 1
            fi
            ;;
        "h")
            echo -e "$usage";;
        *)
            echo -e "Invalid option: \"$ARG\"\n$usage"
            exit 1
            ;;
    esac
done
