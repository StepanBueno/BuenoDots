#!/bin/bash

PLAYER_ID="934740280"

# Получаем статистику игрока
player_stats=$(curl -s "https://api.opendota.com/api/players/${PLAYER_ID}/heroes")

# Получаем информацию о всех героях (для маппинга ID -> имя)
heroes_data=$(curl -s "https://api.opendota.com/api/heroes")

echo "Статистика героев с именами:"
echo "============================"

# Создаем временный файл для маппинга героев
hero_map=$(mktemp)
echo "$heroes_data" | jq -r '.[] | "\(.id):\(.localized_name)"' > "$hero_map"

# Обрабатываем статистику
echo "$player_stats" | jq -r '.[] | select(.games > 0)' | while read -r hero; do
    hero_id=$(echo "$hero" | jq -r '.hero_id')
    games=$(echo "$hero" | jq -r '.games')
    win=$(echo "$hero" | jq -r '.win')
    
    # Получаем имя героя из маппинга
    hero_name=$(grep "^${hero_id}:" "$hero_map" | cut -d: -f2)
    
    if [ -n "$hero_name" ]; then
        winrate=$(( win * 100 / games ))
        printf "%-20s | Игр: %3d | WR: %3d%%\n" "$hero_name" "$games" "$winrate"
    fi
done

# Удаляем временный файл
rm "$hero_map"