# jdae

A modified version of the Arch Linux live environment which runs a custom install script on startup.

The .sh files in the repo are for building the system yourself! Precompiled .iso downloads can be found under releases.

## System requirements
Resource | Minimum | Recommended
--- | --- | ---
CPU | Any x86_64 CPU | 4 threads, 2GHz
GPU | Any | 2GB VRAM; supports OpenGL 4+, OpenCL 2+, and Vulkan
RAM | 931MB | 4GB
Storage | 4GB | 64GB

## Support for new users
A guide to helpful programs and commands can be found [here](https://github.com/JaredDinosaur/jdae/blob/main/SUPPORT.md).

## Known issues:
Issues under Miscallaneous are bugs in other programs which cannot be fixed within the installer.
### Installer-related:
- On some machines, especially VMs, the installer may fail to mount /mnt/boot on its first try. If the installation is run again, it works. The reason for this is currently unknown.
- ext4 will ask for confirmation when overwriting an existing partition.
- XFS can rarely fail to format on unencrypted, non-empty disks.
- The internet connection test may sometimes fail when a connection is present.
- Selecting "Other" for GPU drivers can install the default drivers instead (usually Nvidia).
### Miscallaneous:
- Winboat may not recognise Docker until `sudo systemctl start docker` is run.
- Packages may fail to install due to a held lock. This can be fixed by running `rm -f ~/.gnupg/public-keys.d/pubring.db.lock`.
