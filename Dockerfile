# The first stage copies my configuration from system_files/ over and adds DNF
# repositories.

FROM quay.io/fedora-ostree-desktops/silverblue:44 AS base
RUN --mount=type=bind,src=/build_scripts/base.sh,dst=/build_scripts/base.sh \
    --mount=type=bind,src=/build_scripts/_lib.sh,dst=/build_scripts/_lib.sh \
    --mount=type=bind,src=/system_files,dst=/system_files \
    --mount=type=cache,dst=/var/cache \
    sh /build_scripts/base.sh

# The second stage builds nvidia-kmod.

FROM base AS kmod-builder
RUN --mount=type=bind,src=/build_scripts/nvidia.sh,dst=/build_scripts/nvidia.sh \
    --mount=type=bind,src=/build_scripts/_lib.sh,dst=/build_scripts/_lib.sh \
    --mount=type=cache,dst=/var/cache \
    sh /build_scripts/nvidia.sh

# The final stage is based on the first stage.
# It installs nvidia-kmod along with other packages.

FROM base AS verms-os
RUN --mount=type=bind,src=/build_scripts/final.sh,dst=/build_scripts/final.sh \
    --mount=type=bind,src=/build_scripts/_lib.sh,dst=/build_scripts/_lib.sh \
    --mount=type=bind,src=/build_scripts/packages.txt,dst=/build_scripts/packages.txt \
    --mount=type=bind,src=/build_scripts/packages_no_weak_deps.txt,dst=/build_scripts/packages_no_weak_deps.txt \
    --mount=type=bind,from=kmod-builder,src=/var/cache/akmods,dst=/tmp/kmods \
    sh /build_scripts/final.sh
