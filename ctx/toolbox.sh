#!/bin/sh
set -eu

# Removals
dnf -y remove nano

sed -i '/^enabled=1/{s/1/0/}' /etc/yum.repos.d/fedora-cisco-openh264.repo

# RPM Fusion and VS Code
dnf config-manager addrepo --from-repofile /ctx/sys_files/vscode.repo

dnf -y install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$1.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$1.noarch.rpm"

# Toolbox packages
grep -Ev '^(#|$)' /ctx/toolbox-packages.txt | xargs -d '\n' dnf -y install

# Kitty integration inside container
dnf -y install kitty-kitten kitty-terminfo

dnf rq --leaves --qf '%{name}.%{arch}\n' >~/preinstalled.txt

cp ctx/sys_files/verms_dnf5.conf /etc/dnf/dnf5-aliases.d/

dnf -y autoremove
dnf clean all
