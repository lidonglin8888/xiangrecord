# 日期时间格式修复文档

## 问题描述
后端API在处理POST请求时报错：
```
JSON parse error: Cannot deserialize value of type `java.time.LocalDateTime` from String "2025-06-17T02:06:12.199Z": Failed to deserialize java.time.LocalDateTime
```

## 问题原因
1. **前端发送格式**：ISO 8601标准格式 `2025-06-17T02:06:12.199Z`（UTC时间，带Z后缀）
2. **后端期望格式**：`yyyy-MM-dd HH:mm:ss`（本地时间格式）
3. **格式不匹配**：Jackson无法将ISO 8601格式解析为配置的本地时间格式

## 解决方案

### 1. 修改DTO和实体类的日期格式注解
将所有`@JsonFormat`注解从：
```java
@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
```

修改为：
```java
@JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timezone = "UTC")
```

### 2. 修改的文件
- `PoopRecordDTO.java`：recordTime、createdAt、updatedAt字段
- `PoopRecord.java`：recordTime字段
- `ApiResponse.java`：timestamp字段

### 3. 格式说明
- `yyyy-MM-dd'T'HH:mm:ss.SSS'Z'`：支持ISO 8601格式
- `timezone = "UTC"`：指定时区为UTC
- 单引号包围的字符（'T'和'Z'）：字面量字符

## 修复后的效果

### 请求示例
```json
{
  "id": 1750064592199,
  "recordTime": "2025-06-17T02:06:12.199Z",
  "color": "brown",
  "smell": "mild",
  "moisture": "dry",
  "shape": "lumpy",
  "size": "large",
  "texture": "fluffy",
  "mood": "normal",
  "notes": "ceshi"
}
```

### 响应示例
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1750064592199,
    "recordTime": "2025-06-17T02:06:12.199Z",
    "createdAt": "2025-06-16T17:03:12.277Z",
    "updatedAt": "2025-06-16T17:03:12.277Z"
  },
  "timestamp": "2025-06-16T17:03:12.277Z"
}
```

## 验证方法
1. 重启后端服务
2. 使用前端发送POST请求到 `/api/v1/records`
3. 确认请求成功处理，无日期格式错误

## 注意事项
1. **时区处理**：所有日期时间现在统一使用UTC时区
2. **前后端一致性**：确保前端发送的日期格式与后端配置一致
3. **数据库存储**：LocalDateTime在数据库中仍按本地时间存储
4. **API文档更新**：Swagger文档中的示例已更新为ISO 8601格式

## 预防措施
1. 在开发新的日期时间字段时，统一使用ISO 8601格式
2. 考虑在全局Jackson配置中设置默认的日期时间格式
3. 添加单元测试验证日期时间序列化/反序列化功能