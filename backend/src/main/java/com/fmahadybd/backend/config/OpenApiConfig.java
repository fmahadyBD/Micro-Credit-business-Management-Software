package com.fmahadybd.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.core.jackson.ModelResolver;
import com.fasterxml.jackson.databind.ObjectMapper;

@Configuration
public class OpenApiConfig {
    
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Installment Management API")
                        .description("API for managing installments with file uploads")
                        .version("1.0"));
    }

    /**
     * Configure ObjectMapper for OpenAPI to handle lazy loading properly
     */
    @Bean
    public ModelResolver modelResolver(ObjectMapper objectMapper) {
        return new ModelResolver(objectMapper);
    }
}