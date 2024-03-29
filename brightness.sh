#!/bin/bash
# adjusts brightnesses of all displays using ddccontrol
# to use without root privileges, add for every /dev/i2c-* the line KERNEL=="i2c-[0-9]", SUBSYSTEM=="i2c-dev", GROUP=="ddc", MODE="0660" to /etc/udev/rules.d/ to /etc/udev/rules.d/98-ddc.rules

displays=("dev:/dev/i2c-1" "dev:/dev/i2c-3")

if [[ ${1} =~ ^[0-9]+$ ]]; then
    for i in ${displays[@]}; do
        ddccontrol -r 0x10 -w ${1} ${i}
    done
else
    case ${1} in
        up)
            inc="+10";;
        down)
            inc="-10";;
        *)
            exit;;
    esac
    for i in ${displays[@]}; do
        cur=$(ddccontrol -r 0x10 ${i} | grep "Control 0x10" 2> /dev/null | awk '{print $3}' | sed -e 's/[^0-9]\+/ /g' | awk '{print $1}')
        new=$(($cur$inc))
        ddccontrol -r 0x10 -w ${new} ${i}
    done
fi
