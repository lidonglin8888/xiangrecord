package com.xiangrecord.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * 更新密码请求DTO
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Data
@Schema(description = "更新密码请求")
public class UpdatePasswordRequest {

    @Schema(description = "用户ID", hidden = true)
    private Long userId;

    @Schema(description = "旧密码", example = "oldPassword123")
    @NotBlank(message = "旧密码不能为空")
    private String oldPassword;

    @Schema(description = "新密码", example = "newPassword123")
    @NotBlank(message = "新密码不能为空")
    @Size(min = 6, max = 20, message = "密码长度必须在6-20个字符之间")
    private String newPassword;

    @Schema(description = "确认新密码", example = "newPassword123")
    @NotBlank(message = "确认密码不能为空")
    private String confirmPassword;
}