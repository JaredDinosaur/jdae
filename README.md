# jdae

A modified version of the Arch Linux live environment which runs a custom install script on startup.

The .sh files in the repo are for building the system yourself! Precompiled .iso downloads can be found under releases.

## Known issues:
### Installer-related:
- On some machines, especially VMs, the installer may fail to mount /mnt/boot on its first try. If the installation is run again, it works. The reason for this is currently unknown.
- XFS can rarely fail to format on unencrypted, non-empty disks.
- The internet connection test may sometimes fail when a connection is present.
- Selecting "Other" for GPU drivers can install the default drivers instead (usually Nvidia).
- Proton VPN and Bottles may fail to install. They can be installed manually by running `flatpak install com.protonvpn.www -y` and `flatpak install com.usebottles.bottles` respectively after rebooting.
### Miscallaneous:
- Winboat does not recognise Docker until `sudo systemctl start docker` is run.
- Plasma can start in big picture mode on the first login. Before you log in, select "Plasma (Wayland)" in the menu on the top left of the screen.
- Packages may fail to install due to a held lock. This can be fixed by running `rm -f ~/.gnupg/public-keys.d/pubring.db.lock`.
