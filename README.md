# api-monitor 📊 硅基流动（SiliconFlow）API 用量监控

一个**零依赖**的本地反向代理，透明地记录你（或任意客户端）调用硅基流动模型 API 的每一笔请求：
模型、输入/输出 token、耗时、HTTP 状态、估算费用，并生成带图表的 HTML 统计报告。

> 特点：**不改程序代码**，只改一行 `baseURL`（可逆、改前自动备份）；代理不需要你的 API key（原样透传）。适合小白上手。

---

## ✨ 功能

- 🔁 **透明反代**：把请求原样转发到 `api.siliconflow.cn`，结果原样返回——对调用方完全透明，功能不变、不冲突。
- 🧮 **逐笔记录**：时间、模型、prompt/completion/total tokens、缓存 token、耗时、状态、估算费用。
- 📈 **HTML 报告**：卡片统计（请求数/token/费用/成功率/平均耗时）+ 按小时折线趋势 + 按模型/端点汇总。
- 🧾 **明细日志**：`data/api-traffic.jsonl`（每行一条 JSON，方便二次处理）。
- 🩺 **小白友好日志**：运行日志 `logs/run.log`，启动时把关键信息、常见故障和解决提示都写清楚。
- 🌐 同时提供 `GET /__stats.json` 原始聚合，方便对接其他工具。
- 🎨 支持**流式（SSE）和非流式**响应。

---

## 📁 目录结构

```
api-monitor/
├─ proxy-server.js        # 反代 + 日志 + 实时报告服务（核心）
├─ gen-report.js          # 生成静态 HTML 报告 & stats.json
├─ toggle-dsh.js          # 一键切换/还原 DSH 的 baseURL（改前自动备份）
├─ start.bat              # Windows 双击启动（小白友好）
├─ start.sh               # Linux / macOS 启动
├─ pricing.json           # 费用估算单价（可改）
├─ package.json           # Node 项目元信息
├─ .gitignore             # 忽略生成的 data/ 与 logs/
├─ LICENSE                # MIT
├─ README.md              # 本文件
├─ examples/              # 示例日志（供仓库展示）
├─ data/                  # 运行后生成：api-traffic.jsonl、api-report.html、stats.json
└─ logs/                  # 运行后生成：run.log
```

---

## 🚀 快速开始

### 前提
- 需要 [Node.js](https://nodejs.org) ≥ 16（无需 npm install，无任何第三方依赖）。

### 1. 启动监控代理
**Windows**：双击 `start.bat`；或命令行
```bash
node proxy-server.js
```
**Linux/macOS**：`bash start.sh` 或 `node proxy-server.js`

可改用环境变量：`DSH_PROXY_PORT`（默认 8787）、`DSH_PROXY_HOST`（默认 127.0.0.1）、`DSH_UPSTREAM`（默认 `https://api.siliconflow.cn`）。

启动后浏览器打开 **`http://127.0.0.1:8787/__report`** 查看报告，`/__stats.json` 看原始聚合。

### 2. 把要监控的客户端指向本代理
以 DeepSeek Harness 为例（也可用于任何把 baseURL 指向硅基流动的程序）：
```bash
node toggle-dsh.js apply     # baseURL -> http://127.0.0.1:8787/v1（自动备份）
node toggle-dsh.js status    # 查看当前
node toggle-dsh.js restore   # 还原官方地址
```
> 切换/还原只改配置文件里一行 `baseURL`，已自动备份为 `.bak`，可逆。改动需让客户端重新加载配置（如重启 DSH）后生效。

### 3. 生成离线报告
```bash
node gen-report.js           # 生成 data/api-report.html 和 data/stats.json
```

---

## 🩹 小白故障排查

| 症状 | 常见原因 | 怎么解决 |
|---|---|---|
| 双击 `start.bat` 一闪而过/报「没有找到 Node」 | 没装 Node.js | 到 https://nodejs.org 下载安装，装完重开。可在命令行输入 `node -v` 确认。 |
| 启动报 **端口被占用**（EADDRINUSE） | 代理可能已在跑，或端口被别的程序占用 | 先打开 `http://127.0.0.1:8787/__report` 看是否已有代理；若被其它程序占用，换端口：`set DSH_PROXY_PORT=8788` 再启动。 |
| 打开报告页空白/连不上 | 代理没在运行，或地址打错 | 确认代理窗口还开着；地址应为 `http://127.0.0.1:8787/__report`。 |
| 转发了但客户端报「Token is invalid / 401」 | 客户端没带 API key（或 key 不在它的环境里） | 代理是原样透传的，请检查客户端是否正确配置了 `SILICONFLOW_API_KEY`。 |
| 请求明细里有记录，但 **token 栏为空** | 流式请求，上游没在末尾返回 `usage` 字段 | 属正常，流式若拿不到 usage 则此列留空；非流式能精确统计。 |
| 费用为 **估算** | 用的是 `pricing.json` 里的默认单价 | 打开 `pricing.json` 按真实价格修改单价即可。 |
| 改了 `baseURL` 不生效 | 客户端没重新加载配置 | 重启客户端/新会话后再试。 |
| 想彻底还原直连 | 之前执行过 apply | 运行 `node toggle-dsh.js restore`。 |
| 报告/日志里的**私人数据**不该公开 | `data/` 和 `logs/` 会被 git 忽略 | 已在 `.gitignore` 排除；发布仓库时不会带上你的真实数据。 |

遇到其它问题：日志都在 **`logs/run.log`**，把报错贴去提 [issue](../../issues) 即可（记得先隐去 API key）。
## ⚠️ 免责声明
- 费用为**估算**，不保证与硅基流动账单完全一致，请以官方账单为准。
- 本工具只记录请求**元数据**（模型名、token 数、耗时等），**不记录 prompt/回答内容**，尽量保护隐私；具体是否记录内容由上游返回内容决定，本代理默认不落正文。
