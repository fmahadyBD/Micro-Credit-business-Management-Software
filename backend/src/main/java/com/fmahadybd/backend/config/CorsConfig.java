package com.fmahadybd.backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.Arrays;
import java.util.List;

@Configuration
public class CorsConfig implements WebMvcConfigurer {

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
        CorsConfiguration configuration = new CorsConfiguration();
        
        // Split comma-separated values
        List<String> origins = Arrays.asList(allowedOrigins.split("\\s*,\\s*"));
        List<String> methods = Arrays.asList(allowedMethods.split("\\s*,\\s*"));
        List<String> headers = Arrays.asList(allowedHeaders.split("\\s*,\\s*"));
        
        // CRITICAL FIX: Use setAllowedOriginPatterns instead of setAllowedOrigins
        // when allowCredentials is true
        configuration.setAllowedOriginPatterns(origins); // Changed from setAllowedOrigins
        configuration.setAllowedMethods(methods);
        configuration.setAllowedHeaders(headers);
        configuration.setAllowCredentials(allowCredentials);
        configuration.setMaxAge(3600L); // 1 hour
        
        // Add exposed headers for Authorization token
        configuration.setExposedHeaders(Arrays.asList("Authorization", "Content-Type"));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);

        System.out.println("✅ CORS Configuration:");
        System.out.println("   Allowed Origins: " + origins);
        System.out.println("   Allowed Methods: " + methods);
        System.out.println("   Allowed Headers: " + headers);
        System.out.println("   Allow Credentials: " + allowCredentials);
        
        return source;
    }

    // Additional CORS configuration for WebMvc
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns(allowedOrigins.split("\\s*,\\s*")) // Changed from allowedOrigins
                .allowedMethods(allowedMethods.split("\\s*,\\s*"))
                .allowedHeaders(allowedHeaders.split("\\s*,\\s*"))
                .exposedHeaders("Authorization", "Content-Type")
                .allowCredentials(allowCredentials)
                .maxAge(3600);
    }
}