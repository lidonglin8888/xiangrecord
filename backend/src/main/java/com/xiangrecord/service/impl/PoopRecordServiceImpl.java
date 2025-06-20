package com.xiangrecord.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xiangrecord.dto.PoopRecordDTO;
import com.xiangrecord.entity.PoopRecord;
import com.xiangrecord.mapper.PoopRecordMapper;
import com.xiangrecord.service.PoopRecordService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * 便便记录服务实现类
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Slf4j
@Service
@Transactional(readOnly = true)
public class PoopRecordServiceImpl extends ServiceImpl<PoopRecordMapper, PoopRecord> implements PoopRecordService {

    @Override
    @Transactional
    public PoopRecordDTO createRecord(PoopRecordDTO recordDTO) {
        log.info("创建便便记录: {}", recordDTO);
        
        // 设置记录时间
        if (recordDTO.getRecordTime() == null) {
            recordDTO.setRecordTime(LocalDateTime.now());
        }
        
        PoopRecord entity = convertToEntity(recordDTO);
        // MyBatis-Plus会自动生成ID和填充创建时间、更新时间
        boolean success = save(entity);
        
        if (success) {
            log.info("便便记录创建成功，ID: {}", entity.getId());
            return convertToDTO(entity);
        } else {
            throw new RuntimeException("创建便便记录失败");
        }
    }

    @Override
    public Optional<PoopRecordDTO> getRecordById(Long id) {
        log.debug("根据ID获取便便记录: {}", id);
        
        PoopRecord entity = getById(id);
        return entity != null ? Optional.of(convertToDTO(entity)) : Optional.empty();
    }

    @Override
    @Transactional
    public Optional<PoopRecordDTO> updateRecord(Long id, PoopRecordDTO recordDTO) {
        log.info("更新便便记录，ID: {}, 数据: {}", id, recordDTO);
        
        PoopRecord existingRecord = getById(id);
        if (existingRecord != null) {
            // 更新字段
            existingRecord.setRecordTime(recordDTO.getRecordTime());
            existingRecord.setColor(recordDTO.getColor());
            existingRecord.setSmell(recordDTO.getSmell());
            existingRecord.setMoisture(recordDTO.getMoisture());
            existingRecord.setShape(recordDTO.getShape());
            existingRecord.setSize(recordDTO.getSize());
            existingRecord.setTexture(recordDTO.getTexture());
            existingRecord.setMood(recordDTO.getMood());
            existingRecord.setNotes(recordDTO.getNotes());
            
            boolean success = updateById(existingRecord);
            if (success) {
                log.info("便便记录更新成功，ID: {}", id);
                return Optional.of(convertToDTO(existingRecord));
            }
        }
        return Optional.empty();
    }

    @Override
    @Transactional
    public boolean deleteRecord(Long id) {
        log.info("删除便便记录，ID: {}", id);
        
        if (getById(id) != null) {
            boolean result = removeById(id);
            if (result) {
                log.info("便便记录删除成功，ID: {}", id);
            }
            return result;
        }
        
        log.warn("便便记录不存在，ID: {}", id);
        return false;
    }

    @Override
    public IPage<PoopRecordDTO> getAllRecords(Page<PoopRecordDTO> page, Long userId) {
        log.debug("分页查询所有便便记录，页码: {}, 大小: {}, 用户ID: {}", page.getCurrent(), page.getSize(), userId);

        Page<PoopRecord> recordPage = new Page<>(page.getCurrent(), page.getSize());
        LambdaQueryWrapper<PoopRecord> queryWrapper = new LambdaQueryWrapper<PoopRecord>()
                .eq(userId != null, PoopRecord::getUserId, userId)
                .orderByDesc(PoopRecord::getRecordTime);
        IPage<PoopRecord> result = page(recordPage, queryWrapper);
        return result.<PoopRecordDTO>convert(record -> convertToDTO(record));
    }

