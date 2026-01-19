# 🚀 ClawCloud 部署指南

本项目已预配置 Docker 镜像，支持一键部署到 ClawCloud。

## 部署方式对比

| 方式 | 复杂度 | 维护成本 | 推荐场景 |
|------|--------|----------|----------|
| **GitHub Container Registry** ⭐ | ⭐ | 最低 | **推荐**：代码推送自动构建镜像 |
| **本地构建上传** | ⭐⭐ | 中等 | 无 GitHub 自动化需求 |
| **ClawCloud 构建** | ⭐⭐⭐ | 高 | 需要完全自定义构建过程 |

---

## 📋 方式一：GitHub Container Registry（推荐）

### 步骤 1: 启用 GitHub Packages

项目已配置 `docker-publish.yml`，每次推送到 main 分支会自动构建并推送镜像到 GitHub Container Registry。

```bash
# 推送代码触发自动构建
git add .
git commit -m "Prepare for ClawCloud deployment"
git push origin main
```

镜像地址格式：
```
ghcr.io/<your-username>/daily_stock_analysis:latest
```

### 步骤 2: 配置 ClawCloud

1. **创建应用**
   - 登录 ClawCloud 控制台
   - 选择「创建应用」→「容器应用」
   - 填写应用名称：`stock-analyzer`

2. **配置镜像**
   - 镜像地址：`ghcr.io/<your-username>/daily_stock_analysis:latest`
   - 认证方式：使用 GitHub Personal Access Token

3. **配置环境变量**（重要！）

   在 ClawCloud 环境变量配置中添加以下必填项：

   | 环境变量 | 值 | 说明 |
   |----------|-----|------|
   | `STOCK_LIST` | `600519,300750,002594` | 自选股列表 |
   | `GEMINI_API_KEY` | `your_google_ai_key` | Google AI Studio 获取 |
   | `WECHAT_WEBHOOK_URL` | `your_wechat_webhook` | 企业微信（可选） |
   | `FEISHU_WEBHOOK_URL` | `your_feishu_webhook` | 飞书（可选） |
   | `TAVILY_API_KEYS` | `your_tavily_key` | 新闻搜索（推荐） |
   | `BOCHA_API_KEYS` | `your_bocha_key` | 中文搜索（推荐） |

   **可选通知渠道**：
   ```
   TELEGRAM_BOT_TOKEN=xxx
   TELEGRAM_CHAT_ID=xxx
   EMAIL_SENDER=your@email.com
   EMAIL_PASSWORD=your_password
   CUSTOM_WEBHOOK_URLS=url1,url2
   ```

4. **配置持久存储**

   创建以下持久卷挂载：

   | 挂载路径 | 大小 | 说明 |
   |----------|------|------|
   | `/app/data` | 100MB | 数据库文件 |
   | `/app/logs` | 500MB | 日志文件 |
   | `/app/reports` | 1GB | 分析报告 |

5. **配置端口**

   | 容器端口 | 协议 | 说明 |
   |----------|------|------|
   | `8000` | TCP | WebUI 端口（可选） |

6. **配置健康检查**

   ```
   检查路径: / (或自定义)
   初始延迟: 30秒
   检查间隔: 30秒
   超时时间: 10秒
   不健康阈值: 3
   ```

7. **资源配置建议**

   ```
   CPU: 1核
   内存: 512MB
   实例数: 1
   ```

### 步骤 3: 启动应用

1. 点击「部署」按钮
2. 观察日志确认启动成功
3. 访问应用 URL（如配置了 WebUI）

---

## 📋 方式二：本地构建上传

### 步骤 1: 本地构建镜像

```bash
# 构建镜像
docker build -t daily_stock_analysis:latest .

# 打标签
docker tag daily_stock_analysis:latest <clawcloud-registry>/daily_stock_analysis:latest

# 推送到 ClawCloud 仓库
docker push <clawcloud-registry>/daily_stock_analysis:latest
```

### 步骤 2: 在 ClawCloud 创建应用

参考「方式一」的步骤 2-7。

---

## 📋 方式三：ClawCloud 源码构建

### 步骤 1: 连接到代码仓库

1. 在 ClawCloud 选择「源码构建」
2. 连接 GitHub 仓库
3. 选择分支：`main`

### 步骤 2: 配置构建命令

```
构建命令: docker build -t daily_stock_analysis .
工作目录: /
```

### 步骤 3: 配置运行环境

```yaml
# ClawCloud 运行环境配置
runtime: python 3.11
build_command: pip install -r requirements.txt
start_command: python main.py --schedule --webui
```

### 步骤 4: 配置环境变量和挂载卷

