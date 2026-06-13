#!/usr/bin/env bash

# ==============================================================================
# ORQUESTADOR - CELESTIAL TOKYO ARCHITECTURE
# ==============================================================================
# Este script crea la estructura completa en ~/dotfiles y genera el install.sh
# ==============================================================================

DOT_DIR="$HOME/dotfiles"

echo -e "\e[34m[*] Iniciando el Orquestador Celestial...\e[0m"
echo "[*] Creando jerarquía de directorios en $DOT_DIR..."

mkdir -p "$DOT_DIR"/{bspwm,sxhkd,polybar,rofi,picom,ghostty,btop,cava,gtk-3.0,sddm,betterlockscreen,dunst,starship,fastfetch}

# ---------------------------------------------------------
# 1. BSPWM
# ---------------------------------------------------------
cat <<'EOF' >"$DOT_DIR/bspwm/bspwmrc"
#!/usr/bin/env bash

pgrep -x sxhkd > /dev/null || sxhkd &
~/.config/polybar/launch.sh &
pgrep -x picom > /dev/null || picom --config ~/.config/picom/picom.conf &
pgrep -x dunst > /dev/null || dunst &
lxpolkit &

# Regla del Scratchpad
bspc rule -a Scratchpad state=floating rectangle=800x600+560+240 center=true

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    bspc monitor "$m" -d 1 2 3 4 5
  done
else
  bspc monitor -d 1 2 3 4 5
fi

bspc config border_width         2
bspc config window_gap          12
bspc config split_ratio          0.50
bspc config borderless_monocle   true
bspc config gapless_monocle      true
bspc config focus_follows_pointer true

bspc config normal_border_color  "#1a1b26"
bspc config active_border_color  "#414868"
bspc config focused_border_color "#7aa2f7"
EOF
chmod +x "$DOT_DIR/bspwm/bspwmrc"

# ---------------------------------------------------------
# 2. SXHKD (Tu Configuración + Scratchpad)
# ---------------------------------------------------------
cat <<'EOF' >"$DOT_DIR/sxhkd/sxhkdrc"
# wm independent hotkeys
super + Return
	ghostty
super + e
        thunar
super + b
    firefox
super + n
    ghostty -e nvim
Print
    spectacle -r
super + d
	rofi -show drun -show-icons
super + Escape
	pkill -USR1 -x sxhkd

# bspwm hotkeys
super + alt + {q,r}
	bspc {quit,wm -r}
super + {_,shift + }w
	bspc node -{c,k}
super + m
	bspc desktop -l next
super + y
	bspc node newest.marked.local -n newest.!automatic.local
super + g
	bspc node -s biggest.window

# state/flags
super + {t,shift + t,s,f}
	bspc node -t {tiled,pseudo_tiled,floating,fullscreen}
super + ctrl + {m,x,y,z}
	bspc node -g {marked,locked,sticky,private}

# focus/swap
super + {_,shift + }{h,j,k,l}
	bspc node -{f,s} {west,south,north,east}
super + {p,b,comma,period}
	bspc node -f @{parent,brother,first,second}
super + {_,shift + }c
	bspc node -f {next,prev}.local.!hidden.window
super + bracket{left,right}
	bspc desktop -f {prev,next}.local
super + {grave,Tab}
	bspc {node,desktop} -f last
super + {o,i}
	bspc wm -h off; \
	bspc node {older,newer} -f; \
	bspc wm -h on
super + {_,shift + }{1-9,0}
	bspc {desktop -f,node -d} '^{1-9,10}'

# preselect
super + ctrl + {h,j,k,l}
	bspc node -p {west,south,north,east}
super + ctrl + {1-9}
	bspc node -o 0.{1-9}
super + ctrl + space
	bspc node -p cancel
super + ctrl + shift + space
	bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel

# move/resize
super + alt + {h,j,k,l}
	bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}
super + alt + shift + {h,j,k,l}
	bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}
super + {Left,Down,Up,Right}
	bspc node -v {-20 0,0 20,0 -20,20 0}

# TECLAS ESPECIALES LENOVO IDEAPAD
XF86AudioMute
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
XF86AudioLowerVolume
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
XF86AudioRaiseVolume
    wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
XF86AudioMicMute
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
XF86MonBrightnessDown
    brightnessctl set 5%-
XF86MonBrightnessUp
    brightnessctl set +5%
XF86Display
    arandr
XF86WLAN
    rfkill toggle all
XF86Settings
    lxappearance
XF86ScreenSaver
    i3lock -c 1a1b26 --clock --indicator --ring-color=7aa2f7ff --inside-color=1a1b26ff --keyhl-color=e0af68ff --time-color=a9b1d6ff --date-color=a9b1d6ff
