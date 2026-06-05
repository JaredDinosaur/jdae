#!/bin/bash
set -euo pipefail
setlocale(){
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Select your locale: "'\e(B\e[m'
        echo
        echo -e '\e[36m'"[1]" '\e(B\e[m'"English - United Kingdom" '\e[35m'"(default)"
        echo -e '\e[36m'"[2]" '\e(B\e[m'"English - United States"
        read -n 1 choice
        case $choice in
            1)
                keys="uk"
                reg="GB"
                loop=0
                ;;
            2)
                keys="--default"
                reg="US"
                loop=0
                ;;
            *)
                ;;
        esac
    done
}

diskpart(){
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo "Available disks:"
        echo
        # List available disks
        hwinfo --disk --short
        echo
        echo "Recommended minimum disk space: 64GB for VMs, 128GB for real hardware"
        read -p "The disk to install to is /dev/___: " disk
        echo
        echo -e '\e[3m'"WARNING: The contents of this disk will be changed or erased!"'\e(B\e[m'
        echo -e '\e[3m'"Double check that you have selected the correct disk!"'\e(B\e[m'
        echo -e '\e[3m'"Are you sure you want to continue?"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[Y]" '\e(B\e[m'"I understand, continue"
        echo -e '\e[36m'"[N]" '\e(B\e[m'"Choose another disk"
        echo -e '\e[36m'"[Q]" '\e(B\e[m'"Cancel the installation (power off)"
        read -n 1 choice
        case $choice in
            y|Y)
                loop=0
                ;;
            q|Q)
                poweroff
                exit 1
                ;;
            *)
                ;;
        esac
    done
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Choose a partitioning method:"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[1]" '\e(B\e[m'"Automatic partition layout (uses entire disk)"
        echo -e '\e[36m'"[2]" '\e(B\e[m'"Manual configuration"
        read -n 1 choice
        case $choice in
            1)
                rootno=3
                bootno=1
                swapno=2
                formboot=1
                manpart=0
                loop=0
                ;;
            2)
                manpart=1
                loop=0
                ;;
            *)
                ;;
        esac
    done
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Choose a root filesystem:"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[1]" '\e(B\e[m'"ext4" '\e[35m'"(default)"
        echo -e '\e[36m'"[2]" '\e(B\e[m'"btrfs"
        echo -e '\e[36m'"[3]" '\e(B\e[m'"xfs"
        echo
        echo -e '\e[36m'"[H]" '\e(B\e[m'"Help"
        read -n 1 choice
        case $choice in
            1)
                rootfs="ext4"
                loop=0
                ;;
            2)
                rootfs="btrfs"
                loop=0
                ;;
            3)
                rootfs="xfs"
                loop=0
                ;;
            h|H)
                clear
                echo -e '\e[3m'"Help page: Filesystems"'\e(B\e[m'
                echo
                echo -e '\e[35m'"ext4"'\e(B\e[m'":"
                echo "The default option. Balances performance and simplicity."
                echo
                echo -e '\e[35m'"btrfs"'\e(B\e[m'":"
                echo "Has copy-on-write functionality to easily make backups. Good for data integrity, but may run slightly slower."
                echo
                echo -e '\e[35m'"xfs"'\e(B\e[m'":"
                echo "High performance filesystem. Good for servers and large drives."
                echo
                echo -e '\e[3m'"Press any key to continue..."
                read -n 1
                ;;
            *)
                ;;
        esac
    done
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Would you like to encrypt your root partition?"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes"
        echo -e '\e[36m'"[N]" '\e(B\e[m'"No"
        echo
        echo -e '\e[36m'"[H]" '\e(B\e[m'"Help"
        read -n 1 choice
        case $choice in
            y|Y)
                crypt=1
                clear
                valid=0
                while [[ $valid == 0 ]]; do
                    read -s -p "Enter the encryption password (will not show): " cryptpass
                    if [[ $cryptpass == "" ]]; then
                        clear
                        echo "Password cannot be blank!"
                        echo
                    else
                        echo
                        read -s -p "Confirm password: " cryptconf
                        if [[ $cryptconf == $cryptpass ]]; then
                            clear
                            printf -v cryptstar '%*s' "${#cryptpass}" ''
                            cryptstar=${cryptstar// /*}
                            valid=1
                        else
                            clear
                            echo "Passwords do not match!"
                            echo
                        fi
                    fi
                done
                loop=0
                ;;
            n|N)
                crypt=0
                loop=0
                ;;
            h|H)
                clear
                echo -e '\e[3m'"Help page: Disk Encryption"'\e(B\e[m'
                echo
                echo "This will ask you for an encryption password every time you start your machine."
                echo "Files on your main partition will be inaccessible without the key, making your system more secure."
                echo "This may cause issues with some boot animations, and your main partition cannot be unlocked if you forget the key."
                echo
                echo -e '\e[3m'"Press any key to continue..."
                read -n 1
                ;;
            *)
                ;;
        esac
    done
}

