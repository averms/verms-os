ARG MAJOR_VERSION

# Podman 4.9 doesn't cache bind mounts from host correctly[1]
# so we use a scratch image.
#
# [1]: https://github.com/containers/buildah/issues/5400

FROM scratch AS context
COPY /context /

FROM quay.io/fedora-ostree-desktops/silverblue:41.20250226.0-x86_64 AS base
ARG MAJOR_VERSION
RUN --mount=type=bind,from=context,src=/,dst=/context \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    sh /context/base-verms.sh ${MAJOR_VERSION}

FROM base AS kmod-builder
RUN --mount=type=bind,from=context,src=/,dst=/context \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    sh /context/nvidia-verms.sh

FROM base AS verms-os
RUN --mount=type=bind,from=context,src=/,dst=/context \
    --mount=type=bind,from=kmod-builder,src=/var/cache/akmods,dst=/tmp/kmods \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    sh /context/full-verms.sh
