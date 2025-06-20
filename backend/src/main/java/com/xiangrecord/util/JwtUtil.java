package com.xiangrecord.util;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

/**
 * JWT工具类
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Slf4j
@Component
public class JwtUtil {

    @Value("${jwt.secret:xiangrecord-jwt-secret-key-2024-very-long-and-secure}")
    private String secret;

    @Value("${jwt.expiration:3600}")
    private Long expiration; // 默认1小时

    @Value("${jwt.refresh-expiration:604800}")
    private Long refreshExpiration; // 默认7天

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    /**
     * 生成访问令牌
     * 
     * @param userId 用户ID
     * @param username 用户名
     * @return JWT token
     */
    public String generateToken(Long userId, String username) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("username", username);
        claims.put("type", "access");
        return createToken(claims, userId.toString(), expiration * 1000);
    }

    /**
     * 生成刷新令牌
     * 
     * @param userId 用户ID
     * @return 刷新令牌
     */
    public String generateRefreshToken(Long userId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("type", "refresh");
        return createToken(claims, userId.toString(), refreshExpiration * 1000);
    }

    /**
     * 创建令牌
     * 
     * @param claims 声明
     * @param subject 主题
     * @param expiration 过期时间（毫秒）
     * @return JWT token
     */
    private String createToken(Map<String, Object> claims, String subject, Long expiration) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expiration);

        return Jwts.builder()
                .claims(claims)
                .subject(subject)
                .issuedAt(now)
                .expiration(expiryDate)
                .signWith(getSigningKey())
                .compact();
    }

    /**
     * 验证令牌
     * 
     * @param token JWT token
     * @return 是否有效
     */
    public boolean validateToken(String token) {
        try {
            Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            log.error("JWT token validation failed: {}", e.getMessage());
            return false;
        }
    }

    /**
     * 从令牌中获取用户ID
     * 
     * @param token JWT token
     * @return 用户ID
     */
    public Long getUserIdFromToken(String token) {
        try {
            Claims claims = getClaimsFromToken(token);
            Object userId = claims.get("userId");
            if (userId instanceof Integer) {
                return ((Integer) userId).longValue();
            } else if (userId instanceof Long) {
                return (Long) userId;
            } else {
                return Long.parseLong(userId.toString());
            }
        } catch (Exception e) {
            log.error("Failed to get user ID from token: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 从令牌中获取用户名
     * 
     * @param token JWT token
     * @return 用户名
     */
    public String getUsernameFromToken(String token) {
        return getClaimFromToken(token, claims -> claims.get("username", String.class));
    }

    /**
     * 从令牌中获取过期时间
     * 
     * @param token JWT token
     * @return 过期时间
     */
    public Date getExpirationDateFromToken(String token) {
        return getClaimFromToken(token, Claims::getExpiration);
    }

    /**
     * 从令牌中获取过期时间戳
     * 
     * @param token JWT token
     * @return 过期时间戳（毫秒）
     */
    public Long getExpirationFromToken(String token) {
        try {
            Date expiration = getExpirationDateFromToken(token);
            return expiration != null ? expiration.getTime() : null;
        } catch (Exception e) {
            log.error("Failed to get expiration from token: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 检查令牌是否过期
     * 
     * @param token JWT token
     * @return 是否过期
     */
    public boolean isTokenExpired(String token) {
        try {
            Date expiration = getExpirationDateFromToken(token);
            return expiration.before(new Date());
        } catch (Exception e) {
            log.error("Failed to check token expiration: {}", e.getMessage());
            return true;
        }
    }

    /**
     * 获取令牌类型
     * 
     * @param token JWT token
     * @return 令牌类型（access/refresh）
     */
    public String getTokenType(String token) {
        return getClaimFromToken(token, claims -> claims.get("type", String.class));
    }

    /**
     * 从令牌中获取指定声明
     * 
     * @param token JWT token
     * @param claimsResolver 声明解析器
     * @param <T> 返回类型
     * @return 声明值
     */
    public <T> T getClaimFromToken(String token, Function<Claims, T> claimsResolver) {
        try {
            final Claims claims = getClaimsFromToken(token);
            return claimsResolver.apply(claims);
        } catch (Exception e) {
            log.error("Failed to get claim from token: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 从令牌中获取所有声明
     * 
     * @param token JWT token
     * @return 声明
     */
    private Claims getClaimsFromToken(String token) {
        return Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    /**
     * 获取令牌过期时间（秒）
     * 
     * @return 过期时间
     */
    public Long getExpirationTime() {
        return expiration;
    }

    /**
     * 获取刷新令牌过期时间（秒）
     * 
     * @return 刷新令牌过期时间
     */
    public Long getRefreshExpirationTime() {
        return refreshExpiration;
    }

    /**
     * 刷新令牌
     * 
     * @param refreshToken 刷新令牌
     * @param username 用户名
     * @return 新的访问令牌
     */
    public String refreshToken(String refreshToken, String username) {
        try {
            if (!validateToken(refreshToken)) {
                return null;
            }
            
            String tokenType = getTokenType(refreshToken);
            if (!"refresh".equals(tokenType)) {
                return null;
            }
            
            Long userId = getUserIdFromToken(refreshToken);
            if (userId == null) {
                return null;
            }
            
            return generateToken(userId, username);
        } catch (Exception e) {
            log.error("Failed to refresh token: {}", e.getMessage());
            return null;
        }
    }
}