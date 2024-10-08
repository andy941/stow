#!/bin/bash

xrandr --auto
xrandr --output eDP-1 --primary
xrandr | grep "^DP-1 connected" && xrandr --output DP-1 --primary --above eDP-1 --mode "$1"
xrandr | grep "^DP-2 connected" && xrandr --output DP-2 --primary --above eDP-1 --mode "$1"
xrandr | grep "^DP-1-1 connected" && xrandr --output DP-1-1 --primary --above eDP-1 --mode "$1"
xrandr | grep "^DP-2-2 connected" && xrandr --output DP-2-2 --primary --above eDP-1 --mode "$1"

nitrogen --restore
${HOME}/.i3/polybar_launcher.sh
