# Trying to compile with an Alpine-based image may result in errors such as
# "LaTeX Error: Cannot determine size of graphic in" ...
# FROM alpine:latest
# RUN apk add --no-cache inkscape make texlive-full

FROM ubuntu:latest
# texlive-full has hard dependencies on several texlive-*-doc packages.
# The documentation is of no use in a container, and it would add gigabytes
# to both the download and the resulting image.
# Those dependencies cannot be skipped with apt options alone, since they are
# Depends instead of Recommends, so a dummy package that provides them
# is built with equivs before installing texlive-full.
RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    <<EOF
set -eu
rm -f /etc/apt/apt.conf.d/docker-clean
apt-get update
apt-get install -y --no-install-recommends equivs

# Resolve the documentation packages that texlive-full would pull in.
apt-get install --simulate -y --no-install-recommends texlive-full \
    | awk '/^Inst /{print $2}' | grep -E -- '-doc$' > /tmp/texlive-doc-packages || true

if [ -s /tmp/texlive-doc-packages ]; then
    # The dummy has to provide the candidate versions, as the dependencies of
    # texlive-full are versioned, and to conflict with the real packages,
    # so that apt does not install those instead.
    provides=
    conflicts=
    while read -r pkg; do
        version=$(apt-cache policy "$pkg" | awk '/Candidate:/{print $2}')
        provides="${provides:+$provides, }$pkg (= $version)"
        conflicts="${conflicts:+$conflicts, }$pkg"
    done < /tmp/texlive-doc-packages

    cat > /tmp/texlive-doc-dummy <<CONTROL
Section: misc
Priority: optional
Standards-Version: 3.9.2
Package: texlive-doc-dummy
Version: 1.0
Provides: $provides
Conflicts: $conflicts
Replaces: $conflicts
Description: dummy package for the TeX Live documentation
 Satisfies the texlive-*-doc dependencies of texlive-full without
 downloading and installing the documentation itself.
CONTROL

    cd /tmp
    equivs-build /tmp/texlive-doc-dummy
    dpkg --install /tmp/texlive-doc-dummy_1.0_all.deb
fi

# equivs is needed only for building the dummy package.
apt-get purge -y equivs
apt-get autoremove -y --purge

apt-get install -y --no-install-recommends \
    inkscape latexmk make texlive-full
EOF