pkgs(){
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Choose a set of packages:"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[1]" '\e(B\e[m'"Desktop with Plasma" '\e[35m'"(default)"
        echo -e '\e[36m'"[2]" '\e(B\e[m'"Desktop with Hyprland"
        echo -e '\e[36m'"[3]" '\e(B\e[m'"Desktop with Xfce"
        echo -e '\e[36m'"[4]" '\e(B\e[m'"Desktop with LXQt"
        echo -e '\e[36m'"[5]" '\e(B\e[m'"Command line"
        echo -e '\e[36m'"[6]" '\e(B\e[m'"Minimal"
        echo
        echo -e '\e[36m'"[H]" '\e(B\e[m'"Help"
        read -n 1 choice
        case $choice in
            1)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop partitionmanager plymouth dolphin discover packagekit packagekit-qt6 plasma sddm vlc iwd git nano konsole dialog limine sudo efibootmgr networkmanager network-manager-applet base-devel blueman btrfs-progs dosfstools e2fsprogs xfsprogs"
                profile="Desktop (Plasma)"
                loop=0
                ;;
            2)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop partitionmanager plymouth dolphin discover packagekit packagekit-qt6 vlc iwd hyprland kitty wofi waybar hyprpaper git nano konsole dialog sddm limine sudo efibootmgr networkmanager network-manager-applet base-devel blueman dunst wireplumber noto-fonts pipewire-pulse nerd-fonts sof-firmware sddm-kcm plymouth-kcm systemsettings breeze breeze-cursors breeze-plymouth flatpak-kcm plasma-integration btrfs-progs dosfstools e2fsprogs xfsprogs"
                profile="Desktop (Hyprland)"
                loop=0
                ;;
            3)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop xfce4 xfce4-goodies plymouth discover packagekit packagekit-qt6 vlc iwd git nano dialog lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings limine sudo efibootmgr networkmanager network-manager-applet base-devel blueman btrfs-progs dosfstools e2fsprogs xfsprogs"
                profile="Desktop (Xfce)"
                loop=0
                ;;
            4)
                pkglist="base linux linux-firmware firefox flatpak screenfetch tree htop partitionmanager plymouth discover packagekit packagekit-qt6 lxqt vlc iwd git nano dialog lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings limine sudo efibootmgr networkmanager network-manager-applet base-devel blueman btrfs-progs dosfstools e2fsprogs xfsprogs"
                profile="Desktop (LXQt)"
                loop=0
                ;;
            5)
                pkglist="base linux linux-firmware screenfetch tree htop plymouth iwd python git nano dialog limine sudo efibootmgr networkmanager base-devel blueman btrfs-progs dosfstools e2fsprogs xfsprogs"
                profile="Command line"
                loop=0
                ;;
            6)
                pkglist="base linux linux-firmware git iwd python nano limine sudo efibootmgr networkmanager base-devel"
                profile="Minimal"
                loop=0
                ;;
            h|H)
                clear
                echo -e '\e[3m'"Help page: Package Sets and Desktop Environments"'\e(B\e[m'
                echo
                echo -e '\e[35m'"Desktop (Plasma)"'\e(B\e[m'":"
                echo "An easy-to-use Windows-like desktop which is highly customisable and stable."
                echo "This is the best option for beginners, although it may run slower on old systems."
                echo
                echo -e '\e[35m'"Desktop (Hyprland)"'\e(B\e[m'":"
                echo "An extremely lightweight and configurable tiling window manager."
                echo "It is very complicated and may be unstable, especially on virtual machines."
                echo
                echo -e '\e[35m'"Desktop (Xfce)"'\e(B\e[m'":"
                echo "A somewhat Mac-like desktop which is fast and customisable."
                echo "It is slightly more complicated than Plasma."
                echo
                echo -e '\e[35m'"Desktop (LXQt)"'\e(B\e[m'":"
                echo "A more advanced but very lightweight Windows-like desktop."
                echo "Ideal for low-end machines."
                echo
                echo -e '\e[35m'"Command line"'\e(B\e[m'":"
                echo "A simple text interface with some basic utilities."
                echo "This option is ideal if you wish to install a different desktop environment."
                echo
                echo -e '\e[35m'"Minimal"'\e(B\e[m'":"
                echo "The most basic set of packages with no extras."
                echo "This is recommended for servers or extremely slow machines."
                echo
                echo -e '\e[3m'"Press any key to continue..."
                read -n 1
                ;;
            *)
                ;;
        esac
    done
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Install additional packages?"'\e(B\e[m'
        echo -e '\e[3m'"This includes an ad blocker, resource monitor, and support for additional file systems."'\e(B\e[m'
        echo
        echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes"
        echo -e '\e[36m'"[N]" '\e(B\e[m'"No"
        echo
        echo -e '\e[36m'"[H]" '\e(B\e[m'"Help"
        read -n 1 choice
        case $choice in
            y|Y)
                extrapkgs=1
                loop=0
                ;;
            n|N)
                extrapkgs=0
                loop=0
                ;;
            h|H)
                clear
                echo -e '\e[3m'"Help page: Additional Packages"'\e(B\e[m'
                echo
                echo "Includes packages such as extra terminal utilies, an ad blocker, and support for more filesystems such as NTFS and APFS."
                echo "This adds some time to the installation process and is ideal for working alongside Windows or macOS."
                echo
                echo -e '\e[3m'"Press any key to continue..."
                read -n 1
                ;;
            *)
                ;;
        esac
    done
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Install Steam, GPU drivers, and additional gaming features?"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes"
        echo -e '\e[36m'"[N]" '\e(B\e[m'"No"
        echo
        echo -e '\e[36m'"[H]" '\e(B\e[m'"Help"
        read -n 1 choice
        case $choice in
            y|Y)
                loop=1
                while [[ $loop == 1 ]]; do
                    clear
                    echo -e '\e[3m'"Select your graphics card manufacturer."'\e(B\e[m'
                    echo -e '\e[3m'"For Nvidia, proprietary drivers are better for more recent cards (GTX 1650 or newer)."'\e(B\e[m'
                    echo -e '\e[3m'"If your machine has no graphics card, select your CPU manufacturer."'\e(B\e[m'
                    echo
                    echo -e '\e[36m'"[1]" '\e(B\e[m'"Intel"
                    echo -e '\e[36m'"[2]" '\e(B\e[m'"AMD (Radeon)"
                    echo -e '\e[36m'"[3]" '\e(B\e[m'"Nvidia (Open Source)"
                    echo -e '\e[36m'"[4]" '\e(B\e[m'"Nvidia (Proprietary)"
                    echo -e '\e[36m'"[5]" '\e(B\e[m'"Other"
                    read -n 1 choice
                    case $choice in
                        1)
                            gpupkg=" vulkan-intel xf86-video-intel lib32-vulkan-intel"
                            gpuconf="Intel"
                            loop=0
                            ;;
                        2)
                            gpupkg=" vulkan-radeon xf86-video-amdgpu lib32-vulkan-radeon"
                            gpuconf="AMD (Radeon)"
                            loop=0
                            ;;
                        3)
                            gpupkg=" vulkan-nouveau xf86-video-nouveau lib32-vulkan-nouveau"
                            gpuconf="Nvidia (Open Source)"
                            loop=0
                            ;;
                        4)
                            gpupkg=" nvidia nvidia-utils lib32-nvidia-utils"
                            gpuconf="Nvidia (Proprietary)"
                            loop=0
                            ;;
                        5)
                            gpupkg=""
                            gpuconf="Other"
                            loop=0
                            ;;
                        *)
                            ;;
                    esac
                done
                gamer=1
                loop=0
                ;;
            n|N)
                gamer=0
                loop=0
                ;;
            h|H)
                clear
                echo -e '\e[3m'"Help page: Gaming Packages"'\e(B\e[m'
                echo
                echo "Includes Steam and Lutris to manage your games, compatibility tools to help your games run better, and extra drivers for your graphics card."
                echo "Choose these if you plan on playing games, doing creative work, or performing other intensive tasks."
                echo
                echo -e '\e[3m'"Press any key to continue..."
                read -n 1
                ;;
            *)
                ;;
        esac
    done
}

