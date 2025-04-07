#!/usr/bin/env bash
set -eu
shopt -s inherit_errexit

IMAGE_URL=ghcr.io/averms/verms-os:latest

build() {
    _oci --tag verms-os .
}

push-verms() {
    podman push --creds averms verms-os:latest "${IMAGE_URL}"
}

build-qcow2() {
    _image ./qemu_config.toml \
        build \
        --use-librepo --rootfs xfs --type qcow2 "${IMAGE_URL}"
}

build-iso() {
    _image ./iso_config.toml \
        build \
        --use-librepo --rootfs xfs --type anaconda-iso "${IMAGE_URL}"
}

_oci() {
    podman build --pull=newer "$@"
}

_image() {
    local config="$1"
    shift

    sudo podman run --pull=newer --rm -it --privileged --security-opt label=disable \
        -v rpmmd:/rpmmd \
        -v osbuild:/store \
        -v ./output:/output \
        -v "${config}:/config.toml:ro" \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        quay.io/centos-bootc/bootc-image-builder:latest \
        "$@"
}

help() {
    echo "$0 <task> [args]"
    echo
    compgen -A function | grep -v '^_' | cat -n
}

TIMEFORMAT="Task completed in %3lR"
time "${@:-help}"
