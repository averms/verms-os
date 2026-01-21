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
autodnf swap mesa-va-drivers mesa-va-drivers-freeworld
autodnf swap mesa-vulkan-drivers mesa-vulkan-drivers-freeworld
autodnf "do" --action=remove \
    ffmpeg-free \
    libavcodec-free \
    libavfilter-free \
    libavformat-free \
    libavutil-free \
    --action=install ffmpeg-libs

# NVIDIA drivers
autodnf install "/tmp/kmods/nvidia/kmod-nvidia-${kernel_ver}"*.rpm

# Host packages
autodnf install $(from_file build_scripts/host.txt)
autodnf --setopt install_weak_deps=False install $(from_file build_scripts/host-no-weak-deps.txt)

# Make /opt part of the image, not machine-local state
rm /opt
mkdir /opt

# Install Chrome, which is only possible with the above change
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
# The exclusion for libnsl.x86_64 comes from steam installing libnsl.i686. DNF5 seems to
# want x86_64 versions of every package installed as a dependency. Rather than fight it,
# we'll just ignore it.
dnf autoremove --assumeno \
    --exclude libnsl.x86_64

dnf clean all
rm -r /var/*
bootc container lint
