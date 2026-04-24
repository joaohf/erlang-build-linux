SUMMARY = ""

IMAGE_FSTYPES = "tar.gz"

IMAGE_FEATURES += "staticdev-pkgs"

IMAGE_INSTALL = "\
    ${CORE_IMAGE_EXTRA_INSTALL} \
    packagegroup-core-full-cmdline-dev-utils \
    packagegroup-core-sdk \
    packagegroup-core-standalone-sdk-target \
    packagegroup-erlang-build-sdk-target \
    packagegroup-erlang-build-sdk-target-utils \
    "

inherit core-image