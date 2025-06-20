package com.xiangrecord.service;

/**
 * 短信服务接口
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
public interface SmsService {

    /**
     * 发送验证码短信
     * 
     * @param phone 手机号
     * @param code 验证码
     * @param type 验证码类型（register, login, reset_password等）
     * @return 是否发送成功
     */
    boolean sendVerificationCode(String phone, String code, String type);

    /**
     * 发送通知短信
     * 
     * @param phone 手机号
     * @param message 短信内容
     * @return 是否发送成功
     */
    boolean sendNotification(String phone, String message);
}