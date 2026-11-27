#!/bin/sh
# 在目标 DSM 上验证候选运行时及原生模块加载情况。
set -eu
if [ "$#" -ne 2 ]; then
    echo "用法: sh scripts/check-runtime.sh /绝对路径/node /绝对路径/dsh入口.js" >&2
    exit 2
fi
case "$1:$2" in
    /*:/*) ;;
    *) echo "请使用绝对路径" >&2; exit 2 ;;
esac

printf 'CPU 架构: '
uname -m
printf '内核版本: '
uname -r
if command -v getconf >/dev/null 2>&1; then
    getconf GNU_LIBC_VERSION || true
fi
if [ -r /etc.defaults/VERSION ]; then
    sed -n '/^productversion=/p; /^buildnumber=/p' /etc.defaults/VERSION
fi

umask 077
probe="$(mktemp -d)"
trap 'rm -rf "$probe"' EXIT
mkdir -p "$probe/workspace"
export HOME="$probe" XDG_CONFIG_HOME="$probe/config" XDG_DATA_HOME="$probe/data"
export XDG_CACHE_HOME="$probe/cache" XDG_STATE_HOME="$probe/state"
cd "$probe/workspace"
"$1" --version
"$1" -e 'const { DatabaseSync } = require("node:sqlite"); const db = new DatabaseSync(":memory:"); console.log(db.prepare("SELECT sqlite_version() AS version").get().version); db.close()'
"$1" "$2" web --help

"$1" - "$2" <<'JS'
const { createRequire } = require("node:module");
const { spawn } = createRequire(process.argv[2])("node-pty");
const terminal = spawn("/bin/sh", ["-c", "printf 'dsh-pty-ok\\n'"], {
  name: "xterm",
  cols: 80,
  rows: 24,
  env: { PATH: "/usr/bin:/bin" },
});
let output = "";
const timeout = setTimeout(() => {
  process.exitCode = 1;
  terminal.kill();
}, 5000);
terminal.onData((chunk) => { output += chunk; });
terminal.onExit(({ exitCode }) => {
  clearTimeout(timeout);
  if (exitCode !== 0 || !output.includes("dsh-pty-ok")) {
    console.error("终端子进程验证失败");
    process.exitCode = 1;
    return;
  }
  console.log("通过：终端原生模块加载并运行了测试命令");
});
JS
