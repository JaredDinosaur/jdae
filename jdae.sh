#!/bin/bash
setlocale(){
    loop=1
    clear
    while [[ $loop == 1 ]]; do
        choice=$(gum choose "Tiny" "Small (HD default)" "Regular" "Large (4K default)" "Huge" "Colossal" "Done" --header="Select a font size, then select Done to continue: ")
        case $choice in
            "Tiny")
                setfont drdos8x8
                clear
                ;;
            "Small (HD default)")
                setfont
                clear
                ;;
            "Regular")
                setfont ter-124b
                clear
                ;;
            "Large (4K default)")
                setfont ter-132b
                clear
                ;;
            "Huge")
                setfont ter-124b -d
                clear
                ;;
            "Colossal")
                setfont ter-132b -d
                clear
                ;;
            "Done")
                if (( $(tput cols) < 90 )); then
                    clear
                    echo
                    echo "The screen must be at least 90 characters wide!"
                    echo "Please choose a smaller font!"
                    echo
                else
                    loop=0
                fi
                ;;
        esac
    done
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        choice=$(gum choose "English - United Kingdom (default)" "English - United States" --header="Select your locale:")
        case $choice in
            "English - United Kingdom (default)")
                keys="uk"
                reg="GB"
                loop=0
                ;;
            "English - United States")
                keys="--default"
                reg="US"
                loop=0
                ;;
            *)
                ;;
        esac
    done
    loadkeys $keys
}

