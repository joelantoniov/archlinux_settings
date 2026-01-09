
#!/bin/bash

# --- 1. SYSTEM INITIALIZATION ---
echo "Starting Principal OS Reconstruction..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm git base-devel

# --- 2. MANUAL ESSENTIALS (SAFETY NET) ---
# These are the tools that power your custom scripts and UI
echo "Installing core workflow tools..."
sudo pacman -S --needed --noconfirm \
    feh picom xclip translate-shell \
    ripgrep fd mpd mpc zathura zathura-pdf-mupdf \
    flameshot kitty nodejs npm go unzip \
    texlive-most texlive-langspanish

# --- 3. THE AUR HELPER ---
if ! command -v yay &> /dev/null; then
    echo "Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd - && rm -rf /tmp/yay
fi

# --- 4. MASS INSTALLATION FROM YOUR LISTS ---
echo "Restoring official packages from your backup..."
if [ -f "system_files/lists/pkglist.txt" ]; then
    sudo pacman -S --needed --noconfirm - < system_files/lists/pkglist.txt
fi

echo "Restoring AUR packages..."
if [ -f "system_files/lists/aurlist.txt" ]; then
    yay -S --needed --noconfirm - < system_files/lists/aurlist.txt
fi

# --- 5. HIERARCHICAL FOLDER CREATION ---
# We create every path explicitly to prevent 'No such file or directory' errors
echo "Creating directory structures..."
mkdir -p ~/.config/awesome
mkdir -p ~/.config/nvim/templates
mkdir -p ~/.config/rofi
mkdir -p ~/.config/mpd/playlists
mkdir -p ~/.config/zathura
mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/kitty/welcome_prayers/images
mkdir -p ~/.config/kitty/welcome_prayers/texts
mkdir -p ~/.automation/scripts
mkdir -p ~/.local/share/fonts
mkdir -p ~/.local/share/zoxide

# --- 6. DATA INJECTION ---
echo "Injecting configurations..."

# Configs
[ -d "config/awesome" ] && cp -r config/awesome/* ~/.config/awesome/
[ -d "config/nvim" ] && cp -r config/nvim/* ~/.config/nvim/
[ -d "config/rofi" ] && cp -r config/rofi/* ~/.config/rofi/
[ -d "config/mpd" ] && cp -r config/mpd/* ~/.config/mpd/
[ -d "config/zathura" ] && cp -r config/zathura/* ~/.config/zathura/
[ -d "config/kitty" ] && cp -r config/kitty/* ~/.config/kitty/
[ -d "config/gtk-3.0" ] && cp -r config/gtk-3.0/* ~/.config/gtk-3.0/

# Scripts
[ -d "automation" ] && cp -r automation/* ~/.automation/

# System Files
cp system_files/bashrc_arch ~/.bashrc
cp system_files/Xresources_arch ~/.Xresources 2>/dev/null
[ -f "system_files/zoxide/db" ] && cp system_files/zoxide/db ~/.local/share/zoxide/db

# Fonts
if [ -d "local_assets/fonts" ]; then
    cp -r local_assets/fonts/* ~/.local/share/fonts/
    fc-cache -fv
fi

# --- 7. FINAL PERMISSIONS & SERVICES ---
echo "Setting permissions..."
chmod +x ~/.automation/scripts/*.sh
[ -f "~/.config/kitty/welcome_prayers/welcome.sh" ] && chmod +x ~/.config/kitty/welcome_prayers/welcome.sh

echo "Enabling services..."
systemctl --user enable --now mpd

echo "RECONSTRUCTION COMPLETE."
