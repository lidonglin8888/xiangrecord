package com.xiangrecord.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import java.time.LocalDateTime;

/**
 * 用户实体类
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
@Builder
@TableName("users")
@Schema(description = "用户信息")
public class User extends BaseEntity {

    @NotBlank(message = "用户名不能为空")
    @TableField("username")
    @Schema(description = "用户名", example = "张三")
    private String username;

    @Email(message = "邮箱格式不正确")
    @TableField("email")
    @Schema(description = "邮箱", example = "zhangsan@example.com")
    private String email;

    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    @TableField("phone")
    @Schema(description = "手机号", example = "13800138000")
    private String phone;

    @TableField("password_hash")
    @Schema(description = "密码哈希值")
    private String passwordHash;

    @TableField("avatar")
    @Schema(description = "头像URL", example = "https://example.com/avatar.jpg")
    private String avatar;

    @NotBlank(message = "登录类型不能为空")
    @TableField("login_type")
    @Schema(description = "登录类型", example = "phone", allowableValues = {"phone", "huawei", "wechat"})
    private String loginType;

    @TableField("huawei_id")
    @Schema(description = "华为账号ID")
    private String huaweiId;

    @TableField("wechat_id")
    @Schema(description = "微信账号ID")
    private String wechatId;

    @TableField("last_login_time")
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timezone = "UTC")
    @Schema(description = "最后登录时间", example = "2024-01-15T14:30:00.000Z")
    private LocalDateTime lastLoginTime;

    @TableField("is_active")
    @Schema(description = "是否激活", example = "true")
    private Boolean isActive;

    @TableField("is_deleted")
    @Schema(description = "是否删除", example = "false")
    private Boolean isDeleted;

    // 注意：创建时间、更新时间、ID等字段已在BaseEntity中定义
    // MyBatis-Plus会通过MetaObjectHandler自动填充这些字段
}