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

# Codecs and graphics
autodnf "do" --action=remove \
    ffmpeg-free \
    libavcodec-free \
    libavfilter-free \
    libavformat-free \
    libavutil-free \
    --action=install ffmpeg-libs \
    --action=remove mesa-vulkan-drivers \
    --action=install mesa-vulkan-drivers-freeworld \
    mesa-va-drivers-freeworld

# Make /opt part of the image, not machine-local state. Necessary to install Google
# Chrome
rm /opt
mkdir /opt

mkdir /nix

# Host packages
autodnf install $(from_file build_scripts/packages.txt)
autodnf --setopt install_weak_deps=False install $(from_file build_scripts/packages_no_weak_deps.txt)

# Systemd
systemctl disable avahi-daemon.service
systemctl disable flatpak-add-fedora-repos.service
systemctl enable bootc-fetch-apply-updates.timer
systemctl enable tailscaled.service

# If it tries to autoremove, something went wrong.
dnf autoremove --assumeno

dnf clean all
rm -r /var/*
bootc container lint
