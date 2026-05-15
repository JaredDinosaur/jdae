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
mkdir -p airootfs/usr/local/bin
cp ../jdae.sh airootfs/usr/local/bin
chmod +x airootfs/usr/local/bin/jdae.sh
mkdir -p airootfs/etc/systemd/system
echo "[Unit]" >> airootfs/etc/systemd/system/jdae.service
echo "Description=JDAE startup script" >> airootfs/etc/systemd/system/jdae.service
echo "After=multi-user.target" >> airootfs/etc/systemd/system/jdae.service
echo "" >> airootfs/etc/systemd/system/jdae.service
echo "[Service]" >> airootfs/etc/systemd/system/jdae.service
echo "Type=simple" >> airootfs/etc/systemd/system/jdae.service
echo "ExecStart=/usr/local/bin/jdae.sh" >> airootfs/etc/systemd/system/jdae.service
echo "" >> airootfs/etc/systemd/system/jdae.service
echo "[Install]" >> airootfs/etc/systemd/system/jdae.service
echo "WantedBy=multi-user.target" >> airootfs/etc/systemd/system/jdae.service
mkdir -p airootfs/etc/systemd/system/multi-user.target.wants
ln -s /etc/systemd/system/jdae.service airootfs/etc/systemd/system/multi-user.target.wants/myscript.service
ln -s /usr/lib/systemd/system/NetworkManager.service airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service
sudo rm -rf work out
cd ..
sudo mkarchiso -v jdae
echo ""
echo "Done."
