# meta-erlang-build produces toolchain targeting cross-distro compatible binaries,
# so it's necessary to keep GCC's default location of the dynamic linker. 
# Yocto's default dynamic linker location in /lib for e.g. x86_64 results in binaries
# not being executable on Linux distributions using the default location.
#
# The 0009 file is removed because it caused patch fuzz, it only applies to armv4 so
# it's ok for removing it
SRC_URI:remove = "\
    file://0007-Define-GLIBC_DYNAMIC_LINKER-and-UCLIBC_DYNAMIC_LINKE.patch \
    file://0009-gcc-armv4-pass-fix-v4bx-to-linker-to-support-EABI.patch \
    "
