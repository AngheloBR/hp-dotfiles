#!/usr/bin/env bash

# ==============================================================================
# INSTALLER - CELESTIAL TOKYO ARCHITECTURE
# Ejecutar este script clonado en la VM o máquina real
# ==============================================================================

echo -e "\e[34m"
cat << "BANNER"
   ___    _          _   _       _   _____     _                 
  / __|__| |___  ___| |_(_)__ _ | | |_   _|___| |___  _ ___      
 | (__/ -_) / -_)(_-<  _| / _` || |   | | / _ \ / / || / _ \     
  \___\___|_\___|/__/\__|_\__,_||_|   |_| \___/_\_\\_, \___/     
         Arquitectura Material You + Tokyo Night
BANNER
echo -e "\e[0m"

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

echo "[*] Detectando helper de AUR..."
AUR="pacman -S --noconfirm"
if command -v paru &> /dev/null; then AUR="paru -S --noconfirm"; elif command -v yay &> /dev/null; then AUR="yay -S --noconfirm"; fi

DEPENDENCIES=(xorg-server xorg-xinit bspwm sxhkd polybar rofi picom feh kitty ghostty btop cava dunst starship fastfetch sddm qt5-graphicaleffects lxsession)

echo "[*] Instalando dependencias..."
for dep in "${DEPENDENCIES[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        echo "Instalando $dep..."
        $AUR "$dep"
    fi
done

echo "[*] Creando enlaces simbólicos (Symlinks)..."
mkdir -p "$CONFIG_DIR"

link_config() {
    local app=$1
    if [ -d "$CONFIG_DIR/$app" ]; then
        mv "$CONFIG_DIR/$app" "$CONFIG_DIR/${app}_backup_$(date +%s)"
    fi
    ln -sfn "$DOTFILES_DIR/$app" "$CONFIG_DIR/$app"
    echo -e "\e[32m[✓] $app linkeado.\e[0m"
}

for app in bspwm sxhkd polybar rofi picom ghostty btop cava gtk-3.0 dunst fastfetch; do
    link_config "$app"
done

echo "[*] Configurando SDDM (Si tienes permisos de sudo)..."
if [ -d /usr/share/sddm/themes/ ]; then
    sudo git clone https://github.com/aczw/sddm-theme-corners.git /usr/share/sddm/themes/corners || true
    sudo cp "$DOTFILES_DIR/sddm/theme.conf" /usr/share/sddm/themes/corners/theme.conf || true
    echo -e "[Theme]\nCurrent=corners" | sudo tee /etc/sddm.conf.d/theme.conf > /dev/null
fi

echo -e "\n\e[32m[+] ¡Instalación base completada! Reinicia bspwm (Super + Alt + r) para aplicar la magia.\e[0m"
