#!/bin/bash

# =================================================================
# 脚本名称: monitor_isp.sh
# 功能描述: 定期检查 Input Source Pro 的内存占用，超过阈值则重启应用。
# 使用方法: ./monitor_isp.sh
# =================================================================

# --- 配置区域 ---
# 应用程序名称（用于 open -a 和 osascript）
APP_NAME="Input Source Pro"

# 内存阈值 (单位: MB)
# 建议根据实际情况调整，例如 512 或 1024
THRESHOLD_MB=60

# 日志文件路径
LOG_FILE="$HOME/Library/Logs/isp_monitor.log"

# --- 逻辑处理 ---

# 创建日志目录（如果不存在）
mkdir -p "$(dirname "$LOG_FILE")"

log_message() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

# 获取所有匹配进程的内存占用 (RSS)，单位为 KB
# ps -ax -o rss,comm | grep "$APP_NAME" 会获取所有包含该名称的进程
# awk 计算总和
TOTAL_KB=$(ps -ax -o rss,comm | grep -i "$APP_NAME" | grep -v grep | awk '{sum+=$1} END {print sum}')

if [ -z "$TOTAL_KB" ] || [ "$TOTAL_KB" -eq 0 ]; then
    # 如果没找到进程，可能是应用没启动，不做处理或选择自动启动（根据需求决定）
    # 这里选择只记录但不自动启动，避免用户手动关闭后又被脚本拉起
    exit 0
fi

# 转换为 MB
TOTAL_MB=$((TOTAL_KB / 1024))

log_message "当前内存占用: ${TOTAL_MB}MB (阈值: ${THRESHOLD_MB}MB)"

if [ "$TOTAL_MB" -gt "$THRESHOLD_MB" ]; then
    log_message "警告: 内存占用超过阈值，正在尝试重启 $APP_NAME..."
    
    # 1. 尝试优雅退出
    osascript -e "quit app \"$APP_NAME\"" > /dev/null 2>&1
    sleep 5
    
    # 2. 检查是否仍然存在进程，若存在则强制杀掉
    if pgrep -fi "$APP_NAME" > /dev/null; then
        log_message "应用未能在 5 秒内退出，正在强制结束进程..."
        pkill -fi "$APP_NAME"
        sleep 2
    fi
    
    # 3. 重新启动应用
    open -a "$APP_NAME"
    
    if [ $? -eq 0 ]; then
        log_message "成功重启 $APP_NAME"
    else
        log_message "错误: 重启 $APP_NAME 失败，请检查应用路径是否正确。"
    fi
fi
