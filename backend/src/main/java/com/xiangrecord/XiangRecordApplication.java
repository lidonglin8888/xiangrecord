package com.xiangrecord;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Info;

/**
 * 便便记录应用主启动类
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@SpringBootApplication
@OpenAPIDefinition(
    info = @Info(
        title = "便便记录 API",
        version = "1.0.0",
        description = "便便记录应用后端API接口文档"
    )
)
public class XiangRecordApplication {

    public static void main(String[] args) {
        SpringApplication.run(XiangRecordApplication.class, args);
        System.out.println("\n==================================");
        System.out.println("🎉 便便记录应用启动成功！");
        System.out.println("==================================");
    }
}