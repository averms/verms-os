#!/bin/sh
set -eu

. context/lib.sh

autodnf install akmod-nvidia
akmods --force
