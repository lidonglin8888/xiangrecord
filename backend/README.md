# 香香记录后端服务

便便记录管理系统的后端API服务，基于Spring Boot框架开发。

## 项目简介

本项目为便便记录管理系统提供RESTful API服务，支持记录的增删改查、条件查询、统计分析等功能。

## 技术栈

- **框架**: Spring Boot 2.7.x
- **数据库**: H2 (开发环境) / MySQL (生产环境)
- **ORM**: Spring Data JPA + Hibernate
- **文档**: Swagger/OpenAPI 3
- **构建工具**: Maven
- **Java版本**: JDK 8+

## 功能特性

### 核心功能
- ✅ 便便记录的增删改查
- ✅ 多条件组合查询
- ✅ 分页查询支持
- ✅ 数据统计分析
- ✅ 今日记录快速查看
- ✅ 最近记录查询

### 技术特性
- ✅ RESTful API设计
- ✅ 统一响应格式
- ✅ 全局异常处理
- ✅ 参数校验
- ✅ API文档自动生成
- ✅ CORS跨域支持
- ✅ 多环境配置

## 快速开始

### 环境要求

- JDK 8 或更高版本
- Maven 3.6+
- IDE (推荐 IntelliJ IDEA)

### 运行步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd xiangrecord/backend
   ```

2. **安装依赖**
   ```bash
   mvn clean install
   ```

3. **运行应用**
   ```bash
   mvn spring-boot:run
   ```
   
   或者在IDE中直接运行 `XiangRecordApplication.java`

4. **访问应用**
   - 应用地址: http://localhost:8080
   - API文档: http://localhost:8080/swagger-ui.html
   - H2控制台: http://localhost:8080/h2-console (开发环境)

## API文档

启动应用后，可以通过以下地址访问API文档：

- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **OpenAPI JSON**: http://localhost:8080/api-docs

### 主要API端点

| 方法 | 路径 | 描述 |
|------|------|------|
| POST | `/api/v1/records` | 创建记录 |
| GET | `/api/v1/records/{id}` | 获取记录 |
| PUT | `/api/v1/records/{id}` | 更新记录 |
| DELETE | `/api/v1/records/{id}` | 删除记录 |
| GET | `/api/v1/records` | 分页查询记录 |
| GET | `/api/v1/records/search` | 条件查询记录 |
| GET | `/api/v1/records/recent` | 获取最近记录 |
| GET | `/api/v1/records/today` | 获取今日记录 |
| GET | `/api/v1/records/stats/count` | 统计记录数量 |

## 数据模型

### 便便记录 (PoopRecord)

```json
{
  "id": "记录ID",
  "recordTime": "记录时间",
  "color": "颜色",
  "smell": "气味",
  "moisture": "干湿度",
  "shape": "形状",
  "size": "大小",
  "texture": "质地",
  "mood": "心情",
  "notes": "备注",
  "createdAt": "创建时间",
  "updatedAt": "更新时间"
}
```

### 统一响应格式

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {},
  "timestamp": "2024-01-01T12:00:00"
}
```

## 配置说明

### 环境配置

项目支持多环境配置：

- **开发环境** (default): 使用H2内存数据库
- **生产环境** (prod): 使用MySQL数据库
- **测试环境** (test): 使用H2内存数据库，每次重新创建表

### 切换环境

```bash
# 生产环境
mvn spring-boot:run -Dspring-boot.run.profiles=prod

# 测试环境
mvn spring-boot:run -Dspring-boot.run.profiles=test
```

### 数据库配置

#### H2数据库 (开发环境)
- 无需额外配置，应用启动时自动创建
- 控制台访问: http://localhost:8080/h2-console
- JDBC URL: `jdbc:h2:mem:xiangrecord`
- 用户名: `sa`
- 密码: (空)

#### MySQL数据库 (生产环境)

1. 创建数据库:
   ```sql
   CREATE DATABASE xiangrecord CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

2. 修改配置文件或设置环境变量:
   ```yaml
   spring:
     datasource:
       url: jdbc:mysql://localhost:3306/xiangrecord
       username: your_username
       password: your_password
   ```

## 开发指南

### 项目结构

```
src/main/java/com/xiangrecord/
├── XiangRecordApplication.java     # 启动类
├── controller/                     # 控制器层
│   └── PoopRecordController.java
├── service/                        # 服务层
│   ├── PoopRecordService.java
│   └── impl/
│       └── PoopRecordServiceImpl.java
├── repository/                     # 数据访问层
│   └── PoopRecordRepository.java
├── entity/                         # 实体类
│   └── PoopRecord.java
├── dto/                           # 数据传输对象
│   ├── PoopRecordDTO.java
│   └── ApiResponse.java
├── util/                          # 工具类
│   └── PoopRecordMapper.java
└── exception/                     # 异常处理
    ├── BusinessException.java
    └── GlobalExceptionHandler.java
```

### 代码规范

- 使用Lombok减少样板代码
- 统一使用SLF4J进行日志记录
- 所有API都有完整的Swagger注解
- 使用JSR-303进行参数校验
- 遵循RESTful API设计原则

### 添加新功能

1. 在相应的层添加代码
2. 添加单元测试
3. 更新API文档
4. 更新README文档

## 测试

### 运行测试

```bash
# 运行所有测试
mvn test

# 运行特定测试类
mvn test -Dtest=PoopRecordControllerTest
```

### 测试覆盖率

```bash
mvn jacoco:report
```

## 部署

### 打包应用

```bash
mvn clean package
```

### JAR包部署

```bash
# 编译打包
mvn clean package -DskipTests

# 启动应用
java -jar target/xiangrecord-backend-1.0.0.jar --spring.profiles.active=prod
```

## 监控和日志

### 日志配置

- 开发环境: 控制台输出，DEBUG级别
- 生产环境: 文件输出，INFO级别
- 日志文件位置: `logs/xiangrecord.log`

### 健康检查

应用提供了基本的健康检查端点：
- `/actuator/health` (如果启用了Actuator)

## 常见问题

### Q: 启动时提示端口被占用
A: 修改 `application.yml` 中的 `server.port` 配置

### Q: H2控制台无法访问
A: 确保在开发环境下运行，生产环境默认关闭H2控制台

### Q: 数据库连接失败
A: 检查数据库配置和网络连接

## 贡献指南

1. Fork 项目
2. 创建特性分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 联系方式

- 项目维护者: xiangrecord
- 邮箱: your-email@example.com
- 项目地址: https://github.com/your-username/xiangrecord

## 更新日志

### v1.0.0 (2024-01-01)
- 初始版本发布
- 实现基础的便便记录管理功能
- 提供完整的RESTful API
- 支持多环境配置
- 集成Swagger API文档