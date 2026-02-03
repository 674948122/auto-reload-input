# Input Source Pro 内存监控与自动重启方案

为了解决 Input Source Pro 在 macOS 14.8.2 上长时间运行后内存占用过高及卡顿的问题，本方案提供了一个自动化监控脚本。

## 包含文件

1. `monitor_isp.sh`: 核心监控脚本，负责检查内存并在超标时重启应用。
2. `com.user.isp_monitor.plist`: macOS launchd 配置文件，负责定时运行脚本。

## 安装步骤

### 1. 准备脚本
确保脚本具有执行权限（已预设）：
```bash
chmod +x monitor_isp.sh
```

### 2. 配置路径
由于 `plist` 文件需要脚本的绝对路径，请打开 `com.user.isp_monitor.plist`，将以下部分修改为您脚本实际存放的路径：
```xml
<key>ProgramArguments</key>
<array>
    <string>/您的路径/monitor_isp.sh</string>
</array>
```

### 3. 部署自动化任务
将 `plist` 文件复制到 macOS 的 LaunchAgents 目录：
```bash
cp com.user.isp_monitor.plist ~/Library/LaunchAgents/
```

### 4. 加载任务
运行以下命令使监控任务立即生效：
```bash
launchctl load ~/Library/LaunchAgents/com.user.isp_monitor.plist
```

## 配置说明

- **内存阈值**：默认设置为 **60MB**。您可以编辑 `monitor_isp.sh` 中的 `THRESHOLD_MB` 变量来调整。
- **检查频率**：默认每 **1 小时** (3600秒) 检查一次。您可以编辑 `com.user.isp_monitor.plist` 中的 `StartInterval` 来调整。
- **日志查看**：脚本会记录运行状态到以下文件：
  `~/Library/Logs/isp_monitor.log`

## 卸载方案
如果不再需要此监控，运行以下命令：
```bash
launchctl unload ~/Library/LaunchAgents/com.user.isp_monitor.plist
rm ~/Library/LaunchAgents/com.user.isp_monitor.plist
```
