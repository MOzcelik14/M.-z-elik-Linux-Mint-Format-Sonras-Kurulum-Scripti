#!/bin/bash

set -e

echo "=============================="
echo "== GEREKSİZ BİLEŞENLER KALDIRILIYOR VE YENİ PAKETLER KURULUYOR =="
echo "=============================="

systemctl disable NetworkManager-wait-online.service
sudo apt purge -y thunderbird transmission-gtk warpinator rhythmbox && sudo apt autoremove --purge -y
sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
sudo apt update
sudo apt install -y numlockx fish steam wine winetricks audacious fastfetch btop

echo "=============================="
echo "== SHELL AYARLANIYOR =="
echo "=============================="

chsh -s /usr/bin/fish
curl -sS https://starship.rs/install.sh | sh -s -- -y

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

echo "Fish yapılandırılıyor..."

mkdir -p ~/.config/fish

cat > ~/.config/fish/config.fish <<'EOF'
if status is-interactive
    echo " "
    set_color normal

    # Fastfetch
    fastfetch

    echo
end

# Starship
starship init fish | source

alias güncelle='sudo apt update || true && sudo apt upgrade -y && flatpak update'
alias temizle='sudo apt autoremove && sudo apt autoclean -y && flatpak uninstall --unused'
alias yükle='sudo apt install'
alias fyükle='flatpak install'
alias sil='sudo apt remove'
alias fsil='flatpak remove'
alias kapa='poweroff'
alias söyle='echo'
EOF

echo

echo "Fastfetch yapılandırılıyor..."

mkdir -p ~/.config/fastfetch

cat > ~/.config/fastfetch/config.jsonc <<'EOF'
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json",
  "display": {
    "key": {
      "width": 10
    },
    "size": {
      "binaryPrefix": "jedec"
    },
    "separator": ""
  },
  "logo": {
    "type": "kitty-direct",
    "source": "~/.config/fastfetch/marin.png",
    "width": 20,
    "height": 10
  },
  "modules": [
    "break",
    {
      "type": "os",
      "key": "is",
      "keyColor": "yellow",
      "format": "{name}"
    },
    {
      "type": "kernel",
      "key": "lnx",
      "keyColor": "green"
    },
    {
      "type": "packages",
      "key": "pkgs",
      "keyColor": "cyan"
    },
    {
      "type": "uptime",
      "key": "çs",
      "keyColor": "green"
    },
    {
      "type": "cpu",
      "key": "mib",
      "keyColor": "red",
      "format": "{name}"
    },
    {
      "type": "gpu",
      "key": "gib",
      "keyColor": "red",
      "format": "{name}"
    },
    {
      "type": "memory",
      "key": "ram",
      "keyColor": "yellow",
      "format": "{used} / {total}"
    },
    {
      "type": "swap",
      "key": "swp-zram",
      "keyColor": "yellow",
      "format": "{used} / {total}"
    },
    {
      "type": "disk",
      "key": "dep",
      "keyColor": "cyan",
      "folders": [
        "/"
      ],
      "format": "{size-used} / {size-total}"
    },
    "break",
    {
      "type": "custom",
      "format": "\u001b[33m󰮯 \u001b[32m󰊠 \u001b[34m󰊠 \u001b[31m󰊠 \u001b[36m󰊠 \u001b[35m󰊠 \u001b[37m󰊠 \u001b[97m󰊠"
    }
  ]
}
EOF

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
