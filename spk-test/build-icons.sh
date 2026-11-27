#!/bin/bash
set -euo pipefail
node - "$1" "$2" <<'JS'
const path = require("node:path");
const runtime = path.resolve(process.argv[2]);
const destination = path.resolve(process.argv[3]);
const sharp = require(path.join(runtime, "node_modules/sharp"));
const source = path.join(runtime, "node_modules/@deepseek-ai/dsh-web-frontend/dist/icon-512.png");
Promise.all([
  sharp(source).resize(72, 72).png().toFile(path.join(destination, "PACKAGE_ICON.PNG")),
  sharp(source).resize(256, 256).png().toFile(path.join(destination, "PACKAGE_ICON_256.PNG")),
]).catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
JS
