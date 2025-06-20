-- =============================================
-- 香香记录系统 - 数据库维护和查询脚本
-- =============================================

USE `xiangrecord`;

-- =============================================
-- 数据库维护脚本
-- =============================================

-- 1. 清理过期数据（删除1年前的记录）
-- DELETE FROM `poop_record` 
-- WHERE `created_at` < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- 2. 优化表
-- OPTIMIZE TABLE `poop_record`;

-- 3. 分析表
-- ANALYZE TABLE `poop_record`;

-- 4. 检查表
-- CHECK TABLE `poop_record`;

-- 5. 修复表
-- REPAIR TABLE `poop_record`;

-- =============================================
-- 常用查询脚本
-- =============================================

-- 1. 查看表结构和索引
SHOW CREATE TABLE `poop_record`;
SHOW INDEX FROM `poop_record`;
DESCRIBE `poop_record`;

-- 2. 基础统计查询
-- 总记录数
SELECT COUNT(*) as total_records FROM `poop_record`;

-- 最新记录
SELECT * FROM `poop_record` ORDER BY `record_time` DESC LIMIT 1;

-- 最早记录
SELECT * FROM `poop_record` ORDER BY `record_time` ASC LIMIT 1;

-- 3. 按时间范围查询
-- 今天的记录
SELECT * FROM `poop_record` 
WHERE DATE(`record_time`) = CURDATE()
ORDER BY `record_time` DESC;

-- 本周的记录
SELECT * FROM `poop_record` 
WHERE `record_time` >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY `record_time` DESC;

-- 本月的记录
SELECT * FROM `poop_record` 
WHERE YEAR(`record_time`) = YEAR(NOW()) 
AND MONTH(`record_time`) = MONTH(NOW())
ORDER BY `record_time` DESC;

-- 4. 按属性统计
-- 颜色分布统计
SELECT 
    `color`,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM `poop_record`), 2) as percentage
FROM `poop_record` 
GROUP BY `color` 
ORDER BY count DESC;

-- 心情分布统计
SELECT 
    `mood`,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM `poop_record`), 2) as percentage
FROM `poop_record` 
GROUP BY `mood` 
ORDER BY count DESC;

-- 形状分布统计
SELECT 
    `shape`,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM `poop_record`), 2) as percentage
FROM `poop_record` 
GROUP BY `shape` 
ORDER BY count DESC;

-- 大小分布统计
SELECT 
    `size`,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM `poop_record`), 2) as percentage
FROM `poop_record` 
GROUP BY `size` 
ORDER BY count DESC;

-- 5. 时间趋势分析
-- 每日记录数量趋势（最近30天）
SELECT 
    DATE(`record_time`) as record_date,
    COUNT(*) as daily_count
FROM `poop_record` 
WHERE `record_time` >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(`record_time`)
ORDER BY record_date DESC;

-- 每周记录数量趋势
SELECT 
    YEAR(`record_time`) as year,
    WEEK(`record_time`) as week,
    COUNT(*) as weekly_count
FROM `poop_record` 
GROUP BY YEAR(`record_time`), WEEK(`record_time`)
ORDER BY year DESC, week DESC
LIMIT 12;

-- 每月记录数量趋势
SELECT 
    YEAR(`record_time`) as year,
    MONTH(`record_time`) as month,
    COUNT(*) as monthly_count
FROM `poop_record` 
GROUP BY YEAR(`record_time`), MONTH(`record_time`)
ORDER BY year DESC, month DESC
LIMIT 12;

-- 6. 健康状况分析
-- 异常颜色记录（非棕色、黄色）
SELECT 
    `record_time`,
    `color`,
    `mood`,
    `notes`
FROM `poop_record` 
WHERE `color` NOT IN ('棕色', '黄色', '深棕色')
ORDER BY `record_time` DESC;

-- 担心或难受的记录
SELECT 
    `record_time`,
    `color`,
    `shape`,
    `mood`,
    `notes`
FROM `poop_record` 
WHERE `mood` IN ('担心', '难受')
ORDER BY `record_time` DESC;

-- 便秘相关记录（很干、颗粒状、很小）
SELECT 
    `record_time`,
    `moisture`,
    `shape`,
    `size`,
    `mood`,
    `notes`
FROM `poop_record` 
WHERE `moisture` = '很干' 
   OR `shape` = '颗粒状' 
   OR `size` = '很小'
ORDER BY `record_time` DESC;

-- 7. 复合条件查询
-- 健康状态良好的记录
SELECT 
    `record_time`,
    `color`,
    `shape`,
    `mood`
FROM `poop_record` 
WHERE `color` IN ('棕色', '深棕色', '黄色')
  AND `shape` IN ('香肠型', '条状')
  AND `mood` IN ('开心', '满意')
  AND `moisture` = '适中'
ORDER BY `record_time` DESC;

-- 需要关注的记录
SELECT 
    `record_time`,
    `color`,
    `shape`,
    `moisture`,
    `mood`,
    `notes`
FROM `poop_record` 
WHERE `color` IN ('黑色', '红色', '白色', '绿色')
   OR `mood` IN ('担心', '难受')
   OR `moisture` IN ('很干', '很湿')
   OR `shape` IN ('水状', '颗粒状')
ORDER BY `record_time` DESC;

-- 8. 数据完整性检查
-- 检查是否有空值
SELECT 
    COUNT(*) as total,
    SUM(CASE WHEN `color` IS NULL OR `color` = '' THEN 1 ELSE 0 END) as null_color,
    SUM(CASE WHEN `smell` IS NULL OR `smell` = '' THEN 1 ELSE 0 END) as null_smell,
    SUM(CASE WHEN `moisture` IS NULL OR `moisture` = '' THEN 1 ELSE 0 END) as null_moisture,
    SUM(CASE WHEN `shape` IS NULL OR `shape` = '' THEN 1 ELSE 0 END) as null_shape,
    SUM(CASE WHEN `size` IS NULL OR `size` = '' THEN 1 ELSE 0 END) as null_size,
    SUM(CASE WHEN `texture` IS NULL OR `texture` = '' THEN 1 ELSE 0 END) as null_texture,
    SUM(CASE WHEN `mood` IS NULL OR `mood` = '' THEN 1 ELSE 0 END) as null_mood
FROM `poop_record`;

-- 检查重复ID
SELECT 
    `id`,
    COUNT(*) as count
FROM `poop_record` 
GROUP BY `id` 
HAVING COUNT(*) > 1;

-- 9. 性能优化查询
-- 查看查询执行计划
-- EXPLAIN SELECT * FROM `poop_record` WHERE `record_time` >= DATE_SUB(NOW(), INTERVAL 7 DAY);
-- EXPLAIN SELECT * FROM `poop_record` WHERE `color` = '棕色' AND `mood` = '开心';

-- 查看表大小
SELECT 
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) as table_size_mb,
    table_rows
FROM information_schema.tables 
WHERE table_schema = 'xiangrecord' 
AND table_name = 'poop_record';

-- =============================================
-- 备份和恢复脚本
-- =============================================

-- 导出数据（在命令行执行）
-- mysqldump -u root -p xiangrecord poop_record > poop_record_backup.sql

-- 导入数据（在命令行执行）
-- mysql -u root -p xiangrecord < poop_record_backup.sql

-- 仅导出表结构
-- mysqldump -u root -p --no-data xiangrecord poop_record > poop_record_structure.sql

-- 仅导出数据
-- mysqldump -u root -p --no-create-info xiangrecord poop_record > poop_record_data.sql

COMMIT;