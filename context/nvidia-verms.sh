#!/bin/sh
set -eu

. context/lib.sh

autodnf install akmod-nvidia
akmods --force --kernels "$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-devel)"
