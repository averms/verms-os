#!/bin/sh
set -eu

# Removals
dnf -y remove nano

sed -i '/^enabled=1/{s/1/0/}' /etc/yum.repos.d/fedora-cisco-openh264.repo

# RPM Fusion and VS Code
dnf config-manager addrepo --from-repofile context/etc/yum.repos.d/vscode.repo

dnf -y install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$1.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$1.noarch.rpm"

# Toolbox packages
grep -Ev '^(#|$)' /context/toolbox-packages.txt | xargs -d '\n' dnf -y install

# Kitty integration inside container
dnf -y install kitty-kitten kitty-terminfo

dnf rq --leaves --qf '%{name}.%{arch}\n' >~/preinstalled.txt

cp --no-target-directory -vR context/etc /etc

dnf -y autoremove
dnf clean all
