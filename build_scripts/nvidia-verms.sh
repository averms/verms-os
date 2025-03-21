#!/bin/sh
set -eu

. build_scripts/lib.sh

autodnf install "kernel-devel-matched-${kernel_ver}"
autodnf install akmod-nvidia
akmods --force --kernels "${kernel_ver}"
