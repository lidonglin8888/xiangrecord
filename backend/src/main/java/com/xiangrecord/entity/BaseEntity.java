package com.xiangrecord.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 基础实体类
 * 包含通用字段：id、创建时间、更新时间、逻辑删除标记
 */
@Data
public abstract class BaseEntity {

    /**
     * 主键ID，自增
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

//    /**
//     * 逻辑删除标记
//     * 0: 未删除
//     * 1: 已删除
//     */
//    @TableLogic
//    @TableField(fill = FieldFill.INSERT)
//    private Integer deleted;
//
//    /**
//     * 版本号（乐观锁）
//     */
//    @Version
//    @TableField(fill = FieldFill.INSERT)
//    private Integer version;
}