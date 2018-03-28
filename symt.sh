#!/bin/bash

set -e

HOST="$(rustc -vV | grep 'host:' | cut -d' ' -f2)"
REL_FLAG="$1"
REL_PATH="debug"

if [ "$REL_FLAG" == "--release" ]; then
    REL_PATH="release"
fi

failed=0

while IFS= read -r target; do
    echo "$target:"

    cargo --color=always build --target $target $REL_FLAG

    lib_path="target/$target/$REL_PATH/libcompiler_builtins.rlib"

    echo "    $(tput bold)Undefined$(tput sgr0) (for $(tput bold)$target$(tput sgr0)):"

    undefined="$(
        diff --new-line-format="" --unchanged-line-format="" \
            <(nm "$lib_path" | cut -c10- | grep -i '^u' | cut -c3- | sort -u) \
            <(nm "$lib_path" | cut -c10- | grep -i '^t' | cut -c3- | sort -u) \
            || true)"

    if [ -n "$undefined" ]; then
        undefined="$undefined\n"
        failed=1
    fi

    echo -e "$undefined" | sed 's/^/        /'
done <<'EOF'
i686-apple-darwin
i686-pc-windows-gnu
i686-pc-windows-msvc
i686-unknown-linux-gnu
x86_64-apple-darwin
x86_64-pc-windows-gnu
x86_64-pc-windows-msvc
x86_64-unknown-linux-gnu
aarch64-apple-ios
aarch64-linux-android
aarch64-unknown-fuchsia
aarch64-unknown-linux-gnu
arm-linux-androideabi
arm-unknown-linux-gnueabi
arm-unknown-linux-gnueabihf
arm-unknown-linux-musleabi
arm-unknown-linux-musleabihf
armv7-apple-ios
armv7-linux-androideabi
armv7-unknown-linux-gnueabihf
armv7-unknown-linux-musleabihf
armv7s-apple-ios
asmjs-unknown-emscripten
i386-apple-ios
i586-pc-windows-msvc
i586-unknown-linux-gnu
i686-linux-android
i686-unknown-freebsd
i686-unknown-linux-musl
mips-unknown-linux-gnu
mips-unknown-linux-musl
mips64-unknown-linux-gnuabi64
mips64el-unknown-linux-gnuabi64
mipsel-unknown-linux-gnu
mipsel-unknown-linux-musl
powerpc-unknown-linux-gnu
powerpc64-unknown-linux-gnu
powerpc64le-unknown-linux-gnu
s390x-unknown-linux-gnu
sparc64-unknown-linux-gnu
sparcv9-sun-solaris
wasm32-unknown-emscripten
x86_64-apple-ios
x86_64-rumprun-netbsd
x86_64-sun-solaris
x86_64-unknown-freebsd
x86_64-unknown-fuchsia
x86_64-unknown-linux-musl
x86_64-unknown-netbsd
x86_64-unknown-redox
armv5te-unknown-linux-gnueabi
i686-pc-windows-msvc
i686-unknown-haiku
i686-unknown-netbsd
le32-unknown-nacl
mips-unknown-linux-uclibc
mipsel-unknown-linux-uclibc
msp430-none-elf
sparc64-unknown-netbsd
thumbv6m-none-eabi
thumbv7em-none-eabi
thumbv7em-none-eabihf
thumbv7m-none-eabi
x86_64-pc-windows-msvc
x86_64-unknown-bitrig
x86_64-unknown-dragonfly
x86_64-unknown-haiku
x86_64-unknown-openbsd
EOF

exit $failed
