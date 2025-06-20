package com.xiangrecord.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 验证码响应DTO
 *
 * @author xiangrecord
 * @version 1.0.0
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Schema(description = "验证码响应")
public class VerificationCodeResponse {

    @Schema(description = "验证码有效期（秒）", example = "300")
    public Integer expiresIn;



}