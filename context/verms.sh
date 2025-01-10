#!/bin/sh
set -eu

# https://gitlab.com/fedora/bootc/base-images/-/merge_requests/71
ln --no-target-directory -s ../run /var/run

# Configuration
# Copy without overwriting permissions for already existing directories unlike
# Dockerfile COPY.
cp --no-target-directory -vR context/etc /etc

# Fix package reasons
dnf -y mark dependency '*' >/dev/null
dnf rq --leaves | xargs -d '\n' dnf -y mark user >/dev/null
dnf -y mark user bootc rpm-ostree qemu-user-static-aarch64

# Removals
dnf -y remove \
    bind-utils \
    gnome-software \
    gnome-tour \
    nano \
    ntfs-3g ntfsprogs

# Enable google-chrome and disable fedora-cisco-openh264.
# We don't use config-manager setopt because rpm-ostree doesn't notice it.
sed -i '/^enabled=0/{s/0/1/}' /etc/yum.repos.d/google-chrome.repo
sed -i '/^enabled=1/{s/1/0/}' /etc/yum.repos.d/fedora-cisco-openh264.repo

# RPM Fusion
dnf -y install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$1.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$1.noarch.rpm"

# Codecs
dnf -y swap mesa-va-drivers mesa-va-drivers-freeworld
dnf -y swap '(ffmpeg-free or libswscale-free or libavformat-free or libavfilter-free or libavutil-free or libavcodec-free)' ffmpeg-libs

# Mitigate https://bugzilla.redhat.com/show_bug.cgi?id=2332429
dnf -y swap OpenCL-ICD-Loader ocl-icd

# Host packages
grep -Ev '^#|^$' context/host.txt |
    xargs -d '\n' dnf -y install
grep -Ev '^#|^$' context/host-no-weak-deps.txt |
    xargs -d '\n' dnf -y --setopt install_weak_deps=False install

# Install google-chrome-stable. Taken from
# https://github.com/travier/fedora-sysexts/blob/047ab6b890/google-chrome/Containerfile
mv /opt /opt.bk
mkdir /opt
dnf -y install google-chrome-stable
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
systemctl enable rpm-ostreed-automatic.timer

# If it tries to autoremove, something went wrong.
dnf --assumeno autoremove
# This does what dnf clean all does and more.
rm -r /var/cache/*
bootc container lint
