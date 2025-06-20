package com.xiangrecord.controller;

import com.xiangrecord.dto.*;
import com.xiangrecord.service.UserService;
import com.xiangrecord.util.JwtUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;

/**
 * 用户信息控制器
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Slf4j
@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
@Validated
@Tag(name = "用户信息", description = "用户信息查询和更新相关接口")
@SecurityRequirement(name = "bearerAuth")
public class UserController {

    private final UserService userService;
    private final JwtUtil jwtUtil;

    /**
     * 获取当前用户信息
     */
    @GetMapping("/profile")
    @Operation(summary = "获取用户信息", description = "获取当前登录用户的详细信息")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<UserDTO>> getUserProfile(HttpServletRequest request) {
        log.info("获取用户信息请求");
        
        try {
            // 从token中获取用户ID
            Long userId = getUserIdFromToken(request);
            if (userId == null) {
                return ResponseEntity.ok(ApiResponse.error("用户未登录"));
            }
            
            UserDTO userInfo = userService.getUserById(userId);
            if (userInfo == null) {
                return ResponseEntity.ok(ApiResponse.error("用户不存在"));
            }
            
            return ResponseEntity.ok(ApiResponse.success(userInfo));
        } catch (Exception e) {
            log.error("获取用户信息失败: {}", e.getMessage(), e);
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 根据用户ID获取用户信息
     */
    @GetMapping("/{userId}")
    @Operation(summary = "根据ID获取用户信息", description = "根据用户ID获取用户的基本信息")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<UserDTO>> getUserById(
            @Parameter(description = "用户ID") @PathVariable @NotNull Long userId) {
        log.info("根据ID获取用户信息请求: {}", userId);
        
        try {
            UserDTO userInfo = userService.getUserById(userId);
            if (userInfo == null) {
                return ResponseEntity.ok(ApiResponse.error("用户不存在"));
            }
            
            return ResponseEntity.ok(ApiResponse.success(userInfo));
        } catch (Exception e) {
            log.error("根据ID获取用户信息失败: {}", e.getMessage(), e);
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 根据手机号获取用户信息
     */
    @GetMapping("/phone/{phone}")
    @Operation(summary = "根据手机号获取用户信息", description = "根据手机号获取用户的基本信息")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<UserDTO>> getUserByPhone(
            @Parameter(description = "手机号") @PathVariable String phone) {
        log.info("根据手机号获取用户信息请求: {}", phone);
        
        try {
            UserDTO userInfo = userService.getUserByPhone(phone);
            if (userInfo == null) {
                return ResponseEntity.ok(ApiResponse.error("用户不存在"));
            }
            
            return ResponseEntity.ok(ApiResponse.success(userInfo));
        } catch (Exception e) {
            log.error("根据手机号获取用户信息失败: {}", e.getMessage(), e);
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 更新用户信息
     */
    @PutMapping("/profile")
    @Operation(summary = "更新用户信息", description = "更新当前登录用户的信息")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<UserDTO>> updateUserProfile(
            @Valid @RequestBody UpdateUserRequest request,
            HttpServletRequest httpRequest) {
        log.info("更新用户信息请求");
        
        try {
            // 从token中获取用户ID
            Long userId = getUserIdFromToken(httpRequest);
            if (userId == null) {
                return ResponseEntity.ok(ApiResponse.error("用户未登录"));
            }
            
            // 设置用户ID
            request.setUserId(userId);
            
            UserDTO updatedUser = userService.updateUser(request);
            return ResponseEntity.ok(ApiResponse.success(updatedUser));
        } catch (Exception e) {
            log.error("更新用户信息失败: {}", e.getMessage(), e);
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 更新用户头像
     */
    @PutMapping("/avatar")
    @Operation(summary = "更新用户头像", description = "更新当前登录用户的头像")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<String>> updateUserAvatar(
            @Parameter(description = "头像URL") @RequestParam String avatarUrl,
            HttpServletRequest request) {
        log.info("更新用户头像请求");
        
        try {
            // 从token中获取用户ID
            Long userId = getUserIdFromToken(request);
            if (userId == null) {
                return ResponseEntity.ok(ApiResponse.error("用户未登录"));
            }
            
            // 创建更新请求
            UpdateUserRequest updateRequest = new UpdateUserRequest();
            updateRequest.setUserId(userId);
            updateRequest.setAvatarUrl(avatarUrl);
            
            UserDTO updatedUser = userService.updateUser(updateRequest);
            return ResponseEntity.ok(ApiResponse.success(updatedUser.getAvatar()));
        } catch (Exception e) {
            log.error("更新用户头像失败: {}", e.getMessage(), e);
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 更新用户密码
     */
    @PutMapping("/password")
    @Operation(summary = "更新用户密码", description = "更新当前登录用户的密码")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<Boolean>> updatePassword(
            @Valid @RequestBody UpdatePasswordRequest request,
            HttpServletRequest httpRequest) {
        log.info("更新用户密码请求");
        
        try {
            // 从token中获取用户ID
            Long userId = getUserIdFromToken(httpRequest);
            if (userId == null) {
                return ResponseEntity.ok(ApiResponse.error("用户未登录"));
            }
            
            // 设置用户ID
            request.setUserId(userId);
            
            boolean success = userService.updatePassword(request);
            return ResponseEntity.ok(ApiResponse.success(success));
        } catch (Exception e) {
            log.error("更新用户密码失败: {}", e.getMessage(), e);
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 绑定手机号
     */
    @PostMapping("/bind/phone")
    @Operation(summary = "绑定手机号", description = "为当前用户绑定手机号")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<Boolean>> bindPhone(
            @Valid @RequestBody BindPhoneRequest request,
            HttpServletRequest httpRequest) {
        log.info("绑定手机号请求: {}", request.getPhone());
        
        try {
            // 从token中获取用户ID
            Long userId = getUserIdFromToken(httpRequest);
            if (userId == null) {
                return ResponseEntity.ok(ApiResponse.error("用户未登录"));
            }
            
            // 设置用户ID
            request.setUserId(userId);
            
            boolean success = userService.bindPhone(request);
            return ResponseEntity.ok(ApiResponse.success(success));
        } catch (Exception e) {
            log.error("绑定手机号失败: {}", e.getMessage(), e);
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 绑定邮箱
     */
    @PostMapping("/bind/email")
    @Operation(summary = "绑定邮箱", description = "为当前用户绑定邮箱")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<Boolean>> bindEmail(
            @Valid @RequestBody BindEmailRequest request,
            HttpServletRequest httpRequest) {
        log.info("绑定邮箱请求: {}", request.getEmail());
        
        try {
            // 从token中获取用户ID
            Long userId = getUserIdFromToken(httpRequest);
            if (userId == null) {
                return ResponseEntity.ok(ApiResponse.error("用户未登录"));
            }
            
            // 设置用户ID
            request.setUserId(userId);
            
            boolean success = userService.bindEmail(request);
            return ResponseEntity.ok(ApiResponse.success(success));
        } catch (Exception e) {
            log.error("绑定邮箱失败: {}", e.getMessage(), e);
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 注销账户
     */
    @DeleteMapping("/account")
    @Operation(summary = "注销账户", description = "注销当前用户账户")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<ApiResponse<Boolean>> deleteAccount(
            HttpServletRequest request) {
        log.info("注销账户请求");
        
        try {
            // 从token中获取用户ID
            Long userId = getUserIdFromToken(request);
            if (userId == null) {
                return ResponseEntity.ok(ApiResponse.error("用户未登录"));
            }
            
            boolean success = userService.deleteUser(userId);
            return ResponseEntity.ok(ApiResponse.success(success));
        } catch (Exception e) {
            log.error("注销账户失败: {}", e.getMessage(), e);
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 从请求中获取用户ID
     */
    private Long getUserIdFromToken(HttpServletRequest request) {
        try {
            String token = extractTokenFromRequest(request);
            if (token == null) {
                return null;
            }
            
            return jwtUtil.getUserIdFromToken(token);
        } catch (Exception e) {
            log.error("从token获取用户ID失败: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 从请求中提取token
     */
    private String extractTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}