package com.xiangrecord.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

/**
 * 登录请求DTO
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Schema(description = "登录请求")
public class LoginRequest {

    @NotBlank(message = "登录类型不能为空")
    @Schema(description = "登录类型", example = "phone", allowableValues = {"phone", "huawei", "wechat"})
    private String loginType;

    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    @Schema(description = "手机号（手机号登录时必填）", example = "13800138000")
    private String phone;

    @Schema(description = "密码（手机号登录时必填）", example = "123456")
    private String password;

    @Schema(description = "华为授权码（华为登录时必填）")
    private String huaweiAuthCode;

    @Schema(description = "微信授权码（微信登录时必填）")
    private String wechatAuthCode;

    @Schema(description = "验证码（如果需要）")
    private String verificationCode;
}