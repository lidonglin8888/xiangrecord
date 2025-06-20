# 后端路由问题修复说明

## 问题描述

访问后端API时出现以下错误：
```
org.springframework.web.servlet.resource.NoResourceFoundException: No static resource v1/records.
```

## 问题原因

**路由配置冲突**：Spring Boot将API请求错误地路由到了静态资源处理器，而不是控制器。

### 具体原因分析

1. **配置文件冲突**：
   - `application.yml` 中设置了 `server.servlet.context-path: /api`
   - 控制器中使用了 `@RequestMapping("/api/v1/records")`
   - 实际访问路径变成了：`/api/api/v1/records`（重复了/api）

2. **路由匹配失败**：
   - 客户端请求：`GET /api/v1/records`
   - Spring期望路径：`/api/api/v1/records`
   - 由于路径不匹配，Spring将请求转发给静态资源处理器
   - 静态资源处理器找不到对应资源，抛出异常

## 解决方案

### 1. 修改后端配置

**文件**：`src/main/resources/application.yml`

**修改前**：
```yaml
server:
  servlet:
    context-path: /api
```

**修改后**：
```yaml
server:
  servlet:
    # context-path: /api  # 注释掉，避免与控制器路径冲突
```

### 2. 保持控制器路径不变

控制器中的路径配置保持不变：
```java
@RequestMapping("/api/v1/records")
public class PoopRecordController {
    // ...
}
```

### 3. 前端配置确认

前端NetworkConfig中的路径配置正确：
```typescript
public static readonly API_BASE_PATH = '/api/v1/records';
```

## 修复后的访问路径

- **API基础路径**：`http://localhost:8080/api/v1/records`
- **Swagger文档**：`http://localhost:8080/swagger-ui.html`
- **API文档**：`http://localhost:8080/v3/api-docs`

## 验证方法

1. **重启后端服务**
2. **测试API访问**：
   ```bash
   curl http://localhost:8080/api/v1/records
   ```
3. **检查日志**：确认请求被正确路由到控制器

## 预防措施

1. **避免路径重复**：
   - 要么使用 `context-path`，控制器路径去掉前缀
   - 要么不使用 `context-path`，控制器路径包含完整路径

2. **统一路径管理**：
   - 建议在配置文件中统一管理API路径前缀
   - 避免在多个地方重复定义相同的路径段

3. **测试验证**：
   - 每次修改路由配置后，及时测试API访问
   - 使用Swagger UI验证所有接口路径

## 相关文件

- `backend/src/main/resources/application.yml` - 服务器配置
- `backend/src/main/java/com/xiangrecord/controller/PoopRecordController.java` - 控制器
- `entry/src/main/ets/config/NetworkConfig.ets` - 前端网络配置