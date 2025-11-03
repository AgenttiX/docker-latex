# Trying to compile with an Alpine-based image may result in errors such as
# "LaTeX Error: Cannot determine size of graphic in" ...
# FROM alpine:latest
# RUN apk add --no-cache inkscape make texlive-full

FROM ubuntu:latest
RUN apt update \
    && apt install -y --no-install-recommends inkscape make texlive-full \
    # Removing documentation packages afterwards is a bit hacky, \
    # but it adds overhead only when building the image. \
    && apt --purge remove -y .\*-doc$ \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*
