-- =============================================
-- 香香记录系统 - 示例数据插入脚本
-- =============================================

USE `xiangrecord`;

-- 清空现有数据（可选）
-- TRUNCATE TABLE `poop_record`;

-- =============================================
-- 插入示例便便记录数据
-- =============================================

-- 最近一周的记录
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
    `notes`,
    `created_at`,
    `updated_at`
) VALUES 
-- 今天的记录
(
    CONCAT(UNIX_TIMESTAMP(NOW()) * 1000, 'abc001'),
    DATE_SUB(NOW(), INTERVAL 2 HOUR),
    '棕色',
    '正常',
    '适中',
    '香肠型',
    '中等',
    '光滑',
    '开心',
    '今天状态很好，早餐后正常排便',
    NOW(),
    NOW()
),

-- 昨天的记录
(
    CONCAT(UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 1 DAY)) * 1000, 'def002'),
    DATE_SUB(NOW(), INTERVAL 1 DAY),
    '黄色',
    '轻微',
    '偏干',
    '块状',
    '较小',
    '粗糙',
    '一般',
    '昨天喝水少了，有点干燥',
    DATE_SUB(NOW(), INTERVAL 1 DAY),
    DATE_SUB(NOW(), INTERVAL 1 DAY)
),

-- 前天的记录
(
    CONCAT(UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 2 DAY)) * 1000, 'ghi003'),
    DATE_SUB(NOW(), INTERVAL 2 DAY),
    '深棕色',
    '正常',
    '适中',
    '香肠型',
    '较大',
    '光滑',
    '满意',
    '多吃了蔬菜，效果不错',
    DATE_SUB(NOW(), INTERVAL 2 DAY),
    DATE_SUB(NOW(), INTERVAL 2 DAY)
),

-- 3天前的记录
(
    CONCAT(UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 3 DAY)) * 1000, 'jkl004'),
    DATE_SUB(NOW(), INTERVAL 3 DAY),
    '棕色',
    '明显',
    '偏湿',
    '糊状',
    '中等',
    '偏软',
    '担心',
    '可能是昨晚吃坏了肚子',
    DATE_SUB(NOW(), INTERVAL 3 DAY),
    DATE_SUB(NOW(), INTERVAL 3 DAY)
),

-- 4天前的记录
(
    CONCAT(UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 4 DAY)) * 1000, 'mno005'),
    DATE_SUB(NOW(), INTERVAL 4 DAY),
    '绿色',
    '轻微',
    '适中',
    '条状',
    '较小',
    '软硬适中',
    '一般',
    '吃了很多绿叶蔬菜',
    DATE_SUB(NOW(), INTERVAL 4 DAY),
    DATE_SUB(NOW(), INTERVAL 4 DAY)
),

-- 5天前的记录
(
    CONCAT(UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 5 DAY)) * 1000, 'pqr006'),
    DATE_SUB(NOW(), INTERVAL 5 DAY),
    '棕色',
    '正常',
    '适中',
    '香肠型',
    '中等',
    '光滑',
    '开心',
    '规律作息的好处',
    DATE_SUB(NOW(), INTERVAL 5 DAY),
    DATE_SUB(NOW(), INTERVAL 5 DAY)
),

-- 6天前的记录
(
    CONCAT(UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 6 DAY)) * 1000, 'stu007'),
    DATE_SUB(NOW(), INTERVAL 6 DAY),
    '黄色',
    '无味',
    '很干',
    '颗粒状',
    '很小',
    '偏硬',
    '难受',
    '便秘了，需要多喝水多运动',
    DATE_SUB(NOW(), INTERVAL 6 DAY),
    DATE_SUB(NOW(), INTERVAL 6 DAY)
),

-- 一周前的记录
(
    CONCAT(UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 7 DAY)) * 1000, 'vwx008'),
    DATE_SUB(NOW(), INTERVAL 7 DAY),
    '深棕色',
    '正常',
    '适中',
    '香肠型',
    '较大',
    '光滑',
    '满意',
    '周末在家，饮食规律',
    DATE_SUB(NOW(), INTERVAL 7 DAY),
    DATE_SUB(NOW(), INTERVAL 7 DAY)
),

-- 更早的一些记录
(
    CONCAT(UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 10 DAY)) * 1000, 'yz009'),
    DATE_SUB(NOW(), INTERVAL 10 DAY),
    '棕色',
    '轻微',
    '偏湿',
    '条状',
    '中等',
    '偏软',
    '一般',
    '工作压力大，肠胃有点不适',
    DATE_SUB(NOW(), INTERVAL 10 DAY),
    DATE_SUB(NOW(), INTERVAL 10 DAY)
),

(
    CONCAT(UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 15 DAY)) * 1000, 'abc010'),
    DATE_SUB(NOW(), INTERVAL 15 DAY),
    '黑色',
    '强烈',
    '适中',
    '块状',
    '较小',
    '粗糙',
    '担心',
    '颜色异常，需要注意饮食',
    DATE_SUB(NOW(), INTERVAL 15 DAY),
    DATE_SUB(NOW(), INTERVAL 15 DAY)
);

-- =============================================
-- 验证插入的数据
-- =============================================

-- 查看所有记录
SELECT 
    id,
    record_time,
    color,
    smell,
    moisture,
    shape,
    size,
    texture,
    mood,
    notes,
    created_at
FROM `poop_record` 
ORDER BY `record_time` DESC;

-- 统计各种颜色的记录数量
SELECT 
    color,
    COUNT(*) as count
FROM `poop_record` 
GROUP BY color 
ORDER BY count DESC;

-- 统计各种心情的记录数量
SELECT 
    mood,
    COUNT(*) as count
FROM `poop_record` 
GROUP BY mood 
ORDER BY count DESC;

-- 查看最近7天的记录
SELECT 
    DATE(record_time) as record_date,
    COUNT(*) as daily_count,
    GROUP_CONCAT(color) as colors,
    GROUP_CONCAT(mood) as moods
FROM `poop_record` 
WHERE record_time >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(record_time)
ORDER BY record_date DESC;

-- 总记录数
SELECT COUNT(*) as total_records FROM `poop_record`;

COMMIT;