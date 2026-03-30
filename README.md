# OpenClaw Monitor - iOS App

用于查看 OpenClaw Gateway 状态的 iOS 控制面板应用。

## 功能

- Gateway 运行状态监控
- 渠道连接状态（Telegram、飞书等）
- 模型状态查看
- 定时任务 (Cron) 监控
- 技能 (Skills) 列表
- Agent 实时状态

## 编译说明

本项目使用 GitHub Actions 自动编译，生成可安装的 IPA 文件。

### 编译步骤

1. **创建 GitHub 仓库**
   - 将此代码推送到 GitHub

2. **启用 GitHub Actions**
   - 访问仓库的 Actions 页面
   - 点击 "I understand my workflows, go ahead and enable them"

3. **推送代码触发编译**
   ```bash
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

4. **下载 IPA**
   - 进入 Actions 页面
   - 点击最新的 workflow 运行
   - 下载 `OpenClawMonitor-IPA` artifact

## 安装 IPA 到 iPhone

1. 下载 IPA 文件到电脑
2. 使用以下方式安装：
   - **AltStore**（推荐）：https://altstore.io
   - **Sideloadly**：https://sideloadly.io
   - **3uTools**（Windows）

## 配置

首次使用时，在 App 的设置页面配置：

- **Host**: OpenClaw Gateway 服务器地址
- **Port**: 18790
- **Token**: 你的 Gateway Token

## OpenClaw Gateway 配置

确保 Gateway 允许外部访问：

```powershell
openclaw config set gateway.bind "0.0.0.0"
openclaw gateway restart
```
