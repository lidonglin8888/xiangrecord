package com.xiangrecord.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;

/**
 * 便便记录数据传输对象
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Schema(description = "便便记录数据传输对象")
public class PoopRecordDTO {

    @Schema(description = "记录ID", example = "123")
    private Long id;

    @NotNull(message = "记录时间不能为空")
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timezone = "UTC")
    @Schema(description = "记录时间", example = "2024-01-15T14:30:00.000Z")
    private LocalDateTime recordTime;

    @NotBlank(message = "颜色不能为空")
    @Schema(description = "颜色", example = "brown", allowableValues = {"brown", "yellow", "green", "black", "red", "white"})
    private String color;

    @NotBlank(message = "气味不能为空")
    @Schema(description = "气味", example = "normal", allowableValues = {"normal", "mild", "strong", "sweet", "sour"})
    private String smell;

    @NotBlank(message = "干湿度不能为空")
    @Schema(description = "干湿度", example = "normal", allowableValues = {"dry", "normal", "wet", "watery"})
    private String moisture;

    @NotBlank(message = "形状不能为空")
    @Schema(description = "形状", example = "sausage", allowableValues = {"sausage", "lumpy", "cracked", "soft", "liquid", "pellets"})
    private String shape;

    @NotBlank(message = "大小不能为空")
    @Schema(description = "大小", example = "medium", allowableValues = {"small", "medium", "large", "extra_large"})
    private String size;

    @NotBlank(message = "质地不能为空")
    @Schema(description = "质地", example = "smooth", allowableValues = {"smooth", "rough", "sticky", "fluffy"})
    private String texture;

    @NotBlank(message = "心情不能为空")
    @Schema(description = "心情", example = "happy", allowableValues = {"happy", "relieved", "normal", "uncomfortable", "painful"})
    private String mood;

    @Schema(description = "备注", example = "今天感觉很舒畅")
    private String notes;

    @Schema(description = "用户ID", example = "123")
    private Long userId;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timezone = "UTC")
    @Schema(description = "创建时间", example = "2024-01-15T14:30:00.000Z")
    private LocalDateTime createdAt;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timezone = "UTC")
    @Schema(description = "更新时间", example = "2024-01-15T14:30:00.000Z")
    private LocalDateTime updatedAt;
}