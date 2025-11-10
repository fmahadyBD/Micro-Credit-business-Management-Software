package com.fmahadybd.backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

@Configuration
public class BeanConfig {

    // This will come from Render environment variables, or default to localhost
    @Value("${CORS_ALLOWED_ORIGINS:http://localhost:4200}")
    private String allowedOrigins;

    @Value("${CORS_ALLOWED_METHODS:GET,POST,DELETE,PUT,OPTIONS,PATCH}")
    private String allowedMethods;

    @Value("${CORS_ALLOWED_HEADERS:Origin,Content-Type,Accept,Authorization}")
    private String allowedHeaders;

    @Value("${CORS_ALLOW_CREDENTIALS:true}")
    private boolean allowCredentials;

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();

        config.setAllowCredentials(allowCredentials);

        // Split comma-separated origins from environment
        List<String> origins = Arrays.asList(allowedOrigins.split(","));
        config.setAllowedOrigins(origins);
        config.setAllowedHeaders(Arrays.asList(allowedHeaders.split(",")));
        config.setAllowedMethods(Arrays.asList(allowedMethods.split(",")));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);

        System.out.println("✅ Allowed CORS Origins: " + origins);
        return source;
    }
}
