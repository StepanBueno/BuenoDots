#!/bin/bash

while true; do
    temp=$(nvidia-smi -q -d temperature 2>/dev/null | grep "GPU Current Temp" | awk '{print $5}')

    if [ -n "$temp" ]; then
        echo "🌡️ $temp°C"
    else
        echo "N/A"
    fi

    sleep 2
done