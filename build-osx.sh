#!/bin/bash

# exit this script if any commmand fails
set -e
#  

host_os=`uname -s | tr "[:upper:]" "[:lower:]"`
host_arch=`uname -m`

rm -rf out.gn/osx

rm -rf dist-osx
mkdir dist-osx

build_v8()
{
    ARGS="is_debug=false \
          symbol_level=0 \
          v8_target_cpu=\"$TARGET_CPU\" \
          v8_use_snapshot=false \
          v8_enable_i18n_support=false \
          v8_use_external_startup_data=false \
          is_component_build=false \
          v8_static_library=true \
          "

    gn gen $OUT_DIR --args="${ARGS}"
    # gn args $OUT_DIR --list
    ninja -C $OUT_DIR d8 -v # -j1

    AR="xcrun ar"
    STRIP="xcrun strip"

    rm -rf $OUT_DIR/libs
    mkdir $OUT_DIR/libs
    pushd $OUT_DIR/libs
    $AR -rcs libv8_base.a ../obj/v8_base/*.o
    $AR -rcs libv8_libbase.a ../obj/v8_libbase/*.o
    $AR -rcs libv8_libsampler.a ../obj/v8_libsampler/*.o
    $AR -rcs libv8_libplatform.a ../obj/v8_libplatform/*.o
    $AR -rcs libv8_nosnapshot.a ../obj/v8_nosnapshot/*.o
    $STRIP -S libv8_base.a
    $STRIP -S libv8_libbase.a
    $STRIP -S libv8_libsampler.a
    $STRIP -S libv8_libplatform.a
    $STRIP -S libv8_nosnapshot.a
    popd

    mkdir -p dist-osx/include
    mkdir -p dist-osx/libs
    cp -r include/* dist-osx/include
    cp $OUT_DIR/libs/lib*.a dist-osx/libs
}

OUT_DIR=out.gn/osx
TARGET_CPU=x64
build_v8

