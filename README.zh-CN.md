# Codex Subagent Kit

[![CI](https://github.com/Charleyli925/codex-subagent-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/Charleyli925/codex-subagent-kit/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

使用 Codex 原生多 Agent 运行能力，再补上一套适合真实开发工作的委派、模型路由、
独立审查、测试和结果验收规则。

> 这是社区独立项目，不是 OpenAI 官方仓库。

[English](README.md)

## 先看安装之后会发生什么

你仍然像平常一样，在模型选择器里选择主 Agent 及其思考深度。本项目不会修改、
升级或降低你的主 Agent。

当任务足够大并且适合拆分时，主 Agent 可以把边界明确的工作交给一个小团队，
自己继续处理不冲突的关键路径，最后再核验并整合所有结果：

```text
你选择的主 Agent —— 保持不变
├── explorer  —— Codex 自带；查代码、执行路径和证据
├── worker    —— Codex 自带；完成一个边界明确的实现任务
├── reviewer  —— 本项目增加；在全新只读上下文里独立审查
└── tester    —— 本项目增加；针对冻结源码运行现有测试

Codex 负责运行这些线程，本项目负责规定它们如何协作。
```

所以仓库里虽然只定义了两份自定义 Agent TOML，实际使用的却是四个角色：
`explorer` 和 `worker` 已经由 Codex 提供，我们只补充缺少的 `reviewer` 和
`tester`，没有重复制造同名角色。

例如，一项功能开发可以把代码路径探索交给 `explorer`，主 Agent 保留关键实现，
耗时测试交给 `tester`，最终 diff 再交给拥有全新上下文的 `reviewer`。子 Agent
返回的摘要只是证据线索，是否完成仍由主 Agent 核验和决定。

## 我们没有重新造一套 Subagent

本项目不实现新的 Agent 运行时、不提供后台调度服务，也不替换 Codex 的编排。
它直接使用 Codex 已有能力，只在官方允许的配置和项目指令层增加规则。

| Codex 原生已经提供 | 本项目补充 |
| --- | --- |
| 内置 `default`、`explorer`、`worker` | 模型中立的 `reviewer`、`tester` |
| 创建 Agent 线程和并行执行 | 判断什么任务值得委派 |
| follow-up、等待、停止和线程生命周期 | 依赖分波、并发上限和单写者规则 |
| 继承主模型/思考深度，以及显式覆盖 | 默认继承和可选的 Sol/Astra 路由 |
| 继承父级权限，以及单 Agent sandbox 覆盖 | Reviewer 只读和 Tester 冻结源码约束 |
| 展示线程活动并汇总结果 | 自包含任务包、路由证据和主 Agent 验收 |

### 那么 V2 是什么关系？

一些本地客户端的会话记录会显示：

```text
multi_agent_version: "v2"
```

这可以理解为 Codex 当前多 Agent 运行时的实现标签。我们会使用客户端实际提供的
这套原生能力，但不会自己再实现一套 V2，也不会要求用户依赖未进入公开配置参考的：

```toml
[features]
multi_agent_v2 = true
```

本项目对外承诺的兼容边界只有官方公开的 `[agents]`、`.codex/agents/*.toml`、
模型/思考深度覆盖和 sandbox 配置。即使以后 Codex 不再使用“V2”这个内部标签，
只要这些公开能力仍然存在，默认方案就可以继续工作。

## 我们主动做出的几个选择

这些不是 Codex 的默认规则，而是从实际开发工作中提炼出来的可修改 preset。

### 选择一：Ultra 保持原生行为

Sol Ultra 和 Astra Ultra 继续使用 Codex 自己的主动委派、模型选择和运行时线程
选择。本项目不会把普通模式的模型路由、三线程上限、固定 Reviewer 或 Tester
要求强制套在 Ultra 上。

这意味着安装 `sol-astra` preset 后：

- Ultra 仍然是什么行为就保持什么行为；
- 项目定义的 Reviewer/Tester 仍然存在，但 Ultra 不被要求必须使用它们；
- 我们不会假装知道 Ultra 内部隐藏的 Agent 配置。

### 选择二：普通 Sol/Astra 的主 Agent 不变，子 Agent 重新分工

只有选择 `sol-astra` preset 时，Sol/Astra 的 Low、Medium、High、XHigh 和 Max
都会应用子 Agent 路由。受到影响的是委派出去的子 Agent，不是用户选择的主 Agent。

- `explorer`、`worker`、`tester`：使用 Luna Max；
- `reviewer`：使用与主 Agent 相同的模型家族；
- 其他主模型：子 Agent 默认继承主 Agent；
- 显式模型不可用：记录失败后，只允许继承主 Agent 重试一次。

我们的判断是：探索、明确实现和跑测试通常是边界清晰、高噪音或高吞吐的工作，
适合交给更快的模型，并通过 Max 思考深度提高稳定性。

### 选择三：Reviewer 不主动降级

Reviewer 负责发现高风险错误、回归、竞态和测试缺口。如果它还承担“能不能交付”
的关键证据职责，就不应该固定成比主 Agent 明显弱的模型。

因此 Reviewer：

- 与主 Agent 使用相同模型家族；
- 最低使用 High；
- 主 Agent 是 XHigh 或 Max 时继续向上对齐；
- 即使模型和深度相同，也通过全新上下文和专门审查指令提供独立价值。

### 选择四：角色和模型解耦

`reviewer` 描述的是职责，不等于某个固定模型。模型路由由 preset 和每次 spawn
共同决定。因此你可以不修改 Reviewer 的工作定义，只替换整个项目的模型策略；
也可以增加新角色而不复制一套以模型命名的 Agent。

## 我们从原生/Ultra 行为里学了什么

我们采用的是外部可以观察和验证的工作原则，而不是复制不可见的 Ultra 内部配置：

- 工作能够独立并行，而且明显改善速度或质量时才委派；
- 把代码探索、日志、测试输出等高噪音工作移出主上下文；
- 每个子 Agent 使用全新上下文和一个窄任务；
- 子 Agent 结果还不是依赖时，主 Agent 继续处理其他工作；
- 输入变化、任务跑偏、重复或源码过期时及时 steer/stop；
- 子 Agent 只返回精炼结果和证据位置；
- 主 Agent 检查实际 diff、文件、日志和测试结果后才能验收。

在此基础上，本项目补充了运行时无法替所有项目决定的规则：源码指纹、文件所有权、
依赖状态、必读文档、停止条件、模型路由证据和最终验收记录。

## 什么情况下会调用 Subagent？

`portable` 和 `sol-astra` 会让主 Agent 主动判断。通常需要同时满足：

1. 子任务具体、范围明确；
2. 可以独立执行；
3. 并行很可能明显节省时间或提高质量；
4. 能写清楚输入、权限、验收方式和停止条件。

适合委派：

- 查找文件、调用链、状态流和风险；
- 执行耗时的现有测试；
- 分析日志和第一失败证据；
- 问题分流与资料总结；
- 使用全新上下文进行独立审查；
- 多个互不依赖的实现任务。

通常不委派：

- 一两步就能完成的小修改；
- 正在阻塞下一步的唯一关键路径；
- 需要和主任务持续共享判断的紧耦合工作；
- 合并、发布、购买、发送消息等不可逆或需要新授权的操作。

`minimal` 更保守：用户明确要求 Subagent，或者大型任务存在明显独立工作线时
才会委派。

## 三套预设

| 预设 | 调用方式 | 模型选择 | 适用场景 |
| --- | --- | --- | --- |
| `portable` | 并行能明显改善速度或质量时主动委派 | 子 Agent 默认继承主 Agent | 推荐给大多数项目 |
| `sol-astra` | 普通模式主动委派，Ultra 保持原生行为 | Luna Max 承担探索、执行和测试；Reviewer 对齐主模型 | 使用 Sol/Astra 的项目 |
| `minimal` | 用户明确要求，或存在明显独立任务时才委派 | 继承主 Agent | 小项目、谨慎试用 |

模型是否可用取决于账号、客户端和时间，因此默认安装的是 `portable`，而不是
锁定具体模型的 `sol-astra`。

如果希望完整采用我们现在这套模型策略，把两条安装命令中的 `portable` 都替换为
`sol-astra` 即可。

## Sol/Astra 完整路由

这张表只在安装 `sol-astra` preset 时生效：

| 主 Agent 选择 | `explorer` / `worker` / `tester` | `reviewer` |
| --- | --- | --- |
| Sol Low / Medium / High | `gpt-5.6-luna` / `max` | `gpt-5.6-sol` / `high` |
| Sol XHigh | `gpt-5.6-luna` / `max` | `gpt-5.6-sol` / `xhigh` |
| Sol Max | `gpt-5.6-luna` / `max` | `gpt-5.6-sol` / `max` |
| Astra Low / Medium / High | `gpt-5.6-luna` / `max` | `gpt-6-astra` / `high` |
| Astra XHigh | `gpt-5.6-luna` / `max` | `gpt-6-astra` / `xhigh` |
| Astra Max | `gpt-5.6-luna` / `max` | `gpt-6-astra` / `max` |
| Sol/Astra Ultra | Codex 原生路由 | Codex 原生路由 |
| 其他主模型 | 继承主 Agent | 继承主 Agent |

## 哪些设置可以自己改？

所有 preset 都只是起点，安装后就是项目自己的普通 TOML 和 Markdown 文件。

| 可配置项 | 当前默认值 | 修改位置 |
| --- | --- | --- |
| 主动委派还是明确要求才委派 | 由 preset 决定 | 根目录 `AGENTS.md` |
| 最大并发子线程 | `portable` 为 3；`minimal` 为 2；`sol-astra` 普通模式为 3、Ultra 原生 | preset 配置和 `AGENTS.md` |
| 每个角色使用什么模型/深度 | 继承或 Sol/Astra 表 | `AGENTS.md` 路由规则 |
| Reviewer 最低思考深度 | `sol-astra` 中为 High | Reviewer 对齐表 |
| Ultra 是否走项目路由 | 默认否 | Ultra 路由规则 |
| 同时允许几个 Agent 写入 | 1 | `.codex/subagent-kit/orchestration.md` |
| 子 Agent 能否继续调用子 Agent | 默认否 | 主规则和 Agent 指令 |
| 模型不可用时如何 fallback | 继承重试一次 | 路由与编排规则 |
| 本次任务需要读什么文档 | 每次任务单独决定 | 任务包 `required_reading` |
| Reviewer/Tester 的行为和权限 | 本项目默认定义 | `.codex/agents/*.toml` |

## 可以增加自己的 Agent 吗？

可以。比如增加一个只负责安全审查的 Agent：

```toml
# .codex/agents/security-reviewer.toml
name = "security_reviewer"
description = "检查一个边界明确的 diff 是否引入具体安全回归。"
sandbox_mode = "read-only"
developer_instructions = """
只审查提供的 diff 和威胁边界。不要修改文件，也不要继续调用其他 Agent。
返回按严重程度排序的发现、文件证据和仍未验证的范围。
"""
```

然后在项目 `AGENTS.md` 中补充：

1. 什么情况下调用它；
2. 它继承主模型，还是使用指定模型/思考深度；
3. 它可以读取和操作什么；
4. 它需要返回哪些证据；
5. 主 Agent 如何验收结果。

新 Agent 也进入同一套任务包、依赖分波、生命周期和结果验收闭环，不需要另外
实现运行时。

## 五分钟安装

运行安装器需要 Bash 3.2 或更高版本；运行诊断和仓库测试需要 Python 3.11
或更高版本。目标环境还需要支持 Subagent 的当前 Codex 客户端。

```bash
git clone https://github.com/Charleyli925/codex-subagent-kit.git
cd codex-subagent-kit

# 先预览，不修改目标项目
./scripts/install.sh --preset portable --project /项目的绝对路径

# 确认后安装
./scripts/install.sh --preset portable --project /项目的绝对路径 --apply

# 检查是否激活
./scripts/doctor.sh --project /项目的绝对路径
```

安装完成后，从目标项目根目录开启一个新的 Codex 会话。

安装器永远不会覆盖已有的：

- `AGENTS.md`
- `.codex/config.toml`
- `.codex/agents/reviewer.toml`
- `.codex/agents/tester.toml`

如果目标文件已经存在，安装器会把待审阅版本放到 `.codex/subagent-kit/`，并提示
需要人工合并的位置。

## 为什么要渐进式披露？

根目录 `AGENTS.md` 只保留短规则。只有大型任务第一次实际委派前，主 Agent 才
读取 `.codex/subagent-kit/orchestration.md`。每个子 Agent 只收到自包含任务包和
本次任务需要的 `required_reading`，不会反复读取整个项目规范。

这样既能保证下沉规则真的按需被读取，又不会让每个模型、每次任务都承担完整文档
的上下文成本。

## 验证

```bash
bash tests/test-kit.sh
```

测试会解析全部 TOML、验证 dry-run、测试干净项目和已有配置项目的安装，并确保
公共核心不依赖 `multi_agent_v2`。

本项目遵循当前 [OpenAI 官方 Subagent 文档](https://learn.chatgpt.com/zh-Hans/docs/agent-configuration/subagents)。
详细兼容性边界见 [docs/compatibility.md](docs/compatibility.md)。

## 许可证

Apache License 2.0，详见 [LICENSE](LICENSE) 和 [NOTICE](NOTICE)。
