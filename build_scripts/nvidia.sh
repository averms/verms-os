#!/bin/sh
set -eu

. build_scripts/_lib.sh

autodnf install "kernel-devel-matched-${kernel_ver}"
autodnf install akmod-nvidia
akmods --force --kernels "${kernel_ver}"
