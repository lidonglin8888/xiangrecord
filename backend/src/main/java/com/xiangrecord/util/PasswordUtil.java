package com.xiangrecord.util;

import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * 密码工具类
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Slf4j
@Component
public class PasswordUtil {

    private final PasswordEncoder passwordEncoder;

    public PasswordUtil() {
        this.passwordEncoder = new BCryptPasswordEncoder(12);
    }

    /**
     * 加密密码
     * 
     * @param rawPassword 原始密码
     * @return 加密后的密码
     */
    public String encode(String rawPassword) {
        try {
            if (rawPassword == null || rawPassword.trim().isEmpty()) {
                throw new IllegalArgumentException("密码不能为空");
            }
            return passwordEncoder.encode(rawPassword);
        } catch (Exception e) {
            log.error("Password encoding failed", e);
            throw new RuntimeException("密码加密失败", e);
        }
    }

    /**
     * 验证密码
     * 
     * @param rawPassword 原始密码
     * @param encodedPassword 加密后的密码
     * @return 是否匹配
     */
    public boolean matches(String rawPassword, String encodedPassword) {
        try {
            if (rawPassword == null || encodedPassword == null) {
                return false;
            }
            return passwordEncoder.matches(rawPassword, encodedPassword);
        } catch (Exception e) {
            log.error("Password matching failed", e);
            return false;
        }
    }

    /**
     * 验证密码强度
     * 
     * @param password 密码
     * @return 是否符合强度要求
     */
    public boolean isStrongPassword(String password) {
        if (password == null || password.length() < 6) {
            return false;
        }
        
        // 至少包含一个数字和一个字母
        boolean hasDigit = password.chars().anyMatch(Character::isDigit);
        boolean hasLetter = password.chars().anyMatch(Character::isLetter);
        
        return hasDigit && hasLetter;
    }

    /**
     * 生成随机密码
     * 
     * @param length 密码长度
     * @return 随机密码
     */
    public String generateRandomPassword(int length) {
        if (length < 6) {
            length = 6;
        }
        
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        StringBuilder password = new StringBuilder();
        
        for (int i = 0; i < length; i++) {
            int index = (int) (Math.random() * chars.length());
            password.append(chars.charAt(index));
        }
        
        return password.toString();
    }
}