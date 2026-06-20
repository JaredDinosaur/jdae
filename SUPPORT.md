# Support for new users

## Apps

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
LibreOffice | Office suite
Heroic | Play Epic, GOG and Amazon games
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

## Terminal commands

### Software management
There are two main program types, regular packages and Flatpak packages.

Regular packages are managed with yay, and Flatpak packages are managed with flatpak.

Both can be managed seamlessly in the Discover app.

Some programs are available as both a regular and Flatpak package.

Regular packages have short names, whereas Flatpak names are formatted like urls.

For example, to install Discord:

As a regular package - `yay -S discord`

As a Flatpak package - `flatpak install com.discordapp.Discord`

Both package managers can be used to install several packages at once:

`yay -S <package1> <package2> <package3> <etc...>`

`flatpak install <package1> <package2> <package3> <etc...>`

After performing a full system upgrade, it is recommended to reboot your system.

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
