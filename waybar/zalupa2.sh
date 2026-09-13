#!/bin/bash

while true; do
    temp2=$(sensors 2>/dev/null | grep "Tctl" | awk '{print $2}' | tr -d '+')

    if [ -n "$temp2" ]; then
        echo "󰍛 $temp2"
    else
        echo "N/A"
    fi
    sleep 2
done