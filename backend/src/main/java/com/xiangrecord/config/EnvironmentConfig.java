package com.xiangrecord.config;

import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

import jakarta.annotation.PostConstruct;
import java.util.Arrays;

/**
 * 环境配置管理类
 * 用于管理不同环境的配置信息和环境判断
 * 
 * @author xiangrecord
 * @since 1.0.0
 */
@Slf4j
@Getter
@Configuration
public class EnvironmentConfig {

    private final Environment environment;

    @Value("${spring.application.name}")
    private String applicationName;

    @Value("${app.info.version:1.0.0}")
    private String applicationVersion;

    @Value("${app.info.description:香香记录系统}")
    private String applicationDescription;

    @Value("${app.info.build-time:unknown}")
    private String buildTime;

    @Value("${server.port:8080}")
    private int serverPort;

    @Value("${server.servlet.context-path:/api}")
    private String contextPath;

    @Value("${app.debug.enabled:false}")
    private boolean debugEnabled;

    @Value("${app.debug.log-requests:false}")
    private boolean logRequestsEnabled;

    @Value("${app.debug.log-responses:false}")
    private boolean logResponsesEnabled;

    public EnvironmentConfig(Environment environment) {
        this.environment = environment;
    }

    /**
 * 初始化后打印环境信息
     */
    @PostConstruct
    public void init() {
        log.info("=== 应用环境信息 ===");
        log.info("应用名称: {}", applicationName);
        log.info("应用版本: {}", applicationVersion);
        log.info("应用描述: {}", applicationDescription);
        log.info("构建时间: {}", buildTime);
        log.info("当前环境: {}", getCurrentProfile());
        log.info("服务端口: {}", serverPort);
        log.info("上下文路径: {}", contextPath);
        log.info("调试模式: {}", debugEnabled);
        log.info("===================");
    }

    /**
     * 获取当前激活的Profile
     * 
     * @return 当前Profile名称
     */
    public String getCurrentProfile() {
        String[] activeProfiles = environment.getActiveProfiles();
        if (activeProfiles.length > 0) {
            return activeProfiles[0];
        }
        
        String[] defaultProfiles = environment.getDefaultProfiles();
        if (defaultProfiles.length > 0) {
            return defaultProfiles[0];
        }
        
        return "unknown";
    }

    /**
     * 获取所有激活的Profile
     * 
     * @return Profile数组
     */
    public String[] getActiveProfiles() {
        return environment.getActiveProfiles();
    }

    /**
     * 判断是否为开发环境
     * 
     * @return true if development environment
     */
    public boolean isDevelopment() {
        return hasProfile("dev");
    }

    /**
     * 判断是否为生产环境
     * 
     * @return true if production environment
     */
    public boolean isProduction() {
        return hasProfile("prod");
    }

    /**
     * 判断是否为测试环境
     * 
     * @return true if test environment
     */
    public boolean isTest() {
        return hasProfile("test");
    }

    /**
     * 判断是否包含指定的Profile
     * 
     * @param profile Profile名称
     * @return true if profile is active
     */
    public boolean hasProfile(String profile) {
        return Arrays.asList(environment.getActiveProfiles()).contains(profile);
    }

    /**
     * 获取配置属性值
     * 
     * @param key 配置键
     * @return 配置值
     */
    public String getProperty(String key) {
        return environment.getProperty(key);
    }

    /**
     * 获取配置属性值，如果不存在则返回默认值
     * 
     * @param key 配置键
     * @param defaultValue 默认值
     * @return 配置值或默认值
     */
    public String getProperty(String key, String defaultValue) {
        return environment.getProperty(key, defaultValue);
    }

    /**
     * 获取指定类型的配置属性值
     * 
     * @param key 配置键
     * @param targetType 目标类型
     * @param <T> 类型参数
     * @return 配置值
     */
    public <T> T getProperty(String key, Class<T> targetType) {
        return environment.getProperty(key, targetType);
    }

    /**
     * 获取指定类型的配置属性值，如果不存在则返回默认值
     * 
     * @param key 配置键
     * @param targetType 目标类型
     * @param defaultValue 默认值
     * @param <T> 类型参数
     * @return 配置值或默认值
     */
    public <T> T getProperty(String key, Class<T> targetType, T defaultValue) {
        return environment.getProperty(key, targetType, defaultValue);
    }

    /**
     * 检查配置属性是否存在
     * 
     * @param key 配置键
     * @return true if property exists
     */
    public boolean containsProperty(String key) {
        return environment.containsProperty(key);
    }

    /**
     * 获取数据库相关配置信息
     * 
     * @return 数据库配置信息
     */
    public DatabaseInfo getDatabaseInfo() {
        return DatabaseInfo.builder()
                .url(getProperty("spring.datasource.url", "unknown"))
                .driverClassName(getProperty("spring.datasource.driver-class-name", "unknown"))
                .username(getProperty("spring.datasource.username", "unknown"))
                .maxPoolSize(getProperty("spring.datasource.hikari.maximum-pool-size", Integer.class, 10))
                .build();
    }

    /**
     * 获取CORS配置信息
     * 
     * @return CORS配置信息
     */
    public CorsInfo getCorsInfo() {
        return CorsInfo.builder()
                .allowedOrigins(getProperty("app.cors.allowed-origins", "*"))
                .allowedMethods(getProperty("app.cors.allowed-methods", "*"))
                .allowedHeaders(getProperty("app.cors.allowed-headers", "*"))
                .allowCredentials(getProperty("app.cors.allow-credentials", Boolean.class, true))
                .maxAge(getProperty("app.cors.max-age", Long.class, 3600L))
                .build();
    }

    /**
     * 数据库配置信息
     */
    @Getter
    @lombok.Builder
    public static class DatabaseInfo {
        private final String url;
        private final String driverClassName;
        private final String username;
        private final Integer maxPoolSize;
    }

    /**
     * CORS配置信息
     */
    @Getter
    @lombok.Builder
    public static class CorsInfo {
        private final String allowedOrigins;
        private final String allowedMethods;
        private final String allowedHeaders;
        private final Boolean allowCredentials;
        private final Long maxAge;
    }

    /**
     * 获取应用完整信息
     * 
     * @return 应用信息字符串
     */
    public String getApplicationInfo() {
        return String.format("%s v%s (%s) - %s", 
                applicationName, 
                applicationVersion, 
                getCurrentProfile(), 
                applicationDescription);
    }

    /**
     * 获取服务器完整地址
     * 
     * @return 服务器地址
     */
    public String getServerUrl() {
        String protocol = getProperty("server.ssl.enabled", Boolean.class, false) ? "https" : "http";
        String host = getProperty("server.address", "localhost");
        return String.format("%s://%s:%d%s", protocol, host, serverPort, contextPath);
    }
}