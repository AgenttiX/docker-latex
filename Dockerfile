FROM ubuntu:latest
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        # build-essential includes make
        build-essential inkscape texlive-full \
    # Removing documentation packages afterwards is a bit hacky,
    # but it adds overhead only when building the image.
    && apt-get --purge remove -y .\*-doc$ \
    && apt-get clean
