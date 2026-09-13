#!/bin/bash

if pgrep -x "naga.py" > /dev/null; then
    # Если запущен - фокусируем окно
    hyprctl dispatch focuswindow "class:kitty"
else
    hyprctl dispatch togglefloating 
    hyprctl dispatch resizeactive exact 450 620
    hyprctl dispatch moveactive exact 100 100
    clear
    ~/.config/waybar/naga/dist/./naga && viu /data929G/br\ br\ windows\ 7/marci\ gif/marci-dota.gif
fi

