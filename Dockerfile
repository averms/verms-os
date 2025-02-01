ARG MAJOR_VERSION

# Bind mounts from host don't cache correctly:
# https://github.com/containers/buildah/issues/5400
# so we use a scratch image.
FROM scratch AS context
COPY /context /

FROM quay.io/fedora-ostree-desktops/silverblue:${MAJOR_VERSION} AS base
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
    sh /context/verms.sh
