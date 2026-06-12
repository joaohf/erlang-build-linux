#!/bin/bash
# 
# Based on: https://github.com/erlef/otp_builds/blob/main/scripts/build_otp_macos.bash

set -euo pipefail

main() {
  if [[ $# -ne 2 ]]; then
    cat <<EOF
Usage:
    build_otp.bash ref_name
EOF
    exit 1
  fi

  local erlang_version=$1
  local ref_name=$2

  : "${BUILD_DIR:=${PWD}/tmp/otp_builds}"
  : "${OTP_DIR:=${BUILD_DIR}/otp-${ref_name}}"
  : "${OTP_TGZ:=${BUILD_DIR}/${ref_name}.tar.gz}"
  n=$(getconf _NPROCESSORS_ONLN)
  export MAKEFLAGS="-j${n}"
  export CFLAGS="-Os"

  ulimit -n 65536

  build_otp "${erlang_version}" "${ref_name}"
}

test_otp() {
  erl -noshell -eval 'io:format("~s~s~n", [
    erlang:system_info(system_version),
    erlang:system_info(system_architecture)]),
    {ok, _} = application:ensure_all_started(crypto), io:format("crypto ok~n"),
    halt().'
}

build_otp() {
  local erlang_version="$1"
  local ref_name="$2"
  local rel_dir="${OTP_DIR}"
  local src_dir="${BUILD_DIR}/otp-${ref_name}-src"
  local test_dir="${OTP_DIR}-test"

  local url="https://github.com/erlang/otp"

  git clone --depth 1 "$url" --branch "$erlang_version" "$src_dir"
  
  (
    cd "$src_dir"
    export ERL_TOP="${PWD}"
    export ERLC_USE_SERVER=true
    export RELEASE_ROOT="${rel_dir}"
    export LANG=C

    ./otp_build configure

    make release
    cd "${rel_dir}"
    ./Install -sasl "${PWD}"

    # Remove Install since the release is relocatable anyway
    rm Install
  )

  export PATH="${rel_dir}/bin:${PATH}"

  # shellcheck disable=SC2310
  if ! test_otp; then
    rm -rf "${rel_dir}"
  fi

  build_tgz
}

build_tgz() {
  echo "creating ${OTP_TGZ}"
  tar czf "${OTP_TGZ}" -C "${OTP_DIR}" .
  sha256sum "${OTP_TGZ}" > "${OTP_TGZ}".sha256
}

# shellcheck disable=SC2068
main $@