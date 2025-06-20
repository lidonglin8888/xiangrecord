package com.xiangrecord.util;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

/**
 * Redis工具类
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class RedisUtil {

    private final RedisTemplate<String, Object> redisTemplate;

    /**
     * 设置键值对
     * 
     * @param key 键
     * @param value 值
     */
    public void set(String key, Object value) {
        try {
            redisTemplate.opsForValue().set(key, value);
        } catch (Exception e) {
            log.error("Redis set operation failed for key: {}", key, e);
        }
    }

    /**
     * 设置键值对并指定过期时间
     * 
     * @param key 键
     * @param value 值
     * @param timeout 过期时间
     * @param unit 时间单位
     */
    public void setEx(String key, Object value, long timeout, TimeUnit unit) {
        try {
            redisTemplate.opsForValue().set(key, value, timeout, unit);
        } catch (Exception e) {
            log.error("Redis setEx operation failed for key: {}", key, e);
        }
    }

    /**
     * 获取值
     * 
     * @param key 键
     * @return 值
     */
    public String get(String key) {
        try {
            Object value = redisTemplate.opsForValue().get(key);
            return value != null ? value.toString() : null;
        } catch (Exception e) {
            log.error("Redis get operation failed for key: {}", key, e);
            return null;
        }
    }

    /**
     * 获取对象值
     * 
     * @param key 键
     * @param clazz 对象类型
     * @param <T> 泛型类型
     * @return 对象值
     */
    @SuppressWarnings("unchecked")
    public <T> T getObject(String key, Class<T> clazz) {
        try {
            Object value = redisTemplate.opsForValue().get(key);
            if (value != null && clazz.isInstance(value)) {
                return (T) value;
            }
            return null;
        } catch (Exception e) {
            log.error("Redis getObject operation failed for key: {}", key, e);
            return null;
        }
    }

    /**
     * 删除键
     * 
     * @param key 键
     * @return 是否删除成功
     */
    public boolean delete(String key) {
        try {
            return Boolean.TRUE.equals(redisTemplate.delete(key));
        } catch (Exception e) {
            log.error("Redis delete operation failed for key: {}", key, e);
            return false;
        }
    }

    /**
     * 检查键是否存在
     * 
     * @param key 键
     * @return 是否存在
     */
    public boolean hasKey(String key) {
        try {
            return Boolean.TRUE.equals(redisTemplate.hasKey(key));
        } catch (Exception e) {
            log.error("Redis hasKey operation failed for key: {}", key, e);
            return false;
        }
    }

    /**
     * 设置键的过期时间
     * 
     * @param key 键
     * @param timeout 过期时间
     * @param unit 时间单位
     * @return 是否设置成功
     */
    public boolean expire(String key, long timeout, TimeUnit unit) {
        try {
            return Boolean.TRUE.equals(redisTemplate.expire(key, timeout, unit));
        } catch (Exception e) {
            log.error("Redis expire operation failed for key: {}", key, e);
            return false;
        }
    }

    /**
     * 获取键的剩余过期时间
     * 
     * @param key 键
     * @param unit 时间单位
     * @return 剩余过期时间
     */
    public long getExpire(String key, TimeUnit unit) {
        try {
            Long expire = redisTemplate.getExpire(key, unit);
            return expire != null ? expire : -1;
        } catch (Exception e) {
            log.error("Redis getExpire operation failed for key: {}", key, e);
            return -1;
        }
    }

    /**
     * 递增操作
     * 
     * @param key 键
     * @param delta 递增值
     * @return 递增后的值
     */
    public long increment(String key, long delta) {
        try {
            Long result = redisTemplate.opsForValue().increment(key, delta);
            return result != null ? result : 0;
        } catch (Exception e) {
            log.error("Redis increment operation failed for key: {}", key, e);
            return 0;
        }
    }

    /**
     * 递减操作
     * 
     * @param key 键
     * @param delta 递减值
     * @return 递减后的值
     */
    public long decrement(String key, long delta) {
        try {
            Long result = redisTemplate.opsForValue().decrement(key, delta);
            return result != null ? result : 0;
        } catch (Exception e) {
            log.error("Redis decrement operation failed for key: {}", key, e);
            return 0;
        }
    }

    /**
     * 设置如果不存在
     * 
     * @param key 键
     * @param value 值
     * @return 是否设置成功
     */
    public boolean setIfAbsent(String key, Object value) {
        try {
            return Boolean.TRUE.equals(redisTemplate.opsForValue().setIfAbsent(key, value));
        } catch (Exception e) {
            log.error("Redis setIfAbsent operation failed for key: {}", key, e);
            return false;
        }
    }

    /**
     * 设置如果不存在并指定过期时间
     * 
     * @param key 键
     * @param value 值
     * @param timeout 过期时间
     * @param unit 时间单位
     * @return 是否设置成功
     */
    public boolean setIfAbsent(String key, Object value, long timeout, TimeUnit unit) {
        try {
            return Boolean.TRUE.equals(redisTemplate.opsForValue().setIfAbsent(key, value, timeout, unit));
        } catch (Exception e) {
            log.error("Redis setIfAbsent with timeout operation failed for key: {}", key, e);
            return false;
        }
    }
}