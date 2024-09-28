#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit
fi

echo "Starting Arch Linux post-installation setup script..."

# 1. Update system and install essential packages
echo "Updating system and installing essential packages..."
pacman -Syu --noconfirm
pacman -S --needed --noconfirm \
  sudo base-devel git networkmanager openssh \
  ufw bluez-utils ntp gdb \
  polkit xorg-xset xorg-xprop xorg-xrandr

# 2. Enable and start NetworkManager
echo "Enabling and starting NetworkManager..."
systemctl enable --now NetworkManager.service

# 3. Install minimal KDE Plasma desktop environment
echo "Installing minimal KDE Plasma desktop environment..."
pacman -S --needed --noconfirm \
  plasma-desktop plasma-nm kde-gtk-config \
  qt6-base  # Install only minimal KDE components

# 4. Install essential applications and utilities
echo "Installing essential applications and utilities..."
pacman -S --needed --noconfirm \
  git python python-pip python-setuptools python-pyqt5 \
  tk yarn npm nodejs rust cmake make ninja \
  wezterm zsh fzf nano ranger shy picom mpv \
  ttf-jetbrains-mono wireguard-tools openresolv \
  openvpn qopenvpn easy-rsa pam nmap reflector \
  glances neofetch feh catimg keepassxc xclip flameshot \
  gparted btrfs-progs dosfstools exfatprogs f2fs-tools \
  ntfs-3g hyperfine python-matplotlib ffmpeg \
  imagemagick djvulibre ghostscript jbigkit libheif \
  libjpeg-turbo libjxl libraw librsvg libtiff libwebp \
  libwmf libzip ocl-icd openexr openjpeg2 pango \
  python-certifi python-numpy blas-openblas python-scipy \
  python-pillow fail2ban gnu-netcat zram-generator \
  libultrahdr wireless_tools thermald powertop acpid

# 5. Install AUR Helper: yay
echo "Installing yay AUR helper..."
if ! command -v yay &> /dev/null; then
  cd /opt
  git clone https://aur.archlinux.org/yay-git.git
  chown -R $USER:$USER ./yay-git
  cd yay-git
  sudo -u $USER makepkg -si --noconfirm
fi

# 6. Install AUR packages
echo "Installing AUR packages..."
yay -S --needed --noconfirm \
  tlp-git tlp-rdw-git tlpui-git auto-cpufreq laptop-mode-tools-git blktrace

# 7. Enable and start essential services
echo "Enabling and starting essential services..."
systemctl enable --now tlp.service
systemctl enable --now ufw.service

# 8. Configure UFW firewall
echo "Configuring UFW firewall..."
ufw enable
ufw logging on

ufw default reject incoming
ufw default allow outgoing
ufw default deny routed 

# 9. Set zsh as the default shell for the user
echo "Setting zsh as the default shell for the user..."
chsh -s $(which zsh) $USER

# 10. Install and enable ly as the display manager
echo "Installing ly as the display manager..."
pacman -S --needed --noconfirm ly
systemctl enable ly.service

echo "Installation complete! Please reboot to start using your system."
