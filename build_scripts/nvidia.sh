#!/bin/sh
set -eu

. build_scripts/_lib.sh

autodnf install akmod-nvidia "kernel-devel-matched-${kernel_ver}"
akmods --force --kernels "${kernel_ver}"
