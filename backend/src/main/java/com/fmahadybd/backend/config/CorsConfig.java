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

    @Value("${cors.allowed.origins}")
    private String allowedOrigins;

    @Value("${cors.allowed.methods}")
    private String allowedMethods;

    @Value("${cors.allowed.headers}")
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

        List<String> origins = Arrays.asList(allowedOrigins.split("\\s*,\\s*"));
        List<String> methods = Arrays.asList(allowedMethods.split("\\s*,\\s*"));
        List<String> headers = Arrays.asList(allowedHeaders.split("\\s*,\\s*"));
        List<String> exposed = Arrays.asList(exposedHeaders.split("\\s*,\\s*"));

        // ✅ use allowedOriginPatterns, never allowedOrigins
        configuration.setAllowedOriginPatterns(origins);
        configuration.setAllowedMethods(methods);
        configuration.setAllowedHeaders(headers);
        configuration.setExposedHeaders(exposed);
        configuration.setAllowCredentials(allowCredentials);
        configuration.setMaxAge(maxAge);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);

        System.out.println("✅ CORS Config Loaded:");
        System.out.println("   Origins: " + origins);
        System.out.println("   Methods: " + methods);
        System.out.println("   Headers: " + headers);
        System.out.println("   Exposed: " + exposed);
        System.out.println("   AllowCredentials: " + allowCredentials);
        System.out.println("   MaxAge: " + maxAge);

        return source;
    }
}
