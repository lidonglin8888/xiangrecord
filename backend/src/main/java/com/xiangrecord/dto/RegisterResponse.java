package com.xiangrecord.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 注册响应DTO
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Schema(description = "注册响应")
public class RegisterResponse {

    @Schema(description = "用户信息")
    public UserDTO user;

    @Schema(description = "用户ID", example = "1")
    public Long userId;

    @Schema(description = "访问令牌", example = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")
    public String token;

    @Schema(description = "刷新令牌", example = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")
    public String refreshToken;

    @Schema(description = "令牌过期时间（秒）", example = "3600")
    public Long expiresIn;


}