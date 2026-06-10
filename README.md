# jdae

A modified version of the Arch Linux live environment which runs a custom install script on startup.

The .sh files in the repo are for building the system yourself! Precompiled .iso downloads can be found under releases.

## Known issues:
- On some machines, especially VMs, the installer may fail to mount /mnt/boot on its first try. If the installation is run again, it works. The reason for this is currently unknown.
- XFS can rarely fail to format on unencrypted, non-empty disks.
- The internet connection test may sometimes fail when a connection is present.
- Selecting "Other" for GPU drivers can install the default drivers instead (usually Nvidia).
