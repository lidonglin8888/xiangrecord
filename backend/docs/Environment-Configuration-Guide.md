# 环境配置指南

本文档详细介绍了如何在项目中使用多环境配置，包括开发、生产和测试环境的配置和切换。

## 目录

- [概述](#概述)
- [环境配置文件](#环境配置文件)
- [环境切换](#环境切换)
- [配置详解](#配置详解)
- [最佳实践](#最佳实践)
- [故障排除](#故障排除)

## 概述

项目采用Spring Boot的Profile机制来管理不同环境的配置，支持以下三种环境：

- **dev (开发环境)**: 用于本地开发，使用H2内存数据库，启用开发工具
- **prod (生产环境)**: 用于生产部署，使用MySQL数据库，优化性能配置
- **test (测试环境)**: 用于自动化测试，使用H2内存数据库，简化配置

## 环境配置文件

### 文件结构

```
src/main/resources/
├── application.yml          # 通用配置
├── application-dev.yml      # 开发环境配置
├── application-prod.yml     # 生产环境配置
└── application-test.yml     # 测试环境配置
```

### 配置文件说明

#### application.yml (通用配置)

包含所有环境共享的配置：
- 应用基本信息
- 默认Profile设置 (dev)
- Jackson序列化配置
- 文件上传配置
- 日志配置
- Swagger配置
- 自定义应用配置

#### application-dev.yml (开发环境)

开发环境特定配置：
- H2内存数据库
- JPA DDL自动创建
- 启用H2控制台
- 启用开发工具
- 详细日志输出
- 启用Swagger文档
- 示例数据初始化

#### application-prod.yml (生产环境)

生产环境特定配置：
- MySQL数据库
- Hikari连接池优化
- JPA DDL验证模式
- 禁用开发工具
- 启用缓存
- 生产级日志配置
- 禁用Swagger文档
- 安全配置
- 性能监控

#### application-test.yml (测试环境)

测试环境特定配置：
- H2内存数据库
- 随机端口
- 测试数据初始化
- 简化日志配置
- Mock服务配置

## 环境切换

项目提供了多种环境切换方式：

### 1. 使用脚本切换 (推荐)

#### Windows环境
```bash
# 切换到开发环境并启动
.\scripts\switch-env.bat dev

# 切换到生产环境并启动
.\scripts\switch-env.bat prod

# 切换到测试环境并启动
.\scripts\switch-env.bat test
```

#### Linux/macOS环境
```bash
# 给脚本添加执行权限
chmod +x scripts/switch-env.sh

# 切换到开发环境并启动
./scripts/switch-env.sh dev

# 切换到生产环境并启动
./scripts/switch-env.sh prod

# 切换到测试环境并启动
./scripts/switch-env.sh test
```

### 2. Maven命令行

```bash
# 开发环境
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# 生产环境
mvn spring-boot:run -Dspring-boot.run.profiles=prod

# 测试环境
mvn spring-boot:run -Dspring-boot.run.profiles=test
```

### 3. 环境变量

```bash
# 设置环境变量
export SPRING_PROFILES_ACTIVE=prod

# 启动应用
java -jar target/xiangrecord-backend-1.0.0.jar
```

### 4. JAR包启动

```bash
# 编译打包
mvn clean package -DskipTests

# 启动不同环境
java -jar target/xiangrecord-backend-1.0.0.jar --spring.profiles.active=dev
java -jar target/xiangrecord-backend-1.0.0.jar --spring.profiles.active=prod
java -jar target/xiangrecord-backend-1.0.0.jar --spring.profiles.active=test
```

## 配置详解

### 数据库配置

#### 开发环境 (MySQL)

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/xiangrecord_dev?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
    username: root
    password: password
    driver-class-name: com.mysql.cj.jdbc.Driver

# MyBatis配置
mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
  mapper-locations: classpath*:/mapper/**/*.xml
  type-aliases-package: com.xiangrecord.entity
```

#### 生产环境 (MySQL)

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/xiangrecord?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
    username: root
    password: password
    driver-class-name: com.mysql.cj.jdbc.Driver
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000

# MyBatis配置
mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.nologging.NoLoggingImpl
    cache-enabled: true
  mapper-locations: classpath*:/mapper/**/*.xml
  type-aliases-package: com.xiangrecord.entity
  global-config:
    db-config:
      id-type: auto
      logic-delete-field: deleted
      logic-delete-value: 1
      logic-not-delete-value: 0
```

### MyBatis配置

- **开发环境**: 启用SQL日志输出，便于调试
- **生产环境**: 禁用SQL日志，启用二级缓存提升性能
- **测试环境**: 禁用SQL日志，简化测试输出

### 日志配置

- **开发环境**: DEBUG级别，控制台输出
- **生产环境**: WARN级别，文件输出，日志滚动
- **测试环境**: WARN级别，简化输出

### 缓存配置

- **开发环境**: 禁用缓存，便于调试
- **生产环境**: 启用Caffeine缓存，提升性能
- **测试环境**: 禁用缓存，确保测试准确性

## 最佳实践

### 1. 配置管理

生产环境敏感信息建议使用外部配置文件或配置中心：

```yaml
spring:
  datasource:
    username: root
    password: password
    url: jdbc:mysql://localhost:3306/xiangrecord
```

### 2. 配置文件分离

- 通用配置放在 `application.yml`
- 环境特定配置放在对应的 `application-{profile}.yml`
- 敏感配置建议使用外部配置文件或配置中心

### 3. 开发环境优化

```yaml
spring:
  devtools:
    restart:
      enabled: true
    livereload:
      enabled: true

# MyBatis开发环境配置
mybatis-plus:
  configuration:
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl  # 显示SQL
    map-underscore-to-camel-case: true
  global-config:
    db-config:
      logic-delete-field: deleted
```

### 4. 生产环境优化

```yaml
# MyBatis生产环境配置
mybatis-plus:
  configuration:
    log-impl: org.apache.ibatis.logging.nologging.NoLoggingImpl  # 不显示SQL
    cache-enabled: true  # 启用二级缓存

spring:
  cache:
    type: caffeine
    
server:
  compression:
    enabled: true
  http2:
    enabled: true
```

### 5. 测试环境配置

```yaml
spring:
  test:
    database:
      replace: none
logging:
  level:
    org.springframework.test: DEBUG
```

## 故障排除

### 常见问题

#### 1. Profile未生效

**问题**: 配置的Profile没有生效

**解决方案**:
- 检查 `SPRING_PROFILES_ACTIVE` 环境变量
- 确认配置文件命名正确 (`application-{profile}.yml`)
- 查看启动日志中的Active profiles信息

#### 2. 数据库连接失败

**问题**: 生产环境MySQL连接失败

**解决方案**:
- 检查MySQL服务是否启动
- 验证数据库连接信息
- 确认数据库用户权限
- 检查防火墙设置

#### 3. H2控制台无法访问

**问题**: 开发环境H2控制台404

**解决方案**:
- 确认Profile为dev
- 检查 `spring.h2.console.enabled=true`
- 访问正确路径: `/api/h2-console`

#### 4. 配置覆盖问题

**问题**: 环境配置被通用配置覆盖

**解决方案**:
- Spring Boot配置优先级：命令行参数 > 环境变量 > Profile配置 > 通用配置
- 使用 `@ConditionalOnProperty` 条件化配置
- 检查配置文件加载顺序

### 调试技巧

#### 1. 查看当前Profile

```bash
# 通过Actuator端点
curl http://localhost:8080/api/actuator/env

# 通过日志
grep "Active profiles" logs/xiangrecord.log
```

#### 2. 查看配置属性

```bash
# 查看所有配置
curl http://localhost:8080/api/actuator/configprops

# 查看环境信息
curl http://localhost:8080/api/actuator/env
```

#### 3. 启用配置调试

```yaml
logging:
  level:
    org.springframework.boot.context.config: DEBUG
    org.springframework.core.env: DEBUG
```

## 环境配置检查清单

### 开发环境

- [ ] H2数据库正常启动
- [ ] H2控制台可访问
- [ ] 热重载功能正常
- [ ] Swagger文档可访问
- [ ] 日志输出详细

### 生产环境

- [ ] MySQL数据库连接正常
- [ ] 连接池配置合理
- [ ] 日志文件正常滚动
- [ ] 缓存功能启用
- [ ] 安全配置生效
- [ ] 性能监控正常

### 测试环境

- [ ] 测试数据库隔离
- [ ] Mock服务正常
- [ ] 测试数据初始化
- [ ] 测试完成后数据清理

## 总结

通过合理的环境配置管理，可以：

1. **提高开发效率**: 开发环境快速启动，热重载，详细调试信息
2. **保证生产稳定**: 生产环境优化配置，安全设置，性能监控
3. **确保测试质量**: 测试环境隔离，数据清理，Mock服务
4. **简化部署流程**: 统一的配置管理，Profile机制支持
5. **降低维护成本**: 清晰的配置结构，完善的文档

建议定期检查和更新环境配置，确保各环境配置的一致性和有效性。