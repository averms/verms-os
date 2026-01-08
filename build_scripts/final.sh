#!/bin/sh
set -eu

. build_scripts/_lib.sh

# Removals
autodnf remove \
    appstream-data \
    bash-color-prompt \
    bash-completion \
    bind-utils \
    gnome-tour \
    gnome-user-share \
    nano \
    ntfs-3g ntfsprogs \
    tree

# Codecs
autodnf swap mesa-va-drivers "https://github.com/averms/verms-os/releases/download/fix-rpmfusion-packages/mesa-va-drivers-freeworld-25.1.9-1.fc42.x86_64.rpm"
autodnf swap mesa-vulkan-drivers "https://github.com/averms/verms-os/releases/download/fix-rpmfusion-packages/mesa-vulkan-drivers-freeworld-25.1.9-1.fc42.x86_64.rpm"
autodnf "do" --action=remove \
    ffmpeg-free \
    libavcodec-free \
    libavfilter-free \
    libavformat-free \
    libavutil-free \
    --action=install ffmpeg-libs

# NVIDIA drivers
autodnf install "/tmp/kmods/nvidia/kmod-nvidia-${kernel_ver}"*.rpm
cat <<EOF >/usr/lib/bootc/kargs.d/10-nvidia.toml
kargs = ["rd.driver.blacklist=nouveau,nova_core", "modprobe.blacklist=nouveau,nova_core"]
EOF

# Host packages
autodnf install $(from_file build_scripts/host.txt)
autodnf --setopt install_weak_deps=False install $(from_file build_scripts/host-no-weak-deps.txt)

# IDK why Steam installs this when it's not needed. TODO: figure out why
autodnf remove libnsl.x86_64

# Install Chrome
rm /opt
mkdir /opt
autodnf install google-chrome-stable
rm -r /etc/cron.daily

mkdir /nix

# Systemd
systemctl enable tailscaled.service
systemctl enable bootc-fetch-apply-updates.timer
systemctl disable avahi-daemon.service
systemctl disable flatpak-add-fedora-repos.service
systemctl disable nvidia-powerd.service
systemctl disable plocate-updatedb.timer

# If it tries to autoremove, something went wrong.
dnf --assumeno autoremove
dnf clean all
rm -r /var/*
bootc container lint
