#!/bin/bash

# Copyright (C) 2024 psionicprjkt

compile_kernel() {
    # compile_kernel
    export ARCH=arm64
    make O=out ARCH=arm64 rova_defconfig

    # Generate profile data during the first compilation
    PATH="${PWD}/clang/bin:${PATH}:${PWD}/clang/bin:${PATH}:${PWD}/clang/bin:${PATH}" \
    make -j$(nproc --all) O=out \
        ARCH=arm64 \
        CC="clang" \
        CLANG_TRIPLE=aarch64-linux-gnu- \
        CROSS_COMPILE="${PWD}/clang/bin/aarch64-linux-gnu-" \
        CROSS_COMPILE_ARM32="${PWD}/clang/bin/arm-linux-gnueabi-" \
        CONFIG_NO_ERROR_ON_MISMATCH=y \
        CFLAGS="-Wno-pragma-messages" 2>&1 | tee build_log.txt
}

setup_kernel_release() {
    # Determine the name of the zip file based on the build type.
    kn="Neural-kernel"
    cn="rova"
    d=$(date "+%d%m%Y")
    lc=$(git log -1 --format=%H | cut -c1-7)

    # Check BUILD_TYPE workflows
    if [[ $BUILD_TYPE == "default" ]]; then
        z="$kn-$cn-$d-$lc.zip"
    elif [[ $BUILD_TYPE == "ksu" ]]; then
        z="$kn-$cn-$d-$lc-ksu.zip"
    else
        echo "Invalid BUILD_TYPE specified: $BUILD_TYPE"
        exit 1
    fi

    # Download the necessary files, unzip them, and package the kernel.
    wget --quiet https://psionicprjkt.my.id/assets/files/AK3-rova.zip && unzip AK3-rova
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel && cd AnyKernel
    zip -r9 "$z" *
}

compile_kernel
setup_kernel_release
