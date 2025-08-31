#!/bin/sh
set -eu

. build_scripts/_lib.sh

# force proprietary drivers because i have a GTX 10 series GPU
echo "%_without_kmod_nvidia_detect 1" >/etc/rpm/macros.nvidia-kmod

autodnf install akmod-nvidia "kernel-devel-matched-${kernel_ver}"
akmods --force --kernels "${kernel_ver}"
