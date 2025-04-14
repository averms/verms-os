#!/usr/bin/env bash
set -eu
shopt -s inherit_errexit

image_repo=ghcr.io/averms
image_id=verms-os:latest

build() {
    _oci --tag "${image_id}" .
}

push-verms() {
    local password
    if [[ $# -eq 1 ]]; then
        password=":${1}"
    else
        password=
    fi
    podman push --creds "averms${password}" "${image_id}" "${image_repo}/${image_id}"
}

build-qcow2() {
    _image ./qemu_config.toml \
        build \
        --use-librepo --rootfs xfs --type qcow2 "${image_repo}/${image_id}"
}

build-iso() {
    _image ./iso_config.toml \
        build \
        --use-librepo --rootfs xfs --type anaconda-iso "${image_repo}/${image_id}"
}

_oci() {
    podman build --pull=newer "$@"
}

_image() {
    local config="$1"
    shift

    sudo podman pull "${image_repo}/${image_id}"
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