    @Override
    public IPage<PoopRecordDTO> getRecordsByTimeRange(
            LocalDateTime startTime,
            LocalDateTime endTime,
            Page<PoopRecordDTO> page) {
        log.debug("根据时间范围查询便便记录: {} - {}", startTime, endTime);

        Page<PoopRecord> recordPage = new Page<>(page.getCurrent(), page.getSize());
        LambdaQueryWrapper<PoopRecord> queryWrapper = new LambdaQueryWrapper<PoopRecord>()
                .between(PoopRecord::getRecordTime, startTime, endTime)
                .orderByDesc(PoopRecord::getRecordTime);
        IPage<PoopRecord> result = page(recordPage, queryWrapper);
        return result.<PoopRecordDTO>convert(record -> convertToDTO(record));
    }

    @Override
    public IPage<PoopRecordDTO> getRecordsByColor(String color, Page<PoopRecordDTO> page) {
        log.debug("根据颜色查询便便记录: {}", color);

        Page<PoopRecord> recordPage = new Page<>(page.getCurrent(), page.getSize());
        LambdaQueryWrapper<PoopRecord> queryWrapper = new LambdaQueryWrapper<PoopRecord>()
                .eq(PoopRecord::getColor, color)
                .orderByDesc(PoopRecord::getRecordTime);
        IPage<PoopRecord> result = page(recordPage, queryWrapper);
        return result.<PoopRecordDTO>convert(record -> convertToDTO(record));
    }

    @Override
    public IPage<PoopRecordDTO> getRecordsByMood(String mood, Page<PoopRecordDTO> page) {
        log.debug("根据心情查询便便记录: {}", mood);

        Page<PoopRecord> recordPage = new Page<>(page.getCurrent(), page.getSize());
        LambdaQueryWrapper<PoopRecord> queryWrapper = new LambdaQueryWrapper<PoopRecord>()
                .eq(PoopRecord::getMood, mood)
                .orderByDesc(PoopRecord::getRecordTime);
        IPage<PoopRecord> result = page(recordPage, queryWrapper);
        return result.<PoopRecordDTO>convert(record -> convertToDTO(record));
    }

