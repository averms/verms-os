#!/bin/sh
set -eu

. context/lib.sh

kernel_version="$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel)"

autodnf install "kernel-devel-matched-${kernel_version}"
autodnf install akmod-nvidia
akmods --force --kernels "${kernel_version}"