sethostname(){
    clear
    valid=0
    while [[ $valid == 0 ]]; do
        read -p "Name your machine (letters, numbers and dashes): " hname
        if [[ "$hname" =~ ^[a-zA-Z0-9-]+$ ]]; then
            valid=1
        else
            clear
            echo "Invalid hostname!"
        fi
    done
}

user(){
    clear
    valid=0
    while [[ $valid == 0 ]]; do
        read -s -p "Enter the root password (will not show): " rootpass
        if [[ $rootpass == "" ]]; then
            clear
            echo
            echo "This will disable the root account! Are you sure?"
            read -p "Enter \"Yes, I understand\" to continue: " rootconf
            if [[ $rootconf == "Yes, I understand" ]]; then
                clear
                valid=1
            else
                clear
            fi
        else
            echo
            read -s -p "Confirm password: " rootconf
            if [[ $rootconf == $rootpass ]]; then
                clear
                printf -v rootstar '%*s' "${#rootpass}" ''
                rootstar=${rootstar// /*}
                valid=1
            else
                clear
                echo "Passwords do not match!"
                echo
            fi
        fi
    done
    clear
    valid=0
    while [[ $valid == 0 ]]; do
        read -p "Name your user (single word, lowercase): " uname
        if [[ "$uname" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
            valid=1
        else
            clear
            echo "Invalid username!"
        fi
    done
    clear
    read -p "Enter your user's full name (can be multiple words): " fullname
    clear
    valid=0
    while [[ $valid == 0 ]]; do
        read -s -p "Enter your user's password (will not show): " pass
        if [[ $pass == "" ]]; then
            clear
            echo "Password cannot be blank!"
            echo
        else
            echo
            read -s -p "Confirm password: " passconf
            if [[ $passconf == $pass ]]; then
                clear
                printf -v star '%*s' "${#pass}" ''
                star=${star// /*}
                valid=1
            else
                clear
                echo "Passwords do not match!"
                echo
            fi
        fi
    done
}

bootent(){
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"Show boot menu?"'\e(B\e[m'
        echo -e '\e[3m'"This allows you to select another system (such as Windows) when you start your machine."'\e(B\e[m'
        echo -e '\e[3m'"To detect other boot entries, install limine-entry-tool and run limine-scan."'\e(B\e[m'
        echo
        echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes"
        echo -e '\e[36m'"[N]" '\e(B\e[m'"No"
        read -n 1 choice
        case $choice in
            y|Y)
                bootmenu=1
                loop=0
                ;;
            n|N)
                bootmenu=0
                loop=0
                ;;
            *)
                ;;
        esac
    done
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"This machine is currently booted in $bootmode mode."'\e(B\e[m'
        echo -e '\e[3m'"Would you like to make your system bootable in both BIOS and UEFI mode?"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes"
        echo -e '\e[36m'"[N]" '\e(B\e[m'"No"
        read -n 1 choice
        case $choice in
            y|Y)
                if [[ $bootmode == "BIOS" ]]; then
                    uefiboot=1
                else
                    biosboot=1
                fi
                loop=0
                ;;
            n|N)
                if [[ $bootmode == "BIOS" ]]; then
                    uefiboot=0
                else
                    biosboot=0
                fi
                loop=0
                ;;
            *)
                ;;
        esac
    done
}

