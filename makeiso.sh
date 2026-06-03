#!/bin/bash
set -e
sudo pacman -S --needed archiso squashfs-tools xorriso
if [[ -d "archiso" ]]; then
	sudo rm -rf archiso
fi
mkdir -p archiso
cd archiso
cp -r /usr/share/archiso/configs/releng jdae
cd jdae
cat >> packages.x86_64 << "EOF"
networkmanager
network-manager-applet
wireless_tools
wpa_supplicant
iw
dialog
usbutils
pciutils
hwinfo
EOF

sed -i "s/#Color/Color/" pacman.conf
sed -i "s/ParallelDownloads = 5/ParallelDownloads = 1/" pacman.conf
sed -i "s/#NoProgressBar/ILoveCandy/" pacman.conf
sed -i "s/iso_name=\"archlinux\"/iso_name=\"jdae\"/" profiledef.sh
sed -i "s/iso_label=\"ARCH/iso_label=\"JDAE/" profiledef.sh
sed -i "s/iso_publisher=\"Arch Linux <https:\/\/archlinux.org>\"/iso_publisher=\"Jared Dinosaur <https:\/\/github.com\/JaredDinosaur>\"/" profiledef.sh
install -Dm755 ../../jdae.sh airootfs/usr/local/bin/jdae.sh
cat > airootfs/root/.zlogin << "EOF"
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
