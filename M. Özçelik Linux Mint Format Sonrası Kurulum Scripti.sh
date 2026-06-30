#!/bin/bash

set -e

echo "=============================="
echo "== GRUB PARAMETRELERİ EKLENİYOR =="
echo "=============================="

sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 acpi_backlight=native nvme_core.default_ps_max_latency_us=0"/' /etc/default/grub

sudo update-grub

echo "=============================="
echo "== PAKETLER KURULUYOR =="
echo "=============================="

sudo apt update
sudo apt install -y numlockx fish steam wine winetricks flatpak

echo "=============================="
echo "== FISH SHELL AYARLANIYOR =="
echo "=============================="

chsh -s /usr/bin/fish

echo "=============================="
echo "== FlatPak Uygulamaları =="
echo "=============================="

flatpak install flathub -y \
app.zen_browser.zen \
org.kde.kdenlive \
org.audacityteam.Audacity \
org.nickvision.tubeconverter \
org.onlyoffice.desktopeditors \
net.davidotek.pupgui2 \
com.heroicgameslauncher.hgl

echo "=============================="
echo "== Winetricks Kurulumları =="
echo "=============================="

winetricks -q d3dx9 dotnet40 dotnet45 dotnet48 vcrun2022 vcrun6sp6

echo "=============================="
echo "== DXVK (FL için gerekli) =="
echo "=============================="

winetricks dxvk2030

echo "=============================="
echo "== BİTTİ =="
echo "=============================="

echo "Reboot önerilir"