参考「方式一」的步骤 3-5。

---

## ⚙️ 配置说明

### 必须配置项

| 配置项 | 说明 | 获取方式 |
|--------|------|----------|
| `STOCK_LIST` | 自选股列表 | 逗号分隔股票代码 |
| `GEMINI_API_KEY` | AI 分析必需 | [Google AI Studio](https://aistudio.google.com/) |

### 推荐配置项

| 配置项 | 说明 |
|--------|------|
| `WECHAT_WEBHOOK_URL` | 企业微信推送 |
| `FEISHU_WEBHOOK_URL` | 飞书推送 |
| `TAVILY_API_KEYS` | 新闻搜索（每月1000次免费） |
| `BOCHA_API_KEYS` | 中文搜索优化 |

### 定时任务配置

```bash
# 启用定时任务
SCHEDULE_ENABLED=true

# 执行时间（北京时间）
SCHEDULE_TIME=18:00

# 大盘复盘
MARKET_REVIEW_ENABLED=true
```

### WebUI 配置（可选）

```bash
# 启用 WebUI
WEBUI_ENABLED=true
WEBUI_HOST=0.0.0.0
WEBUI_PORT=8000

# 登录认证（公网部署必填）
WEBUI_USERNAME=admin
WEBUI_PASSWORD=your_strong_password
```

---

## 🔧 高级配置

### 代理配置（如果需要）

```bash
# 如果服务器在国内，访问 Gemini API 需要代理
http_proxy=http://your-proxy:port
https_proxy=http://your-proxy:port
```

### 资源限制

```yaml
# docker-compose.yml 中的资源限制
deploy:
  resources:
    limits:
      memory: 512M
    reservations:
      memory: 256M
```

### 日志配置

```bash
LOG_DIR=/app/logs
LOG_LEVEL=INFO
MAX_WORKERS=3
```

---

## 🆘 常见问题

### 1. 镜像拉取失败

```bash
# 检查镜像地址是否正确
docker pull ghcr.io/<username>/daily_stock_analysis:latest

# 检查认证凭据
docker login ghcr.io -u <username> -p <token>
```

### 2. 容器启动失败

```bash
# 查看容器日志
docker logs <container_id>

# 常见原因：
# - 环境变量未配置
# - 端口被占用
# - 持久卷权限问题
```

### 3. 数据库锁定

```bash
# 停止服务后删除 lock 文件
rm /app/data/*.lock
```

### 4. API 访问超时

- 检查代理配置
- 确认服务器能访问 Gemini API
- 增加 `GEMINI_REQUEST_DELAY` 值

### 5. 内存不足

调整 ClawCloud 配置中的内存限制：

```
最小内存: 256MB
最大内存: 512MB
```

---

## 📊 监控与维护

### 查看日志

```bash
# 实时日志
docker logs -f <container_id>

# 最近 100 行
docker logs --tail 100 <container_id>
```

### 健康检查

```bash
# 检查容器状态
docker ps

# 检查端口监听
netstat -tlnp | grep 8000
```

### 定期维护

```bash
# 清理旧日志（保留7天）
find /app/logs -mtime +7 -delete

# 清理旧报告（保留30天）
find /app/reports -mtime +30 -delete
```

---

## 🔄 更新部署

### GitHub Actions 自动更新（推荐）

```bash
# 推送代码更新，自动触发重新部署
git add .
git commit -m "Update: xxx"
git push
```

### 手动更新

```bash
# 1. 拉取最新镜像
docker pull ghcr.io/<username>/daily_stock_analysis:latest

# 2. 重启容器
docker-compose restart

# 或使用蓝绿部署（零停机）
docker-compose up -d --no-deps
```

---

## 📝 快速检查清单

部署前确认：

- [ ] 已配置 `GEMINI_API_KEY`
- [ ] 已配置 `STOCK_LIST`
- [ ] 已配置至少一个通知渠道
- [ ] 已创建持久存储卷
- [ ] 已配置健康检查
- [ ] 资源分配合理（建议 512MB+）
- [ ] 已测试应用启动

---

## 💡 提示

1. **首次部署建议**：先不使用定时任务，手动执行一次确认功能正常
2. **监控告警**：配置 ClawCloud 的告警通知，及时发现问题
3. **定期检查**：每周查看日志，确认分析报告正常生成
4. **备份数据**：定期备份 `/app/data` 目录

---

## 📞 支持

- 项目 Issues: https://github.com/ZhuLinsen/daily_stock_analysis/issues
- 部署问题请提供：
  - 错误日志
  - 环境配置（脱敏）
  - 复现步骤

**祝部署顺利！🎉**
