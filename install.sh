#!/bin/bash

set -euo pipefail

rm -rf ~/yay ~/Graphite-gtk-theme ~/Cartethiya ~/LainGrubTheme

SCRIPT_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")" &>/dev/null && pwd)"

sudo cp /etc/pacman.conf /etc/pacman.conf.bak
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    sudo sed -i '/^#\s*\[multilib\]/,/^#\s*Include/ s/^#\s*//' /etc/pacman.conf
    echo "✅ multilib включён в /etc/pacman.conf"
else
    echo "ℹ️ multilib уже включён"
fi

# 1. Установка официальных пакетов (убран дубль команды pacman и повторы пакетов)
sudo pacman -Syu --needed --noconfirm \
  wofi kitty freetype2 zsh git hyprlock hyprpaper waybar \
  ttf-font-awesome otf-font-awesome ttf-jetbrains-mono ttf-dejavu ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono \
  obsidian pavucontrol feh ranger thunar meson nwg-look papirus-icon-theme \
  fastfetch file inetutils neovim code bluez bluez-utils blueman \
  telegram-desktop vlc xfdesktop waypaper wine winetricks \
  steam alacritty base-devel awww polkit-gnome \
  sassc gnome-themes-extra qt5-graphicaleffects qt5-svg qt5-quickcontrols2 # необходимые зависимости для сборки темы Graphite

# 2. Установка yay (клонируем в конкретную папку ~/yay, а не в корень ~)
if ! command -v yay &>/dev/null; then
    git clone https://aur.archlinux.org/yay.git ~/yay
    (cd ~/yay && makepkg -si --noconfirm)
fi
cd "$SCRIPT_DIR"
echo "✅success✅"

yay -S --needed --noconfirm hyprshot wlogout cloudflare-warp-bin

rm -rf ~/.config/hypr ~/.config/wofi ~/.config/kitty ~/.config/waybar
cp -r wofi kitty waybar hypr ~/.config
echo "✅cp success✅"

git clone https://github.com/vinceliuice/Graphite-gtk-theme.git ~/Graphite-gtk-theme
cd ~/Graphite-gtk-theme
./install.sh
cd "$SCRIPT_DIR"

sudo systemctl enable --now warp-svc

git clone https://github.com/ddh4r4m/Cartethiya.git ~/Cartethiya
cd ~/Cartethiya
sudo ./install.sh

sudo tee -a /etc/sddm.conf > /dev/null <<'EOF'
[Theme]
Current=Cartethiya
EOF

[ -f /etc/default/grub.bak ] || sudo cp /etc/default/grub /etc/default/grub.bak

if grep -q '^GRUB_DEFAULT=saved' /etc/default/grub; then
    sudo sed -i 's/^GRUB_DEFAULT=saved/GRUB_DEFAULT=0/' /etc/default/grub
    echo "✅ GRUB_DEFAULT=saved → 0"
fi
if grep -q '^GRUB_SAVEDEFAULT=true' /etc/default/grub; then
    sudo sed -i 's/^GRUB_SAVEDEFAULT=true/#GRUB_SAVEDEFAULT=true/' /etc/default/grub
    echo "✅ GRUB_SAVEDEFAULT=true закомментирован"
fi

git clone --depth=1 https://github.com/uiriansan/LainGrubTheme.git ~/LainGrubTheme 
cd ~/LainGrubTheme
sudo ./install.sh
sudo grub-mkconfig -o /boot/grub/grub.cfg


