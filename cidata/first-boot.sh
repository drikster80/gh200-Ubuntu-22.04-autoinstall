#!/bin/bash
apt-get update
sleep 60
# Install necessary Nvidia packages
apt-get install -y mlnx-fw-updater mlnx-ofed-all
apt-get install -y cuda-drivers-555 nvidia-kernel-open-555 linux-tools-$(uname -r)
apt-get install -y cuda-toolkit nvidia-container-toolkit

# Create the Nvidia Persistence Service
sudo mkdir /lib/systemd/system/nvidia-persistenced.service.d
sudo dd status=none of=/lib/systemd/system/nvidia-persistenced.service.d/override.conf << EOF
[Service]
ExecStart=
ExecStart=/usr/bin/nvidia-persistenced --persistence-mode --verbose
[Install]
WantedBy=multi-user.target
EOF
systemctl enable nvidia-persistenced --now

# Ensure CUDA is set in the PATH and LD_Library
echo "# Library Path for Nvidia CUDA" >> /etc/profile.d/cuda.sh
echo export LD_LIBRARY_PATH=/usr/local/cuda/lib64:'$LD_LIBRARY_PATH' >> /etc/profile.d/cuda.sh
echo export PATH=$HOME/.local/bin:/usr/local/cuda/bin:'$PATH' >> /etc/profile.d/cuda.sh
# Disable irqbalance service
systemctl disable irqbalance

# Set NUMA balancing setting
echo "kernel.numa_balancing = 0" >> /etc/sysctl.conf
sysctl -p

# Ensure nvidia-peermem module is loaded at boot
echo "nvidia-peermem" >> /etc/modules-load.d/nvidia-peermem.conf

systemctl disable first-boot.service
reboot
