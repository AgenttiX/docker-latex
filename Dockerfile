# Trying to compile with an Alpine-based image may result in errors such as
# "LaTeX Error: Cannot determine size of graphic in" ...
# FROM alpine:latest
# RUN apk add --no-cache inkscape make texlive-full

FROM ubuntu:latest
RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        inkscape make texlive-latex-extra texlive-latex-recommended
    # Removing documentation packages afterwards is a bit hacky, \
    # but it adds overhead only when building the image. \
    # && apt-get --purge remove -y .\*-doc$ \
    # && apt-get clean \
    # && rm -rf /var/lib/apt/lists/*
