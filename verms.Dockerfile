ARG MAJOR_VERSION

# Bind mounts from host don't cache correctly:
# https://github.com/containers/buildah/issues/5400
# so we use a scratch image.
FROM scratch AS ctx
COPY /ctx /

FROM quay.io/fedora/fedora-silverblue:${MAJOR_VERSION}

ARG MAJOR_VERSION
RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    sh /ctx/verms.sh ${MAJOR_VERSION}
