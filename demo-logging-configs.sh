#!/bin/bash

echo "AI Agent System - 日志配置演示"
echo "============================"

echo "1. 默认配置演示："
echo "   日志文件: ./logs/ai-agent-system.log"
echo "   日志级别: DEBUG"
echo "   控制台输出: 启用"
echo "   文件输出: 启用"
echo ""

echo "2. 生产环境配置示例："
echo "   export LOG_FILE_PATH=/var/log/ai-agent/production.log"
echo "   export LOG_LEVEL=INFO"
echo "   export LOG_MAX_FILE_SIZE=200MB"
echo "   export LOG_MAX_HISTORY=90"
echo "   export LOG_ENABLE_CONSOLE=false"
echo "   export LOG_ENABLE_FILE=true"
echo ""

echo "3. 开发环境配置示例："
echo "   export LOG_FILE_PATH=./logs/development.log"
echo "   export LOG_LEVEL=DEBUG"
echo "   export LOG_ENABLE_CONSOLE=true"
echo "   export LOG_ENABLE_FILE=true"
echo ""

echo "4. 调试模式配置示例："
echo "   export LOG_LEVEL=TRACE"
echo "   export LOG_ENABLE_CONSOLE=true"
echo "   export LOG_ENABLE_FILE=true"
echo ""

echo "5. 仅控制台输出配置示例："
echo "   export LOG_ENABLE_CONSOLE=true"
echo "   export LOG_ENABLE_FILE=false"
echo ""

echo "6. 自定义日志路径配置："
echo "   export LOG_FILE_PATH=/custom/path/my-app.log"
echo ""

echo "7. 配置文件中的完整示例："
cat << 'EOF'

# 在 application.yml 中配置
app:
  logging:
    file-path: /var/log/ai-agent/app.log  # 日志文件路径
    level: INFO                           # 日志级别
    max-file-size: 100MB                  # 最大文件大小
    max-history: 60                       # 保留历史文件数量
    total-size-cap: 5GB                   # 总大小限制
    enable-console: false                 # 禁用控制台输出
    enable-file: true                     # 启用文件输出

EOF

echo ""
echo "8. 重要提示："
echo "   ✅ 修改配置后需要重启应用程序才能生效"
echo "   ✅ 确保日志目录有写入权限"
echo "   ✅ 定期清理历史日志文件以节省磁盘空间"
echo "   ✅ 生产环境建议使用 INFO 或 WARN 级别"
echo ""

echo "9. 验证配置："
echo "   重启应用程序后运行: ./test-logging.sh"
echo ""

echo "配置演示完成！"
