# Support for new users

## Dual booting

**If you are planning to only run one operating system on your machine, you may [skip this section](https://github.com/JaredDinosaur/jdae/blob/main/SUPPORT.md#apps).**

### Disk Preparation
Ensure you have an empty disk to install Linux on.

**It is not recommended to dual boot Linux and another operating system on the same disk!**

This is because you will have less disk space and the different systems can interfere with each other.

If you have no other choice, make sure to create free space on your disk by shrinking your current system.

You can do this in Windows by right-clicking on the Windows icon and selecting Disk Management.

During the installation, you will have to select Manual configuration for your partitioning method if you are dualbooting on a single disk.

### Encryption (prevent Windows from bricking itself)
If you are not dualbooting alongside Windows, this section may be skipped.

Some Windows systems can automatically activate device encryption or BitLocker. This asks for a key when Secure Boot is disabled, and you may not know the key.

You can check your Windows edition in Settings > System > About > Windows info

Check if device encryption or BitLocker is enabled:

Windows edition | How to check
--- | ---
Windows 8/8.1/10/11 Pro, Education or Enterprise | Control Panel > System and Security > Manage BitLocker
Windows 10/11 Home | Settings > Privacy and Security > Device Encryption
Other | No checking is needed, automatic device encryption does not exist

If the setting doesn't exist, you don't need to worry about this.

**If device encryption or BitLocker is enabled, either disable it or ensure you know the recovery key (i.e. by writing it down).**

### Secure Boot
Some systems have Secure Boot enabled, which makes it difficult for most Linux environments to boot.

In your BIOS/UEFI settings, check whether Secure Boot is enabled.

If it is enabled, you must disable it or configure it to accept JDAE.

### Boot entry detection
If you choose to show the boot menu, you may want to add other systems you have installed (such as Windows).

To do this, run the following commands in the terminal:

`yay -S --needed --noconfirm limine-entry-tool` - Install the boot entry detector. This should take less than five minutes.

`sudo limine-scan` - Run the boot entry detector. This finds other installed systems and asks which one to add to the boot menu.

## Apps
**This is not Windows! .exe files will not run by themselves!**

You can use compatibility tools like WINE, Winboat and Bottles to run .exe files.

### Preinstalled
Program | App description
--- | ---
Discover | Install, remove and manage software
Dolphin, Thunar | Browse your files
Firefox, Brave, Zen Browser, Helium Browser, Mullvad Browser | Browse the internet
Konsole, Kitty, Xfce Terminal | Use the command line
KWrite | Basic text editor
Kate | Advanced text editor, good for programming
ClamTK | Antivirus manager
System Monitor | View and monitor system resources, similar to Task Manager
KDE Partition Manager, GParted | Manage disks, partitions, and filesystems
Timeshift | Create, restore and manage backups
Steam, Lutris | Game launcher
Winboat, Bottles | Run Windows programs
Filelight | Storage manager and disk usage viewer

### Available in Discover
Program | App description
--- | ---
Spotify | Stream music
Sober | Play Roblox
GNU Image Manipulation Program | Create and edit images
OBS Studio | Broadcast and record videos
Discord | Voice and text chat
Audacity | Edit and record audio
Minecraft Bedrock Launcher | Play Minecraft: Bedrock Edition
Heroic | Play Epic, GOG and Amazon games
LibreOffice | Office suite
Proton VPN | Free VPN
Kdenlive | Video editor
Prism Launcher | Minecraft mod and installation manager
Whatsie | WhatsApp client
Minecraft | Official Minecraft launcher
PCSX2 | PlayStation 2 emulator
Dolphin Emulator | GameCube/Wii emulator
Visual Studio Code | Code editor and IDE
Warpinator | Easy network file sharing
Waydroid | Run Android apps natively
Modrinth | Minecraft mod manager

and many more...

## Terminal commands

### Software and firmware management
There are two main program types, regular packages and Flatpak packages.

Regular packages are managed with yay, and Flatpak packages are managed with flatpak.

Both can be managed seamlessly in the Discover app.

Some programs are available as both a regular and Flatpak package.

Regular packages have short names, whereas Flatpak names are formatted like URLs.

For example, to install Discord:

As a regular package - `yay -S discord`

As a Flatpak package - `flatpak install com.discordapp.Discord`

Both package managers can be used to install several packages at once:

`yay -S <package1> <package2> <package3> <etc...>`

`flatpak install <package1> <package2> <package3> <etc...>`

After performing a full system upgrade or updating firmware, it is strongly recommended to reboot your system.

Command | Description
--- | ---
`yay -S <package>` | Install or update a package
`flatpak install <package>` | Install or update a package
`yay -R <package>` | Remove a package
`flatpak uninstall <package>` | Remove a package
`yay -s <term>` | Search for a package
`flatpak search <term>` | Search for a package
`yay -Syu` or just `yay` | Upgrade all packages
`flatpak update` | Upgrade all packages
`yay -Scc` | Clear cache (this can free up disk space and solve some issues)
`yay -Syy` | Synchronise package databases
`sudo fwupdmgr get-updates` | Check for available firmware updates
`sudo fwupdmgr upgrade` | Install available firmware updates

### Credential management
Command | Description
--- | ---
`passwd` | Change your password
`sudo passwd` | Change the password for the root account
`sudo cryptsetup luksChangeKey /dev/<part>` | Change the encryption password of a disk or partition
`chfn -f <name>` | Change your user's full name

### File management
Command | Description
--- | ---
`ls` | Display the contents of the current directory
`cd <location>` | Move into a directory
`touch <file>` | Create an empty file
`mkdir <folder>` | Create a directory
`rm <file>` | Delete a file
`rm -r <folder>` | Delete a directory
`cp <file> <location>` | Copy a file to a certain location
`cp -r <folder> <location>` | Copy a directory to a certain location
`mv <file> <location>` | Move a file to a certain location
`mv -r <folder> <location>` | Move a directory to a certain location
`cat <file>` | Display the contents of a file
`nano <file>` | View and edit a file's contents
`tree` | Display the contents of the current directory and all its subfolders

### Miscallaneous
Command | Description
--- | ---
`sudo <command>` | Run a command with admin permissions
`man <command>` | Display help on how to use a command
`clear` | Clear the screen
`echo <text>` | Display text
`fastfetch` | Display information about your machine
`btop` | View system resource usage
`nmtui` | Manage network connections
`sudo freshclam` | Update antivirus databases
`sudo clamscan <file>` | Scan a file for malware
`sudo clamscan -r <folder>` | Scan a directory for malware
`sudo systemctl start <service>` | Start a system service
`sudo systemctl enable <service>` | Enable a system service
`sudo systemctl enable --now <service>` | Enable and start a system service
`wget <url>` | Download the contents of a webpage

## Terminal keyboard shortcuts

Shortcut | Description
--- | ---
Ctrl + C | Stop the current running process (cancel a command)
Ctrl + I | Command completion, the same as pressing Tab
Ctrl + L | Clear the screen, the same as running `clear`
Ctrl + R | Search through previously run commands
Ctrl + Z | Place the current running process in the background

## Other resources

Google is your friend! It's okay to look things up if you don't know what to do.

For most questions you may have for a program, `man <program>` or the [Arch wiki](https://wiki.archlinux.org/title/Main_page) will have the answer.

It is not recommended to rely on AI for support as it can often make mistakes, which could potentially lead to you breaking your system.
