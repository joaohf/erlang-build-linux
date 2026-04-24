ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
YOCTO_RELEASE ?= scarthgap
YOCTO_DIR ?= /data-work/yocto

# From https://kas.readthedocs.io/en/latest/command-line.html#environment-variables
export SSTATE_DIR := ${YOCTO_DIR}/sstate-cache/${YOCTO_RELEASE}
export DL_DIR := ${YOCTO_DIR}/downloads
export KAS_BUILD_DIR ?= ${YOCTO_DIR}/builds/${YOCTO_RELEASE}-erlang-build

KAS ?= ${HOME}/work/opensource/kas/kas-container
RUN_KAS := run-kas

KAS_CONFIG ?= kas/demos/genericx86-64.yml

ifeq (${UPDATE}, 1)
	update = --update
else
	update = 
endif

shell-genericx86-64:
	$(MAKE) shell KAS_CONFIG=kas/demos/genericx86-64.yml

shell-genericarm64:
	$(MAKE) shell KAS_CONFIG=kas/demos/genericarm64.yml

shell-genericx86-64-musl:
	$(MAKE) shell KAS_CONFIG=kas/demos/genericx86-64-musl.yml

shell-genericarm64-musl:
	$(MAKE) shell KAS_CONFIG=kas/demos/genericarm64-musl.yml

checkout:
	${KAS} checkout ${KAS_CONFIG}

shell:
	${KAS} --runtime-args \
		"--mount src=/dev/kvm,dst=/dev/kvm,type=bind \
		 --mount src=/dev/vhost-net,dst=/dev/vhost-net,type=bind \
		 --device /dev/net/tun:/dev/net/tun \
		 --cap-add=NET_ADMIN \
		 --privileged" \
		shell ${update} ${KAS_CONFIG}

shell-update:
	$(MAKE) shell UPDATE=1

run-shell:
	${RUN_KAS} shell

test:
	$(MAKE) -C lux/test
