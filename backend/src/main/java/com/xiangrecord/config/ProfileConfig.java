package com.xiangrecord.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;

import java.util.concurrent.Executor;
import java.util.concurrent.ThreadPoolExecutor;

/**
 * Profile配置类
 * 根据不同环境加载不同的Bean配置
 * 
 * @author xiangrecord
 * @since 1.0.0
 */
@Slf4j
@Configuration
public class ProfileConfig {

    /**
     * 开发环境配置
     */
    @Configuration
    @Profile("dev")
    @EnableAsync
    @EnableScheduling
    public static class DevelopmentConfig {

        /**
         * 开发环境异步任务执行器
         */
        @Bean("devTaskExecutor")
        public Executor taskExecutor() {
            log.info("配置开发环境异步任务执行器");
            ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
            executor.setCorePoolSize(2);
            executor.setMaxPoolSize(4);
            executor.setQueueCapacity(50);
            executor.setKeepAliveSeconds(60);
            executor.setThreadNamePrefix("dev-async-");
            executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
            executor.setWaitForTasksToCompleteOnShutdown(true);
            executor.setAwaitTerminationSeconds(30);
            executor.initialize();
            return executor;
        }

        /**
         * 开发环境定时任务调度器
         */
        @Bean("devTaskScheduler")
        public ThreadPoolTaskScheduler taskScheduler() {
            log.info("配置开发环境定时任务调度器");
            ThreadPoolTaskScheduler scheduler = new ThreadPoolTaskScheduler();
            scheduler.setPoolSize(2);
            scheduler.setThreadNamePrefix("dev-scheduler-");
            scheduler.setWaitForTasksToCompleteOnShutdown(true);
            scheduler.setAwaitTerminationSeconds(30);
            scheduler.initialize();
            return scheduler;
        }

        /**
         * 开发环境数据初始化器
         */
        @Bean
        @ConditionalOnProperty(name = "app-init.data.enabled", havingValue = "true")
        public DevDataInitializer devDataInitializer() {
            log.info("配置开发环境数据初始化器");
            return new DevDataInitializer();
        }
    }

    /**
     * 生产环境配置
     */
    @Configuration
    @Profile("prod")
    @EnableAsync
    @EnableScheduling
    public static class ProductionConfig {

        /**
         * 生产环境异步任务执行器
         */
        @Bean("prodTaskExecutor")
        public Executor taskExecutor() {
            log.info("配置生产环境异步任务执行器");
            ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
            executor.setCorePoolSize(8);
            executor.setMaxPoolSize(20);
            executor.setQueueCapacity(200);
            executor.setKeepAliveSeconds(300);
            executor.setThreadNamePrefix("prod-async-");
            executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
            executor.setWaitForTasksToCompleteOnShutdown(true);
            executor.setAwaitTerminationSeconds(60);
            executor.initialize();
            return executor;
        }

        /**
         * 生产环境定时任务调度器
         */
        @Bean("prodTaskScheduler")
        public ThreadPoolTaskScheduler taskScheduler() {
            log.info("配置生产环境定时任务调度器");
            ThreadPoolTaskScheduler scheduler = new ThreadPoolTaskScheduler();
            scheduler.setPoolSize(5);
            scheduler.setThreadNamePrefix("prod-scheduler-");
            scheduler.setWaitForTasksToCompleteOnShutdown(true);
            scheduler.setAwaitTerminationSeconds(60);
            scheduler.initialize();
            return scheduler;
        }

        /**
         * 生产环境性能监控器
         */
        @Bean
        @ConditionalOnProperty(name = "app.monitoring.enabled", havingValue = "true")
        public PerformanceMonitor performanceMonitor() {
            log.info("配置生产环境性能监控器");
            return new PerformanceMonitor();
        }
    }

    /**
     * 测试环境配置
     */
    @Configuration
    @Profile("test")
    public static class TestConfig {

        /**
         * 测试环境异步任务执行器
         */
        @Bean("testTaskExecutor")
        public Executor taskExecutor() {
            log.info("配置测试环境异步任务执行器");
            ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
            executor.setCorePoolSize(1);
            executor.setMaxPoolSize(2);
            executor.setQueueCapacity(10);
            executor.setKeepAliveSeconds(30);
            executor.setThreadNamePrefix("test-async-");
            executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
            executor.setWaitForTasksToCompleteOnShutdown(true);
            executor.setAwaitTerminationSeconds(10);
            executor.initialize();
            return executor;
        }

        /**
         * 测试环境数据生成器
         */
        @Bean
        @ConditionalOnProperty(name = "test-data.enabled", havingValue = "true")
        public TestDataGenerator testDataGenerator() {
            log.info("配置测试环境数据生成器");
            return new TestDataGenerator();
        }

        /**
         * 测试环境Mock服务
         */
        @Bean
        @ConditionalOnProperty(name = "test.mock.enabled", havingValue = "true")
        public MockService mockService() {
            log.info("配置测试环境Mock服务");
            return new MockService();
        }
    }

    /**
     * 开发环境数据初始化器
     */
    public static class DevDataInitializer {
        // 开发环境数据初始化逻辑
        public void initializeData() {
            log.info("初始化开发环境数据");
            // 这里可以添加开发环境特定的数据初始化逻辑
        }
    }

    /**
     * 生产环境性能监控器
     */
    public static class PerformanceMonitor {
        // 生产环境性能监控逻辑
        public void startMonitoring() {
            log.info("启动生产环境性能监控");
            // 这里可以添加性能监控逻辑
        }
    }

    /**
     * 测试环境数据生成器
     */
    public static class TestDataGenerator {
        // 测试环境数据生成逻辑
        public void generateTestData() {
            log.info("生成测试环境数据");
            // 这里可以添加测试数据生成逻辑
        }
    }

    /**
     * 测试环境Mock服务
     */
    public static class MockService {
        // 测试环境Mock服务逻辑
        public void setupMocks() {
            log.info("设置测试环境Mock服务");
            // 这里可以添加Mock服务设置逻辑
        }
    }
}