diskpart(){
    loop=1
    clear
    while [[ $loop == 1 ]]; do
        echo "Available disks:"
        echo
        # List available disks
        #lsblk -d -o NAME,SIZE,LABEL
        hwinfo --disk --short
        echo
        echo "Recommended minimum disk space: 64GB for VMs, 128GB for real hardware"
        disk=$(gum input --prompt="The disk to install to is /dev/___: ")

        # Check that disk exists and is writable
        if ! [[ -b /dev/$disk ]]; then
            clear
            echo
            echo "Disk /dev/$disk does not exist!"
            echo
        else
            if ! [[ -w /dev/$disk ]]; then
                clear
                echo
                echo "Disk /dev/$disk is not writable!"
                echo "Check that the disk is not in use!"
                echo
            else
                disksize=$(blockdev --getsize64 /dev/$disk)
                if (( $disksize < $mindisk )); then
                    echo
                    echo -e '\e[31m'"WARNING: This disk is too small for your selected set of packages!"'\e(B\e[m'
                    echo -e '\e[31m'"The minimum recommended disk size for your set of packages is ${mingb}GB!"
                    echo -e '\e[31m'"It is very likely that you will encounter errors during installation!"
                    echo -e '\e[31m'"Choose another set of packages if you cannot use another disk!"
                fi
                echo
                echo -e '\e[3m'"The contents of disk /dev/$disk will be changed or erased!"'\e(B\e[m'
                echo -e '\e[3m'"Double check that you have selected the correct disk!"'\e(B\e[m'
                choice=$(gum choose "I understand, continue" "Choose another disk" "Cancel the installation (power off)" --header="Are you sure you want to continue?")
                case $choice in
                    "I understand, continue")
                        loop=0
                        ;;
                    "Cancel the installation (power off)")
                        poweroff
                        exit 1
                        ;;
                    *)
                        clear
                        ;;
                esac
            fi
        fi
    done
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        choice=$(gum choose "Automatic partition layout (uses entire disk)" "Manual configuration" --header="Choose a partitioning method:")
        case $choice in
            "Automatic partition layout (uses entire disk)")
                rootno=3
                bootno=1
                swapno=2
                formboot=1
                manpart=0
                loop=0
                ;;
            "Manual configuration")
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
        choice=$(gum choose "ext4 (default)" "btrfs" "xfs" "Help" --header="Choose a root filesystem:")
        case $choice in
            "ext4 (default)")
                rootfs="ext4"
                loop=0
                ;;
            "btrfs")
                rootfs="btrfs"
                loop=0
                ;;
            "xfs")
                rootfs="xfs"
                loop=0
                ;;
            "Help")
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
                echo "High performance filesystem. Good for servers and large drives, but cannot be shrunk."
                echo
                echo -e '\e[3m'"Press any key to continue..."'\e(B\e[m'
                read -n 1
                ;;
            *)
                ;;
        esac
    done
    loop=1
    while [[ $loop == 1 ]]; do
        clear
        choice=$(gum choose "Yes" "No" "Help" --header="Would you like to encrypt your root partition?")
        case $choice in
            "Yes")
                crypt=1
                clear
                valid=0
                while [[ $valid == 0 ]]; do
                    cryptpass=$(gum input --prompt="Enter the encryption password: " --password)
                    if [[ $cryptpass == "" ]]; then
                        clear
                        echo "Password cannot be blank!"
                        echo
                    else
                        clear
                        cryptconf=$(gum input --prompt="Confirm password: " --password)
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
            "No")
                crypt=0
                loop=0
                ;;
            "Help")
                clear
                echo -e '\e[3m'"Help page: Disk Encryption"'\e(B\e[m'
                echo
                echo "This will ask you for an encryption password every time you start your machine."
                echo "Files on your main partition will be inaccessible without the key, making your system more secure."
                echo "This may cause issues with some boot animations, and your main partition cannot be unlocked if you forget the key."
                echo
                echo -e '\e[3m'"Press any key to continue..."'\e(B\e[m'
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
        choice=$(gum choose "Desktop with Plasma (default)" "Desktop with Hyprland" "Desktop with Xfce" "Desktop with LXQt" "Command line" "Minimal" "Help" --header="Choose a set of packages:")
        case $choice in
            "Desktop with Plasma (default)")
                pkglist="base linux linux-firmware filelight flatpak screenfetch fastfetch tree htop btop partitionmanager plymouth dolphin discover packagekit packagekit-qt6 plasma sddm vlc iwd git nano kate ark konsole dialog limine sudo efibootmgr networkmanager network-manager-applet base-devel blueman btrfs-progs dosfstools e2fsprogs xfsprogs clamav clamtk power-profiles-daemon man sl"
                profile="Desktop (Plasma)"
                loop=0
                ;;
            "Desktop with Hyprland")
                pkglist="base linux linux-firmware filelight flatpak screenfetch fastfetch tree htop btop partitionmanager plymouth dolphin discover packagekit packagekit-qt6 vlc iwd hyprland kitty wofi waybar hyprpaper git nano kate ark konsole dialog sddm limine sudo efibootmgr networkmanager network-manager-applet base-devel blueman dunst wireplumber noto-fonts pipewire-pulse nerd-fonts sof-firmware sddm-kcm plymouth-kcm systemsettings breeze breeze-cursors breeze-plymouth flatpak-kcm plasma-integration btrfs-progs dosfstools e2fsprogs xfsprogs clamav clamtk man sl"
                profile="Desktop (Hyprland)"
                loop=0
                ;;
            "Desktop with Xfce")
                pkglist="base linux linux-firmware filelight flatpak screenfetch fastfetch tree htop btop xfce4 xfce4-goodies gparted plymouth thunar discover packagekit packagekit-qt6 vlc iwd git nano dialog lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings limine sudo efibootmgr networkmanager network-manager-applet base-devel blueman btrfs-progs dosfstools e2fsprogs xfsprogs clamav clamtk man sl"
                profile="Desktop (Xfce)"
                loop=0
                ;;
            "Desktop with LXQt")
                pkglist="base linux linux-firmware filelight flatpak screenfetch fastfetch tree htop btop partitionmanager plymouth thunar discover packagekit packagekit-qt6 lxqt vlc iwd git nano kate ark dialog lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings limine sudo efibootmgr networkmanager network-manager-applet base-devel blueman btrfs-progs dosfstools e2fsprogs xfsprogs clamav clamtk man sl"
                profile="Desktop (LXQt)"
                loop=0
                ;;
            "Command line")
                pkglist="base linux linux-firmware screenfetch fastfetch tree htop plymouth iwd python git nano dialog limine sudo efibootmgr networkmanager base-devel blueman btrfs-progs dosfstools e2fsprogs xfsprogs clamav man sl"
                profile="Command line"
                loop=0
                ;;
            "Minimal")
                pkglist="base linux linux-firmware git iwd python nano limine sudo efibootmgr networkmanager base-devel"
                profile="Minimal"
                loop=0
                ;;
            "Help")
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
                echo -e '\e[3m'"Press any key to continue..."'\e(B\e[m'
                read -n 1
                ;;
            *)
                ;;
        esac
    done

    clear
    echo "Calculating the minimum required disk space..."

    expkglist=$(
        for pkg in $pkglist; do
            if pacman -Sgq "$pkg" >/dev/null 2>&1; then
                pacman -Sgq "$pkg"
            else
                printf '%s\n' "$pkg"
            fi
        done | sort -u | xargs
    )

    set +e
    dlsize=$(pacman -Si $expkglist | awk '/Download Size/ {sum += $4 * ($5 == "MiB" ? 1024*1024 : $5 == "KiB" ? 1024 : 1)} END {print int(sum)}')
    insize=$(pacman -Si $expkglist | awk '/Installed Size/ {sum += $4 * ($5 == "MiB" ? 1024*1024 : $5 == "KiB" ? 1024 : 1)} END {print int(sum)}')
    ram=$(grep MemTotal /proc/meminfo | awk '{print $2 * 1024}')
    mindisk=$((dlsize+insize+ram+9487198679))
    mingb=$(awk -v num="$mindisk" 'BEGIN { print int((num / (1024^3)) + 0.5) }')
    set -e

    browser="Firefox"
    browserpkg="firefox firefox-i18n-uk firefox-ublock-origin"
    getwinfs=0
    getf2fs=0
    getapplefs=0
    getjfs=0
    getudf=0
    getzfs=0
    getsteam=0
    getlutris=0
    getwinboat=0
    getbottles=0
    gpudrv=0
    gpuconf="None"
    gettimeshift=0
    getvpn=0

    loop=1
    while [[ $loop == 1 ]]; do
        clear
        echo -e '\e[3m'"--------------Extra packages menu----------------"'\e(B\e[m'
        echo -e '\e[3m'"Select an option to change whether to install it."'\e(B\e[m'
        echo -e '\e[3m'"It's strongly recommended to select a GPU driver."'\e(B\e[m'
        echo -e '\e[3m'"-------------------------------------------------"'\e(B\e[m'
        echo
        echo -e '\e[36m'"[1]" '\e(B\e[m'"Web browser: $browser"
        echo -e '\e[36m'"[2]" '\e(B\e[m'"Filesystem utilities:"
        if [[ $getwinfs == 0 ]]; then
            echo -e '\e[35m'"==>" '\e(B\e[m'"Windows filesystems (NTFS and exFAT): No"
        else
            echo -e '\e[35m'"==>" '\e(B\e[m'"Windows filesystems (NTFS and exFAT): Yes"
        fi
        if [[ $getapplefs == 0 ]]; then
            echo -e '\e[35m'"==>" '\e(B\e[m'"macOS filesystems (HFS and APFS): No"
        else
            echo -e '\e[35m'"==>" '\e(B\e[m'"macOS filesystems (HFS and APFS): Yes"
        fi
        if [[ $getzfs == 0 ]]; then
            echo -e '\e[35m'"==>" '\e(B\e[m'"ZFS (high performance filesystem): No"
        else
            echo -e '\e[35m'"==>" '\e(B\e[m'"ZFS (high performance filesystem): Yes"
        fi
        if [[ $getf2fs == 0 ]]; then
            echo -e '\e[35m'"==>" '\e(B\e[m'"f2fs (SSD-friendly filesystem): No"
        else
            echo -e '\e[35m'"==>" '\e(B\e[m'"f2fs (SSD-friendly filesystem): Yes"
        fi
        if [[ $getudf == 0 ]]; then
            echo -e '\e[35m'"==>" '\e(B\e[m'"UDF (DVD filesystem): No"
        else
            echo -e '\e[35m'"==>" '\e(B\e[m'"UDF (DVD filesystem): Yes"
        fi
        if [[ $getjfs == 0 ]]; then
            echo -e '\e[35m'"==>" '\e(B\e[m'"JFS (IBM filesystem): No"
        else
            echo -e '\e[35m'"==>" '\e(B\e[m'"JFS (IBM filesystem): Yes"
        fi
        echo -e '\e[36m'"[3]" '\e(B\e[m'"Gaming packages:"
        if [[ $getsteam == 0 ]]; then
            echo -e '\e[35m'"==>" '\e(B\e[m'"Steam: No"
        else
            echo -e '\e[35m'"==>" '\e(B\e[m'"Steam: Yes"
        fi
        if [[ $getlutris == 0 ]]; then
            echo -e '\e[35m'"==>" '\e(B\e[m'"Lutris (game manager): No"
        else
            echo -e '\e[35m'"==>" '\e(B\e[m'"Lutris (game manager): Yes"
        fi
        if [[ $getwinboat == 0 ]]; then
            echo -e '\e[35m'"==>" '\e(B\e[m'"Winboat (run Windows apps on Linux): No"
        else
            echo -e '\e[35m'"==>" '\e(B\e[m'"Winboat (run Windows apps on Linux): Yes"
        fi
        echo -e '\e[36m'"[4]" '\e(B\e[m'"GPU Driver: $gpuconf"
        if [[ $gettimeshift == 0 ]]; then
            echo -e '\e[36m'"[5]" '\e(B\e[m'"Timeshift (backup utility): No"
        else
            echo -e '\e[36m'"[5]" '\e(B\e[m'"Timeshift (backup utility): Yes"
        fi
        echo
        echo -e '\e[36m'"[0]" '\e(B\e[m'"Done"
        read -n 1 choice
        case $choice in
            1)
                clear
                choice=$(gum choose "Firefox (default)" "Brave" "Zen Browser" "Helium Browser" "Mullvad Browser" "None" --header="Choose a web browser:")
                case $choice in
                    "Firefox (default)")
                        browser="Firefox"
                        browserpkg="firefox firefox-i18n-uk firefox-ublock-origin"
                        ;;
                    "Brave")
                        browser="Brave"
                        browserpkg="brave-bin"
                        ;;
                    "Zen Browser")
                        browser="Zen Browser"
                        browserpkg="zen-browser-bin firefox-ublock-origin"
                        ;;
                    "Helium Browser")
                        browser="Helium Browser"
                        browserpkg="helium-browser-bin"
                        ;;
                    "Mullvad Browser")
                        browser="Mullvad Browser"
                        browserpkg="mullvad-browser-bin firefox-ublock-origin"
                        ;;
                    "None")
                        browser="None"
                        browserpkg=""
                        ;;
                esac
                ;;
            2)
                submenu=1
                while [[ $submenu == 1 ]]; do
                    clear
                    echo -e '\e[3m'"Filesystem utilities:"'\e(B\e[m'
                    echo
                    if [[ $getwinfs == 0 ]]; then
                        echo -e '\e[36m'"[1]" '\e(B\e[m'"Windows filesystems (NTFS and exFAT): No"
                    else
                        echo -e '\e[36m'"[1]" '\e(B\e[m'"Windows filesystems (NTFS and exFAT): Yes"
                    fi
                    if [[ $getapplefs == 0 ]]; then
                        echo -e '\e[36m'"[2]" '\e(B\e[m'"macOS filesystems (HFS and APFS): No"
                    else
                        echo -e '\e[36m'"[2]" '\e(B\e[m'"macOS filesystems (HFS and APFS): Yes"
                    fi
                    if [[ $getzfs == 0 ]]; then
                        echo -e '\e[36m'"[3]" '\e(B\e[m'"ZFS (high performance filesystem): No"
                    else
                        echo -e '\e[36m'"[3]" '\e(B\e[m'"ZFS (high performance filesystem): Yes"
                    fi
                    if [[ $getf2fs == 0 ]]; then
                        echo -e '\e[36m'"[4]" '\e(B\e[m'"f2fs (SSD-friendly filesystem): No"
                    else
                        echo -e '\e[36m'"[4]" '\e(B\e[m'"f2fs (SSD-friendly filesystem): Yes"
                    fi
                    if [[ $getudf == 0 ]]; then
                        echo -e '\e[36m'"[5]" '\e(B\e[m'"UDF (DVD filesystem): No"
                    else
                        echo -e '\e[36m'"[5]" '\e(B\e[m'"UDF (DVD filesystem): Yes"
                    fi
                    if [[ $getjfs == 0 ]]; then
                        echo -e '\e[36m'"[6]" '\e(B\e[m'"JFS (IBM filesystem): No"
                    else
                        echo -e '\e[36m'"[6]" '\e(B\e[m'"JFS (IBM filesystem): Yes"
                    fi
                    echo -e '\e[36m'"[7]" '\e(B\e[m'"Yes to all"
                    echo -e '\e[36m'"[8]" '\e(B\e[m'"No to all"
                    echo
                    echo -e '\e[36m'"[0]" '\e(B\e[m'"Go back"
                    read -n 1 choice
                    case $choice in
                        1)
                            getwinfs=$((1 - getwinfs))
                            ;;
                        2)
                            getapplefs=$((1 - getapplefs))
                            ;;
                        3)
                            getzfs=$((1 - getzfs))
                            ;;
                        4)
                            getf2fs=$((1 - getf2fs))
                            ;;
                        5)
                            getudf=$((1 - getudf))
                            ;;
                        6)
                            getjfs=$((1 - getjfs))
                            ;;
                        7)
                            getwinfs=1
                            getf2fs=1
                            getapplefs=1
                            getjfs=1
                            getudf=1
                            getzfs=1
                            ;;
                        8)
                            getwinfs=0
                            getf2fs=0
                            getapplefs=0
                            getjfs=0
                            getudf=0
                            getzfs=0
                            ;;
                        0)
                            submenu=0
                            ;;
                    esac
                done
                ;;
            3)
                submenu=1
                while [[ $submenu == 1 ]]; do
                    clear
                    echo -e '\e[3m'"Gaming packages:"'\e(B\e[m'
                    echo
                    if [[ $getsteam == 0 ]]; then
                        echo -e '\e[36m'"[1]" '\e(B\e[m'"Steam: No"
                    else
                        echo -e '\e[36m'"[1]" '\e(B\e[m'"Steam: Yes"
                    fi
                    if [[ $getlutris == 0 ]]; then
                        echo -e '\e[36m'"[2]" '\e(B\e[m'"Lutris (game manager): No"
                    else
                        echo -e '\e[36m'"[2]" '\e(B\e[m'"Lutris (game manager): Yes"
                    fi
                    if [[ $getwinboat == 0 ]]; then
                        echo -e '\e[36m'"[3]" '\e(B\e[m'"Winboat (run Windows apps on Linux): No"
                    else
                        echo -e '\e[36m'"[3]" '\e(B\e[m'"Winboat (run Windows apps on Linux): Yes"
                    fi
                    echo -e '\e[36m'"[4]" '\e(B\e[m'"Yes to all"
                    echo -e '\e[36m'"[5]" '\e(B\e[m'"No to all"
                    echo
                    echo -e '\e[36m'"[0]" '\e(B\e[m'"Go back"
                    read -n 1 choice
                    case $choice in
                        1)
                            getsteam=$((1 - getsteam))
                            ;;
                        2)
                            getlutris=$((1 - getlutris))
                            ;;
                        3)
                            getwinboat=$((1 - getwinboat))
                            ;;
                        4)
                            getsteam=1
                            getlutris=1
                            getwinboat=1
                            ;;
                        5)
                            getsteam=0
                            getlutris=0
                            getwinboat=0
                            ;;
                        0)
                            submenu=0
                            ;;
                    esac
                done
                ;;
            4)
                submenu=1
                while [[ $submenu == 1 ]]; do
                    clear
                    echo -e '\e[3m'"Select your graphics card driver."'\e(B\e[m'
                    echo -e '\e[3m'"For Nvidia, proprietary drivers are better for more recent cards (GTX 1650 or newer)."'\e(B\e[m'
                    echo -e '\e[3m'"If your machine has no graphics card, select your CPU manufacturer."'\e(B\e[m'
                    choice=$(gum choose "Intel" "AMD (Radeon)" "Nvidia (Open Source)" "Nvidia (Proprietary)" "No Driver" --header="")
                    case $choice in
                        "Intel")
                            gpudrv=1
                            gpupkg="vulkan-intel xf86-video-intel lib32-vulkan-intel"
                            gpuconf="Intel"
                            submenu=0
                            ;;
                        "AMD (Radeon)")
                            gpudrv=1
                            gpupkg="vulkan-radeon xf86-video-amdgpu lib32-vulkan-radeon"
                            gpuconf="AMD (Radeon)"
                            submenu=0
                            ;;
                        "Nvidia (Open Source)")
                            gpudrv=1
                            gpupkg="vulkan-nouveau xf86-video-nouveau lib32-vulkan-nouveau"
                            gpuconf="Nvidia (Open Source)"
                            submenu=0
                            ;;
                        "Nvidia (Proprietary)")
                            gpudrv=1
                            gpupkg="nvidia nvidia-utils lib32-nvidia-utils"
                            gpuconf="Nvidia (Proprietary)"
                            submenu=0
                            ;;
                        "No Driver")
                            gpudrv=0
                            gpupkg=""
                            gpuconf="None"
                            submenu=0
                            ;;
                        *)
                            ;;
                    esac
                done
                ;;
            5)
                gettimeshift=$((1 - gettimeshift))
                ;;
            0)
                loop=0
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
        hname=$(gum input --prompt="Name your machine (letters, numbers and dashes): " --char-limit=32)
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
        rootpass=$(gum input --prompt="Enter the root password: " --password)
        if [[ $rootpass == "" ]]; then
            clear
            echo
            echo "This will disable the root account! Are you sure?"
            rootconf=$(gum input --prompt="Enter \"Yes, I understand\" to continue, or anything else to go back: " --placeholder="Yes, I understand")
            if [[ $rootconf == "Yes, I understand" ]]; then
                clear
                valid=1
            else
                clear
            fi
        else
            clear
            rootconf=$(gum input --prompt="Confirm password: " --password)
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
        uname=$(gum input --prompt="Name your user (single word, lowercase): " --char-limit=32)
        if [[ "$uname" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
            valid=1
        else
            clear
            echo "Invalid username!"
        fi
    done
    clear
    fullname=$(gum input --prompt="Enter your user's full name (can be multiple words): ")
    clear
    valid=0
    while [[ $valid == 0 ]]; do
        pass=$(gum input --prompt="Enter your user's password: " --password)
        if [[ $pass == "" ]]; then
            clear
            echo "Password cannot be blank!"
            echo
        else
            clear
            passconf=$(gum input --prompt="Confirm password: " --password)
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
        choice=$(gum choose "Yes" "No" --header="")
        case $choice in
            "Yes")
                bootmenu=1
                loop=0
                ;;
            "No")
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
        echo -e '\e[3m'"If you don't know what this means, just choose Yes."'\e(B\e[m'
        echo -e '\e[3m'"This machine is currently booted in $bootmode mode."'\e(B\e[m'
        choice=$(gum choose "Yes" "No" --header="Would you like to make your system bootable in both BIOS and UEFI mode?")
        case $choice in
            "Yes")
                if [[ $bootmode == "BIOS" ]]; then
                    uefiboot=1
                else
                    biosboot=1
                fi
                loop=0
                ;;
            "No")
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
    pacman -Syy &>/dev/null
    connect=$?
    if [[ $connect == 0 ]]; then
        echo "Connection test successful."
        quit=0
    else
        loop=1
        while [[ $loop == 1 ]]; do
            clear
            echo -e '\e[3m'"Internet connection not found! Would you like to connect to a wireless network?"'\e(B\e[m'
            echo -e '\e[3m'"If you are definitely connected to the internet, the Arch Linux servers may be down."'\e(B\e[m'
            choice=$(gum choose "List available wireless networks" "Cancel installation" "Attempt to continue anyway" --header="")
            case $choice in
                "List available wireless networks")
                    clear
                    iwlist=1
                    while [[ $iwlist == 1 ]]; do
                        # List available wireless networks
                        iface=$(iw dev | awk '$1=="Interface"{print $2; exit}')
                        if [[ $iface == "" ]]; then
                            echo "No wireless devices found!"
                            quit=1
                            loop=0
                            iwlist=0
                        else
                            iwctl station "$iface" get-networks
                            ssid=$(gum input --prompt="Enter the name of the network you wish to connect to: ")
                            # Connect to the selected network
                            iwctl station "$iface" connect "$ssid"
                            case $? in
                                0)
                                    echo "Connected successfully. The script will now restart."
                                    sleep 2
                                    iwlist=0
                                    logout
                                    ;;
                                *)
                                    clear
                                    echo
                                    echo "Could not connect to $ssid"
                                    echo "Please check that the network name and password were typed correctly."
                                    echo
                                    ;;
                            esac
                            quit=2
                            loop=0
                        fi
                    done
                    ;;
                "Cancel installation")
                    quit=1
                    loop=0
                    ;;
                "Attempt to continue anyway")
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
setlocale
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
# Edit pacman config
sed -i "s/#Color/Color/" /etc/pacman.conf
sed -i "s/ParallelDownloads = 5/ParallelDownloads = 1/" /etc/pacman.conf
sed -i "s/#NoProgressBar/ILoveCandy/" /etc/pacman.conf

