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

sudo pacman -Syu --needed --noconfirm \
  wofi kitty freetype2 zsh git hyprlock hyprpaper waybar \
  ttf-font-awesome otf-font-awesome ttf-jetbrains-mono ttf-dejavu ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono \
  obsidian pavucontrol feh ranger thunar meson nwg-look papirus-icon-theme \
  fastfetch file inetutils neovim code bluez bluez-utils blueman \
  telegram-desktop vlc xfdesktop waypaper wine winetricks \
  steam alacritty base-devel awww polkit-gnome \
  sassc gnome-themes-extra qt6-5compat 

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

sudo sed -i 's/import QtGraphicalEffects 1.15/import Qt5Compat.GraphicalEffects 1.15/' \
    /usr/share/sddm/themes/Cartethiya/Main.qml


[ -f /etc/default/grub.bak ] || sudo cp /etc/default/grub /etc/default/grub.bak

grep -q '^GRUB_DEFAULT=' /etc/default/grub \
    && sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=0/' /etc/default/grub \
    || echo 'GRUB_DEFAULT=0' | sudo tee -a /etc/default/grub > /dev/null

sudo sed -i 's/^GRUB_SAVEDEFAULT=true/#GRUB_SAVEDEFAULT=true/' /etc/default/grub

git clone --depth=1 https://github.com/uiriansan/LainGrubTheme.git ~/LainGrubTheme 
cd ~/LainGrubTheme
sudo ./install.sh
sudo grub-mkconfig -o /boot/grub/grub.cfg


