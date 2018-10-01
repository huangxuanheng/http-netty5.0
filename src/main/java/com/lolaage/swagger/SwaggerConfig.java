package com.lolaage.swagger;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurationSupport;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

/**
 * <p>作者 yaohua.liu
 * <p>日期 2017-09-19 20:01
 * <p>说明 swagger配置
 */
/*@Configuration
@EnableSwagger2*/
public class SwaggerConfig extends WebMvcConfigurationSupport {
    @Bean
    public Docket productApi() {
        return new Docket(DocumentationType.SWAGGER_2).host("192.168.43.110:7200")
                .select()
                .apis(RequestHandlerSelectors.basePackage("com.lolaage.helper.controller"))
                //.paths(regex("/product.*"))
                .build();
    }
}
