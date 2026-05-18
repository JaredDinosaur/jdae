#!/bin/bash
set -e
sudo pacman -S --needed archiso squashfs-tools xorriso
mkdir -p archiso
sudo rm -rf archiso
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
cat > airootfs/root/.zlogin << 'EOF'
if [[ $(tty) == "/dev/tty1" ]]; then
    /bin/bash /usr/local/bin/jdae.sh
    echo ""
    echo ""
    echo ""
    echo "The installer has exited."
    echo "To start another installation, run the following commands (unless you chose cleanup and exit):"
    echo "umount /mnt/boot"
    echo "umount /mnt"
    echo "swapoff -a"
    echo "cryptsetup close /dev/mapper/root"
    echo ""
    echo "Then press Ctrl+D to reopen the installer."
    echo ""
fi
EOF
sudo rm -rf work out
cd ..
sudo mkarchiso -v jdae
echo ""
echo "Done."
