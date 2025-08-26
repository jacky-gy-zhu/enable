#!/bin/bash

echo "测试简化的日志配置"
echo "=================="

echo "1. 当前默认配置："
echo "   日志文件: ./logs/ai-agent-system.log"
echo "   可通过环境变量 LOG_FILE_PATH 自定义"
echo "   可通过环境变量 LOG_LEVEL 设置级别 (TRACE, DEBUG, INFO, WARN, ERROR)"

echo -e "\n2. 创建日志目录..."
mkdir -p logs
echo "   日志目录创建完成: ./logs/"

echo -e "\n3. 测试环境变量配置："
echo "   export LOG_FILE_PATH=./logs/custom.log"
echo "   export LOG_LEVEL=INFO"
echo "   export LOG_MAX_FILE_SIZE=100MB"
echo "   export LOG_MAX_HISTORY=60"

echo -e "\n4. 启动应用程序测试："
echo "   启动应用程序后，日志将同时输出到："
echo "   ✅ 控制台 (彩色格式)"
echo "   ✅ 文件 ./logs/ai-agent-system.log (纯文本格式)"

if curl -s http://localhost:8080/api/chat/health > /dev/null 2>&1; then
    echo -e "\n5. 应用程序正在运行，生成测试日志..."
    
    # 发送测试消息
    SESSION_ID=$(curl -s -X POST http://localhost:8080/api/chat/session 2>/dev/null | tr -d '"')
    echo "   发送测试消息..."
    curl -s -X POST http://localhost:8080/api/chat/send \
      -H "Content-Type: application/json" \
      -d "{\"message\": \"测试日志输出\", \"sessionId\": \"$SESSION_ID\"}" > /dev/null
    
    echo "   测试完成，检查日志文件..."
    
    sleep 2  # 等待日志写入
    
    if [ -f "logs/ai-agent-system.log" ]; then
        echo "   ✅ 日志文件已创建"
        echo "   文件大小: $(ls -lh logs/ai-agent-system.log | awk '{print $5}')"
        echo "   最新日志内容:"
        tail -3 logs/ai-agent-system.log | while read line; do
            echo "     $line"
        done
    else
        echo "   ⚠️  日志文件尚未创建，可能需要稍等片刻"
    fi
else
    echo -e "\n5. 应用程序未运行"
    echo "   请先启动应用程序，然后重新运行此测试"
fi

echo -e "\n6. 日志轮转配置："
echo "   ✅ 当文件超过 50MB 时自动轮转"
echo "   ✅ 历史文件自动压缩为 .gz 格式"
echo "   ✅ 保留最近 30 天的日志文件"
echo "   ✅ 总大小限制 2GB"

echo -e "\n7. 实时查看日志："
echo "   tail -f logs/ai-agent-system.log"

echo -e "\n日志配置测试完成！"
