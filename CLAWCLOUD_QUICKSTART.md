# ⚡ ClawCloud 快速部署

## 5 分钟完成部署

### 1. 推送代码触发自动构建（1分钟）

```bash
git add .
git commit -m "Deploy to ClawCloud"
git push
```

镜像地址：`ghcr.io/<your-github-username>/daily_stock_analysis:latest`

### 2. ClawCloud 控制台配置（3分钟）

#### 基础配置
```
应用名称: stock-analyzer
镜像地址: ghcr.io/<username>/daily_stock_analysis:latest
实例数: 1
CPU: 1核
内存: 512MB
```

#### 环境变量（必填）
```
STOCK_LIST=600519,300750,002594
GEMINI_API_KEY=your_google_ai_key
```

#### 环境变量（推荐）
```
WECHAT_WEBHOOK_URL=your_wechat_webhook
TAVILY_API_KEYS=your_tavily_key
BOCHA_API_KEYS=your_bocha_key
```

#### 持久存储
```
/app/data  -> 100MB
/app/logs  -> 500MB
/app/reports -> 1GB
```

#### 端口
```
8000/tcp (WebUI，可选)
```

### 3. 部署验证（1分钟）

访问应用 URL，检查日志确认启动成功。

---

## 验证命令

```bash
# 检查容器状态
docker ps | grep stock

# 查看日志
docker logs -f stock-analyzer

# 手动执行测试
docker exec stock-analyzer python main.py --dry-run
```

## 下一步

- 配置定时任务：`SCHEDULE_ENABLED=true`
- 启用 WebUI：`WEBUI_ENABLED=true`
- 配置通知渠道

详细文档：[CLAWCLOUD.md](./CLAWCLOUD.md)
