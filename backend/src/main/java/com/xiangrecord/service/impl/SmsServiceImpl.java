package com.xiangrecord.service.impl;

import com.xiangrecord.service.SmsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * 短信服务实现类
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Slf4j
@Service
public class SmsServiceImpl implements SmsService {

    @Value("${verification.sms.enabled:false}")
    private boolean smsEnabled;

    @Value("${verification.sms.mock-code:123456}")
    private String mockCode;

    @Override
    public boolean sendVerificationCode(String phone, String code, String type) {
        if (!smsEnabled) {
            // 开发环境模拟发送
            log.info("[模拟短信] 向手机号 {} 发送{}验证码: {}", phone, getTypeDescription(type), code);
            log.info("[开发提示] 请使用模拟验证码: {}", mockCode);
            return true;
        }

        try {
            // 这里应该调用真实的短信服务API
            // 例如：阿里云短信、腾讯云短信、华为云短信等
            return sendRealSms(phone, code, type);
        } catch (Exception e) {
            log.error("发送验证码短信失败: phone={}, type={}, error={}", phone, type, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean sendNotification(String phone, String message) {
        if (!smsEnabled) {
            // 开发环境模拟发送
            log.info("[模拟短信] 向手机号 {} 发送通知: {}", phone, message);
            return true;
        }

        try {
            // 这里应该调用真实的短信服务API
            return sendRealNotificationSms(phone, message);
        } catch (Exception e) {
            log.error("发送通知短信失败: phone={}, message={}, error={}", phone, message, e.getMessage(), e);
            return false;
        }
    }

    /**
     * 发送真实的验证码短信
     * 生产环境中需要实现具体的短信服务商API调用
     */
    private boolean sendRealSms(String phone, String code, String type) {
        // TODO: 实现真实的短信发送逻辑
        // 示例：
        // 1. 选择合适的短信模板
        // 2. 调用短信服务商API
        // 3. 处理返回结果
        
        log.info("发送验证码短信: phone={}, code={}, type={}", phone, code, type);
        
        // 这里应该是真实的API调用
        // 例如：阿里云短信服务
        /*
        try {
            SendSmsRequest request = new SendSmsRequest();
            request.setPhoneNumbers(phone);
            request.setSignName("香记录");
            request.setTemplateCode(getTemplateCode(type));
            request.setTemplateParam("{\"code\":\"" + code + "\"}");
            
            SendSmsResponse response = client.sendSms(request);
            return "OK".equals(response.getCode());
        } catch (Exception e) {
            log.error("调用阿里云短信服务失败", e);
            return false;
        }
        */
        
        return true;
    }

    /**
     * 发送真实的通知短信
     */
    private boolean sendRealNotificationSms(String phone, String message) {
        // TODO: 实现真实的通知短信发送逻辑
        log.info("发送通知短信: phone={}, message={}", phone, message);
        return true;
    }

    /**
     * 获取验证码类型描述
     */
    private String getTypeDescription(String type) {
        return switch (type) {
            case "register" -> "注册";
            case "login" -> "登录";
            case "reset_password" -> "重置密码";
            case "change_phone" -> "更换手机号";
            default -> "验证";
        };
    }

    /**
     * 根据类型获取短信模板代码
     * 生产环境中需要配置真实的模板代码
     */
    private String getTemplateCode(String type) {
        return switch (type) {
            case "register" -> "SMS_REGISTER_TEMPLATE";
            case "login" -> "SMS_LOGIN_TEMPLATE";
            case "reset_password" -> "SMS_RESET_PASSWORD_TEMPLATE";
            case "change_phone" -> "SMS_CHANGE_PHONE_TEMPLATE";
            default -> "SMS_DEFAULT_TEMPLATE";
        };
    }
}