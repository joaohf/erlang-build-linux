YOCTO_RELEASE ?= scarthgap
YOCTO_DIR ?= /data-work/yocto

# From https://kas.readthedocs.io/en/latest/command-line.html#environment-variables
export SSTATE_DIR ?= ${YOCTO_DIR}/sstate-cache/${YOCTO_RELEASE}
export DL_DIR ?= ${YOCTO_DIR}/downloads
export KAS_BUILD_DIR ?= ${YOCTO_DIR}/builds/${YOCTO_RELEASE}-erlang-build

KAS ?= ${HOME}/work/opensource/kas/kas-container
RUN_KAS := run-kas

KAS_CONFIG ?= kas/demos/genericx86-64.yml

ifeq (${UPDATE}, 1)
	update = --update
else
	update = 
endif

$(KAS_BUILD_DIR):
	mkdir -v -p $@

%-genericx86-64-glibc:
	$(MAKE) $* KAS_CONFIG=kas/demos/genericx86-64.yml

%-genericarm64-glibc:
	$(MAKE) $* KAS_CONFIG=kas/demos/genericarm64.yml

%-genericx86-64-musl:
	$(MAKE) $* KAS_CONFIG=kas/demos/genericx86-64-musl.yml

%-genericarm64-musl:
	$(MAKE) $* KAS_CONFIG=kas/demos/genericarm64-musl.yml

checkout:
	${KAS} checkout ${KAS_CONFIG}

shell: $(KAS_BUILD_DIR)
	${KAS} --runtime-args \
		"--mount src=/dev/kvm,dst=/dev/kvm,type=bind \
		 --mount src=/dev/vhost-net,dst=/dev/vhost-net,type=bind \
		 --device /dev/net/tun:/dev/net/tun \
		 --cap-add=NET_ADMIN \
		 --privileged" \
		shell ${update} ${KAS_CONFIG}

build: $(KAS_BUILD_DIR)
	${KAS} --runtime-args \
		"--mount src=/dev/kvm,dst=/dev/kvm,type=bind \
		 --mount src=/dev/vhost-net,dst=/dev/vhost-net,type=bind \
		 --device /dev/net/tun:/dev/net/tun \
		 --cap-add=NET_ADMIN \
		 --privileged" \
		build ${update} ${KAS_CONFIG}

shell-update:
	$(MAKE) shell UPDATE=1

run-shell:
	${RUN_KAS} shell

test:
	$(MAKE) -C lux/test
