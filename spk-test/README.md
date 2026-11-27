# DSM 6.2.3 实机测试包

适用于 DS3615xs-j / Bromolow x86_64。套件构建号为 `0.0.0-0003`，内置 Node.js 24.22.3 glibc 2.17 社区构建和官方 DeepSeek Harness 0.2.2-rc.5。内置套件专用的 libstdc++ 和 libgcc，修复 0001 在 DSM 上遇到的 GLIBCXX_3.4.21 加载错误。测试数据随套件程序存放，请使用临时工作区和测试数据。

1. DSM 套件中心 → 手动安装，选择 SPK。安装后点击运行。
2. 在同一局域网内，用电脑或手机访问 NAS 的 `192.168.1.x:3080`。首次登录需要启动链接。在 NAS 上通过 SSH 读取该链接。

   ```sh
   sudo grep -F ':3080/' /var/packages/DeepSeek-Harness-SPK/target/.test-state/startup.log | tail -n 1
   ```

3. 打开日志中的完整链接，保留查询参数。启动链接带登录凭据，仅自己使用。服务使用 HTTP，限可信局域网，避免在路由器上做公网端口转发。
4. 若 DSM 报启动失败，查看同一日志，回传错误行前删去启动链接和任何 API Key。停止套件后再次访问原链接，应无法连接。
5. 可用以下命令单独验证目标机的 SQLite、CLI 和 PTY 原生模块。

   ```sh
   cd /var/packages/DeepSeek-Harness-SPK/target
   sudo -u dshspk env LD_LIBRARY_PATH="$PWD/runtime/compat-lib" sh ./check-runtime.sh "$PWD/runtime/node" "$PWD/runtime/node_modules/@deepseek-ai/dsh/lib/bin.js"
   ```

服务自动选用 NAS 上的一个 `192.168.1.x` 地址监听 3080。DSM 菜单、升级保留、异常恢复和正式发布仍在后续交付范围内。
