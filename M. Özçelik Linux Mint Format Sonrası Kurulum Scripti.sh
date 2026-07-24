#!/bin/bash

set -e

echo "=============================="
echo "== GEREKSİZ PAKETLER TEMİZLENİYOR VE YENİ PAKETLER KURULUYOR =="
echo "=============================="

sudo apt purge -y thunderbird transmission-gtk warpinator rhythmbox && sudo apt autoremove --purge -y
sudo apt update
sudo apt install -y numlockx fish steam wine winetricks audacious

echo "=============================="
echo "== FISH SHELL AYARLANIYOR =="
echo "=============================="

chsh -s /usr/bin/fish

echo "=============================="
echo "== FlatPak Uygulamaları =="
echo "=============================="

flatpak install flathub -y \
org.kde.kdenlive \
org.audacityteam.Audacity \
org.nickvision.tubeconverter \
org.onlyoffice.desktopeditors \
net.davidotek.pupgui2 \
com.spotify.Client \
com.heroicgameslauncher.hgl

echo "=============================="
echo "== Winetricks Kurulumları =="
echo "=============================="

winetricks -q dotnet40 dotnet45 dotnet48 vcrun2022 vcrun6sp6

echo "=============================="
echo "== DXVK (FL için gerekli) =="
echo "=============================="

winetricks dxvk2030

echo "==> zRAM, Swap ve Swappiness ayarlanıyor..."

# zramswap kurulu değilse kur
sudo apt install -y zramswap

# zRAM yapılandırması
sudo tee /etc/default/zramswap >/dev/null <<EOF
ALGO=zstd
PERCENT=50
PRIORITY=100
EOF

# zRAM servisini etkinleştir ve yeniden başlat
sudo systemctl enable zramswap
sudo systemctl restart zramswap

# Swap dosyasını 4 GB olarak yeniden oluştur
sudo swapoff /swapfile 2>/dev/null || true
sudo rm -f /swapfile
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# fstab'a tek satır olacak şekilde ekle
sudo sed -i '\|^/swapfile|d' /etc/fstab
echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab >/dev/null

# Swappiness değerini 4 yap
echo "vm.swappiness=4" | sudo tee /etc/sysctl.d/99-swappiness.conf >/dev/null
sudo sysctl --system

echo
echo "✅ Ayarlar tamamlandı."
echo

echo "Bellek durumu:"
free -h

echo
echo "Aktif swap alanları:"
swapon --show

echo
echo "zRAM durumu:"
zramctl

echo
echo "Swappiness değeri:"
cat /proc/sys/vm/swappiness
echo

echo "=============================="
echo "== GRUB PARAMETRELERİ EKLENİYOR =="
echo "=============================="

sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 acpi_backlight=native nvme_core.default_ps_max_latency_us=0"/' /etc/default/grub
sudo update-grub

echo "=============================="
echo "== BİTTİ =="
echo "=============================="

echo "Lütfen sistemi rebootla bebeğim."