set -euo pipefail

# Get options
pkgs
diskpart
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
    echo "GPU Driver:             $gpuconf"
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
    echo "----------------------------------------------------------------"
    echo
    choice=$(gum choose "Begin installation" "Cancel installation (power off)" "Exit to shell" "Change locale" "Change partitioning and encryption" "Change packages and drivers" "Change hostname" "Change username and authentication" "Change boot options" --header="Install with these options?")
    case $choice in
        "Begin installation")
            menu=0
            ;;
        "Cancel installation (power off)")
            poweroff
            ;;
        "Exit to shell")
            exit 1
            ;;
        "Change locale")
            setlocale
            ;;
        "Change partitioning and encryption")
            diskpart
            ;;
        "Change packages and drivers")
            pkgs
            ;;
        "Change hostname")
            sethostname
            ;;
        "Change username and authentication")
            user
            ;;
        "Change boot options")
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
systemctl enable clamav-clamonacc clamav-daemon clamav-freshclam
# Update clamav databases
freshclam
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

# Install selected extra packages
extrapkgs=""
extraflat=""
if [[ $browserpkg != "" ]]; then
    extrapkgs="$extrapkgs $browserpkg"
fi
if [[ $getwinfs == 1 ]]; then
    extrapkgs="$extrapkgs exfatprogs ntfs-3g ntfsprogs"
