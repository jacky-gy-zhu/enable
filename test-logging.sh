#!/bin/bash

echo "AI Agent System - 日志配置测试"
echo "================================"

# 显示当前配置
echo "1. 当前日志配置："
echo "   日志文件路径: $(grep -A 10 "app:" src/main/resources/application.yml | grep "file-path:" | awk '{print $2}')"
echo "   日志级别: $(grep -A 10 "app:" src/main/resources/application.yml | grep -w "level:" | awk '{print $2}')"

# 创建日志目录
echo -e "\n2. 创建日志目录..."
mkdir -p logs
echo "   日志目录创建完成: ./logs/"

# 检查应用程序是否运行
if curl -s http://localhost:8080/api/chat/health > /dev/null 2>&1; then
    echo -e "\n3. 应用程序正在运行，测试日志输出..."
    
    # 发送测试消息以生成日志
    SESSION_ID=$(curl -s -X POST http://localhost:8080/api/chat/session 2>/dev/null | tr -d '"')
    echo "   创建会话: $SESSION_ID"
    
    # 发送普通消息
    echo "   发送普通消息..."
    curl -s -X POST http://localhost:8080/api/chat/send \
      -H "Content-Type: application/json" \
      -d "{\"message\": \"Hello, 测试日志记录\", \"sessionId\": \"$SESSION_ID\"}" > /dev/null
    
    # 发送触发Agent的消息
    echo "   发送Agent触发消息..."
    curl -s -X POST http://localhost:8080/api/chat/send \
      -H "Content-Type: application/json" \
      -d "{\"message\": \"Please run a search tool for me\", \"sessionId\": \"$SESSION_ID\"}" > /dev/null
    
    echo "   测试消息发送完成"
else
    echo -e "\n3. 应用程序未运行，无法测试日志输出"
fi

# 检查日志文件
echo -e "\n4. 检查日志文件..."
if [ -f "logs/ai-agent-system.log" ]; then
    echo "   ✅ 日志文件存在: logs/ai-agent-system.log"
    file_size=$(ls -lh logs/ai-agent-system.log | awk '{print $5}')
    echo "   文件大小: $file_size"
    
    echo -e "\n   最近5条日志记录:"
    tail -5 logs/ai-agent-system.log | while read line; do
        echo "   | $line"
    done
else
    echo "   ❌ 日志文件不存在"
fi

# 显示所有日志文件
echo -e "\n5. 日志目录内容:"
if [ -d "logs" ]; then
    ls -la logs/ | while read line; do
        echo "   $line"
    done
else
    echo "   日志目录不存在"
fi

echo -e "\n6. 日志配置说明:"
echo "   ✅ 可通过环境变量配置日志路径: export LOG_FILE_PATH=/custom/path/app.log"
echo "   ✅ 可通过环境变量配置日志级别: export LOG_LEVEL=INFO"
echo "   ✅ 支持日志轮转，自动压缩历史文件"
echo "   ✅ 可分别控制控制台和文件日志的启用/禁用"

echo -e "\n7. 环境变量配置示例:"
echo "   export LOG_FILE_PATH=./logs/my-app.log"
echo "   export LOG_LEVEL=INFO"
echo "   export LOG_MAX_FILE_SIZE=100MB"
echo "   export LOG_MAX_HISTORY=60"
echo "   export LOG_ENABLE_CONSOLE=true"
echo "   export LOG_ENABLE_FILE=true"

echo -e "\n日志配置测试完成！"
