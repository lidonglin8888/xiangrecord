# 网络配置和故障排除指南

## 概述

本应用支持本地模式和云端模式两种数据存储方式。云端模式需要连接到后端API服务器。

## 网络配置

### 1. 配置服务器地址

编辑 `entry/src/main/ets/config/NetworkConfig.ets` 文件：

```typescript
// 开发环境配置（请根据实际情况修改）
public static readonly DEV_SERVER_IP = '192.168.8.222'; // 替换为你的开发机器IP
public static readonly DEV_SERVER_PORT = '8080';
```

### 2. 获取开发机器IP地址

**Windows:**
```cmd
ipconfig
```
查看 "IPv4 地址" 字段

**macOS/Linux:**
```bash
ifconfig
# 或
ip addr
```
查看 "inet" 地址

### 3. 重要注意事项

- ❌ **不要使用 `localhost` 或 `127.0.0.1`**
  - 在真机或模拟器上，这些地址指向设备本身，无法访问开发机器
- ✅ **使用开发机器的实际IP地址**
  - 确保手机/模拟器和开发机器在同一网络中

## 日志配置

### 启用/禁用日志

在 `NetworkConfig.ets` 中配置：

```typescript
// 日志配置
public static readonly ENABLE_API_LOGS = true;  // 是否启用API日志
public static readonly ENABLE_DEBUG_LOGS = true; // 是否启用调试日志
```

### 日志级别说明

- **API日志**: 显示网络请求的基本信息
- **调试日志**: 显示详细的请求/响应数据
- **错误日志**: 始终显示，包含错误信息和解决建议

## 故障排除

### 1. 连接失败问题

当切换到云端模式显示"连接失败"时，应用会自动执行网络诊断并在控制台输出详细报告。

### 2. 常见问题和解决方案

#### 问题1: 使用了localhost地址
**现象**: 网络诊断显示"检测到使用localhost地址"
**解决**: 修改 `NetworkConfig.ets` 中的 `DEV_SERVER_IP` 为实际IP地址

#### 问题2: 无法连接到服务器
**现象**: 网络诊断显示"无法连接到服务器"
**解决步骤**:
1. 确认后端服务已启动
2. 检查IP地址和端口是否正确
3. 确认防火墙没有阻止连接
4. 确认设备和开发机器在同一网络

#### 问题3: API端点响应异常
**现象**: 服务器连通但API返回错误
**解决步骤**:
1. 检查API路径是否正确
2. 确认后端API接口已正确实现
3. 查看后端服务器日志

#### 问题4: 看不到控制台日志
**可能原因**:
1. 日志被禁用了
2. IDE控制台过滤设置
3. 日志级别设置过高

**解决步骤**:
1. 确认 `NetworkConfig.ets` 中日志开关已启用
2. 检查IDE控制台的过滤设置
3. 查看设备日志（如果在真机上运行）

### 3. 网络诊断工具

应用内置了自动网络诊断功能，会检查：

1. **网络配置检查**: 验证IP地址配置
2. **基础连通性检查**: 测试服务器是否可达
3. **API端点检查**: 验证API接口是否正常
4. **HTTP请求检查**: 测试完整的API调用

诊断结果会在控制台详细输出，包含具体的错误信息和解决建议。

### 4. 调试技巧

1. **启用详细日志**:
   ```typescript
   public static readonly ENABLE_DEBUG_LOGS = true;
   ```

2. **查看完整的网络诊断报告**:
   - 切换到云端模式
   - 点击连接检查
   - 查看控制台输出的详细诊断报告

3. **手动测试API**:
   - 使用浏览器访问: `http://你的IP:8080/api/v1/records`
   - 使用Postman等工具测试API接口

## 生产环境配置

在 `NetworkConfig.ets` 中设置生产环境：

```typescript
// 生产环境配置
public static readonly PROD_SERVER_URL = 'https://your-production-server.com/api/v1/records';

// 当前使用的配置
public static readonly IS_PRODUCTION = true; // 设置为true使用生产环境
```

## 性能优化

### 超时配置

```typescript
// 网络超时配置
public static readonly CONNECT_TIMEOUT = 10000; // 连接超时 10秒
public static readonly READ_TIMEOUT = 10000;    // 读取超时 10秒
```

### 重试配置

```typescript
// 重试配置
public static readonly MAX_RETRY_COUNT = 3;     // 最大重试次数
public static readonly RETRY_DELAY = 1000;      // 重试延迟 1秒
```

## 安全注意事项

1. **不要在代码中硬编码生产环境的敏感信息**
2. **使用HTTPS进行生产环境通信**
3. **定期更新网络配置**
4. **在生产环境中禁用调试日志**

---

如果遇到其他网络问题，请查看控制台的详细日志输出，或联系开发团队获取支持。