intchk(){
    echo "Checking internet connection..."
    # Attempt to sync databases
    set +e
    pacman -Syy &>/dev/null
    connect=$?
    set -e
    if [[ $connect == 0 ]]; then
        echo "Connection test successful."
        quit=0
    else
        loop=1
        while [[ $loop == 1 ]]; do
            clear
            echo -e '\e[3m'"Internet connection not found! Would you like to connect to a wireless network?"'\e(B\e[m'
            echo -e '\e[3m'"If you are definitely connected to the internet, the Arch Linux servers may be down."'\e(B\e[m'
            echo
            echo -e '\e[36m'"[Y]" '\e(B\e[m'"List available wireless networks"
            echo -e '\e[36m'"[N]" '\e(B\e[m'"Cancel installation"
            echo -e '\e[36m'"[P]" '\e(B\e[m'"Attempt to continue anyway (only do this if you are sure you have internet access!)"
            read -n 1 choice
            case $choice in
                y|Y)
                    clear
                    # List available wireless networks
                    iface=$(iw dev | awk '$1=="Interface"{print $2; exit}')
                    if [[ $iface == "" ]]; then
                        echo "No wireless devices found!"
                        quit=1
                        loop=0
                    else
                        iwctl station "$iface" get-networks
                        read -p "Enter the name of the network you wish to connect to: " ssid
                        # Connect to the selected network
                        iwctl station "$iface" connect "$ssid"
                        quit=2
                        loop=0
                    fi
                    ;;
                n|N)
                    quit=1
                    loop=0
                    ;;
                p|P)
                    quit=0
                    loop=0
                    ;;
                *)
                    ;;
            esac
        done
    fi
}

