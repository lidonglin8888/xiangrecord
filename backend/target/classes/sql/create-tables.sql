-- =============================================
-- 香香记录系统 - 数据库表结构创建脚本
-- =============================================

USE `xiangrecord`;

-- 设置字符集
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================
-- 便便记录表
-- =============================================
DROP TABLE IF EXISTS `poop_record`;

CREATE TABLE `poop_record` (
  `id` varchar(50) NOT NULL COMMENT '记录ID，格式：时间戳+随机字符串',
  `record_time` datetime NOT NULL COMMENT '记录时间，用户选择的便便时间',
  `color` varchar(20) NOT NULL COMMENT '颜色：棕色、黄色、绿色、黑色、红色、白色',
  `smell` varchar(20) NOT NULL COMMENT '气味：正常、轻微、明显、强烈、无味',
  `moisture` varchar(20) NOT NULL COMMENT '干湿度：很干、偏干、适中、偏湿、很湿',
  `shape` varchar(20) NOT NULL COMMENT '形状：香肠型、块状、条状、糊状、水状、颗粒状',
  `size` varchar(20) NOT NULL COMMENT '大小：很小、较小、中等、较大、很大',
  `texture` varchar(20) NOT NULL COMMENT '质地：光滑、粗糙、软硬适中、偏软、偏硬',
  `mood` varchar(20) NOT NULL COMMENT '心情：开心、满意、一般、担心、难受',
  `notes` text COMMENT '备注信息，用户自定义文本',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_record_time` (`record_time`) COMMENT '记录时间索引',
  KEY `idx_color` (`color`) COMMENT '颜色索引',
  KEY `idx_mood` (`mood`) COMMENT '心情索引',
  KEY `idx_created_at` (`created_at`) COMMENT '创建时间索引',
  KEY `idx_color_mood` (`color`, `mood`) COMMENT '颜色和心情组合索引',
  KEY `idx_record_time_color` (`record_time`, `color`) COMMENT '记录时间和颜色组合索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='便便记录表';

-- =============================================
-- 用户表（预留，如果将来需要多用户支持）
-- =============================================
-- DROP TABLE IF EXISTS `user`;
-- 
-- CREATE TABLE `user` (
--   `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
--   `username` varchar(50) NOT NULL COMMENT '用户名',
--   `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
--   `password` varchar(255) NOT NULL COMMENT '密码（加密）',
--   `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
--   `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL',
--   `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态：1-正常，0-禁用',
--   `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
--   `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
--   PRIMARY KEY (`id`),
--   UNIQUE KEY `uk_username` (`username`),
--   UNIQUE KEY `uk_email` (`email`),
--   KEY `idx_status` (`status`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- =============================================
-- 系统配置表（预留）
-- =============================================
-- DROP TABLE IF EXISTS `system_config`;
-- 
-- CREATE TABLE `system_config` (
--   `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '配置ID',
--   `config_key` varchar(100) NOT NULL COMMENT '配置键',
--   `config_value` text COMMENT '配置值',
--   `description` varchar(255) DEFAULT NULL COMMENT '配置描述',
--   `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
--   `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
--   PRIMARY KEY (`id`),
--   UNIQUE KEY `uk_config_key` (`config_key`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- 查看表结构
-- =============================================
SHOW CREATE TABLE `poop_record`;
DESCRIBE `poop_record`;

-- =============================================
-- 查看索引信息
-- =============================================
SHOW INDEX FROM `poop_record`;

COMMIT;