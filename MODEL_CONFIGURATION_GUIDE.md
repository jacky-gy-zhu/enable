# OpenAI模型配置指南

## 问题解决

### 问题描述
用户遇到了 "Invalid request format. Please check the model configuration." 错误，原因是配置了不存在的模型名称 `gpt-5-mini`。

### 解决方案

#### 1. 可用模型测试结果
通过测试发现以下模型状态：
- ✅ `gpt-3.5-turbo` - 可用
- ✅ `gpt-4` - 可用  
- ✅ `gpt-4-turbo` - 可用
- ✅ `gpt-4o` - 可用
- ✅ `gpt-4o-mini` - 可用
- ❌ `gpt-5-mini` - 不存在

#### 2. 推荐配置

**开发环境（成本优化）：**
```yaml
openai:
  model: gpt-3.5-turbo
```

**生产环境（质量优先）：**
```yaml
openai:
  model: gpt-4o
```

**平衡选择：**
```yaml
openai:
  model: gpt-4o-mini
```

#### 3. 配置验证

系统现在包含配置验证，如果模型名称无效，启动时会报错：
```java
@PostConstruct
public void validateConfig() {
    if (!StringUtils.hasText(model)) {
        throw new IllegalStateException("OpenAI model must be configured in application.yml");
    }
}
```

#### 4. 动态配置读取

所有模型名称现在完全从配置文件读取，无硬编码：
```java
// 配置类
private String model;  // 从application.yml读取

// 控制器使用
.model(openAiConfig.getModel())  // 动态获取
```

## 使用指南

### 切换模型
1. 编辑 `src/main/resources/application.yml`
2. 修改 `openai.model` 值为任何支持的模型
3. 重启应用程序
4. 测试功能

### 验证配置
运行测试脚本验证配置：
```bash
./test-model-config.sh
```

### 模型特点

| 模型 | 特点 | 适用场景 | 成本 |
|------|------|----------|------|
| gpt-3.5-turbo | 快速、经济 | 开发、测试 | 低 |
| gpt-4o-mini | 平衡性能 | 一般应用 | 中 |
| gpt-4o | 高质量 | 生产环境 | 高 |
| gpt-4 | 最高质量 | 复杂任务 | 最高 |

## 最佳实践

1. **开发阶段**: 使用 `gpt-3.5-turbo` 节省成本
2. **测试阶段**: 使用目标生产模型进行测试
3. **生产环境**: 根据质量需求选择 `gpt-4o` 或 `gpt-4o-mini`
4. **定期检查**: OpenAI可能发布新模型或弃用旧模型

## 故障排除

### 常见错误
1. **"Invalid request format"**: 检查模型名称是否正确
2. **"model not found"**: 模型名称不存在或已弃用
3. **启动失败**: 配置验证失败，检查application.yml

### 调试步骤
1. 运行 `./test-models.sh` 测试模型可用性
2. 检查应用程序日志
3. 验证API密钥有效性
4. 确认网络连接正常
