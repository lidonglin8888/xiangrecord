# 便便记录管理系统 - 后端API服务

便便记录管理系统的后端API服务，基于Spring Boot框架开发。

## 项目简介

本项目为便便记录管理系统提供RESTful API服务，支持记录的增删改查、条件查询、统计分析等功能。

## 技术栈

- **框架**: Spring Boot 3.2.0
- **数据库**: MySQL 8.0+
- **ORM**: MyBatis Plus 3.5.7
- **文档**: Swagger/OpenAPI 3
- **构建工具**: Maven 3.6+
- **Java版本**: JDK 17

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

- JDK 17 或更高版本
- Maven 3.6+
- MySQL 8.0+
- IDE (推荐 IntelliJ IDEA)

### 运行步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/lidonglin8888/xiangrecord.git
   cd xiangrecord/backend
   ```

2. **配置数据库**
   - 创建MySQL数据库 `xiangrecord`
   - 修改 `application-dev.yml` 中的数据库连接信息
   - 运行 `src/main/resources/sql/init.sql` 初始化数据库表

3. **安装依赖**
   ```bash
   mvn clean install
   ```

4. **启动应用**
   ```bash
   mvn spring-boot:run
   ```

5. **访问应用**
   - API文档: http://localhost:8080/swagger-ui.html
   - 健康检查: http://localhost:8080/actuator/health

## API文档

启动应用后，可通过以下地址访问API文档：
- Swagger UI: http://localhost:8080/swagger-ui.html
- OpenAPI JSON: http://localhost:8080/v3/api-docs

## 主要API端点

### 记录管理
- `GET /api/records` - 获取记录列表（支持分页和条件查询）
- `GET /api/records/{id}` - 获取单个记录详情
- `POST /api/records` - 创建新记录
- `PUT /api/records/{id}` - 更新记录
- `DELETE /api/records/{id}` - 删除记录

### 统计分析
- `GET /api/records/today` - 获取今日记录
- `GET /api/records/recent` - 获取最近记录
- `GET /api/records/stats` - 获取统计数据

## 配置说明

### 环境配置
项目支持多环境配置：
- `application.yml` - 主配置文件
- `application-dev.yml` - 开发环境配置
- `application-test.yml` - 测试环境配置
- `application-prod.yml` - 生产环境配置

### 数据库配置
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/xiangrecord?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: your_username
    password: your_password
    driver-class-name: com.mysql.cj.jdbc.Driver
```

## 项目结构

```
src/
├── main/
│   ├── java/
│   │   └── com/
│   │       └── xiangrecord/
│   │           ├── XiangRecordApplication.java     # 启动类
│   │           ├── config/                         # 配置类
│   │           ├── controller/                     # 控制器
│   │           ├── service/                        # 服务层
│   │           ├── mapper/                         # 数据访问层
│   │           ├── entity/                         # 实体类
│   │           ├── dto/                           # 数据传输对象
│   │           ├── vo/                            # 视图对象
│   │           ├── common/                        # 公共类
│   │           └── exception/                     # 异常处理
│   └── resources/
│       ├── application.yml                        # 主配置文件
│       ├── application-*.yml                      # 环境配置文件
│       ├── mapper/                               # MyBatis映射文件
│       └── sql/                                  # SQL脚本
└── test/                                         # 测试代码
```

## 开发指南

### 代码规范
- 使用Lombok减少样板代码
- 统一使用RestController注解
- 服务层使用@Service注解
- 数据访问层使用@Mapper注解

### 异常处理
项目使用全局异常处理器统一处理异常，返回标准的错误响应格式。

### 数据校验
使用Spring Validation进行参数校验，支持JSR-303注解。

## 部署说明

### 打包
```bash
mvn clean package
```

### 运行
```bash
java -jar target/xiangrecord-backend-1.0.0.jar --spring.profiles.active=prod
```

### Docker部署
```bash
# 构建镜像
docker build -t xiangrecord-backend .

# 运行容器
docker run -d -p 8080:8080 --name xiangrecord-backend xiangrecord-backend
```

## 许可证

MIT License

## 联系方式

- 作者: lidonglin8888
- 邮箱: lidonglin8888@gmail.com
- GitHub: https://github.com/lidonglin8888/xiangrecord