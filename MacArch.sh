#!/bin/bash

echo "🍎 Starting macOSification of your Arch Linux server..."

# 1. Install base GUI stack (Xorg + GNOME + i3 + GDM)
echo "📦 Installing base GUI packages..."
sudo pacman -Syu xorg gnome gdm i3 --noconfirm

# Enable GDM (display manager)
sudo systemctl enable gdm

# 2. Install yay (if not already installed)
if ! command -v yay &> /dev/null; then
    echo "🚀 Installing yay..."
    sudo pacman -S --needed git base-devel --noconfirm
    cd /opt
    sudo git clone https://aur.archlinux.org/yay.git
    sudo chown -R $USER:$USER yay
    cd yay && makepkg -si --noconfirm && cd ~
fi

# 3. Install macOS themes + GNOME tools
yay -S whitesur-gtk-theme whitesur-icon-theme macos-cursors gnome-tweaks plank \
    gnome-shell-extension-user-theme gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-just-perfection gnome-shell-extension-panel-osd \
    gnome-shell-extension-appindicator --noconfirm

# 4. Install and configure Plymouth
echo "🎬 Setting up Plymouth splash..."
sudo pacman -S plymouth --noconfirm
yay -S plymouth-theme-whitesur --noconfirm
sudo sed -i 's/^HOOKS=(/HOOKS=(base udev plymouth/' /etc/mkinitcpio.conf
sudo mkinitcpio -P
sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="splash /' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo plymouth-set-default-theme -R WhiteSur

# 5. Apply GNOME/macOS theme
echo "🎨 Applying macOS theme..."
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'macOS-Monterey'
gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark'

# 6. Apply shell theme (macOS style top bar)
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark'
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gnome-extensions enable just-perfection-desktop@just-perfection
gnome-extensions enable panel-osd@jderose9.github.com
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com

# 7. Setup Plank dock autostart
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/plank.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Plank
EOF

# 8. i3 autostart inside GNOME
mkdir -p ~/.config/gnome-session
cat > ~/.config/gnome-session/gnome-session.override <<EOF
[GNOME Session]
RequiredComponents=gnome-settings-daemon;gnome-shell;i3
EOF

# 9. Optional: Apple logo in top left (replace Activities)
gsettings set org.gnome.shell.extensions.just-perfection show-activities-button false
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-format '12h'

# Add Apple logo app
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/apple.desktop <<EOF
[Desktop Entry]
Name=
Exec=xdg-open https://apple.com
Icon=apple
Type=Application
Categories=Utility;
EOF

# 10. Final Touches
echo -e "\n✅ macOSification complete. Reboot to enjoy your 🍎 Mac-like Arch Linux experience!"

