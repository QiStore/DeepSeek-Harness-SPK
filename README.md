# DeepSeek-Harness-SPK

DeepSeek Harness 的群晖 DSM 原生套件社区适配。在 NAS 上运行官方 Agent 和 Web UI，通过局域网浏览器访问。当前适配目标为 DS3615xs-j、DSM 6.2.3-25426、Bromolow x86_64。

## 下载与安装

当前构建为 **`0.0.0-0005`**。DSM 套件中心显示名为 **DeepSeek Harness**，并使用官方 Harness 图标。运行时载荷与 `0004` 的 SHA256 一致。

- [下载 DeepSeek-Harness-SPK-DSM6-bromolow-0005.spk](https://github.com/QiStore/DeepSeek-Harness-SPK/releases/download/v0.0.0-0005/DeepSeek-Harness-SPK-DSM6-bromolow-0005.spk)
- [Release 附带的 SHA256 校验](https://github.com/QiStore/DeepSeek-Harness-SPK/releases/download/v0.0.0-0005/SHA256SUMS.txt) · [变更记录](CHANGELOG.md)

1. 如已安装 `0004`，先备份要保留的配置和工作区。覆盖安装的数据保留仍待实机验证。
2. 在 **DSM 套件中心 → 手动安装** 选择 `0005`，安装后启动。
3. 在同一局域网打开 NAS 的 `192.168.1.x:3080`。首次访问请使用完整的登录链接，获取方式见 [安装、登录和排查](spk-test/README.md)。

## 验收状态

`0004` 已在目标设备通过局域网网页访问、DeepSeek 官方模型和一个第三方提供商的模型调用。Agent 工具执行、升级数据保留等项目仍待实机验证，**1.0.0 正式版尚未发布**。详见 [验收记录](ACCEPTANCE.md)。

## 官方上游

- 仓库：[deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness)
- 当前验证候选：[dsh-v0.2.2-rc.5](https://github.com/deepseek-ai/deepseek-harness/tree/9c2670d3bce5275e0d1610272958121af87787bb)
- 官方启动方式：`dsh web --no-open`
- [上游 MIT 许可证](https://github.com/deepseek-ai/deepseek-harness/blob/9c2670d3bce5275e0d1610272958121af87787bb/LICENSE)

