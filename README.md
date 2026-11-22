# jdae

A modified version of the Arch Linux live environment which runs a custom install script on startup.
> [!IMPORTANT]
> The .sh files in this repo are for building the system yourself! Precompiled .iso downloads can be found under Releases.

## System requirements
Resource | Minimum | Recommended
--- | --- | ---
CPU | Any x86_64 CPU | 4 threads, 2GHz
GPU | Any | 2GB VRAM; supports OpenGL 4+, OpenCL 2+, and Vulkan
RAM | ~1GB | 4GB
Storage | ~4GB | 64GB

## Support for new users
>[!TIP]
> A guide to helpful programs and commands can be found [here](SUPPORT.md).

## Known issues:
> [!NOTE]
> Issues under Miscallaneous are bugs in other programs which cannot be fixed within the installer.
### Installer-related:
- Selecting "Other" for GPU drivers can install the default drivers instead (usually Nvidia).
- Some UEFI systems do not detect the boot entry for Arch. This is rare, but requires you to add a boot entry manually.
### Miscallaneous:
- Winboat may not recognise Docker until `sudo systemctl start docker` is run.
- Packages may fail to install due to a held lock. This can be fixed by running `rm -f ~/.gnupg/public-keys.d/pubring.db.lock`.
