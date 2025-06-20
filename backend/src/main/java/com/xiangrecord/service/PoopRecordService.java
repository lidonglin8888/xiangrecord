package com.xiangrecord.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.xiangrecord.dto.PoopRecordDTO;
import com.xiangrecord.entity.PoopRecord;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 便便记录服务接口
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
public interface PoopRecordService {

    /**
     * 创建记录
     * 
     * @param recordDTO 记录DTO
     * @return 创建的记录
     */
    PoopRecordDTO createRecord(PoopRecordDTO recordDTO);

    /**
     * 根据ID获取记录
     * 
     * @param id 记录ID
     * @return 记录DTO
     */
    Optional<PoopRecordDTO> getRecordById(Long id);

    /**
     * 更新记录
     * 
     * @param id 记录ID
     * @param recordDTO 更新的记录DTO
     * @return 更新后的记录
     */
    Optional<PoopRecordDTO> updateRecord(Long id, PoopRecordDTO recordDTO);

    /**
     * 删除记录
     * 
     * @param id 记录ID
     * @return 是否删除成功
     */
    boolean deleteRecord(Long id);

    /**
     * 分页查询所有记录
     * 
     * @param page 分页参数
     * @param userId 用户ID（可选）
     * @return 分页记录列表
     */
    IPage<PoopRecordDTO> getAllRecords(Page<PoopRecordDTO> page, Long userId);

    /**
     * 根据时间范围查询记录
     * 
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @param page 分页参数
     * @return 分页记录列表
     */
    IPage<PoopRecordDTO> getRecordsByTimeRange(
            LocalDateTime startTime, 
            LocalDateTime endTime, 
            Page<PoopRecordDTO> page
    );

    /**
     * 根据颜色查询记录
     * 
     * @param color 颜色
     * @param page 分页参数
     * @return 分页记录列表
     */
    IPage<PoopRecordDTO> getRecordsByColor(String color, Page<PoopRecordDTO> page);

    /**
     * 根据心情查询记录
     * 
     * @param mood 心情
     * @param page 分页参数
     * @return 分页记录列表
     */
    IPage<PoopRecordDTO> getRecordsByMood(String mood, Page<PoopRecordDTO> page);

    /**
     * 获取最近的记录
     * 
     * @param limit 限制数量
     * @param userId 用户ID（可选）
     * @return 记录列表
     */
    List<PoopRecordDTO> getRecentRecords(int limit, Long userId);

    /**
     * 获取今日记录
     * 
     * @param userId 用户ID（可选）
     * @return 今日记录列表
     */
    List<PoopRecordDTO> getTodayRecords(Long userId);

    /**
     * 根据多个条件查询记录
     * 
     * @param color 颜色（可选）
     * @param mood 心情（可选）
     * @param startTime 开始时间（可选）
     * @param endTime 结束时间（可选）
     * @param page 分页参数
     * @param userId 用户ID（可选）
     * @return 分页记录列表
     */
    IPage<PoopRecordDTO> getRecordsByConditions(
            String color,
            String mood,
            LocalDateTime startTime,
            LocalDateTime endTime,
            Page<PoopRecordDTO> page,
            Long userId
    );

    /**
     * 统计指定时间范围内的记录数量
     * 
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @param userId 用户ID（可选）
     * @return 记录数量
     */
    long countRecordsByTimeRange(LocalDateTime startTime, LocalDateTime endTime, Long userId);

    /**
     * 根据颜色统计记录数量
     * 
     * @param color 颜色
     * @param userId 用户ID（可选）
     * @return 记录数量
     */
    long countRecordsByColor(String color, Long userId);

    /**
     * 根据心情统计记录数量
     * 
     * @param mood 心情
     * @param userId 用户ID（可选）
     * @return 记录数量
     */
    long countRecordsByMood(String mood, Long userId);
}