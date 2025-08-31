#!/bin/sh
set -eu

. build_scripts/_lib.sh

autodnf install akmod-nvidia-3:560.35.03-1.fc41.x86_64 "kernel-devel-matched-${kernel_ver}"
akmods --force --kernels "${kernel_ver}"
