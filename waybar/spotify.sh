#!/bin/bash

STATUS=$(playerctl -p spotify status 2>/dev/null)

if [ "$STATUS" = "Playing" ]; then
    playerctl -p spotify metadata --format '   {{artist}} - {{title}}'
elif [ "$STATUS" = "Paused" ]; then
    playerctl -p spotify metadata --format ' {{artist}} - {{title}}'
else
    echo "   No music"
fi