#!/bin/sh
set -eu

. build_scripts/_lib.sh

# Copy without overwriting permissions for already existing directories unlike
# Dockerfile COPY.
cp --no-target-directory -vR system_files /

# Mark only leaves as user-installed.
autodnf mark dependency '*' >/dev/null
autodnf mark user $(dnf repoquery --leaves) >/dev/null
autodnf mark user fwupd rpm-ostree qemu-user-static-aarch64

# Enable google-chrome and disable fedora-cisco-openh264.
# We don't use config-manager setopt because rpm-ostree doesn't notice it.
sed -i '/^enabled=0/{s/0/1/}' /etc/yum.repos.d/google-chrome.repo
sed -i '/^enabled=1/{s/1/0/}' /etc/yum.repos.d/fedora-cisco-openh264.repo

# Fix sbin merge bug: https://github.com/coreos/rpm-ostree/pull/5507
sed -i 's@^d /usr/local/sbin 0755 root root -$@L /usr/local/sbin - - - - bin@' /usr/lib/tmpfiles.d/rpm-ostree-0-integration.conf

# Flathub
mkdir -p /etc/flatpak/remotes.d
curl -fRL --retry 1 -o /etc/flatpak/remotes.d/flathub.flatpakrepo \
    https://dl.flathub.org/repo/flathub.flatpakrepo

# RPM Fusion
ver="$(rpm -E %fedora)"
autodnf install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${ver}.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${ver}.noarch.rpm"

# Use only HTTPS mirrors.
for repo in /etc/yum.repos.d/*.repo; do
    sed -i 's/metalink?/metalink?protocol=https\&/g' "$repo"
done
