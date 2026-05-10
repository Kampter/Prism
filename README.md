# Evidence Agent

> AI 驱动的个人职业展示系统。让证据替你说话，让 Agent 替你社交。

[![Claude Code](https://img.shields.io/badge/Claude%20Code-2.1+-blue)](https://claude.ai/code)

## 是什么

一个为你个人打造的 AI Agent，整合你的 GitHub、技术博客、证书等多源数据，构建可验证的"证据链"。外部访客可以在与你真实交流之前，先与你的 Agent 深度对话——了解你的技术能力、项目经历、思维方式。聊得合适，再预约 Coffee Chat。

**核心价值**：
- 🎯 **降低不匹配** —— 访客先了解你，再决定是否深入交流
- 🤖 **24/7 替你社交** —— Agent 基于真实证据回答，不是编造
- 📊 **可视化证据链** —— 能力雷达图自动从 GitHub/博客生成
- 💬 **对话即筛选** —— 不匹配的访客在对话阶段自然过滤掉

## 截图（待补充）

| 能力雷达图 | Agent 对话界面 | 预约系统 |
|-----------|--------------|---------|
| (todo) | (todo) | (todo) |

## 技术栈

```
前端          后端           数据           AI
───────────────────────────────────────────────────
Next.js 15    FastAPI        PostgreSQL 17   Claude API
CopilotKit    LangGraph      pgvector        Anthropic SDK
shadcn/ui     Pydantic       asyncpg
Tailwind      Black/ruff
```

## 快速开始

### 前置要求

- Node.js 20+ + pnpm 9+
- Python 3.12+ + uv
- Docker（用于本地数据库）

### 本地开发

```bash
# 1. 克隆仓库
git clone https://github.com/Kampter/Prism.git
cd Prism

# 2. 启动数据库
docker-compose up -d postgres

# 3. 配置环境变量
cp .env.example .env
# 编辑 .env，填入你的 ANTHROPIC_API_KEY 等

# 4. 安装依赖
pnpm install

# 5. 启动前后端
pnpm dev
```

访问：
- 前端: http://localhost:3000
- 后端 API: http://localhost:8000
- 后端文档: http://localhost:8000/docs

## 项目结构

```
prism/
├── apps/
│   ├── web/              # Next.js 15 + CopilotKit 前端
│   │   ├── app/          # App Router 页面
│   │   ├── components/   # React 组件
│   │   └── lib/          # 工具函数
│   │
│   └── api/              # FastAPI + LangGraph 后端
│       ├── agents/       # LangGraph agent 定义
│       ├── routes/       # API 路由
│       ├── services/     # 业务逻辑（GitHub 抓取、RAG）
│       ├── tools/        # Agent 工具
│       └── tests/        # 测试
│
├── packages/
│   ├── database/         # PostgreSQL migrations + seeds
│   └── types/            # 前后端共享类型
│
├── .claude/              # Claude Code Harness（见下方）
├── docker-compose.yml    # 本地数据库
└── pnpm-workspace.yaml   # Monorepo 配置
```

## 开发命令

```bash
# 同时启动前后端
pnpm dev

# 单独启动
pnpm dev:web     # Next.js localhost:3000
pnpm dev:api     # FastAPI localhost:8000

# 数据库
pnpm db:migrate  # 执行 migration
pnpm db:seed     # 插入种子数据
pnpm db:studio   # 可视化数据库

# 代码质量
pnpm lint        # 前后端 lint
pnpm format      # 格式化
pnpm test        # 运行测试
```

## 环境变量

| 变量 | 说明 | 必填 |
|------|------|------|
| `ANTHROPIC_API_KEY` | Claude API 密钥 | ✅ |
| `DATABASE_URL` | PostgreSQL 连接字符串 | ✅ |
| `GITHUB_CLIENT_ID` | GitHub OAuth App ID | ⬜ |
| `GITHUB_CLIENT_SECRET` | GitHub OAuth App Secret | ⬜ |

完整变量列表见 `.env.example`。

## 路线图

- [ ] Week 1: GitHub OAuth + 数据抓取 + 能力雷达图
- [ ] Week 2: RAG 知识库 + Agent 对话 + 证据链引用
- [ ] Week 3: 预约系统（Generative UI）+ 后台管理
- [ ] Week 4: 自己先用，验证假设

## 开发基础设施

本仓库同时作为 **Claude Code 生产级 harness** 参考实现。包含：

| 功能 | 位置 |
|------|------|
| 代码 Review | `.claude/agents/code-reviewer.md` |
| 安全审计 | `.claude/agents/security-auditor.md` |
| 自动化测试 | `.claude/agents/test-writer.md` |
| 提交规范 | `/commit` skill |
| 安全扫描 | `.claude/hooks/security-scan.sh` |
| 代码格式化 | `.claude/hooks/format-code.sh` |

完整 harness 指南: [docs/harness-guide.md](docs/harness-guide.md)

## License

MIT — see [LICENSE](LICENSE)
