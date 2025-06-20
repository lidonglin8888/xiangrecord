package com.xiangrecord.service;

import com.xiangrecord.dto.*;
import com.xiangrecord.entity.User;

import java.util.Optional;

/**
 * 用户服务接口
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
public interface UserService {

    /**
     * 手机号登录
     * 
     * @param phone 手机号
     * @param password 密码
     * @return 登录响应
     */
    LoginResponse loginWithPhone(String phone, String password);

    /**
     * 华为账号登录
     * 
     * @param authCode 华为授权码
     * @return 登录响应
     */
    LoginResponse loginWithHuawei(String authCode);

    /**
     * 微信账号登录
     * 
     * @param authCode 微信授权码
     * @return 登录响应
     */
    LoginResponse loginWithWechat(String authCode);

    /**
     * 用户注册
     * 
     * @param request 注册请求
     * @return 注册响应
     */
    RegisterResponse register(RegisterRequest request);

    /**
     * 发送验证码
     * 
     * @param request 验证码请求
     * @return 验证码响应
     */
    VerificationCodeResponse sendVerificationCode(VerificationCodeRequest request);

    /**
     * 验证token有效性
     * 
     * @param token JWT token
     * @return 是否有效
     */
    boolean validateToken(String token);

    /**
     * 退出登录
     * 
     * @param token JWT token
     * @return 是否成功
     */
    boolean logout(String token);

    /**
     * 根据用户ID获取用户信息
     * 
     * @param userId 用户ID
     * @return 用户信息
     */
    UserDTO getUserById(Long userId);

    /**
     * 根据手机号获取用户信息
     * 
     * @param phone 手机号
     * @return 用户信息
     */
    UserDTO getUserByPhone(String phone);

    /**
     * 更新用户信息
     * 
     * @param request 更新请求
     * @return 更新后的用户信息
     */
    UserDTO updateUser(UpdateUserRequest request);

    /**
     * 更新用户密码
     * 
     * @param request 更新密码请求
     * @return 是否成功
     */
    boolean updatePassword(UpdatePasswordRequest request);

    /**
     * 绑定手机号
     * 
     * @param request 绑定手机号请求
     * @return 是否成功
     */
    boolean bindPhone(BindPhoneRequest request);

    /**
     * 绑定邮箱
     * 
     * @param request 绑定邮箱请求
     * @return 是否成功
     */
    boolean bindEmail(BindEmailRequest request);

    /**
     * 删除用户
     * 
     * @param userId 用户ID
     * @return 是否成功
     */
    boolean deleteUser(Long userId);

    /**
     * 更新用户最后登录时间
     * 
     * @param userId 用户ID
     */
    void updateLastLoginTime(Long userId);

    /**
     * 验证验证码
     * 
     * @param phone 手机号
     * @param code 验证码
     * @param type 验证码类型
     * @return 是否有效
     */
    boolean verifyCode(String phone, String code, String type);

    /**
     * 检查手机号是否已注册
     * 
     * @param phone 手机号
     * @return 是否已注册
     */
    boolean isPhoneRegistered(String phone);

    /**
     * 检查邮箱是否已注册
     * 
     * @param email 邮箱
     * @return 是否已注册
     */
    boolean isEmailRegistered(String email);

    /**
     * 刷新访问令牌
     * 
     * @param refreshToken 刷新令牌
     * @return 新的访问令牌
     */
    String refreshToken(String refreshToken);
}