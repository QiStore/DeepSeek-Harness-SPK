# DSM 6.2.3 实机测试包

适用于 DS3615xs-j / Bromolow x86_64。套件构建号为 `0.0.0-0001`，内置 Node.js 24.22.3 glibc 2.17 社区构建和官方 DeepSeek Harness 0.2.2-rc.5。测试数据随套件程序存放，请使用临时工作区和测试数据。

1. DSM 套件中心 → 手动安装，选择 SPK。安装后点击运行。
2. 在 Windows PowerShell 建立 SSH 隧道。将 `DSM用户` 替换为可以 SSH 登录 NAS 的管理员账号。

   ```powershell
   ssh -L 3080:127.0.0.1:3080 DSM用户@192.168.1.48
   ```

3. 在这个 SSH 会话下查看私有启动信息，复制日志中最新的本机启动链接到电脑浏览器。链接包含启动凭据，仅自己使用。

   ```sh
   sudo grep 'http://127.0.0.1:3080/' /var/packages/DeepSeek-Harness-SPK/target/.test-state/startup.log
   ```

4. 若 DSM 报启动失败，查看同一日志，回传错误行前删去 URL 中的启动凭据和任何 API Key。安装失败时保留套件中心报错。停止套件后再次访问原链接，应无法连接。
5. 可用以下命令单独验证目标机的 SQLite、CLI 和 PTY 原生模块。

   ```sh
   cd /var/packages/DeepSeek-Harness-SPK/target
   sudo -u dshspk sh ./check-runtime.sh "$PWD/runtime/node" "$PWD/runtime/node_modules/@deepseek-ai/dsh/lib/bin.js"
   ```

当前测试入口仅绑定本机端口 3080。DSM 菜单、升级保留、异常恢复和正式发布仍在后续交付范围内。
