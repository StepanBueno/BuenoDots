#!/bin/bash

# Проверяем, запущен ли процесс с точным именем "timer"
if pgrep -x "timer" > /dev/null; then
    # Фокусируем окно по классу (если класс окна совпадает с именем)
    hyprctl dispatch focuswindow "class:timer"
else
    # Запускаем таймер в фоне
    /home/stepan/.config/waybar/timer/target/release/timer &
    # Даём окну время на создание (можно увеличить, если медленно)
    sleep 0.35
    # Теперь применяем команды к свежесозданному окну
    hyprctl dispatch focuswindow "class:timer"
    hyprctl dispatch togglefloating
    hyprctl dispatch resizeactive exact 450 500
    hyprctl dispatch moveactive exact 810 25
fi