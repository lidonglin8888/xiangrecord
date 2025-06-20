package com.xiangrecord.entity;

import com.baomidou.mybatisplus.annotation.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.EqualsAndHashCode;
import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

/**
 * 便便记录实体类
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
@Builder
@TableName("poop_records")
@Schema(description = "便便记录")
public class PoopRecord extends BaseEntity {

    @NotNull(message = "记录时间不能为空")
    @TableField("record_time")
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timezone = "UTC")
    @Schema(description = "记录时间", example = "2024-01-15T14:30:00.000Z")
    private LocalDateTime recordTime;

    @NotBlank(message = "颜色不能为空")
    @TableField("color")
    @Schema(description = "颜色", example = "brown", allowableValues = {"brown", "yellow", "green", "black", "red", "white"})
    private String color;

    @NotBlank(message = "气味不能为空")
    @TableField("smell")
    @Schema(description = "气味", example = "normal", allowableValues = {"normal", "mild", "strong", "sweet", "sour"})
    private String smell;

    @NotBlank(message = "干湿度不能为空")
    @TableField("moisture")
    @Schema(description = "干湿度", example = "normal", allowableValues = {"dry", "normal", "wet", "watery"})
    private String moisture;

    @NotBlank(message = "形状不能为空")
    @TableField("shape")
    @Schema(description = "形状", example = "sausage", allowableValues = {"sausage", "lumpy", "cracked", "soft", "liquid", "pellets"})
    private String shape;

    @NotBlank(message = "大小不能为空")
    @TableField("size")
    @Schema(description = "大小", example = "medium", allowableValues = {"small", "medium", "large", "extra_large"})
    private String size;

    @NotBlank(message = "质地不能为空")
    @TableField("texture")
    @Schema(description = "质地", example = "smooth", allowableValues = {"smooth", "rough", "sticky", "fluffy"})
    private String texture;

    @NotBlank(message = "心情不能为空")
    @TableField("mood")
    @Schema(description = "心情", example = "happy", allowableValues = {"happy", "relieved", "normal", "uncomfortable", "painful"})
    private String mood;

    @TableField("notes")
    @Schema(description = "备注", example = "今天感觉很舒畅")
    private String notes;

    /**
     * 用户ID
     */
    @TableField("user_id")
    private Long userId;

    // 注意：创建时间、更新时间、ID等字段已在BaseEntity中定义
    // MyBatis-Plus会通过MetaObjectHandler自动填充这些字段
}