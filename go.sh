#!/usr/bin/env bash
set -eu
shopt -s inherit_errexit

build-verms() {
    _oci --tag verms-os .
}

build-toolbox() {
    _oci --tag toolbox -f toolbox.Dockerfile
}

push-verms() {
    podman push --creds averms verms-os:latest ghcr.io/averms/verms-os:latest
}

build-qcow2() {
    _image ./qemu_config.toml \
        build \
        --use-librepo --rootfs xfs --type qcow2 ghcr.io/averms/verms-os:latest
}

build-iso() {
    _image ./iso_config.toml \
        build \
        --use-librepo --rootfs xfs --type anaconda-iso ghcr.io/averms/verms-os:latest
}

_oci() {
    podman build --pull=always --build-arg MAJOR_VERSION=41 "$@"
}

_image() {
    local config="$1"
    shift

    sudo podman run --pull=always --rm -it --privileged --security-opt label=disable \
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
