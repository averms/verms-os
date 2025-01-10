ARG MAJOR_VERSION

# Bind mounts from host don't cache correctly:
# https://github.com/containers/buildah/issues/5400
# so we use a scratch image.
FROM scratch AS context
COPY /context /

FROM quay.io/fedora/fedora-silverblue:${MAJOR_VERSION}

ARG MAJOR_VERSION
RUN --mount=type=bind,from=context,src=/,dst=/context \
    sh /context/verms.sh ${MAJOR_VERSION}