fi
if [[ $getapplefs == 1 ]]; then
    extrapkgs="$extrapkgs hfsprogs apfsprogs"
fi
if [[ $getzfs == 1 ]]; then
    extrapkgs="$extrapkgs zfs-utils"
fi
if [[ $getf2fs == 1 ]]; then
    extrapkgs="$extrapkgs f2fs-tools"
fi
if [[ $getudf == 1 ]]; then
    extrapkgs="$extrapkgs udftools"
fi
if [[ $getjfs == 1 ]]; then
    extrapkgs="$extrapkgs jfsutils"
fi
if [[ $getsteam == 1 ]]; then
    extrapkgs="$extrapkgs steam gamescope mesa"
fi
if [[ $getlutris == 1 ]]; then
    extrapkgs="$extrapkgs lutris"
fi
if [[ $getwinboat == 1 ]]; then
    extrapkgs="$extrapkgs winboat-bin docker docker-compose"
fi
if [[ $gpudrv == 1 ]]; then
    extrapkgs="$extrapkgs $gpupkg"
fi
if [[ $gettimeshift == 1 ]]; then
    extrapkgs="$extrapkgs timeshift btrfs-assistant btrfsmaintenance"
fi
if [[ $extrapkgs != "" ]]; then
    echo "yay -S --needed --noconfirm$extrapkgs" >> jdai-usr.sh
