package com.xiangrecord.controller;

import com.xiangrecord.dto.*;
import com.xiangrecord.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import java.util.Map;

/**
 * 用户认证控制器
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Slf4j
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Validated
@Tag(name = "用户认证", description = "用户登录、注册、验证码等认证相关接口")
public class AuthController {

    private final UserService userService;

    @PostMapping("/login/phone")
    @Operation(summary = "手机号登录", description = "使用手机号和密码进行登录")
    @ApiResponses({
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "登录成功"),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "请求参数错误"),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "401", description = "手机号或密码错误")
    })
    public ResponseEntity<ApiResponse<LoginResponse>> loginWithPhone(@Valid @RequestBody LoginRequest request) {
        log.info("Phone login request for: {}", request.getPhone());
        
        try {
            if (!"phone".equals(request.getLoginType())) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(ApiResponse.badRequest("登录类型错误"));
            }
            
            if (request.getPhone() == null || request.getPassword() == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(ApiResponse.badRequest("手机号和密码不能为空"));
            }
            
            LoginResponse response = userService.loginWithPhone(request.getPhone(), request.getPassword());
            return ResponseEntity.ok(ApiResponse.success("登录成功", response));
        } catch (Exception e) {
            log.error("手机号登录失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "登录失败: " + e.getMessage()));
        }
    }

    @PostMapping("/login/huawei")
    @Operation(summary = "华为账号登录", description = "使用华为授权码进行登录")
    @ApiResponses({
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "登录成功"),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "请求参数错误"),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "401", description = "华为授权失败")
    })
    public ResponseEntity<ApiResponse<LoginResponse>> loginWithHuawei(@Valid @RequestBody LoginRequest request) {
        log.info("Huawei login request");
        
        try {
            if (!"huawei".equals(request.getLoginType())) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(ApiResponse.badRequest("登录类型错误"));
            }
            
            if (request.getHuaweiAuthCode() == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(ApiResponse.badRequest("华为授权码不能为空"));
            }
            
            LoginResponse response = userService.loginWithHuawei(request.getHuaweiAuthCode());
            return ResponseEntity.ok(ApiResponse.success("华为登录成功", response));
        } catch (Exception e) {
            log.error("华为登录失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "华为登录失败: " + e.getMessage()));
        }
    }

    @PostMapping("/login/wechat")
    @Operation(summary = "微信账号登录", description = "使用微信授权码进行登录")
    @ApiResponses({
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "登录成功"),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "请求参数错误"),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "401", description = "微信授权失败")
    })
    public ResponseEntity<ApiResponse<LoginResponse>> loginWithWechat(@Valid @RequestBody LoginRequest request) {
        log.info("WeChat login request");
        
        try {
            if (!"wechat".equals(request.getLoginType())) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(ApiResponse.badRequest("登录类型错误"));
            }
            
            if (request.getWechatAuthCode() == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(ApiResponse.badRequest("微信授权码不能为空"));
            }
            
            LoginResponse response = userService.loginWithWechat(request.getWechatAuthCode());
            return ResponseEntity.ok(ApiResponse.success("微信登录成功", response));
        } catch (Exception e) {
            log.error("微信登录失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "微信登录失败: " + e.getMessage()));
        }
    }

    @PostMapping("/register")
    @Operation(summary = "用户注册", description = "使用手机号进行用户注册")
    @ApiResponses({
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "注册成功"),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "请求参数错误"),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "409", description = "手机号或邮箱已注册")
    })
    public ResponseEntity<ApiResponse<RegisterResponse>> register(@Valid @RequestBody RegisterRequest request) {
        log.info("Registration request for phone: {}", request.getPhone());
        
        try {
            RegisterResponse response = userService.register(request);
            return ResponseEntity.ok(ApiResponse.success("注册成功", response));
        } catch (Exception e) {
            log.error("用户注册失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "注册失败: " + e.getMessage()));
        }
    }

    @PostMapping("/verification-code")
    @Operation(summary = "发送验证码", description = "向指定手机号发送验证码")
    @ApiResponses({
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "验证码发送成功"),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "请求参数错误"),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "429", description = "发送频率过高")
    })
    public ResponseEntity<ApiResponse<VerificationCodeResponse>> sendVerificationCode(
            @Valid @RequestBody VerificationCodeRequest request) {
        log.info("Verification code request for phone: {}, type: {}", request.getPhone(), request.getType());
        
        try {
            VerificationCodeResponse response = userService.sendVerificationCode(request);
            return ResponseEntity.ok(ApiResponse.success("验证码发送成功", response));
        } catch (Exception e) {
            log.error("发送验证码失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "发送验证码失败: " + e.getMessage()));
        }
    }

    @PostMapping("/validate")
    @Operation(summary = "验证Token", description = "验证JWT Token的有效性")
    @ApiResponses({
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "验证成功"),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "Token无效")
    })
    public ResponseEntity<ApiResponse<Map<String, Object>>> validateToken(
            @Parameter(description = "JWT Token", required = true)
            @RequestBody Map<String, String> request) {
        
        try {
            String token = request.get("token");
            if (token == null || token.trim().isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(ApiResponse.badRequest("Token不能为空"));
            }
            
            boolean isValid = userService.validateToken(token);
            Map<String, Object> data = Map.of(
                "valid", isValid,
                "message", isValid ? "Token有效" : "Token无效或已过期"
            );
            
            if (isValid) {
                return ResponseEntity.ok(ApiResponse.success("Token验证成功", data));
            } else {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(ApiResponse.error(401, "Token无效或已过期", data));
            }
        } catch (Exception e) {
            log.error("Token验证失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "Token验证失败: " + e.getMessage()));
        }
    }

    @PostMapping("/logout")
    @Operation(summary = "退出登录", description = "用户退出登录，将Token加入黑名单")
    @ApiResponses({
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "退出成功"),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "Token无效")
    })
    public ResponseEntity<ApiResponse<Map<String, Object>>> logout(
            @Parameter(description = "JWT Token", required = true)
            @RequestBody Map<String, String> request) {
        
        try {
            String token = request.get("token");
            if (token == null || token.trim().isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(ApiResponse.badRequest("Token不能为空"));
            }
            
            boolean success = userService.logout(token);
            Map<String, Object> data = Map.of(
                "success", success,
                "message", success ? "退出成功" : "退出失败"
            );
            
            if (success) {
                return ResponseEntity.ok(ApiResponse.success("退出登录成功", data));
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(ApiResponse.error(400, "退出失败", data));
            }
        } catch (Exception e) {
            log.error("退出登录失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "退出登录失败: " + e.getMessage()));
        }
    }

    @GetMapping("/user/{userId}")
    @Operation(summary = "获取用户信息", description = "根据用户ID获取用户信息")
    @ApiResponses({
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "获取成功"),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "404", description = "用户不存在")
    })
    public ResponseEntity<ApiResponse<UserDTO>> getUserInfo(
            @Parameter(description = "用户ID", required = true)
            @PathVariable Long userId) {
        
        try {
            UserDTO user = userService.getUserById(userId);
            if (user != null) {
                return ResponseEntity.ok(ApiResponse.success("获取用户信息成功", user));
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(ApiResponse.error(404, "用户不存在"));
            }
        } catch (Exception e) {
            log.error("获取用户信息失败，用户ID: {}", userId, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "获取用户信息失败: " + e.getMessage()));
        }
    }

    @PostMapping("/refresh")
    @Operation(summary = "刷新Token", description = "使用刷新令牌获取新的访问令牌")
    @ApiResponses({
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "刷新成功"),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "刷新令牌无效"),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "401", description = "刷新令牌已过期")
    })
    public ResponseEntity<ApiResponse<Map<String, String>>> refreshToken(
            @Parameter(description = "刷新令牌", required = true)
            @RequestBody Map<String, String> request) {
        
        try {
            String refreshToken = request.get("refreshToken");
            if (refreshToken == null || refreshToken.trim().isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(ApiResponse.badRequest("刷新令牌不能为空"));
            }
            
            String newToken = userService.refreshToken(refreshToken);
            if (newToken != null) {
                Map<String, String> data = Map.of(
                    "token", newToken,
                    "message", "Token刷新成功"
                );
                return ResponseEntity.ok(ApiResponse.success("Token刷新成功", data));
            } else {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(ApiResponse.error(401, "刷新令牌无效或已过期"));
            }
        } catch (Exception e) {
            log.error("Token刷新失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "Token刷新失败: " + e.getMessage()));
        }
    }

    @GetMapping("/check/phone/{phone}")
    @Operation(summary = "检查手机号", description = "检查手机号是否已注册")
    @ApiResponses({
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "检查成功")
    })
    public ResponseEntity<ApiResponse<Map<String, Object>>> checkPhone(
            @Parameter(description = "手机号", required = true)
            @PathVariable String phone) {
        
        try {
            boolean registered = userService.isPhoneRegistered(phone);
            Map<String, Object> data = Map.of(
                "registered", registered,
                "message", registered ? "手机号已注册" : "手机号未注册"
            );
            return ResponseEntity.ok(ApiResponse.success("检查手机号成功", data));
        } catch (Exception e) {
            log.error("检查手机号失败，手机号: {}", phone, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "检查手机号失败: " + e.getMessage()));
        }
    }
}