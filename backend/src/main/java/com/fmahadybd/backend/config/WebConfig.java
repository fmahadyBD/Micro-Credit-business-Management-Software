package com.fmahadybd.backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.io.File;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${UPLOAD_PATH:./uploads}")
    private String uploadsPath;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Convert to absolute path to avoid any relative path issues
        File uploadDir = new File(uploadsPath);
        String absolutePath = uploadDir.getAbsolutePath();
        
        // Ensure it ends with File.separator
        if (!absolutePath.endsWith(File.separator)) {
            absolutePath += File.separator;
        }
        
        String resourceLocation = "file:" + absolutePath;
        
        System.out.println("=== FILE SERVING CONFIG ===");
        System.out.println("Upload path: " + uploadsPath);
        System.out.println("Absolute path: " + absolutePath);
        System.out.println("Resource location: " + resourceLocation);
        System.out.println("Directory exists: " + uploadDir.exists());
        System.out.println("===========================");
        
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations(resourceLocation)
                .setCachePeriod(3600);
    }
}