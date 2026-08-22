#!/bin/bash
verbose=0
while getopts "v" flag; do
    if [[ $flag == "v" ]]; then
        verbose=1
    fi
done
set -e
sudo pacman -S --needed archiso squashfs-tools xorriso
if [[ -d "archiso" ]]; then
	echo -e '\e[34m'"[INFO]" '\e(B\e[m'"Removing previous build..."
	case $verbose in
        0)
            sudo rm -rf archiso
            ;;
        1)
            sudo rm -rvf archiso
            ;;
	esac
fi
mkdir -p archiso
cd archiso
echo -e '\e[34m'"[INFO]" '\e(B\e[m'"Configuring system..."
case $verbose in
    0)
        cp -r /usr/share/archiso/configs/releng jdae
        ;;
    1)
        cp -rv /usr/share/archiso/configs/releng jdae
        ;;
esac
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
gum
EOF

sed -i "s/#Color/Color/" pacman.conf
sed -i "s/ParallelDownloads = 5/ParallelDownloads = 1/" pacman.conf
sed -i "s/#NoProgressBar/ILoveCandy/" pacman.conf
sed -i "s/iso_name=\"archlinux\"/iso_name=\"jdae\"/" profiledef.sh
sed -i "s/iso_label=\"ARCH/iso_label=\"JDAE/" profiledef.sh
sed -i "s/iso_publisher=\"Arch Linux <https:\/\/archlinux.org>\"/iso_publisher=\"Jared Dinosaur <https:\/\/github.com\/JaredDinosaur>\"/" profiledef.sh
sed -i "s/timeout 15/timeout 10/" efiboot/loader/loader.conf
sed -i "s/beep on/beep off/" efiboot/loader/loader.conf
sed -i "s/title    Arch Linux install medium (%ARCH%, UEFI)/title    JDAE (normal mode)/" efiboot/loader/entries/01-archiso-linux.conf
sed -i "s/title    Arch Linux install medium (%ARCH%, UEFI) with speech/title    JDAE (accessibility mode)/" efiboot/loader/entries/02-archiso-speech-linux.conf
sed -i "s/timeout=15/timeout=10/" grub/grub.cfg
sed -i "s/menuentry \"Arch Linux install medium (%ARCH%, ${archiso_platform})\"/menuentry \"JDAE (normal mode)\"/" grub/grub.cfg
sed -i "s/menuentry \"Arch Linux install medium with speakup screen reader (%ARCH%, ${archiso_platform})\"/menuentry \"JDAE (accessibility mode)\"/" grub/grub.cfg

install -Dm755 ../../jdae.sh airootfs/usr/local/bin/jdae.sh
cat > airootfs/root/.zlogin << "EOF"
/bin/bash exit.sh
EOF

cat > airootfs/root/exit.sh << "EOF"
if [[ $(tty) == "/dev/tty1" ]]; then
    /bin/bash /usr/local/bin/jdae.sh
    case $? in
        0)
            echo ""
            echo ""
            echo ""
            echo "The installer has exited."
            echo "If you chose clean up and exit, press Ctrl+D to reopen the installer."
            echo "Otherwise, the following commands must be run beforehand before reopening:"
            echo "umount -Rv /mnt"
            echo "swapoff -av"
            echo "cryptsetup close -v /dev/mapper/root"
            echo ""
            ;;
        *)
            echo ""
            echo ""
            echo ""
            echo "The installer has exited."
            echo "To start another installation, run the following commands:"
            echo "umount -Rv /mnt"
            echo "swapoff -av"
            echo "cryptsetup close -v /dev/mapper/root"
            echo ""
            echo "Then press Ctrl+D to reopen the installer."
            echo ""
            ;;
    esac
fi
EOF

echo -e '\e[34m'"[INFO]" '\e(B\e[m'"Cleaning up..."
case $verbose in
    0)
        sudo rm -rf work out
        ;;
    1)
        sudo rm -rvf work out
        ;;
esac
cd ..
echo -e '\e[34m'"[INFO]" '\e(B\e[m'"Building image (should take 20-30 minutes)..."
case $verbose in
    0)
        sudo mkarchiso -v jdae 2>&1 | grep --line-buffered -E '::|mkarchiso|filesystem on /'
        ;;
    1)
        sudo mkarchiso -v jdae
        ;;
esac
echo ""
echo -e '\e[32m'"[ OK ]" '\e(B\e[m'"Done."
