package com.fmahadybd.backend.utils;



import lombok.experimental.UtilityClass;
import lombok.extern.slf4j.Slf4j;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Slf4j
@UtilityClass
public class FileUtils {

    /**
     * Ensure upload directory exists
     */
    public static void createUploadDirectory(String uploadPath) {
        try {
            Path path = Paths.get(uploadPath);
            if (!Files.exists(path)) {
                Files.createDirectories(path);
                log.info("Created upload directory: {}", path.toAbsolutePath());
            }
        } catch (Exception e) {
            log.error("Failed to create upload directory: {}", uploadPath, e);
        }
    }

    /**
     * Check if file exists
     */
    public static boolean fileExists(String filePath) {
        try {
            return Files.exists(Paths.get(filePath));
        } catch (Exception e) {
            return false;
        }
    }
}