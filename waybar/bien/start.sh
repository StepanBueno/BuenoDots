#!/bin/bash

if pgrep -x "start" > /dev/null; then 
    killall "start"
else 
    ~/.config/waybar/bien/start &
fi