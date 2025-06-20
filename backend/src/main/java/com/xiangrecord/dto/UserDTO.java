package com.xiangrecord.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 用户信息DTO（不包含敏感信息）
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Schema(description = "用户信息")
public class UserDTO {

    @Schema(description = "用户ID", example = "1")
    private Long id;

    @Schema(description = "用户名", example = "张三")
    private String username;

    @Schema(description = "邮箱", example = "zhangsan@example.com")
    private String email;

    @Schema(description = "手机号", example = "13800138000")
    private String phone;

    @Schema(description = "头像URL", example = "https://example.com/avatar.jpg")
    private String avatar;

    @Schema(description = "登录类型", example = "phone", allowableValues = {"phone", "huawei", "wechat"})
    private String loginType;

    @Schema(description = "华为账号ID")
    private String huaweiId;

    @Schema(description = "微信账号ID")
    private String wechatId;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timezone = "UTC")
    @Schema(description = "创建时间", example = "2024-01-15T14:30:00.000Z")
    private LocalDateTime createTime;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timezone = "UTC")
    @Schema(description = "最后登录时间", example = "2024-01-15T14:30:00.000Z")
    private LocalDateTime lastLoginTime;

    @Schema(description = "是否激活", example = "true")
    private Boolean isActive;
}