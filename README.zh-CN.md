# Codex Subagent Kit

一套可移植、项目级的 Codex Subagent 工作流：角色清晰、路由显式、并发有界、
渐进式读取，并由主 Agent 基于证据验收结果。

> 这是社区独立项目，不是 OpenAI 官方仓库。

## 它解决什么问题

很多 Subagent 示例只提供几份 TOML，却没有说明：什么时候委派、如何避免并发
写冲突、子任务应该包含哪些输入、路由错误如何处理，以及主 Agent 如何验收。

本项目提供完整但可渐进读取的闭环：

- 使用 Codex 内置 `explorer`、`worker`；
- 提供模型中立的 `reviewer`、`tester`；
- 默认继承主 Agent 模型；
- 可选 Sol/Astra 路由；
- 提供任务包、依赖分波、线程生命周期和结果验收规则；
- 提供不覆盖已有项目配置的安装器。

运行安装器需要 Bash 3.2 或更高版本；运行诊断和仓库测试需要 Python 3.11
或更高版本。目标环境还需要支持 Subagent 的当前 Codex 客户端。

## 五分钟开始

```bash
git clone https://github.com/Charleyli925/codex-subagent-kit.git
cd codex-subagent-kit

# 先预览，不修改目标项目
./scripts/install.sh --preset portable --project /项目的绝对路径

# 确认后安装
./scripts/install.sh --preset portable --project /项目的绝对路径 --apply

# 检查激活状态
./scripts/doctor.sh --project /项目的绝对路径
```

安装完成后，从目标项目根目录开启一个新的 Codex 会话。

## 三套预设

| 预设 | 调用方式 | 模型选择 | 适用场景 |
| --- | --- | --- | --- |
| `portable` | 并行能明显改善速度或质量时主动委派 | 默认继承主 Agent | 推荐给大多数项目 |
| `sol-astra` | 普通模式主动委派，Ultra 保持原生行为 | Luna Max 承担探索、执行和测试；Reviewer 对齐主模型 | 使用 Sol/Astra 路由的项目 |
| `minimal` | 用户明确要求，或存在明显独立任务时才委派 | 继承主 Agent | 小项目、谨慎试用 |

角色和模型保持解耦：角色决定“做什么”，preset 决定“用什么模型和思考深度”。

## 安全安装

安装器默认是 dry-run，并且永远不会覆盖现有的：

- `AGENTS.md`
- `.codex/config.toml`
- `.codex/agents/reviewer.toml`
- `.codex/agents/tester.toml`

如果目标文件已经存在，安装器会把可审阅版本放到
`.codex/subagent-kit/`，并提示需要人工合并的位置。

## 渐进式披露

根目录 `AGENTS.md` 只保留短规则。大型任务第一次委派前，主 Agent 才读取
`.codex/subagent-kit/orchestration.md`。每个子 Agent 只收到自包含任务包和与本次
任务有关的 `required_reading`，不会反复读取整个项目规范。

## 默认角色

| 角色 | 来源 | 职责 |
| --- | --- | --- |
| `explorer` | Codex 内置 | 只读探索文件、执行路径和风险 |
| `worker` | Codex 内置 | 完成一个边界明确的实现任务 |
| `reviewer` | 本项目 | 使用全新上下文做独立审查，不修改文件 |
| `tester` | 本项目 | 运行现有测试、保存证据，不修改源码和断言 |

主 Agent 始终负责授权边界、模型路由、写冲突控制、纠偏、整合与最终验收。

## 兼容性边界

本项目只依赖 OpenAI 官方文档公开的 `[agents]`、`.codex/agents/*.toml`、
`model`、`model_reasoning_effort` 和 `sandbox_mode`。

公共版本不依赖未公开的 `multi_agent_v2` 开关。模型是否可用取决于用户的账号、
客户端和时间；因此默认 preset 不锁定任何模型。

## 项目自己的规则放在哪里

具体项目的测试命令、架构约束、PR/合并制度和发布授权应留在项目自己的
`AGENTS.md` 中。通过任务包的 `required_reading` 把相关章节交给子 Agent，
不要把产品规则复制进通用角色。

## 验证

```bash
bash tests/test-kit.sh
```

测试会解析全部 TOML、验证 dry-run、测试干净项目和已有配置项目的安装，并检查
公共核心没有依赖 `multi_agent_v2`。

## 许可证

Apache License 2.0，详见 [LICENSE](LICENSE) 和 [NOTICE](NOTICE)。
