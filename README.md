# DeepSeek-Harness-SPK

DeepSeek Harness 的群晖 DSM 原生套件社区适配。目标是在 NAS 上运行官方 Agent 和 Web UI，供电脑、手机和平板通过浏览器访问。

## 当前可用构建

`0.0.0-0005` 将套件中心名称改为 DeepSeek Harness，并更新产品描述。运行时载荷与 `0004` 一致。

`0.0.0-0004` 已在 DS3615xs-j、DSM 6.2.3-25426、Bromolow x86_64 上通过局域网 Web UI、DeepSeek 官方模型和一个第三方提供商的模型调用。

- [安装、登录和排查](spk-test/README.md)
- [SHA256 校验](SHA256SUMS.txt)
- [变更记录](CHANGELOG.md)
- [实机验收与正式发布条件](ACCEPTANCE.md)

## 官方上游

- 仓库：[deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness)
- 当前验证候选：[dsh-v0.2.2-rc.5](https://github.com/deepseek-ai/deepseek-harness/tree/9c2670d3bce5275e0d1610272958121af87787bb)
- 官方启动方式：`dsh web --no-open`
- [上游 MIT 许可证](https://github.com/deepseek-ai/deepseek-harness/blob/9c2670d3bce5275e0d1610272958121af87787bb/LICENSE)

目标设备为 DSM 6.2.3-25426 / Bromolow x86_64。运行时验证和正式发布条件见 [ACCEPTANCE.md](ACCEPTANCE.md)。
