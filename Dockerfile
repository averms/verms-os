# The first stage copies my configuration from system_files/ over and adds DNF
# repositories.

FROM quay.io/fedora-ostree-desktops/silverblue:41 AS base
RUN --mount=type=bind,src=/system_files,dst=/system_files \
    --mount=type=bind,src=/build_scripts,dst=/build_scripts \
    sh /build_scripts/base-verms.sh

# The second stage builds nvidia-kmod.

FROM base AS kmod-builder
RUN --mount=type=bind,src=/build_scripts,dst=/build_scripts \
    sh /build_scripts/nvidia-verms.sh

# The final stage is based on the first stage and installs nvidia-kmod along with other
# packages.

FROM base AS verms-os
RUN --mount=type=bind,src=/build_scripts,dst=/build_scripts \
    --mount=type=bind,from=kmod-builder,src=/var/cache/akmods,dst=/tmp/kmods \
    sh /build_scripts/full-verms.sh
