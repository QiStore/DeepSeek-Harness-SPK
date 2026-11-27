#!/bin/bash
set -euo pipefail
if [ "$#" -ne 3 ]; then
    echo "用法: build.sh NODE_DIST_DIR LOCKED_RUNTIME_DIR OUT_DIR" >&2
    exit 2
fi
source_dir="$(cd "$(dirname "$0")" && pwd)"
node_dist="$(realpath "$1")"
runtime="$(realpath "$2")"
out="$(realpath "$3")"
root="$(mktemp -d)"
trap 'rm -rf "$root"' EXIT
mkdir -p "$root/spk" "$root/payload/runtime/compat-lib"
for package in libgcc-13.3.0-h77fa898_1 libstdcxx-13.3.0-hc0a3c3a_1; do
    case "$package" in
        libgcc*) digest=8d8bf84ebb7a8801cfc085c67d03e7a9d9fe339e29c64fb599f1d5f308ef2bb1; library=libgcc_s.so.1 ;;
        libstdcxx*) digest=5ea3348ab602c7ff78604e747a18ef928a69f844c9eda449aed078696a6e3c42; library=libstdc++.so.6 ;;
    esac
    archive="$root/$package.conda"
    curl -fsSL --retry 3 -o "$archive" "https://conda.anaconda.org/conda-forge/linux-64/$package.conda"
    printf '%s  %s\n' "$digest" "$archive" | sha256sum -c -
    mkdir -p "$root/$package"
    unzip -p "$archive" 'pkg-*.tar.zst' | tar --zstd -xC "$root/$package"
    install -m 644 "$root/$package/lib/$library" "$root/payload/runtime/compat-lib/$library"
    cp -R "$root/$package/share/licenses" "$root/payload/runtime/compat-lib/"
done
cp "$source_dir/INFO" "$root/spk/"
cp -a "$source_dir/conf" "$source_dir/scripts" "$root/spk/"
install -m 755 "$node_dist/bin/node" "$root/payload/runtime/node"
install -m 644 "$node_dist/LICENSE" "$root/payload/runtime/LICENSE.node"
install -m 644 "$runtime/node_modules/@deepseek-ai/dsh/LICENSE" "$root/spk/LICENSE"
cp "$source_dir/../scripts/check-runtime.sh" "$root/payload/"
bash "$source_dir/build-icons.sh" "$runtime" "$root/spk"
tar -C "$root/payload" -cf "$root/package.tar" .
tar -C "$runtime" --transform='s,^node_modules,runtime/node_modules,' -rf "$root/package.tar" node_modules
gzip -1 -n -c "$root/package.tar" > "$root/spk/package.tgz"
file="$out/DeepSeek-Harness-SPK-DSM6-bromolow-test-0004.spk"
tar -C "$root/spk" --format=ustar -cf "$file" INFO package.tgz scripts conf LICENSE PACKAGE_ICON.PNG PACKAGE_ICON_256.PNG
tar -tf "$file"
(cd "$out" && sha256sum "$(basename "$file")")