    @Override
    public List<PoopRecordDTO> getRecentRecords(int limit, Long userId) {
        log.debug("获取最近的便便记录，数量: {}, 用户ID: {}", limit, userId);

        LambdaQueryWrapper<PoopRecord> queryWrapper = new LambdaQueryWrapper<PoopRecord>()
                .eq(userId != null, PoopRecord::getUserId, userId)
                .orderByDesc(PoopRecord::getRecordTime)
                .last("LIMIT " + limit);

        return list(queryWrapper)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public List<PoopRecordDTO> getTodayRecords(Long userId) {
        log.debug("获取今日便便记录，用户ID: {}", userId);

        LocalDateTime startOfDay = LocalDateTime.now().with(LocalTime.MIN);
        LocalDateTime endOfDay = LocalDateTime.now().with(LocalTime.MAX);

        LambdaQueryWrapper<PoopRecord> queryWrapper = new LambdaQueryWrapper<PoopRecord>()
                .eq(userId != null, PoopRecord::getUserId, userId)
                .between(PoopRecord::getRecordTime, startOfDay, endOfDay)
                .orderByDesc(PoopRecord::getRecordTime);

        return list(queryWrapper)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public IPage<PoopRecordDTO> getRecordsByConditions(
            String color,
            String mood,
            LocalDateTime startTime,
            LocalDateTime endTime,
            Page<PoopRecordDTO> page,
            Long userId) {
        log.debug("根据条件查询便便记录 - 颜色: {}, 心情: {}, 时间范围: {} - {}, 用户ID: {}",
                color, mood, startTime, endTime, userId);

        Page<PoopRecord> recordPage = new Page<>(page.getCurrent(), page.getSize());
        LambdaQueryWrapper<PoopRecord> queryWrapper = new LambdaQueryWrapper<PoopRecord>()
                .eq(userId != null, PoopRecord::getUserId, userId)
                .eq(StringUtils.hasText(color), PoopRecord::getColor, color)
                .eq(StringUtils.hasText(mood), PoopRecord::getMood, mood)
                .ge(startTime != null, PoopRecord::getRecordTime, startTime)
                .le(endTime != null, PoopRecord::getRecordTime, endTime)
                .orderByDesc(PoopRecord::getRecordTime);

        IPage<PoopRecord> result = page(recordPage, queryWrapper);
        return result.<PoopRecordDTO>convert(record -> convertToDTO(record));
    }

    @Override
    public long countRecordsByTimeRange(LocalDateTime startTime, LocalDateTime endTime, Long userId) {
        log.debug("统计时间范围内的便便记录数量: {} - {}, 用户ID: {}", startTime, endTime, userId);

        LambdaQueryWrapper<PoopRecord> queryWrapper = new LambdaQueryWrapper<PoopRecord>()
                .eq(userId != null, PoopRecord::getUserId, userId)
                .between(PoopRecord::getRecordTime, startTime, endTime);
        return count(queryWrapper);
    }

    @Override
    public long countRecordsByColor(String color, Long userId) {
        log.debug("统计颜色的便便记录数量: {}, 用户ID: {}", color, userId);

        LambdaQueryWrapper<PoopRecord> queryWrapper = new LambdaQueryWrapper<PoopRecord>()
                .eq(userId != null, PoopRecord::getUserId, userId)
                .eq(PoopRecord::getColor, color);
        return count(queryWrapper);
    }

    @Override
    public long countRecordsByMood(String mood, Long userId) {
        log.debug("统计心情的便便记录数量: {}, 用户ID: {}", mood, userId);

        LambdaQueryWrapper<PoopRecord> queryWrapper = new LambdaQueryWrapper<PoopRecord>()
                .eq(userId != null, PoopRecord::getUserId, userId)
                .eq(PoopRecord::getMood, mood);
        return count(queryWrapper);
    }

    /**
     * 将PoopRecord实体转换为PoopRecordDTO
     */
    private PoopRecordDTO convertToDTO(PoopRecord entity) {
        if (entity == null) {
            return null;
        }

        PoopRecordDTO dto = new PoopRecordDTO();
        dto.setId(entity.getId());
        dto.setRecordTime(entity.getRecordTime());
        dto.setColor(entity.getColor());
        dto.setSmell(entity.getSmell());
        dto.setMoisture(entity.getMoisture());
        dto.setShape(entity.getShape());
        dto.setSize(entity.getSize());
        dto.setTexture(entity.getTexture());
        dto.setMood(entity.getMood());
        dto.setNotes(entity.getNotes());
        dto.setUserId(entity.getUserId());
        dto.setCreatedAt(entity.getCreatedAt());
        dto.setUpdatedAt(entity.getUpdatedAt());

        return dto;
    }

    /**
     * 将PoopRecordDTO转换为PoopRecord实体
     */
    private PoopRecord convertToEntity(PoopRecordDTO dto) {
        if (dto == null) {
            return null;
        }

        PoopRecord entity = new PoopRecord();
        entity.setId(null);
        if (dto.getId() != 0) {
            entity.setId(dto.getId());
        }
        entity.setRecordTime(dto.getRecordTime());
        entity.setColor(dto.getColor());
        entity.setSmell(dto.getSmell());
        entity.setShape(dto.getShape());
        entity.setTexture(dto.getTexture());
        entity.setMood(dto.getMood());
        entity.setNotes(dto.getNotes());
        entity.setMoisture(dto.getMoisture());
        entity.setSize(dto.getSize());
        entity.setUserId(dto.getUserId());
        entity.setCreatedAt(dto.getCreatedAt());
        if (dto.getCreatedAt() == null) {
            entity.setCreatedAt(LocalDateTime.now());
        }
        entity.setUpdatedAt(dto.getUpdatedAt());
        if (dto.getUpdatedAt() == null) {
            entity.setUpdatedAt(LocalDateTime.now());
        }
        
        return entity;
    }
}