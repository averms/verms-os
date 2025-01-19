#!/bin/sh
set -eu

# https://gitlab.com/fedora/bootc/base-images/-/merge_requests/71
ln --no-target-directory -s ../run /var/run

# Configuration
# Copy without overwriting permissions for already existing directories unlike
# Dockerfile COPY.
cp --no-target-directory -vR context/etc /etc

# Don't prompt and fail if it can't install the latest version of everything.
# This prevents downgrading if rpmfusion is not up to date.
autodnf() {
    command dnf --assumeyes --best "$@"
}

# Fix package reasons
autodnf mark dependency '*' >/dev/null
autodnf mark user $(dnf repoquery --leaves) >/dev/null
autodnf mark user fwupd rpm-ostree qemu-user-static-aarch64

# Removals
autodnf remove \
    bash-color-prompt \
    bash-completion \
    bind-utils \
    gnome-software \
    gnome-tour \
    nano \
    ntfs-3g ntfsprogs \
    tree

# Enable google-chrome and disable fedora-cisco-openh264.
# We don't use config-manager setopt because rpm-ostree doesn't notice it.
sed -i '/^enabled=0/{s/0/1/}' /etc/yum.repos.d/google-chrome.repo
sed -i '/^enabled=1/{s/1/0/}' /etc/yum.repos.d/fedora-cisco-openh264.repo

# RPM Fusion
autodnf install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$1.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$1.noarch.rpm"

# Codecs
autodnf swap mesa-va-drivers mesa-va-drivers-freeworld
autodnf swap '(ffmpeg-free or libswscale-free or libavformat-free or libavfilter-free or libavutil-free or libavcodec-free)' ffmpeg-libs

# Mitigate https://bugzilla.redhat.com/show_bug.cgi?id=2332429
autodnf swap OpenCL-ICD-Loader ocl-icd

# Host packages
autodnf install $(grep -Ev '^#|^$' context/host.txt)
autodnf --setopt install_weak_deps=False install $(grep -Ev '^#|^$' context/host-no-weak-deps.txt)

# Install google-chrome-stable. Taken from
# https://github.com/travier/fedora-sysexts/blob/047ab6b890/google-chrome/Containerfile
mv /opt /opt.bk
mkdir /opt
autodnf install google-chrome-stable
mv /opt/google/chrome /usr/lib/google-chrome
ln -sf /usr/lib/google-chrome/google-chrome /usr/bin/google-chrome-stable
for i in 16 24 32 48 64 128 256; do
    mkdir -p "/usr/share/icons/hicolor/${i}x${i}/apps"
    ln -sf "/usr/lib/google-chrome/product_logo_${i}.png" \
        "/usr/share/icons/hicolor/${i}x${i}/apps/google-chrome.png"
done
rm -r /etc/cron.daily
rmdir /opt/google /opt
mv /opt.bk /opt

# Systemd
systemctl enable tailscaled.service
systemctl enable bootc-fetch-apply-updates.timer
systemctl disable avahi-daemon.service

# If it tries to autoremove, something went wrong.
dnf --assumeno autoremove
# Clean all except for libdnf5 which is mount type=cache.
find /var/cache -mindepth 1 -maxdepth 1 -not -name libdnf5 -print0 | xargs -0 rm -r
rm -r /var/log/*
bootc container lint
