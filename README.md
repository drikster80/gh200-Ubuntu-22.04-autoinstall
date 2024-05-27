# gh200-Ubuntu-22.04-autoinstall
Automated installation of GH200 system using Ubuntu 22.04 using USB drive

A lot of this came from the [Official Nvidia Ubuntu 22.04 Grace Installation Guide](https://docs.nvidia.com/grace-ubuntu-install-guide.pdf). If you have problems, please see that guide for more details.

This repo was created based on testing of the GH200 system (specifically the Supermicro ARS-111GL-NHR). The systems I'm testing on also have a Bluiefield-3 installed, but this should not matter for the installation.

The contained scripts will perform the following actions:

### During Installation:
- Create a new user (as defined by user)
- Make `linux-nvidia-64k-hwe-22.04` the default kernel
- Create a 12G "recovery partition"
- Install the [Nvidia CUDA SBSA repo](https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/sbsa/)
- Install the [Nvidia MLNX-OFED repo](https://linux.mellanox.com/public/repo/mlnx_ofed/latest/ubuntu22.04/arm64)
- Update/Upgrade all packages
- Install the First-boot service that will run on the first boot

### During First Boot of system
- Install cuda-drivers and nvidia-kernel-open drivers
- Install cuda-toolkit-12-4 nvidia-container-toolkit
- Install mlnx-fw-updater mlnx-ofed-all
- Update and enable the nvidia-persistenced service due to bug
- Disable the first-boot service
- Reboot the system

## Creating Installable USB drive via Rufus
There are multiple ways to create an installable Ubuntu 22.04 USB drive. I used [Rufus](https://rufus.ie/downloads/) on a Windows-11 system.

1. Download [Rufus Portable](https://github.com/pbatard/rufus/releases/download/v4.5/rufus-4.5p.exe) and the latest [Ubuntu-22.04.4 ISO](https://mirror.umd.edu/ubuntu-iso/22.04/ubuntu-22.04.4-live-server-amd64.iso).
2. Select USB drive.
3. Install as ISO (enuring you can modify the files on the USB afterwards)

## Customize the user-data file
Before copying over the files, you'll need to customize the cidata/user-data file with your installation details

Replace the following items:
| Item | Description |
| ----------- | ----------- |
| \<HOSTNAME> | Hostname of the system |
| \<PASSWORD> | Generated SHA-512 hash (can generate with `openssl passwd -6`) |
| \<USERNAME> | Initial User name |
| \<ADDRESS-CIDR> | Address of network port in CIDR form (e.g. 10.1.1.10/24) |
| \<GATEWAY-ADDRESS> | Address of network gateway |
| \<NAMESERVER-N> | Address of DNS Nameservers |
| \<SEARCH-DOMAIN> | DNS Search domain (e.g. my-domain.com)|


## Updating with CIDATA for auto-install
After creating a bootable Ubuntu installation drive, copy the files from cidata to the 

1. Create directory `cidata` in the root of the Ubuntu USB drive

2. Copy All files over to the cidata directory on the Ubuntu USB drive
    - user-data : Ubuntu [Autoinstall](https://canonical-subiquity.readthedocs-hosted.com/en/latest/intro-to-autoinstall.html) file
    - meta-data : Ubuntu Meta-data files
    - first-boot.service : One-shot service to launch the first-boot.sh script
    - first-boot.sh : Script that will run on first boot

3. Update the `boot/grub/grub.cfg` file and add the following menuentry to the list:

```
menuentry "Install GH200 System (Requires Internet)" {
        set gfxpayload=keep
        linux   /casper/vmlinuz quiet autoinstall 'ds=nocloud-net;s=file:///cdrom/cidata/'
        initrd  /casper/initrd
}
```

## Install the system via USB drive


## Validating everything is working
