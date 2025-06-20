# 香香记录系统 - MySQL数据库配置指南

## 📋 目录

- [环境要求](#环境要求)
- [MySQL安装](#mysql安装)
- [数据库配置](#数据库配置)
- [SQL脚本说明](#sql脚本说明)
- [应用配置](#应用配置)
- [数据库连接测试](#数据库连接测试)
- [常见问题](#常见问题)
- [性能优化](#性能优化)
- [备份策略](#备份策略)

## 🔧 环境要求

- **MySQL版本**: 8.0+ (推荐 8.0.33+)
- **Java版本**: 17+
- **操作系统**: Windows 10/11, macOS, Linux
- **内存**: 至少 4GB RAM
- **存储**: 至少 10GB 可用空间

## 📦 MySQL安装

### Windows安装

1. 下载MySQL安装包
   ```
   https://dev.mysql.com/downloads/mysql/
   ```

2. 运行安装程序，选择"Developer Default"配置

3. 设置root密码（建议使用强密码）

4. 配置MySQL服务自动启动

### macOS安装

```bash
# 使用Homebrew安装
brew install mysql

# 启动MySQL服务
brew services start mysql

# 安全配置
mysql_secure_installation
```

### Linux安装

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install mysql-server

# CentOS/RHEL
sudo yum install mysql-server

# 启动服务
sudo systemctl start mysql
sudo systemctl enable mysql

# 安全配置
sudo mysql_secure_installation
```

## 🗄️ 数据库配置

### 1. 连接到MySQL

```bash
mysql -u root -p
```

### 2. 创建数据库

```sql
-- 创建生产环境数据库
CREATE DATABASE xiangrecord CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建开发环境数据库
CREATE DATABASE xiangrecord_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建测试环境数据库
CREATE DATABASE xiangrecord_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户（可选）
CREATE USER 'xiangrecord'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON xiangrecord.* TO 'xiangrecord'@'localhost';
GRANT ALL PRIVILEGES ON xiangrecord_dev.* TO 'xiangrecord'@'localhost';
GRANT ALL PRIVILEGES ON xiangrecord_test.* TO 'xiangrecord'@'localhost';
FLUSH PRIVILEGES;
```

### 3. 执行初始化脚本

按以下顺序执行SQL脚本：

```sql
-- 1. 创建数据库和基础配置
source /path/to/init-database.sql;

-- 2. 创建表结构
source /path/to/create-tables.sql;

-- 3. 插入示例数据（可选）
source /path/to/insert-sample-data.sql;
```

### 3. 验证安装

```sql
-- 检查数据库
SHOW DATABASES;

-- 使用数据库
USE xiangrecord;

-- 检查表
SHOW TABLES;

-- 检查表结构
DESCRIBE poop_record;

-- 查看示例数据
SELECT COUNT(*) FROM poop_record;
```

## 📄 SQL脚本说明

### 1. init-database.sql
- **功能**: 创建数据库、设置字符集、创建用户（可选）
- **执行时机**: 首次部署
- **注意事项**: 包含示例数据，生产环境可删除

### 2. create-tables.sql
- **功能**: 创建所有表结构和索引
- **执行时机**: 首次部署或结构更新
- **注意事项**: 会删除现有表，谨慎使用

### 3. insert-sample-data.sql
- **功能**: 插入测试数据
- **执行时机**: 开发和测试环境
- **注意事项**: 生产环境不建议执行

### 4. maintenance-queries.sql
- **功能**: 维护和查询脚本
- **执行时机**: 日常维护
- **注意事项**: 包含各种统计和分析查询

## ⚙️ 应用配置

### 1. 更新application.yml

#### 生产环境配置 (application-prod.yml)

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/xiangrecord?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
    driver-class-name: com.mysql.cj.jdbc.Driver
    username: root
    password: password
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000

# MyBatis配置
mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.nologging.NoLoggingImpl
  mapper-locations: classpath*:/mapper/**/*.xml
  type-aliases-package: com.xiangrecord.entity
  global-config:
    db-config:
      id-type: auto
      logic-delete-field: deleted
      logic-delete-value: 1
      logic-not-delete-value: 0
```

#### 开发环境配置 (application-dev.yml)

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/xiangrecord_dev?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
    driver-class-name: com.mysql.cj.jdbc.Driver
    username: root
    password: password

# MyBatis配置
mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl  # 开发环境显示SQL
  mapper-locations: classpath*:/mapper/**/*.xml
  type-aliases-package: com.xiangrecord.entity
```

### 2. 环境变量配置（推荐）

```bash
# 设置环境变量
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=xiangrecord
export DB_USERNAME=root
export DB_PASSWORD=your_password
```

```yaml
# application.yml中使用环境变量
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/xiangrecord?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: password
```

## 🔍 数据库连接测试

### 1. 命令行测试

```bash
# 测试连接
mysql -h localhost -P 3306 -u root -p xiangrecord

# 执行简单查询
mysql -u root -p -e "SELECT COUNT(*) FROM xiangrecord.poop_record;"
```

### 2. 应用测试

```bash
# 启动应用
cd backend
mvn spring-boot:run

# 检查日志
tail -f logs/application.log

# 测试API
curl http://localhost:8080/api/records
```

## ❓ 常见问题

### 1. 连接被拒绝

**问题**: `Connection refused`

**解决方案**:
```bash
# 检查MySQL服务状态
sudo systemctl status mysql

# 启动MySQL服务
sudo systemctl start mysql

# 检查端口
netstat -tlnp | grep 3306
```

### 2. 认证失败

**问题**: `Access denied for user`

**解决方案**:
```sql
-- 重置密码
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;

-- 创建新用户
CREATE USER 'xiangrecord'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON xiangrecord.* TO 'xiangrecord'@'localhost';
FLUSH PRIVILEGES;
```

### 3. 字符集问题

**问题**: 中文乱码

**解决方案**:
```sql
-- 检查字符集
SHOW VARIABLES LIKE 'character_set%';

-- 修改数据库字符集
ALTER DATABASE xiangrecord CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 修改表字符集
ALTER TABLE poop_record CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 4. 时区问题

**问题**: 时间显示不正确

**解决方案**:
```sql
-- 设置时区
SET GLOBAL time_zone = '+8:00';

-- 或在连接URL中指定
jdbc:mysql://localhost:3306/xiangrecord?serverTimezone=Asia/Shanghai
```

## 🚀 性能优化

### 1. 索引优化

```sql
-- 查看索引使用情况
SHOW INDEX FROM poop_record;

-- 分析查询性能
EXPLAIN SELECT * FROM poop_record WHERE record_time >= DATE_SUB(NOW(), INTERVAL 7 DAY);

-- 添加复合索引（如果需要）
CREATE INDEX idx_record_time_color_mood ON poop_record(record_time, color, mood);
```

### 2. 配置优化

```ini
# my.cnf 配置建议
[mysqld]
# 基础配置
max_connections = 200
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M

# 字符集配置
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# 时区配置
default-time-zone = '+08:00'

# 性能配置
innodb_flush_log_at_trx_commit = 2
sync_binlog = 0
```

### 3. 查询优化

```sql
-- 使用LIMIT限制结果集
SELECT * FROM poop_record ORDER BY record_time DESC LIMIT 20;

-- 使用索引字段进行WHERE条件
SELECT * FROM poop_record WHERE record_time >= '2024-01-01';

-- 避免SELECT *，只查询需要的字段
SELECT id, record_time, color, mood FROM poop_record;
```

## 💾 备份策略

### 1. 定期备份

```bash
#!/bin/bash
# backup.sh - 每日备份脚本

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/mysql"
DB_NAME="xiangrecord"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份数据库
mysqldump -u root -p$MYSQL_PASSWORD $DB_NAME > $BACKUP_DIR/xiangrecord_$DATE.sql

# 压缩备份文件
gzip $BACKUP_DIR/xiangrecord_$DATE.sql

# 删除7天前的备份
find $BACKUP_DIR -name "xiangrecord_*.sql.gz" -mtime +7 -delete

echo "Backup completed: xiangrecord_$DATE.sql.gz"
```

### 2. 设置定时任务

```bash
# 编辑crontab
crontab -e

# 添加每日凌晨2点备份
0 2 * * * /path/to/backup.sh
```

### 3. 恢复数据

```bash
# 恢复完整数据库
mysql -u root -p xiangrecord < backup_file.sql

# 恢复特定表
mysql -u root -p xiangrecord -e "source backup_file.sql"
```

## 📊 监控和维护

### 1. 性能监控

```sql
-- 查看慢查询
SHOW VARIABLES LIKE 'slow_query_log';
SHOW VARIABLES LIKE 'long_query_time';

-- 查看连接数
SHOW STATUS LIKE 'Threads_connected';
SHOW STATUS LIKE 'Max_used_connections';

-- 查看缓冲池状态
SHOW STATUS LIKE 'Innodb_buffer_pool%';
```

### 2. 定期维护

```sql
-- 分析表
ANALYZE TABLE poop_record;

-- 优化表
OPTIMIZE TABLE poop_record;

-- 检查表
CHECK TABLE poop_record;
```

## 🔒 安全配置

### 1. 用户权限

```sql
-- 创建应用专用用户
CREATE USER 'xiangrecord_app'@'localhost' IDENTIFIED BY 'strong_password';

-- 授予最小权限
GRANT SELECT, INSERT, UPDATE, DELETE ON xiangrecord.* TO 'xiangrecord_app'@'localhost';

-- 刷新权限
FLUSH PRIVILEGES;
```

### 2. 网络安全

```ini
# my.cnf 安全配置
[mysqld]
# 绑定本地地址
bind-address = 127.0.0.1

# 禁用远程root登录
skip-networking

# 启用SSL
ssl-ca = /path/to/ca.pem
ssl-cert = /path/to/server-cert.pem
ssl-key = /path/to/server-key.pem
```

---

## 📞 技术支持

如果在配置过程中遇到问题，请：

1. 检查MySQL错误日志：`/var/log/mysql/error.log`
2. 查看应用日志：`logs/application.log`
3. 参考官方文档：https://dev.mysql.com/doc/
4. 联系开发团队获取支持

---

**注意**: 生产环境部署前，请务必：
- 修改默认密码
- 配置防火墙规则
- 设置定期备份
- 启用监控告警
- 进行安全审计