super + x
    ~/.config/scripts/lockscreen.sh
ctrl + alt + Tab
    rofi -show window -show-icons
XF86Calculator
    ghostty -e bc
super + v
    rofi -modi "Portapapeles:greenclip print" -show Portapapeles -run-command '{cmd}' -theme ~/.config/rofi/greenclip.rasi

# --- EXTRAS ARQUITECTO RICE ---
# Scratchpad Táctico
super + shift + Return
    ghostty --class=Scratchpad -e bash
EOF

# ---------------------------------------------------------
# 3. PICOM
# ---------------------------------------------------------
cat <<'EOF' >"$DOT_DIR/picom/picom.conf"
corner-radius = 12;
rounded-corners-exclude = ["class_g = 'Polybar'", "window_type = 'tooltip'"];
backend = "glx";
blur: { method = "dual_kawase"; strength = 6; background = false; background-frame = false; background-fixed = false; }
shadow = true; shadow-radius = 15; shadow-opacity = 0.4; shadow-offset-x = -15; shadow-offset-y = -15; shadow-color = "#000000";
vsync = true; use-damage = true; glx-no-stencil = true;
fading = true; fade-in-step = 0.03; fade-out-step = 0.03; fade-delta = 4;
animations = true; animation-stiffness = 110.0; animation-dampening = 20.0; animation-clamping = true; animation-mass = 1.0;
animation-for-open-window = "zoom"; animation-for-unmap-window = "zoom"; animation-for-workspace-switch-in = "slide-down"; animation-for-workspace-switch-out = "slide-up";
EOF

