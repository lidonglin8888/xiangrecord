package com.xiangrecord.service.impl;

import com.xiangrecord.dto.*;
import com.xiangrecord.entity.User;
import com.xiangrecord.mapper.UserMapper;
import com.xiangrecord.service.UserService;
import com.xiangrecord.util.JwtUtil;
import com.xiangrecord.util.PasswordUtil;
import com.xiangrecord.util.RedisUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.Random;
import java.util.concurrent.TimeUnit;

/**
 * 用户服务实现类
 *
 * @author xiangrecord
 * @version 1.0.0
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;
    private final JwtUtil jwtUtil;
    private final PasswordUtil passwordUtil;
    private final RedisUtil redisUtil;

    /**
     * 验证码相关常量
     */
    private static final String VERIFICATION_CODE_PREFIX = "verification_code:";
    private static final int VERIFICATION_CODE_EXPIRE_MINUTES = 5;
    private static final int VERIFICATION_CODE_LENGTH = 6;

    /**
     * Token黑名单常量
     */
    private static final String TOKEN_BLACKLIST_PREFIX = "token_blacklist:";

    @Override
    @Transactional
    public LoginResponse loginWithPhone(String phone, String password) {
        try {
            // 查找用户
            Optional<User> userOpt = userMapper.findByPhone(phone);
            if (userOpt.isEmpty()) {
                throw new RuntimeException("用户不存在");
            }

            User user = userOpt.get();
            if (user.getIsDeleted()) {
                throw new RuntimeException("用户已被删除");
            }
            if (!user.getIsActive()) {
                throw new RuntimeException("用户已被禁用");
            }

            // 验证密码
            if (!passwordUtil.matches(password, user.getPasswordHash())) {
                throw new RuntimeException("密码错误");
            }

            // 更新最后登录时间
            updateLastLoginTime(user.getId());

            // 生成JWT tokenaa
            String token = jwtUtil.generateToken(user.getId(), user.getUsername());
            String refreshToken = jwtUtil.generateRefreshToken(user.getId());

            return LoginResponse.builder()
                    .token(token)
                    .refreshToken(refreshToken)
                    .user(convertToUserDTO(user))
                    .build();
        } catch (Exception e) {
            log.error("Phone login failed: {}", phone, e);
            throw new RuntimeException("登录失败: " + e.getMessage());
        }
    }

    @Override
    public LoginResponse loginWithHuawei(String authCode) {
        // TODO: 实现华为账号登录逻辑
        throw new RuntimeException("华为账号登录功能暂未实现");
    }

    @Override
    public LoginResponse loginWithWechat(String authCode) {
        // TODO: 实现微信账号登录逻辑
        throw new RuntimeException("微信账号登录功能暂未实现");
    }

    @Override
    @Transactional
    public RegisterResponse register(RegisterRequest request) {
        try {
            // 验证验证码
            if (!verifyCode(request.getPhone(), request.getVerificationCode(), "register")) {
                throw new RuntimeException("验证码错误或已过期");
            }

            // 检查手机号是否已注册
            if (isPhoneRegistered(request.getPhone())) {
                throw new RuntimeException("手机号已被注册");
            }

            // 检查邮箱是否已注册（如果提供了邮箱）
            if (StringUtils.hasText(request.getEmail()) && isEmailRegistered(request.getEmail())) {
                throw new RuntimeException("邮箱已被注册");
            }

            // 创建新用户
            User user = new User();
            user.setUsername(request.getUsername());
            user.setPhone(request.getPhone());
            user.setEmail(request.getEmail());
            user.setPasswordHash(passwordUtil.encode(request.getPassword()));
            user.setLoginType("phone");
            user.setIsActive(true);
            user.setIsDeleted(false);
            user.setCreatedAt(LocalDateTime.now());
            user.setUpdatedAt(LocalDateTime.now());

            userMapper.insert(user);

            // 生成JWT token
            String token = jwtUtil.generateToken(user.getId(), user.getUsername());
            String refreshToken = jwtUtil.generateRefreshToken(user.getId());

            return RegisterResponse.builder()
                    .token(token)
                    .refreshToken(refreshToken)
                    .user(convertToUserDTO(user))
                    .build();
        } catch (Exception e) {
            log.error("User registration failed: {}", request.getPhone(), e);
            throw new RuntimeException("注册失败: " + e.getMessage());
        }
    }

    @Override
    public VerificationCodeResponse sendVerificationCode(VerificationCodeRequest request) {
        try {
            // 生成6位数字验证码
            String code = generateVerificationCode();

            // 存储到Redis，设置5分钟过期
            String key = VERIFICATION_CODE_PREFIX + request.getType() + ":" + request.getPhone();
            redisUtil.setEx(key, code, VERIFICATION_CODE_EXPIRE_MINUTES, TimeUnit.MINUTES);

            // TODO: 调用短信服务发送验证码
            log.info("Verification code sent to {}: {}", request.getPhone(), code);

            return VerificationCodeResponse.builder()
                    .expiresIn(VERIFICATION_CODE_EXPIRE_MINUTES * 60)
                    .build();
        } catch (Exception e) {
            log.error("Send verification code failed: {}", request.getPhone(), e);
            throw new RuntimeException("验证码发送失败: " + e.getMessage());
        }
    }

    @Override
    public boolean verifyCode(String phone, String code, String type) {
        try {
            String key = VERIFICATION_CODE_PREFIX + type + ":" + phone;
            String storedCode = redisUtil.get(key);

            if (storedCode != null && storedCode.equals(code)) {
                // 验证成功后删除验证码
                redisUtil.delete(key);
                return true;
            }
            return false;
        } catch (Exception e) {
            log.error("Verify code failed: {}", phone, e);
            return false;
        }
    }

    @Override
    public boolean validateToken(String token) {
        try {
            // 检查token是否在黑名单中
            String blacklistKey = TOKEN_BLACKLIST_PREFIX + token;
            if (redisUtil.hasKey(blacklistKey)) {
                return false;
            }

            // 验证token有效性
            return jwtUtil.validateToken(token);
        } catch (Exception e) {
            log.error("Token validation failed", e);
            return false;
        }
    }

    @Override
    public String refreshToken(String refreshToken) {
        try {
            // 验证刷新token
            if (!jwtUtil.validateToken(refreshToken)) {
                throw new RuntimeException("刷新token无效");
            }

            // 检查token类型
            String tokenType = jwtUtil.getTokenType(refreshToken);
            if (!"refresh".equals(tokenType)) {
                throw new RuntimeException("token类型错误");
            }

            // 获取用户ID
            Long userId = jwtUtil.getUserIdFromToken(refreshToken);
            if (userId == null) {
                throw new RuntimeException("无法获取用户信息");
            }

            // 获取用户信息
            User user = userMapper.selectById(userId);
            if (user == null || user.getIsDeleted()) {
                throw new RuntimeException("用户不存在");
            }

            // 生成新的访问token
            return jwtUtil.generateToken(userId, user.getUsername());
        } catch (Exception e) {
            log.error("Refresh token failed", e);
            throw new RuntimeException("刷新token失败: " + e.getMessage());
        }
    }

    @Override
    public boolean logout(String token) {
        try {
            // 将token加入黑名单
            String blacklistKey = TOKEN_BLACKLIST_PREFIX + token;
            long expireTime = jwtUtil.getExpirationTime();
            long currentTime = System.currentTimeMillis();

            if (expireTime > currentTime) {
                // 转换为秒
                long ttl = (expireTime - currentTime) / 1000;
                redisUtil.setEx(blacklistKey, "blacklisted", ttl, TimeUnit.SECONDS);
            }

            return true;
        } catch (Exception e) {
            log.error("Logout failed", e);
            return false;
        }
    }

    @Override
    public UserDTO getUserById(Long userId) {
        try {
            User user = userMapper.selectById(userId);
            if (user != null && !user.getIsDeleted()) {
                return convertToUserDTO(user);
            }
            return null;
        } catch (Exception e) {
            log.error("Get user by id failed: {}", userId, e);
            return null;
        }
    }

    @Override
    public UserDTO getUserByPhone(String phone) {
        try {
            Optional<User> userOpt = userMapper.findByPhone(phone);
            if (userOpt.isPresent() && !userOpt.get().getIsDeleted()) {
                return convertToUserDTO(userOpt.get());
            }
            return null;
        } catch (Exception e) {
            log.error("Get user by phone failed: {}", phone, e);
            return null;
        }
    }

    @Override
    public void updateLastLoginTime(Long userId) {
        try {
            userMapper.updateLastLoginTime(userId, LocalDateTime.now());
        } catch (Exception e) {
            log.error("Update last login time failed: {}", userId, e);
        }
    }

    @Override
    public boolean isPhoneRegistered(String phone) {
        try {
            return userMapper.existsByPhone(phone);
        } catch (Exception e) {
            log.error("Check phone registration failed: {}", phone, e);
            return false;
        }
    }

    @Override
    public boolean isEmailRegistered(String email) {
        try {
            return userMapper.existsByEmail(email);
        } catch (Exception e) {
            log.error("Check email registration failed: {}", email, e);
            return false;
        }
    }

    @Override
    public UserDTO updateUser(UpdateUserRequest request) {
        try {
            User user = userMapper.selectById(request.getUserId());
            if (user == null || user.getIsDeleted()) {
                throw new RuntimeException("用户不存在");
            }

            // 更新用户信息
            if (request.getUsername() != null) {
                user.setUsername(request.getUsername());
            }
            if (request.getEmail() != null) {
                user.setEmail(request.getEmail());
            }
            if (request.getPhone() != null) {
                user.setPhone(request.getPhone());
            }
            if (request.getAvatarUrl() != null) {
                user.setAvatar(request.getAvatarUrl());
            }
            if (request.getHuaweiAccountId() != null) {
                user.setHuaweiId(request.getHuaweiAccountId());
            }
            if (request.getWechatAccountId() != null) {
                user.setWechatId(request.getWechatAccountId());
            }

            userMapper.updateById(user);
            return convertToUserDTO(user);
        } catch (Exception e) {
            log.error("Update user failed: {}", request.getUserId(), e);
            throw new RuntimeException("更新用户信息失败: " + e.getMessage());
        }
    }

    @Override
    public boolean updatePassword(UpdatePasswordRequest request) {
        try {
            // 验证确认密码
            if (!request.getNewPassword().equals(request.getConfirmPassword())) {
                throw new RuntimeException("新密码与确认密码不一致");
            }

            User user = userMapper.selectById(request.getUserId());
            if (user == null || user.getIsDeleted()) {
                throw new RuntimeException("用户不存在");
            }

            // 验证旧密码
            if (!passwordUtil.matches(request.getOldPassword(), user.getPasswordHash())) {
                throw new RuntimeException("旧密码错误");
            }

            // 更新密码
            user.setPasswordHash(passwordUtil.encode(request.getNewPassword()));
            userMapper.updateById(user);

            return true;
        } catch (Exception e) {
            log.error("Update password failed: {}", request.getUserId(), e);
            throw new RuntimeException("更新密码失败: " + e.getMessage());
        }
    }

    @Override
    public boolean bindPhone(BindPhoneRequest request) {
        try {
            // 验证验证码
            if (!verifyCode(request.getPhone(), request.getVerificationCode(), "bind")) {
                throw new RuntimeException("验证码错误或已过期");
            }

            // 检查手机号是否已被其他用户使用
            if (isPhoneRegistered(request.getPhone())) {
                throw new RuntimeException("该手机号已被其他用户使用");
            }

            User user = userMapper.selectById(request.getUserId());
            if (user == null || user.getIsDeleted()) {
                throw new RuntimeException("用户不存在");
            }

            user.setPhone(request.getPhone());
            userMapper.updateById(user);

            return true;
        } catch (Exception e) {
            log.error("Bind phone failed: {}", request.getUserId(), e);
            throw new RuntimeException("绑定手机号失败: " + e.getMessage());
        }
    }

    @Override
    public boolean bindEmail(BindEmailRequest request) {
        try {
            // 验证验证码
            if (!verifyCode(request.getEmail(), request.getVerificationCode(), "bind")) {
                throw new RuntimeException("验证码错误或已过期");
            }

            // 检查邮箱是否已被其他用户使用
            if (isEmailRegistered(request.getEmail())) {
                throw new RuntimeException("该邮箱已被其他用户使用");
            }

            User user = userMapper.selectById(request.getUserId());
            if (user == null || user.getIsDeleted()) {
                throw new RuntimeException("用户不存在");
            }

            user.setEmail(request.getEmail());
            userMapper.updateById(user);

            return true;
        } catch (Exception e) {
            log.error("Bind email failed: {}", request.getUserId(), e);
            throw new RuntimeException("绑定邮箱失败: " + e.getMessage());
        }
    }

    @Override
    public boolean deleteUser(Long userId) {
        try {
            User user = userMapper.selectById(userId);
            if (user == null || user.getIsDeleted()) {
                throw new RuntimeException("用户不存在");
            }

            // 软删除
            user.setIsDeleted(true);
            userMapper.updateById(user);

            return true;
        } catch (Exception e) {
            log.error("Delete user failed: {}", userId, e);
            throw new RuntimeException("删除用户失败: " + e.getMessage());
        }
    }

    /**
     * 生成验证码
     */
    private String generateVerificationCode() {
        Random random = new Random();
        StringBuilder code = new StringBuilder();
        for (int i = 0; i < VERIFICATION_CODE_LENGTH; i++) {
            code.append(random.nextInt(10));
        }
        return code.toString();
    }

    /**
     * 转换User实体为UserDTO
     */
    private UserDTO convertToUserDTO(User user) {
        UserDTO userDTO = new UserDTO();
        BeanUtils.copyProperties(user, userDTO);
        return userDTO;
    }
}