SUMMARY = "Target packages for the Erlang SDK"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = "\
    ${PN} \
    ${PN}-utils \
    "

RDEPENDS:${PN} = " \
    libcrypto \
    ncurses-libncurses \
    ncurses-libncursesw \
    "

RDEPENDS:${PN}-utils = "\
    bash \
    acl \
    attr \
    bc \
    coreutils \
    cpio \
    ed \
    file \
    findutils \
    gawk \
    grep \
    less \
    ncurses \
    net-tools \
    procps \
    psmisc \
    sed \
    tar \
    bzip2 \
    gzip \
    time \
    util-linux \
    curl \
    netbase \
    iputils \
    iproute2 \
    openssl \
    git \
    openssh-scp \
    "
