FROM alpine:latest
RUN apk add --no-cache inkscape make texlive-full
    # Removing documentation packages afterwards is a bit hacky, \
    # but it adds overhead only when building the image. \
    # apt --purge remove -y .\*-doc$ \