fi
if [[ $extrapkgs == *"docker"* ]]; then
    echo "sudo usermod -aG docker $uname" >> jdai-usr.sh
    echo "sudo systemctl enable docker" >> jdai-usr.sh
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
sudo mv /etc/sddm.conf.d /etc/sddm.conf
yay -R --noconfirm plasma-bigscreen
EOF
fi
# Install hyprland configuration files
if [[ $profile == "Desktop (Hyprland)" ]]; then
    cat >> jdai-usr.sh << "EOF"
cd ..
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
        ram=$(grep MemTotal /proc/meminfo | awk '{print int($2/512)}')
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
            loop=1
            while [[ $loop == 1 ]]; do
                rootno=$(gum input --prompt="Which partition number should be used for root? ")
                if [[ "$disk" == *"d"* ]]; then
                    root="${disk}${rootno}"
                else
                    root="${disk}p${rootno}"
                fi
                if ! [[ -e "/dev/$root" ]]; then
                    clear
                    echo
                    echo "Partition /dev/$root does not exist!"
                    echo
                else
                    loop=0
                fi
            done
            clear
            loop=1
            while [[ $loop == 1 ]]; do
                bootno=$(gum input --prompt="Which partition number should be used for boot? (usually 1) ")
                if [[ "$disk" == *"d"* ]]; then
                    boot="${disk}${bootno}"
                else
                    boot="${disk}p${bootno}"
                fi
                if ! [[ -e "/dev/$boot" ]]; then
                    clear
                    echo
                    echo "Partition /dev/$boot does not exist!"
                    echo
                else
                    loop=0
                fi
            done
            clear
            loop=1
            while [[ $loop == 1 ]]; do
                swapno=$(gum input --prompt="Which partition number should be used for swap? ")
                if [[ "$disk" == *"d"* ]]; then
                    swap="${disk}${swapno}"
                else
                    swap="${disk}p${swapno}"
                fi
                if ! [[ -e "/dev/$swap" ]]; then
                    clear
                    echo
                    echo "Partition /dev/$swap does not exist!"
                    echo
                else
                    loop=0
                fi
            done
            loop=1
            while [[ $loop == 1 ]]; do
                clear
                choice=$(gum choose "Yes, format it" "No, keep existing data" --header="Format the boot partition? This will remove all data on the partition!")
                case $choice in
                    "Yes, format it")
                        formboot=1
                        loop=0
                        ;;
                    "No, keep existing data")
                        formboot=0
                        loop=0
                        ;;
                    *)
                        ;;
                esac
            done
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
                choice=$(gum choose "Yes, continue" "No, change my options" "Cancel installation" --header="Are you sure these options are correct?")
                case $choice in
                    "Yes, continue")
                        menu=0
                        loop=0
                        ;;
                    "No, change my options")
                        loop=0
                        ;;
                    "Cancel installation")
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
    choice=$(gum choose "Reboot now" "Enter the system (as root)" "Enter the system (as your user)" "Exit to shell" "Clean up and exit" --header="Installation is complete! What would you like to do?")
    case $choice in
        "Reboot now")
            reboot
            loop=0
            ;;
        "Enter the system (as root)")
            arch-chroot /mnt
            reboot
            loop=0
            ;;
        "Enter the system (as your user)")
            arch-chroot -u $uname /mnt
            reboot
            loop=0
            ;;
        "Exit to shell")
            clear
            loop=0
            ;;
        "Clean up and exit")
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
