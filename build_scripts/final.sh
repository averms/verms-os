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
autodnf swap '(ffmpeg-free or libswscale-free or libavformat-free or libavfilter-free or libavutil-free or libavcodec-free)' ffmpeg-libs

# Mitigate https://bugzilla.redhat.com/show_bug.cgi?id=2332429
autodnf swap OpenCL-ICD-Loader ocl-icd

# NVIDIA drivers
autodnf install "/tmp/kmods/nvidia/kmod-nvidia-${kernel_ver}"*.rpm
cat <<EOF >/usr/lib/bootc/kargs.d/10-nvidia.toml
kargs = ["rd.driver.blacklist=nouveau,nova_core", "modprobe.blacklist=nouveau,nova_core", "nvidia-drm.modeset=1"]
EOF

# Host packages
autodnf install $(from_file build_scripts/host.txt)
autodnf --setopt install_weak_deps=False install $(from_file build_scripts/host-no-weak-deps.txt)

# idk why steam installs this when it's not needed. TODO: figure out why
autodnf remove libnsl.x86_64

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
systemctl disable nvidia-powerd.service
systemctl disable plocate-updatedb.timer

# If it tries to autoremove, something went wrong.
dnf --assumeno autoremove
dnf clean all
rm -r /var/*
bootc container lint
