-- =============================================
-- 香香记录系统 - MySQL数据库初始化脚本
-- =============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `xiangrecord` 
DEFAULT CHARACTER SET utf8mb4 
DEFAULT COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE `xiangrecord`;

-- 创建用户（可选，如果需要专门的数据库用户）
-- CREATE USER IF NOT EXISTS 'xiangrecord_user'@'localhost' IDENTIFIED BY 'xiangrecord_password';
-- GRANT ALL PRIVILEGES ON xiangrecord.* TO 'xiangrecord_user'@'localhost';
-- FLUSH PRIVILEGES;

-- 删除已存在的表（如果需要重新创建）
-- DROP TABLE IF EXISTS `poop_record`;

-- 创建便便记录表
CREATE TABLE IF NOT EXISTS `poop_record` (
    `id` VARCHAR(50) NOT NULL COMMENT '记录ID',
    `record_time` DATETIME NOT NULL COMMENT '记录时间',
    `color` VARCHAR(20) NOT NULL COMMENT '颜色',
    `smell` VARCHAR(20) NOT NULL COMMENT '气味',
    `moisture` VARCHAR(20) NOT NULL COMMENT '干湿度',
    `shape` VARCHAR(20) NOT NULL COMMENT '形状',
    `size` VARCHAR(20) NOT NULL COMMENT '大小',
    `texture` VARCHAR(20) NOT NULL COMMENT '质地',
    `mood` VARCHAR(20) NOT NULL COMMENT '心情',
    `notes` TEXT COMMENT '备注',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    INDEX `idx_record_time` (`record_time`),
    INDEX `idx_color` (`color`),
    INDEX `idx_mood` (`mood`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='便便记录表';

-- 插入示例数据（可选）
INSERT INTO `poop_record` (
    `id`, 
    `record_time`, 
    `color`, 
    `smell`, 
    `moisture`, 
    `shape`, 
    `size`, 
    `texture`, 
    `mood`, 
    `notes`
) VALUES 
(
    '1704067200000abc123def', 
    '2024-01-01 08:00:00', 
    '棕色', 
    '正常', 
    '适中', 
    '香肠型', 
    '中等', 
    '光滑', 
    '开心', 
    '新年第一次记录，状态良好'
),
(
    '1704153600000def456ghi', 
    '2024-01-02 09:30:00', 
    '黄色', 
    '轻微', 
    '偏干', 
    '块状', 
    '较小', 
    '粗糙', 
    '一般', 
    '昨天吃了太多零食'
),
(
    '1704240000000ghi789jkl', 
    '2024-01-03 07:45:00', 
    '深棕色', 
    '正常', 
    '适中', 
    '香肠型', 
    '较大', 
    '光滑', 
    '满意', 
    '多喝水的效果很好'
);

-- 查看表结构
-- DESCRIBE `poop_record`;

-- 查看示例数据
-- SELECT * FROM `poop_record` ORDER BY `record_time` DESC;

-- 统计记录数量
-- SELECT COUNT(*) as total_records FROM `poop_record`;

COMMIT;