clear
# Check boot mode
if [[ -d "/sys/firmware/efi" ]]; then
    echo "The system is booted in UEFI mode."
    bootmode="UEFI"
    uefiboot=1
    biosboot=0
else
    echo "The system is booted in BIOS mode."
    bootmode="BIOS"
    uefiboot=0
    biosboot=1
fi
# Check internet connection
quit=0
intchk
if [[ $quit == 1 ]]; then
    exit 2
fi
while [[ $quit == 2 ]]; do
    intchk
    if [[ $quit == 1 ]]; then
        exit 2
    fi
done
# Edit pacman config and install hwinfo
sed -i "s/#Color/Color/" /etc/pacman.conf
sed -i "s/ParallelDownloads = 5/ParallelDownloads = 1/" /etc/pacman.conf
sed -i "s/#NoProgressBar/ILoveCandy/" /etc/pacman.conf

# Get options
setlocale
diskpart
pkgs
sethostname
user
bootent

# Show options and ask for confirmation
menu=1
while [[ $menu == 1 ]]; do
    clear
    echo "Region:                 $reg"
    echo "Disk:                   $disk"
    case $manpart in
        0)
            echo "Partitioning:           Automatic (using entire disk)"
            ;;
        1)
            echo "Partitioning:           Manual"
            ;;
    esac
    echo "Filesystem:             $rootfs"
    case $crypt in
        0)
            echo "Disk encryption:        Disabled"
            ;;
        1)
            echo "Disk encryption:        Enabled"
            echo "Encryption password:    $cryptstar"
            ;;
    esac
    echo "Profile:                $profile"
    case $extrapkgs in
        0)
            echo "Additional packages:    Disabled"
            ;;
        1)
            echo "Additional packages:    Enabled"
            ;;
    esac
    case $gamer in
        0)
            echo "Gaming features:        Disabled"
            echo "GPU Driver:             None"
            ;;
        1)
            echo "Gaming features:        Enabled"
            echo "GPU Driver:             $gpuconf"
            ;;
    esac
    echo "Hostname:               $hname"
    if [[ $rootpass == "" ]]; then
        echo "Root account:               Disabled"
    else
        echo "Root password:          $rootstar"
    fi
    echo "Username:               $uname"
    echo "Full name:              $fullname"
    echo "Password:               $star"
    case $bootmenu in
        0)
            echo "Boot menu:              Hidden"
            ;;
        1)
            echo "Boot menu:              Shown"
            ;;
    esac
    case $uefiboot in
        0)
            echo "Boot mode:              BIOS only"
            ;;
        1)
            case $biosboot in
                0)
                    echo "Boot mode:              UEFI only"
                    ;;
                1)
                    echo "Boot mode:              BIOS and UEFI"
                    ;;
            esac
            ;;
    esac
    echo
    echo -e '\e[3m'"Install with these options?"'\e(B\e[m'
    echo
    echo "-------------------------------------"
    echo
    echo -e '\e[36m'"[Y]" '\e(B\e[m'"Begin installation"
    echo -e '\e[36m'"[N]" '\e(B\e[m'"Cancel installation (power off)"
    echo -e '\e[36m'"[Q]" '\e(B\e[m'"Exit to shell"
    echo
    echo -e '\e[36m'"[1]" '\e(B\e[m'"Change locale"
    echo -e '\e[36m'"[2]" '\e(B\e[m'"Change partitioning and encryption"
    echo -e '\e[36m'"[3]" '\e(B\e[m'"Change packages and drivers"
    echo -e '\e[36m'"[4]" '\e(B\e[m'"Change hostname"
    echo -e '\e[36m'"[5]" '\e(B\e[m'"Change username and authentication"
    echo -e '\e[36m'"[6]" '\e(B\e[m'"Change boot options"
    read -n 1 choice
    case $choice in
        y|Y)
            menu=0
            ;;
        n|N)
            poweroff
            ;;
        q|Q)
            exit 1
            ;;
        1)
            setlocale
            ;;
        2)
            diskpart
            ;;
        3)
            pkgs
            ;;
        4)
            sethostname
            ;;
        5)
            user
            ;;
        6)
            bootent
            ;;
        *)
            ;;
    esac
done

# Make child scripts executable
echo "#!/bin/bash" > jdai-efi-2.sh
echo "#!/bin/bash" > jdai-usr.sh
chmod +x jdai-efi-2.sh
chmod +x jdai-usr.sh

