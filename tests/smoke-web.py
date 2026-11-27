#!/usr/bin/env python3
"""启动官方 Web 服务并验证匿名访问与启动凭据交换。"""
import os
from pathlib import Path
import re
import selectors
import subprocess
import sys
import tempfile
import time
from urllib.error import HTTPError
from urllib.request import build_opener, HTTPCookieProcessor, ProxyHandler

node, entry = (str(Path(path).resolve(strict=True)) for path in sys.argv[1:])
with tempfile.TemporaryDirectory() as home:
    env = {
        "PATH": os.environ["PATH"],
        "HOME": home,
        "XDG_CONFIG_HOME": f"{home}/config",
        "XDG_DATA_HOME": f"{home}/data",
        "XDG_CACHE_HOME": f"{home}/cache",
        "XDG_STATE_HOME": f"{home}/state",
    }
    with subprocess.Popen(
        [node, entry, "web", "--host", "127.0.0.1", "--port", "0", "--no-open"],
        cwd=home, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
    ) as server:
        try:
            with selectors.DefaultSelector() as selector:
                selector.register(server.stdout, selectors.EVENT_READ)
                deadline = time.monotonic() + 35
                output = b""
                while time.monotonic() < deadline:
                    if not selector.select(max(0, deadline - time.monotonic())):
                        break
                    chunk = os.read(server.stdout.fileno(), 8192)
                    if not chunk:
                        break
                    output += chunk
                    match = re.search(rb"http://127\.0\.0\.1:\d+/[^\s\x1b]+", output)
                    if match:
                        break
            if not (match := re.search(rb"http://127\.0\.0\.1:\d+/([^\s\x1b]+)", output)):
                raise RuntimeError("未收到官方 Web 启动地址")
            launch_url = match.group(0).decode()
            root = launch_url.split("?", 1)[0]
            if launch_url == root or not root.endswith("/"):
                raise RuntimeError("官方启动地址格式变化")
            browser = build_opener(ProxyHandler({}), HTTPCookieProcessor())
            try:
                with browser.open(root, timeout=5):
                    raise RuntimeError("匿名请求获得了 Web 页面")
            except HTTPError as error:
                if error.code not in (401, 403):
                    raise
            # 启动地址含进程凭据，异常时也避免将其写入测试日志。
            try:
                with browser.open(launch_url, timeout=5) as response:
                    if response.status != 200 or "text/html" not in response.headers.get("Content-Type", ""):
                        raise RuntimeError("官方 Web 页面响应异常")
                with browser.open(root, timeout=5) as response:
                    if response.status != 200:
                        raise RuntimeError("会话响应异常")
            except Exception:
                raise RuntimeError("官方启动凭据交换或会话 Cookie 验证失败") from None
            print("通过：Web 服务启动、匿名访问拦截、会话 Cookie")
        finally:
            server.terminate()
            try:
                server.wait(timeout=5)
            except subprocess.TimeoutExpired:
                server.kill()
                server.wait()
