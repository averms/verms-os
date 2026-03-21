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
    kernel-modules-extra \
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

# Make /opt part of the image, not machine-local state. Necessary to install Google
# Chrome
rm /opt
mkdir /opt

# Host packages
autodnf install $(from_file build_scripts/packages.txt)
autodnf --setopt install_weak_deps=False install $(from_file build_scripts/packages_no_weak_deps.txt)

mkdir /nix

# Systemd
systemctl disable avahi-daemon.service
systemctl disable flatpak-add-fedora-repos.service
systemctl enable bootc-fetch-apply-updates.timer
systemctl enable tailscaled.service

# If it tries to autoremove, something went wrong.
# The exclusions come from steam installing libnsl.i686 and libXScrnSaver.i686. DNF5
# seems to want x86_64 versions of every package installed as a dependency. Rather than
# fight it, we'll just ignore it.
dnf autoremove --assumeno \
    --exclude libnsl.x86_64 \
    --exclude libXScrnSaver.x86_64

dnf clean all
rm -r /var/*
bootc container lint
