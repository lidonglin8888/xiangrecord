-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
    username VARCHAR(50) NOT NULL COMMENT '用户名',
    email VARCHAR(100) COMMENT '邮箱',
    phone VARCHAR(20) COMMENT '手机号',
    password_hash VARCHAR(255) COMMENT '密码哈希值',
    avatar VARCHAR(500) COMMENT '头像URL',
    login_type VARCHAR(20) NOT NULL DEFAULT 'phone' COMMENT '登录类型：phone, huawei, wechat',
    huawei_id VARCHAR(100) COMMENT '华为账号ID',
    wechat_id VARCHAR(100) COMMENT '微信账号ID',
    last_login_time DATETIME COMMENT '最后登录时间',
    is_active BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否激活',
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否删除',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    -- 索引
    UNIQUE KEY uk_users_phone (phone),
    UNIQUE KEY uk_users_email (email),
    UNIQUE KEY uk_users_huawei_id (huawei_id),
    UNIQUE KEY uk_users_wechat_id (wechat_id),
    INDEX idx_users_login_type (login_type),
    INDEX idx_users_create_time (create_time),
    INDEX idx_users_is_active (is_active),
    INDEX idx_users_is_deleted (is_deleted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 插入测试数据
INSERT INTO users (username, phone, password_hash, login_type, is_active, is_deleted) 
VALUES 
('测试用户', '13800138000', '$2a$12$rQWpwKZQJjZJjZJjZJjZJeO7.7.7.7.7.7.7.7.7.7.7.7.7.7.7.7.7.7.7.7', 'phone', TRUE, FALSE)
ON DUPLICATE KEY UPDATE username = VALUES(username);

-- 注意：上面的密码哈希值是示例，实际使用时应该是真实的BCrypt哈希值
-- 密码 '123456' 的BCrypt哈希值示例：$2a$12$rQWpwKZQJjZJjZJjZJjZJeO7.7.7.7.7.7.7.7.7.7.7.7.7.7.7.7.7.7.7.7