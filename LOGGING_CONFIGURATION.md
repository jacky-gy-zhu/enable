# 日志配置指南

## 概述

AI Agent系统支持简单而强大的日志配置，使用SpringBoot标准的日志配置方式，避免复杂的依赖问题。

## 配置方法

### 1. 通过application.yml配置

```yaml
# SpringBoot标准日志配置
logging:
  level:
    com.enable: ${LOG_LEVEL:DEBUG}  # 应用程序日志级别
    org.springframework.web: INFO   # Spring Web日志
    root: INFO                       # 根日志级别
  
  # 日志文件配置
  file:
    name: ${LOG_FILE_PATH:./logs/ai-agent-system.log}  # 日志文件路径
  
  # 日志格式配置
  pattern:
    console: "%clr(%d{yyyy-MM-dd HH:mm:ss.SSS}){faint} %clr(%-5level) %clr([%thread]){faint} %clr(%logger{36}){cyan} %clr(:){faint} %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss.SSS} %-5level [%thread] %logger{36} - %msg%n"
  
  # 日志轮转配置
  logback:
    rollingpolicy:
      file-name-pattern: ${LOG_FILE_PATH:./logs/ai-agent-system.log}.%d{yyyy-MM-dd}.%i.gz
      max-file-size: ${LOG_MAX_FILE_SIZE:50MB}
      max-history: ${LOG_MAX_HISTORY:30}
      total-size-cap: ${LOG_TOTAL_SIZE_CAP:2GB}
      clean-history-on-start: true
```

### 2. 通过环境变量配置

```bash
# 设置日志文件路径
export LOG_FILE_PATH=/var/log/ai-agent/app.log

# 设置日志级别 (TRACE, DEBUG, INFO, WARN, ERROR)
export LOG_LEVEL=INFO

# 设置最大文件大小
export LOG_MAX_FILE_SIZE=100MB

# 设置保留历史文件数量
export LOG_MAX_HISTORY=60

# 设置总大小限制
export LOG_TOTAL_SIZE_CAP=5GB
```

**注意**: 简化后的配置默认同时输出到控制台和文件，无需额外开关控制。

## 配置选项详解

### 日志级别
- `TRACE` - 最详细的日志
- `DEBUG` - 调试信息（默认）
- `INFO` - 一般信息
- `WARN` - 警告信息
- `ERROR` - 错误信息

### 文件轮转配置
- **按大小轮转**: 当文件达到指定大小时自动创建新文件
- **按时间轮转**: 每天自动创建新的日志文件
- **压缩存储**: 历史日志文件自动压缩为.gz格式
- **自动清理**: 超过保留期限的日志文件自动删除

### 日志格式

#### 控制台输出格式
```
2025-08-26 16:22:30.123 DEBUG [http-nio-8080-exec-1] c.e.ai.agents.service.AgentService : Processing request with agent for session: abc123
```

#### 文件输出格式
```
2025-08-26 16:22:30.123 DEBUG [http-nio-8080-exec-1] com.enable.ai.agents.service.AgentService - Processing request with agent for session: abc123
```

## 使用场景

### 开发环境
```yaml
app:
  logging:
    file-path: ./logs/dev.log
    level: DEBUG
    enable-console: true
    enable-file: true
```

### 生产环境
```bash
export LOG_FILE_PATH=/var/log/ai-agent/production.log
export LOG_LEVEL=INFO
export LOG_MAX_FILE_SIZE=200MB
export LOG_MAX_HISTORY=90
export LOG_ENABLE_CONSOLE=false
export LOG_ENABLE_FILE=true
```

### 调试模式
```bash
export LOG_LEVEL=TRACE
export LOG_ENABLE_CONSOLE=true
```

## 特定组件日志

系统为不同组件配置了特定的日志级别：

- **Agent服务** (`com.enable.ai.agents.service.AgentService`): DEBUG
- **OpenAI服务** (`com.enable.ai.agents.service.OpenAiService`): DEBUG  
- **MCP服务器** (`com.enable.ai.agents.service.McpServerService`): DEBUG
- **Web控制器** (`com.enable.ai.web.controller`): INFO
- **Spring框架** (`org.springframework`): INFO

## 日志文件结构

```
logs/
├── ai-agent-system.log              # 当前日志文件
├── ai-agent-system.log.2025-08-25.0.gz   # 昨天的日志（压缩）
├── ai-agent-system.log.2025-08-24.0.gz   # 前天的日志（压缩）
└── ...
```

## 监控和维护

### 查看实时日志
```bash
# 实时查看日志
tail -f logs/ai-agent-system.log

# 查看特定级别的日志
grep "ERROR" logs/ai-agent-system.log

# 查看特定组件的日志
grep "AgentService" logs/ai-agent-system.log
```

### 日志分析
```bash
# 统计错误数量
grep -c "ERROR" logs/ai-agent-system.log

# 查看最近的错误
grep "ERROR" logs/ai-agent-system.log | tail -10

# 按时间过滤
grep "2025-08-26 16:" logs/ai-agent-system.log
```

## 故障排除

### 日志文件未生成
1. 检查日志目录权限
2. 确认配置文件语法正确
3. 重启应用程序

### 日志文件过大
1. 调整`max-file-size`设置
2. 减少`max-history`设置
3. 设置合适的`total-size-cap`

### 性能影响
1. 将日志级别改为`INFO`或`WARN`
2. 禁用控制台日志：`LOG_ENABLE_CONSOLE=false`
3. 使用异步日志记录

## 最佳实践

1. **生产环境**：使用`INFO`级别，禁用控制台输出
2. **开发环境**：使用`DEBUG`级别，启用控制台输出
3. **定期清理**：设置合理的历史文件保留策略
4. **监控磁盘空间**：确保日志不会占满磁盘
5. **安全考虑**：避免在日志中记录敏感信息

## 配置验证

重启应用程序后，运行测试脚本验证配置：
```bash
./test-logging.sh
```

这将测试日志配置并显示日志文件的生成情况。
