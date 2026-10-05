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

# Host packages
autodnf install $(from_file build_scripts/packages.txt)
autodnf --setopt install_weak_deps=False install $(from_file build_scripts/packages_no_weak_deps.txt)

# Systemd
systemctl disable avahi-daemon.service
systemctl disable flatpak-add-fedora-repos.service
systemctl enable bootc-fetch-apply-updates.timer
systemctl enable tailscaled.service
systemctl enable nix.mount
systemctl enable nix-daemon.socket

printf "\n!include nix.custom.conf\n" >>/etc/nix/nix.conf
# SELinux has no rules for /nix, so everything there is labelled default_t. Our
# shells and nix-daemon are unconfined so that mostly works, but various other
# things dont:
#
# 1. systemd can't read units or run binaries from the store
# 2. a store shell can't be a login shell
# 3. the socket described by nix-daemon.socket can't be created[1]
# 4. potentially other SELinux errors
#
# Having a proper SELinux setup for nix and fixing those would require a lot of
# work. The SELinux labels shipped by the Determinate Nix installer and its
# forks help for the initial install but new store paths won't get those labels
# since CppNix doesn't set labels or support SELinux and never will.[2]
#
# So I think we'll mostly try to use Nix in a way that avoids the brokenness
# described above. The line below fixes the SELinux label for just the socket.
#
# [1]: https://bugzilla.redhat.com/show_bug.cgi?id=2525943
# [2]: https://github.com/NixOS/nix/pull/2670#issuecomment-1346175168

semanage fcontext -a -t var_run_t '/nix/var/nix/daemon-socket(/.*)?'

# If it tries to autoremove, something went wrong.
dnf autoremove --assumeno

dnf clean all
rm -r /var/*
bootc container lint
