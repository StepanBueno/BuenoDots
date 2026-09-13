#!/bin/bash
# Откат изменений, сделанных install.sh
# Использование:
#   bash uninstall.sh                     # только конфиги/темы/клоны
#   REMOVE_PACKAGES=1 bash uninstall.sh   # ещё и удалить пакеты
#   REMOVE_AUR=1      bash uninstall.sh   # + AUR-пакеты и yay

set -uo pipefail

REMOVE_PACKAGES="${REMOVE_PACKAGES:-0}"
REMOVE_AUR="${REMOVE_AUR:-0}"

confirm() {
    read -r -p "$1 [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]]
}

echo "⚠️  Это удалит:"
echo "   - ~/.config/{hypr,wofi,kitty,waybar} (с восстановлением .bak, если есть)"
echo "   - клоны ~/yay, ~/Graphite-gtk-theme, ~/Cartethiya, ~/LainGrubTheme"
echo "   - тему SDDM Cartethiya и правку /etc/sddm.conf"
echo "   - тему GRUB (Lain) и правку /etc/default/grub"
echo "   - Cloudflare WARP (сервис и пакет)"
echo "   - пользовательские темы Graphite и Papirus"
echo
echo "   Пакеты из pacman НЕ удаляются, если не задать REMOVE_PACKAGES=1."
echo "   AUR-пакеты и yay — только при REMOVE_AUR=1."
echo

confirm "Продолжить?" || { echo "Отменено."; exit 0; }

# Прогреем sudo, чтобы не спрашивал пароль в середине
sudo -v || { echo "sudo недоступен"; exit 1; }

# ── 1. Дотфайлы ────────────────────────────────────────────────
echo "→ Убираю ~/.config/{hypr,wofi,kitty,waybar}"
for d in hypr wofi kitty waybar; do
    target="$HOME/.config/$d"
    latest_bak="$(ls -dt "$HOME/.config/${d}".bak.* 2>/dev/null | head -n1 || true)"
    if [ -n "$latest_bak" ]; then
        rm -rf -- "$target"
        mv -- "$latest_bak" "$target"
        echo "   ↩ восстановлен из $(basename "$latest_bak")"
    elif [ -d "$target" ]; then
        rm -rf -- "$target"
        echo "   удалён ~/.config/$d"
    fi
done

# ── 2. Клоны репозиториев ──────────────────────────────────────
echo "→ Удаляю клоны из \$HOME"
rm -rf -- ~/yay ~/Graphite-gtk-theme ~/Cartethiya ~/LainGrubTheme

# ── 3. SDDM: сброс темы Cartethiya ─────────────────────────────
echo "→ Сбрасываю тему SDDM"
if [ -f /etc/sddm.conf.d/10-theme.conf ]; then
    sudo rm -f /etc/sddm.conf.d/10-theme.conf
    echo "   удалён /etc/sddm.conf.d/10-theme.conf"
fi
if [ -f /etc/sddm.conf ] && grep -q '^Current=Cartethiya' /etc/sddm.conf; then
    sudo sed -i 's/^Current=Cartethiya.*$/#Current=/' /etc/sddm.conf
    echo "   закомментирована строка Current=Cartethiya в /etc/sddm.conf"
fi
# Файлы самой темы
if [ -d /usr/share/sddm/themes/Cartethiya ]; then
    sudo rm -rf /usr/share/sddm/themes/Cartethiya
    echo "   удалена /usr/share/sddm/themes/Cartethiya"
fi

# ── 4. GRUB: сброс темы Lain ───────────────────────────────────
echo "→ Сбрасываю тему GRUB"
# Ищем каталоги темы в стандартных местах
for p in /boot/grub/themes/Lain /boot/grub/themes/LainGrubTheme /boot/grub/themes/lain; do
    [ -d "$p" ] && { sudo rm -rf -- "$p"; echo "   удалена $p"; }
done
if grep -q '^GRUB_THEME=' /etc/default/grub; then
    sudo sed -i 's|^GRUB_THEME=.*|#GRUB_THEME=|' /etc/default/grub
    echo "   закомментирован GRUB_THEME в /etc/default/grub"
fi
sudo grub-mkconfig -o /boot/grub/grub.cfg >/dev/null
echo "   grub.cfg перегенерирован"

# ── 5. pacman.conf — вернуть бэкап (если есть) ─────────────────
if [ -f /etc/pacman.conf.bak ]; then
    echo "→ Найден /etc/pacman.conf.bak"
    if confirm "   Восстановить /etc/pacman.conf из бэкапа?"; then
        sudo cp /etc/pacman.conf.bak /etc/pacman.conf
        echo "   восстановлен"
    fi
fi

# ── 6. Cloudflare WARP ─────────────────────────────────────────
echo "→ Отключаю warp-svc"
sudo systemctl disable --now warp-svc 2>/dev/null || true

# ── 7. Пользовательские темы и иконки ──────────────────────────
echo "→ Убираю пользовательские темы"
rm -rf -- ~/.themes/Graphite* \
          ~/.local/share/themes/Graphite* \
          ~/.icons/Papirus* \
          ~/.local/share/icons/Papirus*

# ── 8. AUR-пакеты и yay (опционально) ──────────────────────────
if [ "$REMOVE_AUR" = "1" ] && command -v yay &>/dev/null; then
    echo "→ Удаляю AUR-пакеты"
    yay -Rns --noconfirm hyprshot wlogout cloudflare-warp-bin 2>/dev/null || \
        echo "   ⚠️  часть AUR-пакетов не удалилась"
    if confirm "   Удалить сам yay?"; then
        sudo pacman -Rns --noconfirm yay 2>/dev/null || \
            echo "   ⚠️  yay не удалился (возможно, установлен вручную)"
    fi
fi

# ── 9. Официальные пакеты (опционально) ────────────────────────
if [ "$REMOVE_PACKAGES" = "1" ]; then
    echo "→ Удаляю установленные пакеты (может занять время)"
    # Только те, что ставил install.sh. Системные (git, zsh, freetype2,
    # base-devel, ttf-dejavu) намеренно не трогаем.
    sudo pacman -Rns --noconfirm \
        wofi kitty hyprlock hyprpaper waybar \
        ttf-font-awesome otf-font-awesome ttf-jetbrains-mono \
        ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono \
        obsidian pavucontrol feh ranger thunar meson nwg-look \
        papirus-icon-theme fastfetch inetutils neovim code \
        bluez bluez-utils blueman telegram-desktop vlc \
        xfdesktop waypaper wine winetricks alacritty \
        awww polkit-gnome spotify sassc gnome-themes-extra \
        gtk-engine-murrine 2>/dev/null || \
        echo "   ⚠️  часть пакетов не удалилась — скорее всего, их тянут другие"
    echo "   ℹ️  steam, powerline/nerd-fonts, а также base-devel/git/zsh"
    echo "      оставлены — удали вручную, если точно не нужны."
fi

echo
echo "✅ Готово. Перезагрузись, чтобы GRUB и SDDM применили изменения."