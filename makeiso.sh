#!/bin/bash
set -e
sudo pacman -S --needed archiso squashfs-tools xorriso
mkdir -p archiso
cd archiso
cp -r /usr/share/archiso/configs/releng jdae
cd jdae
echo "networkmanager" >> packages.x86_64
echo "network-manager-applet" >> packages.x86_64
echo "wireless_tools" >> packages.x86_64
echo "wpa_supplicant" >> packages.x86_64
echo "iw" >> packages.x86_64
echo "dialog" >> packages.x86_64
echo "usbutils" >> packages.x86_64
echo "pciutils" >> packages.x86_64
echo "hwinfo" >> packages.x86_64
install -Dm755 ../../jdae.sh airootfs/usr/local/bin/jdae.sh
cat > airootfs/root/.bash_profile << 'EOF'
/bin/bash /usr/bin/jdae.sh
EOF
sudo rm -rf work out
cd ..
sudo mkarchiso -v jdae
echo ""
echo "Done."
