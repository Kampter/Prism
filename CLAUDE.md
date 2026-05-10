# Evidence Agent — 个人职业 AI Agent

## 项目概述

Evidence Agent 是一个 AI 驱动的个人职业展示系统。核心逻辑：通过多源数据（GitHub、技术博客、证书等）构建可验证的"证据链"，让外部访客在与你真实交流之前，先与你的 Agent 深度对话，了解你的能力、想法和性格，从而降低不匹配的概率。

> 这是为内向者（i 人）设计的职业社交基础设施——不依赖面试表现，而是让真实积累的证据替你说话。

## 技术架构

```
┌─────────────────────────────────────────────────────────────┐
│                      前端层：apps/web                        │
│  Next.js 15 + CopilotKit + shadcn/ui + Tailwind CSS        │
│  • 能力雷达图（GitHub 数据可视化）                            │
│  • Agent 聊天界面（CopilotChat / CopilotPopup）              │
│  • Generative UI（预约按钮、表单等由 Agent 动态渲染）         │
│  • 双向状态同步（Agent 能读能改前端状态）                      │
└─────────────────────────────────────────────────────────────┘
                              ↑↓
┌─────────────────────────────────────────────────────────────┐
│                      后端层：apps/api                        │
│  FastAPI + LangGraph + Anthropic SDK                        │
│  • Agent 编排（LangGraph 图状态机）                           │
│  • RAG 检索（PostgreSQL + pgvector）                         │
│  • 数据抓取（GitHub API、RSS、PDF 解析）                      │
│  • 工具调用（搜索证据、生成预约、发送通知）                    │
│  • CopilotKit AG-UI 协议端点                                 │
└─────────────────────────────────────────────────────────────┘
                              ↑↓
┌─────────────────────────────────────────────────────────────┐
│                      数据层：packages/database               │
│  PostgreSQL 17 + pgvector                                   │
│  • 证据链数据（GitHub 项目、博客文章、证书）                   │
│  • 对话历史                                                 │
│  • 预约记录                                                 │
│  • 向量索引（用于 RAG）                                      │
└─────────────────────────────────────────────────────────────┘
```

## 目录结构

```
prism/
├── apps/
│   ├── web/           # Next.js 15 + CopilotKit 前端
│   └── api/           # FastAPI + LangGraph 后端
├── packages/
│   ├── database/      # PostgreSQL schema + migrations
│   └── types/         # 前后端共享 TypeScript 类型
├── .claude/           # Claude Code Harness 基础设施
│   ├── agents/        # 子 agent 定义
│   ├── skills/        # 斜杠命令
│   ├── hooks/         # 生命周期钩子
│   ├── rules/         # 路径规则（python.md / typescript.md / shell.md）
│   └── settings.json  # 项目权限与配置
├── docker-compose.yml # 本地开发数据库
└── pnpm-workspace.yaml
```

## 开发约定

### 前端（apps/web）
- **框架**: Next.js 15 App Router, React 19
- **UI**: shadcn/ui + Tailwind CSS
- **AI**: CopilotKit (@copilotkit/react-core, @copilotkit/react-ui)
- **图表**: Recharts（能力雷达图）
- **格式化**: Prettier, 100 char line length
- **类型**: Strict TypeScript

### 后端（apps/api）
- **框架**: FastAPI
- **Agent**: LangGraph (Python)
- **AI**: Anthropic SDK (Claude)
- **数据库**: asyncpg + sqlalchemy
- **格式化**: Black, 88 char line length
- **类型**: 全类型提示 (type hints)

### 提交规范
- Conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`
- 分支前缀: `feature/`, `fix/`, `hotfix/`
- `main` 受保护

## 安全

- `.env` 文件受 PreToolUse 钩子保护（禁止 Write/Edit）
- `node_modules/` 和 `.git/` 对所有子 agent 只读
- MCP 服务器使用托管策略
- 所有代码变更需 review subagent 审批

## 快速开始

```bash
# 1. 启动本地数据库
docker-compose up -d postgres

# 2. 复制环境变量并填入 API keys
cp .env.example .env

# 3. 安装依赖
pnpm install

# 4. 启动前后端（并行）
pnpm dev

# 前端: http://localhost:3000
# 后端: http://localhost:8000
```

## 关键设计决策

| 决策 | 选择 | 原因 |
|------|------|------|
| 前端 Agent UI | CopilotKit | 唯一支持 Generative UI + 双向状态同步的框架 |
| 后端 Agent 编排 | LangGraph | 图状态机天然适合多步骤 RAG + 预约引导流程 |
| AI 模型 | Claude (Anthropic) | 长上下文、指令遵循好、适合 RAG 引用 |
| 数据库 | PostgreSQL + pgvector | 证据链量小，无需单独向量数据库 |
| 包管理 | pnpm workspace | monorepo 统一管理前后端 |

---

## 附录：Harness 基础设施索引

本仓库同时作为 Claude Code 生产级 harness 参考实现。Harness 组件：

| 组件 | 位置 | 说明 |
|------|------|------|
| Subagents | `.claude/agents/` | code-reviewer, security-auditor, test-writer, debugger |
| Skills | `.claude/skills/` | /review, /test, /debug, /commit |
| Hooks | `.claude/hooks/` | security-scan, format-code, run-tests |
| Rules | `.claude/rules/` | python.md, typescript.md, shell.md |
| Setup | `scripts/setup.sh` | 环境初始化 |
| Validation | `scripts/validate.sh` | Harness 完整性检查 |

完整 harness 指南: `docs/harness-guide.md`
