# MyBatis使用指南

本文档介绍如何在项目中使用MyBatis和MyBatis-Plus进行数据库操作。

## 目录

- [概述](#概述)
- [配置说明](#配置说明)
- [实体类定义](#实体类定义)
- [Mapper接口](#mapper接口)
- [XML映射文件](#xml映射文件)
- [服务层使用](#服务层使用)
- [最佳实践](#最佳实践)

## 概述

项目使用MyBatis-Plus作为ORM框架，提供了以下特性：

- **代码生成**: 自动生成基础CRUD操作
- **分页插件**: 物理分页，性能优异
- **乐观锁**: 防止并发更新冲突
- **逻辑删除**: 数据安全删除
- **字段自动填充**: 自动填充创建时间、更新时间等
- **SQL日志**: 开发环境显示SQL语句

## 配置说明

### 依赖配置

```xml
<!-- MyBatis Spring Boot Starter -->
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>3.0.3</version>
</dependency>

<!-- MyBatis Plus -->
<dependency>
    <groupId>com.baomidou</groupId>
    <artifactId>mybatis-plus-boot-starter</artifactId>
    <version>3.5.5</version>
</dependency>
```

### 配置文件

#### 开发环境 (application-dev.yml)

```yaml
mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true  # 下划线转驼峰
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl  # 显示SQL
  mapper-locations: classpath*:/mapper/**/*.xml
  type-aliases-package: com.xiangrecord.entity
  global-config:
    db-config:
      id-type: auto  # 主键自增
      logic-delete-field: deleted  # 逻辑删除字段
      logic-delete-value: 1
      logic-not-delete-value: 0
```

#### 生产环境 (application-prod.yml)

```yaml
mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.nologging.NoLoggingImpl  # 不显示SQL
    cache-enabled: true  # 启用二级缓存
  mapper-locations: classpath*:/mapper/**/*.xml
  type-aliases-package: com.xiangrecord.entity
  global-config:
    db-config:
      id-type: auto
      logic-delete-field: deleted
      logic-delete-value: 1
      logic-not-delete-value: 0
```

## 实体类定义

### 基础实体类

```java
@Data
public abstract class BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    @TableLogic
    @TableField(fill = FieldFill.INSERT)
    private Integer deleted;

    @Version
    @TableField(fill = FieldFill.INSERT)
    private Integer version;
}
```

### 业务实体类示例

```java
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("user")
public class User extends BaseEntity {
    
    @TableField("username")
    private String username;
    
    @TableField("email")
    private String email;
    
    @TableField("phone")
    private String phone;
    
    // 不映射到数据库的字段
    @TableField(exist = false)
    private String tempField;
}
```

## Mapper接口

### 基础Mapper

```java
@Mapper
public interface UserMapper extends BaseMapper<User> {
    // BaseMapper已提供基础CRUD方法
    // 可以添加自定义方法
    
    /**
     * 根据用户名查询用户
     */
    User selectByUsername(@Param("username") String username);
    
    /**
     * 分页查询活跃用户
     */
    IPage<User> selectActiveUsers(IPage<User> page, @Param("status") Integer status);
}
```

## XML映射文件

在 `src/main/resources/mapper/` 目录下创建XML文件：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.xiangrecord.mapper.UserMapper">

    <!-- 根据用户名查询用户 -->
    <select id="selectByUsername" resultType="User">
        SELECT * FROM user 
        WHERE username = #{username} 
        AND deleted = 0
    </select>

    <!-- 分页查询活跃用户 -->
    <select id="selectActiveUsers" resultType="User">
        SELECT * FROM user 
        WHERE status = #{status} 
        AND deleted = 0
        ORDER BY create_time DESC
    </select>

</mapper>
```

## 服务层使用

### Service接口

```java
public interface UserService extends IService<User> {
    User findByUsername(String username);
    IPage<User> getActiveUsers(Page<User> page, Integer status);
}
```

### Service实现

```java
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    @Override
    public User findByUsername(String username) {
        return baseMapper.selectByUsername(username);
    }

    @Override
    public IPage<User> getActiveUsers(Page<User> page, Integer status) {
        return baseMapper.selectActiveUsers(page, status);
    }
}
```

### Controller使用

```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("/{id}")
    public User getUser(@PathVariable Long id) {
        return userService.getById(id);
    }

    @GetMapping
    public IPage<User> getUsers(@RequestParam(defaultValue = "1") Integer current,
                               @RequestParam(defaultValue = "10") Integer size) {
        Page<User> page = new Page<>(current, size);
        return userService.page(page);
    }

    @PostMapping
    public boolean createUser(@RequestBody User user) {
        return userService.save(user);
    }

    @PutMapping("/{id}")
    public boolean updateUser(@PathVariable Long id, @RequestBody User user) {
        user.setId(id);
        return userService.updateById(user);
    }

    @DeleteMapping("/{id}")
    public boolean deleteUser(@PathVariable Long id) {
        return userService.removeById(id);  // 逻辑删除
    }
}
```

## 最佳实践

### 1. 实体类设计

- 继承BaseEntity获得通用字段
- 使用@TableName指定表名
- 使用@TableField配置字段映射
- 合理使用@TableLogic实现逻辑删除

### 2. Mapper设计

- 继承BaseMapper获得基础CRUD方法
- 复杂查询使用XML映射文件
- 使用@Param注解参数
- 合理使用分页查询

### 3. 性能优化

- 生产环境关闭SQL日志
- 启用二级缓存
- 使用分页插件进行物理分页
- 合理设计数据库索引

### 4. 安全考虑

- 使用参数化查询防止SQL注入
- 实现逻辑删除保护数据
- 使用乐观锁防止并发冲突
- 敏感字段加密存储

### 5. 开发规范

- 统一命名规范
- 添加适当的注释
- 编写单元测试
- 使用事务管理

## 常用注解说明

| 注解 | 说明 |
|------|------|
| @TableName | 指定表名 |
| @TableId | 主键字段 |
| @TableField | 普通字段 |
| @TableLogic | 逻辑删除字段 |
| @Version | 乐观锁版本字段 |
| @EnumValue | 枚举值字段 |
| @KeySequence | 序列主键 |

## 总结

MyBatis-Plus提供了强大的功能和便利的开发体验，通过合理的配置和使用，可以大大提高开发效率和代码质量。建议在项目开发中严格遵循最佳实践，确保代码的可维护性和性能。