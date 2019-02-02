#!/bin/bash
# for Thinkpad T480 and other laptops with two batteries

energy0=$(cat /sys/class/power_supply/BAT0/energy_now)
energy1=$(cat /sys/class/power_supply/BAT1/energy_now)

energy_full0=$(cat /sys/class/power_supply/BAT0/energy_full)
energy_full1=$(cat /sys/class/power_supply/BAT1/energy_full)

capacity0=$(cat /sys/class/power_supply/BAT0/capacity)
capacity1=$(cat /sys/class/power_supply/BAT1/capacity)

state0=$(cat /sys/class/power_supply/BAT0/status)
state1=$(cat /sys/class/power_supply/BAT1/status)

power0=$([ ! "$state0" == "Charging" ] && cat /sys/class/power_supply/BAT0/power_now || echo 0)
power1=$([ ! "$state1" == "Charging" ] && cat /sys/class/power_supply/BAT1/power_now || echo 0)
energy_total=$(echo "($energy0+$energy1)/1000000" | calc -dp)
energy_full_total=$(echo "($energy_full0+$energy_full1)/1000000" | calc -dp)
capacity_total=$(echo "round(($capacity0+$capacity1)/2)" | calc -dp)
power=$(echo "($power0+$power1)/1000000" | calc -dp)

time_hours=$([ "$power" ] && echo "($energy_total / $power)" | calc -dp || echo 0)
time_minutes=$([ "$time_hours" ] && echo "round(($time_hours % 1) * 60)" | calc -dp || echo 0)

if [ "$1" == "-1" ]; then
    time_hours=$(printf %2d $(echo "floor($time_hours)" | calc -dp))
    time_minutes=$(printf %2d $time_minutes)
    capacity_total=$(printf %3d $capacity_total)
    capacity0=$(printf %3d $capacity0)
    capacity1=$(printf %3d $capacity1)
    power=$(printf %5.2f $power)
    echo -e "${time_hours}h ${time_minutes}m $capacity_total% ($capacity0% + $capacity1%) ${power}W"
else
    time_hours=$(printf %3d $(echo "floor($time_hours)" | calc -dp))
    time_minutes=$(printf %2d $time_minutes)
    capacity_total=$(printf %3d $capacity_total)
    capacity0=$(printf %3d $capacity0)
    capacity1=$(printf %3d $capacity1)
    energy_total=$(printf %5.2f $energy_total)
    energy_full_total=$(printf %5.2f $energy_full_total) 
    echo $time_hours hours $time_minutes minutes
    echo -e "$capacity_total% ($capacity0% + $capacity1%)"
    echo -e "${energy_total}Wh / ${energy_full_total}Wh"
    echo "$power W"
fi
