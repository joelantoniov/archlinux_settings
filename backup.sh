#!/bin/bash

# --- PATH DEFINITIONS ---
# Source: Your mounted Arch partition
ARCH_HOME="/media/joelantonio/1d97c7a2-a8f2-4328-b103-6502c3193ccd/home/joelantonio"
# Destination: Your Data partition
BACKUP_DEST="/media/joelantonio/Data/archlinux_settings"

echo "Starting system-critical backup..."

# 1. Create directory structure
mkdir -p "$BACKUP_DEST/config"
mkdir -p "$BACKUP_DEST/automation"
mkdir -p "$BACKUP_DEST/system_files/lists"
mkdir -p "$BACKUP_DEST/local_assets/fonts"
mkdir -p "$BACKUP_DEST/local_assets/bin"

# 2. Copy Package Lists (The Blueprints)
echo "Copying package lists..."
cp -a "$ARCH_HOME/pkglist.txt" "$BACKUP_DEST/system_files/lists/"
cp -a "$ARCH_HOME/aurlist.txt" "$BACKUP_DEST/system_files/lists/"

# 3. Copy Application Configurations (.config)
# Added gtk-3.0 to preserve your theme/dark mode settings
echo "Copying .config directories..."
for folder in awesome nvim rofi mpd zathura flameshot gtk-3.0 kitty alacritty; do
    if [ -d "$ARCH_HOME/.config/$folder" ]; then
        cp -a "$ARCH_HOME/.config/$folder" "$BACKUP_DEST/config/"
        echo "Successfully copied: $folder"
    fi
done

# 4. Copy Custom Automation and Scripts
echo "Copying automation scripts..."
if [ -d "$ARCH_HOME/.automation" ]; then
    cp -a "$ARCH_HOME/.automation" "$BACKUP_DEST/"
fi
if [ -d "$ARCH_HOME/.local/bin" ]; then
    cp -a "$ARCH_HOME/.local/bin" "$BACKUP_DEST/local_assets/bin"
fi

# 5. Copy Environment and Shell Profiles
echo "Copying shell and environment profiles..."
cp -a "$ARCH_HOME/.bashrc" "$BACKUP_DEST/system_files/bashrc_arch"
cp -a "$ARCH_HOME/.Xresources" "$BACKUP_DEST/system_files/Xresources_arch"
[ -f "$ARCH_HOME/.profile" ] && cp -a "$ARCH_HOME/.profile" "$BACKUP_DEST/system_files/profile_arch"

# 6. Copy Local Assets (Fonts and Databases)
# Fonts are critical for AwesomeWM icons (Nerd Fonts)
echo "Copying fonts and zoxide database..."
if [ -d "$ARCH_HOME/.local/share/fonts" ]; then
    cp -a "$ARCH_HOME/.local/share/fonts" "$BACKUP_DEST/local_assets/"
fi
mkdir -p "$BACKUP_DEST/system_files/zoxide"
if [ -f "$ARCH_HOME/.local/share/zoxide/db" ]; then
    cp -a "$ARCH_HOME/.local/share/zoxide/db" "$BACKUP_DEST/system_files/zoxide/"
fi

echo "Backup process finalized. All critical files are in $BACKUP_DEST"
