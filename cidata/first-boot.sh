#!/bin/bash
apt-get update
sleep 60
apt-get install -y cuda-drivers-555 nvidia-kernel-open-555
apt-get install -y cuda-toolkit-12-4 nvidia-container-toolkit
apt-get install -y mlnx-fw-updater mlnx-ofed-all
sudo mkdir /lib/systemd/system/nvidia-persistenced.service.d
sudo dd status=none of=/lib/systemd/system/nvidia-persistenced.service.d/override.conf << EOF
[Service]
ExecStart=
ExecStart=/usr/bin/nvidia-persistenced --persistence-mode --verbose
[Install]
WantedBy=multi-user.target
EOF
systemctl enable nvidia-persistenced --now
echo "# Library Path for Nvidia CUDA" >> /etc/profile.d/cuda.sh
echo export LD_LIBRARY_PATH=/usr/local/cuda/lib64:'$LD_LIBRARY_PATH' >> /etc/profile.d/cuda.sh
echo export PATH=$HOME/.local/bin:/usr/local/cuda/bin:'$PATH' >> /etc/profile.d/cuda.sh
systemctl disable first-boot.service
reboot