# Set timezone (GB only)
if [[ $reg == "GB" ]]; then
    echo "ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime" >> jdai-efi-2.sh
    echo "hwclock --systohc" >> jdai-efi-2.sh
fi
cat >> jdai-efi-2.sh << "EOF"
# Generate locale
locale-gen
# Generate initramfs
mkinitcpio -P
# Enable system services
systemctl enable ip6tables iptables iwd NetworkManager-dispatcher NetworkManager systemd-network-generator systemd-networkd wpa_supplicant
systemctl enable accounts-daemon
systemctl enable udisks2
systemctl enable upower
systemctl enable sddm
systemctl enable lightdm
systemctl enable wireplumber
EOF
# Create boot entry
if [[ $uefiboot == 1 ]]; then
    echo "efibootmgr --create --disk /dev/${disk} --part 1 --label \"Arch Linux\" --loader '\\BOOTX64.EFI' --unicode" >> jdai-efi-2.sh
fi
if [[ $biosboot == 1 ]]; then
    echo "limine bios-install /dev/$disk" >> jdai-efi-2.sh
fi
# Copy child scripts
echo "cp jdai-usr.sh /home/$uname" >> jdai-efi-2.sh
# Switch to newly created user
echo "cd /home/$uname" >> jdai-efi-2.sh
# Run child script as new user
echo "su $uname -c ./jdai-usr.sh" >> jdai-efi-2.sh

cat >> jdai-usr.sh << "EOF"
# Clone and build yay
sudo pacman -Syy
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
#yay -S --noconfirm limine-entry-tool
EOF

# Install extra packages if selected
if [[ $extrapkgs == 1 ]]; then
    echo "yay -S --noconfirm --needed firefox firefox-i18n-uk firefox-ublock-origin flatpak neofetch screenfetch fastfetch tree htop btop partitionmanager ark thunar konsole dialog exfatprogs f2fs-tools hfsprogs jfsutils ntfs-3g udftools apfsprogs zfs-utils" >> jdai-usr.sh
fi
if [[ $gamer == 1 ]]; then
    echo "yay -S --noconfirm --needed steam gamescope lutris winboat mesa$gpupkg" >> jdai-usr.sh
fi
# Install Plasma configuration files
if [[ $profile == "Desktop (Plasma)" ]]; then
    cat >> jdai-usr.sh << "EOF"
