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
mkdir -p "$root/spk" "$root/payload/runtime"
cp "$source_dir/INFO" "$root/spk/"
cp -a "$source_dir/conf" "$source_dir/scripts" "$root/spk/"
install -m 755 "$node_dist/bin/node" "$root/payload/runtime/node"
install -m 644 "$node_dist/LICENSE" "$root/payload/runtime/LICENSE.node"
install -m 644 "$runtime/node_modules/@deepseek-ai/dsh/LICENSE" "$root/spk/LICENSE"
cp "$source_dir/../scripts/check-runtime.sh" "$root/payload/"
python3 - "$root/spk" <<'PY'
from pathlib import Path
import struct
import sys
import zlib

root = Path(sys.argv[1])
for size, name in [(72, "PACKAGE_ICON.PNG"), (256, "PACKAGE_ICON_256.PNG")]:
    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))
    rows = bytearray()
    for y in range(size):
        rows.append(0)
        for x in range(size):
            border = min(x, y, size - x - 1, size - y - 1)
            rack = size // 4 <= x < size * 3 // 4 and any(
                abs(y - size * row // 8) <= size // 25 for row in (3, 4, 5)
            )
            rows.extend((234, 245, 255) if rack else (49, 128, 188) if border < size // 12 else (27, 71, 111))
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(rows)) + chunk(b"IEND", b"")
    (root / name).write_bytes(png)
PY
tar -C "$root/payload" -cf "$root/package.tar" .
tar -C "$runtime" --transform='s,^node_modules,runtime/node_modules,' -rf "$root/package.tar" node_modules
gzip -1 -n -c "$root/package.tar" > "$root/spk/package.tgz"
file="$out/DeepSeek-Harness-SPK-DSM6-bromolow-test-0001.spk"
tar -C "$root/spk" --format=ustar -cf "$file" INFO package.tgz scripts conf LICENSE PACKAGE_ICON.PNG PACKAGE_ICON_256.PNG
tar -tf "$file"
(cd "$out" && sha256sum "$(basename "$file")")
