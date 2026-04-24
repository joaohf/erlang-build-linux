SUMMARY = "Basic container image"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

IMAGE_FEATURES += "staticdev-pkgs"

IMAGE_FSTYPES = "container oci"

inherit core-image
inherit image-oci


IMAGE_INSTALL = "\
           base-files \
       base-passwd \
    ${CORE_IMAGE_EXTRA_INSTALL} \
    packagegroup-core-full-cmdline-dev-utils \
    packagegroup-core-sdk \
    packagegroup-core-standalone-sdk-target \
    packagegroup-erlang-build-sdk-target \
    packagegroup-erlang-build-sdk-target-utils \
        ${CONTAINER_SHELL} \
    "



# If the following is configured in local.conf (or the distro):
#      PACKAGE_EXTRA_ARCHS:append = " container-dummy-provides"
# 
# it has been explicitly # indicated that we don't want or need a shell, so we'll
# add the dummy provides.
# 
# This is required, since there are postinstall scripts in base-files and base-passwd
# that reference /bin/sh and we'll get a rootfs error if there's no shell or no dummy
# provider.
CONTAINER_SHELL ?= "${@bb.utils.contains('PACKAGE_EXTRA_ARCHS', 'container-dummy-provides', 'container-dummy-provides', 'busybox', d)}"

# Allow build with or without a specific kernel
IMAGE_CONTAINER_NO_DUMMY = "1"

# Workaround /var/volatile for now
ROOTFS_POSTPROCESS_COMMAND += "rootfs_fixup_var_volatile ; "
rootfs_fixup_var_volatile () {
    install -m 1777 -d ${IMAGE_ROOTFS}/${localstatedir}/volatile/tmp
    install -m 755 -d ${IMAGE_ROOTFS}/${localstatedir}/volatile/log
}

OCI_IMAGE_TAG = "erlang-build:latest"

CONTAINER_SHELL = "bash"


# We have (un)patched gcc to create binaries that expect the ld-linux loader in /lib64 on x86_64 systems 
# (like in other linuxes), we need to provide that in our root fs as well.
add_lib64_link() {
  if [ ${@bb.utils.contains('TUNE_FEATURES', 'm64', 'true', 'false', d)} = true ]; then
   ln -srf ${IMAGE_ROOTFS}/lib ${IMAGE_ROOTFS}/lib64
  fi
#  if [ ${MACHINE} = qemux86-64 ]; then
#    ln -srf ${IMAGE_ROOTFS}/lib ${IMAGE_ROOTFS}/lib64
#  fi
#  if [ ${MACHINE} = qemumips64 ]; then
#    ln -srf ${IMAGE_ROOTFS}/lib ${IMAGE_ROOTFS}/lib64
#  fi
}

add_lib32_link() {
  if [ ${@bb.utils.contains('TUNE_FEATURES', 'm32', 'true', 'false', d)} = true ]; then
    ln -srf ${IMAGE_ROOTFS}/lib ${IMAGE_ROOTFS}/lib32
  fi
}


ROOTFS_POSTPROCESS_COMMAND += "add_lib32_link;"
ROOTFS_POSTPROCESS_COMMAND += "add_lib64_link;"

