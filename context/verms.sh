#!/bin/sh
set -eu

# https://gitlab.com/fedora/bootc/base-images/-/merge_requests/71
ln --no-target-directory -s ../run /var/run

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

# RPM Fusion and VS Code
dnf config-manager addrepo --from-repofile context/etc/yum.repos.d/vscode.repo
dnf -y install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$1.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$1.noarch.rpm"

# Codecs
dnf -y swap mesa-va-drivers mesa-va-drivers-freeworld
dnf -y swap --allowerasing ffmpeg-free ffmpeg-libs

# Mitigate https://bugzilla.redhat.com/show_bug.cgi?id=2332429
dnf -y swap OpenCL-ICD-Loader ocl-icd

# Host packages
grep -Ev '^#|^$' context/host-packages.txt | xargs -d '\n' dnf -y install

# Minimal virtualization with virt-manager and qemu. See https://libvirt.org/kbase/rpm-deployment.html
dnf -y install --setopt=install_weak_deps=False \
    virt-manager libvirt-daemon-config-network libvirt-daemon-driver-qemu qemu-kvm

# Install gdb without pulling in dnf4. Needed for coredumpctl.
dnf -y install --setopt=install_weak_deps=False gdb

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

# Configuration
systemctl enable tailscaled.service
systemctl enable rpm-ostreed-automatic.timer
# Copy using permissions of target directory unlike Dockerfile COPY.
cp --no-target-directory -vR context/etc /etc

dnf -y autoremove
dnf clean all
bootc container lint
