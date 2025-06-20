package com.xiangrecord.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xiangrecord.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * 用户Mapper接口
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Mapper
public interface UserMapper extends BaseMapper<User> {

    /**
     * 根据手机号查找用户
     * 
     * @param phone 手机号
     * @return 用户信息
     */
    @Select("SELECT * FROM users WHERE phone = #{phone} AND is_deleted = false")
    Optional<User> findByPhone(@Param("phone") String phone);

    /**
     * 根据华为ID查找用户
     * 
     * @param huaweiId 华为ID
     * @return 用户信息
     */
    @Select("SELECT * FROM users WHERE huawei_id = #{huaweiId} AND is_deleted = false")
    Optional<User> findByHuaweiId(@Param("huaweiId") String huaweiId);

    /**
     * 根据微信ID查找用户
     * 
     * @param wechatId 微信ID
     * @return 用户信息
     */
    @Select("SELECT * FROM users WHERE wechat_id = #{wechatId} AND is_deleted = false")
    Optional<User> findByWechatId(@Param("wechatId") String wechatId);

    /**
     * 根据邮箱查找用户
     * 
     * @param email 邮箱
     * @return 用户信息
     */
    @Select("SELECT * FROM users WHERE email = #{email} AND is_deleted = false")
    Optional<User> findByEmail(@Param("email") String email);

    /**
     * 检查手机号是否已存在
     * 
     * @param phone 手机号
     * @return 是否存在
     */
    @Select("SELECT COUNT(*) > 0 FROM users WHERE phone = #{phone} AND is_deleted = false")
    boolean existsByPhone(@Param("phone") String phone);

    /**
     * 检查邮箱是否已存在
     * 
     * @param email 邮箱
     * @return 是否存在
     */
    @Select("SELECT COUNT(*) > 0 FROM users WHERE email = #{email} AND is_deleted = false")
    boolean existsByEmail(@Param("email") String email);

    /**
     * 更新最后登录时间
     * 
     * @param userId 用户ID
     * @param lastLoginTime 最后登录时间
     * @return 更新行数
     */
    @Update("UPDATE users SET last_login_time = #{lastLoginTime}, updated_at = NOW() WHERE id = #{userId}")
    int updateLastLoginTime(@Param("userId") Long userId, @Param("lastLoginTime") LocalDateTime lastLoginTime);

    /**
     * 软删除用户
     * 
     * @param userId 用户ID
     * @return 更新行数
     */
    @Update("UPDATE users SET is_deleted = true, updated_at = NOW() WHERE id = #{userId}")
    int softDeleteUser(@Param("userId") Long userId);
}