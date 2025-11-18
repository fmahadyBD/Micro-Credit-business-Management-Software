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
public class CorsConfig {

    @Value("${cors.allowed.origins:*}")
    private String allowedOrigins;

    @Value("${cors.allowed.methods:GET,POST,PUT,DELETE,OPTIONS}")
    private String allowedMethods;

    @Value("${cors.allowed.headers:Authorization,Content-Type}")
    private String allowedHeaders;

    @Value("${cors.exposed.headers:Authorization,Content-Type}")
    private String exposedHeaders;

    @Value("${cors.allow.credentials:true}")
    private boolean allowCredentials;

    @Value("${cors.max.age:3600}")
    private long maxAge;

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(Arrays.asList(allowedOrigins.split("\\s*,\\s*")));
        configuration.setAllowedMethods(Arrays.asList(allowedMethods.split("\\s*,\\s*")));
        configuration.setAllowedHeaders(Arrays.asList(allowedHeaders.split("\\s*,\\s*")));
        configuration.setExposedHeaders(Arrays.asList(exposedHeaders.split("\\s*,\\s*")));
        configuration.setAllowCredentials(allowCredentials);
        configuration.setMaxAge(maxAge);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);

        System.out.println("✅ CORS Config Loaded");
        return source;
    }
}
