#!/bin/sh
set -eu

. build_scripts/_lib.sh

# Configuration
# Copy without overwriting permissions for already existing directories unlike
# Dockerfile COPY.
cp --no-target-directory -vR system_files /

# Mark only leaves as user-installed.
autodnf mark dependency '*' >/dev/null
autodnf mark user $(dnf repoquery --leaves) >/dev/null
autodnf mark user fwupd rpm-ostree qemu-user-static-aarch64 kernel-modules-extra

# Enable google-chrome and disable fedora-cisco-openh264.
# We don't use config-manager setopt because rpm-ostree doesn't notice it.
sed -i '/^enabled=0/{s/0/1/}' /etc/yum.repos.d/google-chrome.repo
sed -i '/^enabled=1/{s/1/0/}' /etc/yum.repos.d/fedora-cisco-openh264.repo

# RPM Fusion
ver="$(rpm -E %fedora)"
autodnf install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${ver}.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${ver}.noarch.rpm"