# ---------------------------------------------------------
# 4. ROFI
# ---------------------------------------------------------
cat <<'EOF' >"$DOT_DIR/rofi/tokyo-celestial.rasi"
* { bg-col: #1a1b26cc; bg-col-light: #24283b; border-col: #7aa2f7; selected-col: #24283b; blue: #7aa2f7; fg-col: #c0caf5; fg-col2: #f7768e; font: "JetBrainsMono Nerd Font 12"; }
window { width: 600px; border: 2px; border-color: @border-col; border-radius: 15px; background-color: @bg-col; }
mainbox { background-color: transparent; padding: 20px; }
inputbar { children: [prompt,entry]; background-color: @bg-col-light; border-radius: 10px; padding: 10px; }
listview { background-color: transparent; padding: 10px 0px 0px 0px; columns: 1; lines: 6; }
element { padding: 10px; background-color: transparent; text-color: @fg-col; border-radius: 8px; }
element selected { background-color: @blue; text-color: #1a1b26; }
EOF

cat <<'EOF' >"$DOT_DIR/rofi/config.rasi"
configuration { modi: "drun,run,window"; show-icons: true; icon-theme: "Papirus-Dark"; terminal: "ghostty"; }
@theme "tokyo-celestial"
EOF

# ---------------------------------------------------------
# 5. POLYBAR
# ---------------------------------------------------------
cat <<'EOF' >"$DOT_DIR/polybar/config.ini"
[colors]
bg = #00000000
pill-bg = #cc1a1b26
fg = #c0caf5
celestial = #7aa2f7
accent = #bb9af7

[bar/main]
monitor = ${env:MONITOR:}
width = 98%
height = 34
offset-x = 1%
offset-y = 10
radius = 17
fixed-center = true
background = ${colors.bg}
foreground = ${colors.fg}
modules-left = bspwm
modules-center = date
modules-right = pulseaudio memory cpu wlan
font-0 = "JetBrainsMono Nerd Font:style=Bold:size=10;3"
font-1 = "JetBrainsMono Nerd Font:size=14;4"
module-margin = 1
padding-right = 2
padding-left = 2

[module/bspwm]
type = internal/bspwm
format = <label-state>
format-background = ${colors.pill-bg}
format-padding = 2
format-radius = 17
label-focused = %index%
label-focused-foreground = ${colors.celestial}
label-focused-padding = 1
label-occupied = %index%
label-occupied-foreground = ${colors.accent}
label-occupied-padding = 1
label-empty = %index%
label-empty-foreground = #414868
label-empty-padding = 1

[module/date]
type = internal/date
interval = 5
date = "%a %d %b"
time = "%H:%M"
label = %time% - %date%
format-background = ${colors.pill-bg}
format-padding = 2
format-radius = 17
format-foreground = ${colors.celestial}

[module/pulseaudio]
type = internal/pulseaudio
format-volume = <label-volume>
label-volume = 󰕾 %percentage%%
format-volume-background = ${colors.pill-bg}
format-volume-padding = 2
format-muted = 󰖁 Muted
format-muted-background = ${colors.pill-bg}
format-muted-padding = 2
EOF

cat <<'EOF' >"$DOT_DIR/polybar/launch.sh"
#!/usr/bin/env bash
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload main -c ~/.config/polybar/config.ini &
  done
else
  polybar --reload main -c ~/.config/polybar/config.ini &
fi
EOF
chmod +x "$DOT_DIR/polybar/launch.sh"

# ---------------------------------------------------------
# 6. GHOSTTY, BTOP, CAVA, GTK, FASTFETCH, DUNST, SDDM
# ---------------------------------------------------------
cat <<'EOF' >"$DOT_DIR/ghostty/config"
theme = tokyonight
background-opacity = 0.85
background-blur-radius = 20
font-family = "JetBrainsMono Nerd Font"
font-size = 12
window-padding-x = 15
window-padding-y = 15
palette = 0=#15161e
palette = 1=#f7768e
palette = 2=#9ece6a
palette = 3=#e0af68
palette = 4=#7aa2f7
palette = 5=#bb9af7
palette = 6=#7dcfff
palette = 7=#a9b1d6
EOF

cat <<'EOF' >"$DOT_DIR/btop/btop.conf"
color_theme = "tokyo-night"
theme_background = False
truecolor = True
rounded_corners = True
graph_symbol = "braille"
EOF

cat <<'EOF' >"$DOT_DIR/cava/config"
[general]
framerate = 60
[color]
gradient = 1
gradient_count = 4
gradient_color_1 = '#7aa2f7'
gradient_color_2 = '#bb9af7'
gradient_color_3 = '#f7768e'
gradient_color_4 = '#e0af68'
[smoothing]
integral = 77
EOF

cat <<'EOF' >"$DOT_DIR/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Tokyonight-Dark-B
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=JetBrainsMono Nerd Font 10
gtk-cursor-theme-name=Capitaine-Cursors
gtk-application-prefer-dark-theme=1
gtk-decoration-layout=menu:close
EOF

cat <<'EOF' >"$DOT_DIR/sddm/theme.conf"
[General]
Background="Backgrounds/tokyo-night-celestial.png"
Blur=true
BlurRadius=60
CornerRadius=24
PopupBackground="#991a1b26"
UserColor="#c0caf5"
PasswordColor="#c0caf5"
HighlightColor="#7aa2f7"
HoverColor="#8db0f8"
ErrorColor="#f7768e"
Font="JetBrainsMono Nerd Font"
FontSize=11
PositionX=center
PositionY=center
EOF

cat <<'EOF' >"$DOT_DIR/dunst/dunstrc"
[global]
width = 300
height = 100
offset = 20x20
origin = top-right
corner_radius = 15
frame_width = 2
frame_color = "#7aa2f7"
font = JetBrainsMono Nerd Font 10
padding = 15
horizontal_padding = 15
transparency = 15
background = "#1a1b26"
[urgency_normal]
foreground = "#c0caf5"
EOF

cat <<'EOF' >"$DOT_DIR/fastfetch/config.jsonc"
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": { "color": { "1": "blue", "2": "magenta" }, "padding": { "top": 2, "left": 3, "right": 4 } },
    "display": { "separator": "  󰁔  ", "color": { "keys": "blue" } },
    "modules": [ "break", { "type": "title", "color": { "user": "magenta", "at": "white", "host": "blue" } }, { "type": "custom", "format": "────────────────────────────────────────" }, { "type": "os", "key": "󰣇 OS     ", "format": "{3}" }, "kernel", "uptime", "packages", "wm", "terminal", "memory", { "type": "custom", "format": "────────────────────────────────────────" }, { "type": "colors", "symbol": "circle" }, "break" ]
}
EOF

# ---------------------------------------------------------
# 7. EL SCRIPT DE INSTALACIÓN (INSTALL.SH)
# ---------------------------------------------------------
echo "[*] Generando install.sh principal..."
cat <<'EOF' >"$DOT_DIR/install.sh"
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

DEPENDENCIES=(bspwm sxhkd polybar rofi picom feh kitty ghostty btop cava dunst starship fastfetch sddm qt5-graphicaleffects lxsession)

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
EOF
chmod +x "$DOT_DIR/install.sh"

echo -e "\e[32m[+] ¡Estructura creada con éxito en $DOT_DIR!\e[0m"
echo "[*] Para subirlo a GitHub:"
echo "    cd ~/dotfiles"
echo "    git init && git add . && git commit -m 'Initial commit'"
echo "    git branch -M main"
echo "    git remote add origin <TU_REPOSITORIO>"
echo "    git push -u origin main"