cd ..
git clone https://github.com/JaredDinosaur/plasmaconf
cd plasmaconf
mv kde_settings.conf ..
cp ./* ~/.config
mv ../kde_settings.conf .
sudo cp kde_settings.conf /etc/sddm.conf.d
EOF
fi
# Install hyprland configuration files
if [[ $profile == "Desktop (Hyprland)" ]]; then
    cat >> jdai-usr.sh << "EOF"
cd .." >> jdai-usr.sh
git clone https://github.com/JaredDinosaur/hyprconf
cd hyprconf
mkdir ~/.config/hypr
mkdir ~/.config/kitty
cp hyprland.conf ~/.config/hypr
cp kitty.conf ~/.config/kitty
sudo cp config.jsonc /etc/xdg/waybar
sudo cp style.css /etc/xdg/waybar
EOF
fi

## Scan for other boot entries
#if [[ $bootmenu == 1 ]]; then
#cat >> jdai-usr.sh << "EOF"
#echo
#echo
#echo
#sudo limine-scan
#fi

case $manpart in
    0)
        clear
        echo "Starting installation in 5 seconds..."
        sleep 1
        clear
        echo "Starting installation in 4 seconds..."
        sleep 1
        clear
        echo "Starting installation in 3 seconds..."
        sleep 1
        clear
        echo "Starting installation in 2 seconds..."
        sleep 1
        clear
        echo "Starting installation in 1 second..."
        sleep 1
        clear
        # Handles different partition names (sda/vda vs nvme/mmcblk)
        if [[ "$disk" == *"d"* ]]; then
            root="${disk}${rootno}"
            boot="${disk}${bootno}"
            swap="${disk}${swapno}"
        else
            root="${disk}p${rootno}"
            boot="${disk}p${bootno}"
            swap="${disk}p${swapno}"
        fi
        # Get system RAM amount
        ram=$(grep MemTotal /proc/meminfo | awk '{print int($2/1024)}')
        # Partition disk:
        # /boot  | 1GB
        # [SWAP] | Same as RAM
        # /      | rest of disk
        fdisk /dev/$disk <<EOF
o
n
p
1

+1G
y
n
p
2

+${ram}M
y
n
p
3


w
EOF
        ;;
    1)
        menu=1
        while [[ $menu == 1 ]]; do
            echo
            echo "If your boot mode is not UEFI only, your disk must have an MBR partition table."
            echo "The following partitions are required:"
            echo
            echo " Type | Size"
            echo "------|----------------------------"
            echo " Boot | 256MB to 1GB"
            echo " Swap | Double your RAM"
            echo " Root | 8GB min, 32GB+ recommended"
            echo 
            echo "Press any key to open cfdisk."
            read -n 1
            # Open TUI partition manager
            cfdisk /dev/$disk
            clear
            read -p "Which partition number should be used for root? " rootno
            clear
            read -p "Which partition number should be used for boot? (usually 1) " bootno
            clear
            read -p "Which partition number should be used for swap? " swapno
            clear
            loop=1
            while [[ $loop == 1 ]]; do
                clear
                echo -e '\e[3m'"Format the boot partition? This will remove all data on the partition!"'\e(B\e[m'
                echo
                echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes, format it"
                echo -e '\e[36m'"[N]" '\e(B\e[m'"No, keep existing data (may cause issues)"
                read -n 1 choice
                case $choice in
                    y|Y)
                        formboot=1
                        loop=0
                        ;;
                    n|N)
                        formboot=0
                        loop=0
                        ;;
                    *)
                        ;;
                esac
            done
            # Handles different partition names (sda/vda vs nvme/mmcblk)
            if [[ "$disk" == *"d"* ]]; then
                root="${disk}${rootno}"
                boot="${disk}${bootno}"
                swap="${disk}${swapno}"
            else
                root="${disk}p${rootno}"
                boot="${disk}p${bootno}"
                swap="${disk}p${swapno}"
            fi
            loop=1
            while [[ $loop == 1 ]]; do
                clear
                echo "Root partition: /dev/$root"
                echo "Boot partition: /dev/$boot"
                echo "Swap partition: /dev/$swap"
                case $formboot in
                    0)
                        echo "Format boot partition: No"
                        ;;
                    1)
                        echo "Format boot partition: Yes"
                        ;;
                esac
                echo
                echo -e '\e[3m'"Are you sure these options are correct?"'\e(B\e[m'
                echo
                echo -e '\e[36m'"[Y]" '\e(B\e[m'"Yes, continue"
                echo -e '\e[36m'"[N]" '\e(B\e[m'"No, change my options"
                echo -e '\e[36m'"[Q]" '\e(B\e[m'"Cancel installation"
                read -n 1 choice
                case $choice in
                    y|Y)
                        menu=0
                        loop=0
                        ;;
                    n|N)
                        loop=0
                        ;;
                    q|Q)
                        exit 1
                        ;;
                    *)
                        ;;
                esac
            done
        done
        clear
        echo "Starting installation in 5 seconds..."
        sleep 1
        clear
        echo "Starting installation in 4 seconds..."
        sleep 1
        clear
        echo "Starting installation in 3 seconds..."
        sleep 1
        clear
        echo "Starting installation in 2 seconds..."
        sleep 1
        clear
        echo "Starting installation in 1 second..."
        sleep 1
        clear
        ;;
esac

case $crypt in
    0)
        # Format root partition (no encryption)
        if [[ $rootfs == "ext4" ]]; then
            mkfs.$rootfs /dev/$root
        else
            mkfs.$rootfs -f /dev/$root
        fi
        # Mount root partition to /mnt
        mount /dev/$root /mnt
        ;;
    1)
        # Format and encrypt root partition
        printf "%s" "$cryptpass" | cryptsetup -v --batch-mode luksFormat /dev/$root -
        printf "%s" "$cryptpass" | cryptsetup open /dev/$root root -
        mkfs.$rootfs /dev/mapper/root
        # Mount root partition to /mnt
        mount /dev/mapper/root /mnt
        ;;
esac
if [[ $formboot == 1 ]]; then
    # Format ESP
    mkfs.fat -F32 /dev/$boot
fi
# Mount ESP to /mnt/boot
mount --mkdir /dev/$boot /mnt/boot
# Format and activate swap partition
mkswap /dev/$swap
swapon /dev/$swap
# Install packages
pacstrap -K /mnt $pkglist
# Configure filesystem mount points
genfstab -U /mnt >> /mnt/etc/fstab
# Set language and keyboard layout
echo "en_${reg}.UTF-8 UTF-8" > /mnt/etc/locale.gen
echo "LANG=en_${reg}.UTF-8" > /mnt/etc/locale.conf
if [[ $reg == "GB" ]]; then
    echo "KEYMAP=uk" > /mnt/etc/vconsole.conf
fi
# Set hostname
echo $hname > /mnt/etc/hostname
if [[ $uefiboot == 1 ]]; then
    # Create EFI boot point
    cp /mnt/usr/share/limine/BOOTX64.EFI /mnt/boot/
fi
if [[ $biosboot == 1 ]]; then
    # Create BIOS boot point
    cp /mnt/usr/share/limine/limine-bios.sys /mnt/boot/
fi
# Get root partition UUID
uuid=$(blkid -s UUID -o value /dev/$root)
# Enable initramfs hooks
case $crypt in
    0)
        sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect keyboard keymap consolefont modconf block filesystems fsck)/' /mnt/etc/mkinitcpio.conf
        ;;
    1)
        sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt sd-encrypt filesystems fsck)/' /mnt/etc/mkinitcpio.conf
        ;;
esac
# Configure bootloader
touch /mnt/boot/limine.conf
case $bootmenu in
    0)
        echo "timeout: 0" >> /mnt/boot/limine.conf
        ;;
    1)
        echo "timeout: 10" >> /mnt/boot/limine.conf
        ;;
esac
echo "" >> /mnt/boot/limine.conf
echo "/Arch Linux" >> /mnt/boot/limine.conf
echo "    protocol: linux" >> /mnt/boot/limine.conf
echo "    path: boot():/vmlinuz-linux" >> /mnt/boot/limine.conf
case $crypt in
    0)
        echo "    cmdline: root=UUID=${uuid} zswap.enabled=0 rw rootfstype=${rootfs} quiet splash" >> /mnt/boot/limine.conf
        ;;
    1)
        echo "    cmdline: cryptdevice=UUID=${uuid}:root root=/dev/mapper/root rw rootfstype=${rootfs} quiet splash" >> /mnt/boot/limine.conf
        ;;
esac
echo "    module_path: boot():/initramfs-linux.img" >> /mnt/boot/limine.conf
touch /mnt/etc/default/limine
echo "ESP_PATH=/boot" >> /mnt/etc/default/limine
# Edit pacman configuration
sed -i "s/#Color/Color/" /mnt/etc/pacman.conf
sed -i "s/ParallelDownloads = 5/ParallelDownloads = 1/" /mnt/etc/pacman.conf
sed -i "s/#NoProgressBar/ILoveCandy/" /mnt/etc/pacman.conf
sed -i '/\[multilib\]/,/Include/ s/^#//' /mnt/etc/pacman.conf
# Edit sudo configuration
sed -i 's/^# \(%wheel ALL=(ALL:ALL) NOPASSWD: ALL\)/\1/' /mnt/etc/sudoers

cp ./* /mnt
if [[ $rootpass == "" ]]; then
    # Disable root account
    arch-chroot /mnt passwd -l root
else
    # Set root password
    arch-chroot /mnt chpasswd <<< "root:$rootpass"
fi
# Add user
arch-chroot /mnt useradd -m -G wheel $uname
# Set full name
arch-chroot /mnt chfn -f "$fullname" $uname
# Set password
arch-chroot /mnt chpasswd <<< "$uname:$pass"
# Run child script within chroot
arch-chroot /mnt bash ./jdai-efi-2.sh
# Edit sudo configuration
sed -i 's/^\(%wheel ALL=(ALL:ALL) NOPASSWD: ALL\)/# \1/' /mnt/etc/sudoers
sed -i 's/^# \(%wheel ALL=(ALL:ALL) ALL\)/\1/' /mnt/etc/sudoers

loop=1
while [[ $loop == 1 ]]; do
    clear
    echo -e '\e[3m'"Installation is complete!"'\e(B\e[m'
    echo -e '\e[3m'"What would you like to do?"'\e(B\e[m'
    echo
    echo -e '\e[36m'"[1]" '\e(B\e[m'"Reboot now"
    echo -e '\e[36m'"[2]" '\e(B\e[m'"Exit to shell"
    echo -e '\e[36m'"[3]" '\e(B\e[m'"Clean up and exit (ideal for rerunning the installer)"
    read -n 1 choice
    case $choice in
        1)
            reboot
            loop=0
            ;;
        2)
            clear
            loop=0
            ;;
        3)
            set +e
            umount /mnt/boot
            umount /mnt
            swapoff -a
            cryptsetup close /dev/mapper/root
            set -e
            clear
            loop=0
            ;;
        *)
            ;;
    esac
done
