package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Service
@Slf4j
@RequiredArgsConstructor
public class FileStorageService {

    @Value("${UPLOAD_PATH:./uploads}")
    private String fileUploadPath;

    /**
     * Save product image
     */
    public String saveProductImage(MultipartFile sourceFile, Long productId) {
        final String fileUploadSubPath = "products" + "/" + productId;
        return uploadFile(sourceFile, fileUploadSubPath);
    }

    /**
     * Generic file upload method
     */
    public String saveFile(MultipartFile sourceFile, Long entityId, String folder) {
        final String fileUploadSubPath = folder + "/" + entityId;
        return uploadFile(sourceFile, fileUploadSubPath);
    }

    private String uploadFile(MultipartFile sourceFile, String fileUploadSubPath) {
        try {
            // Clean and normalize paths
            String cleanBasePath = fileUploadPath.replaceAll("/+$", "");
            Path finalUploadPath = Paths.get(cleanBasePath, fileUploadSubPath);
            
            // Create directories if they don't exist
            Files.createDirectories(finalUploadPath);
            
            // Get file extension
            final String fileExtension = getFileExtension(sourceFile.getOriginalFilename());
            String fileName = System.currentTimeMillis() + "." + fileExtension;
            Path targetPath = finalUploadPath.resolve(fileName);
            
            // Save file
            Files.write(targetPath, sourceFile.getBytes());
            log.info("File saved to: {}", targetPath);
            
            // Return relative path for storage in database
            String relativePath = fileUploadSubPath + "/" + fileName;
            log.info("Relative path for DB: {}", relativePath);
            
            return relativePath;
            
        } catch (IOException e) {
            log.error("File was not saved", e);
            throw new RuntimeException("Could not store file: " + e.getMessage());
        }
    }

    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.isEmpty()) {
            return "";
        }
        int lastDotIndex = fileName.lastIndexOf(".");
        if (lastDotIndex == -1) {
            return "";
        }
        return fileName.substring(lastDotIndex + 1).toLowerCase();
    }

    /**
     * Delete file if it exists
     */
    public void deleteFile(String filePath) {
        if (filePath != null && !filePath.isEmpty()) {
            try {
                // Try to delete using absolute path from upload directory
                String cleanBasePath = fileUploadPath.replaceAll("/+$", "");
                Path absolutePath = Paths.get(cleanBasePath, filePath);
                
                boolean deleted = Files.deleteIfExists(absolutePath);
                
                if (deleted) {
                    log.info("Successfully deleted file: {}", absolutePath);
                } else {
                    log.warn("File not found for deletion: {}", absolutePath);
                }
                
            } catch (IOException e) {
                log.warn("Failed to delete file: {}", filePath, e);
            }
        }
    }

    /**
     * Get full file path for serving files
     */
    public Path getFullFilePath(String relativePath) {
        String cleanBasePath = fileUploadPath.replaceAll("/+$", "");
        return Paths.get(cleanBasePath, relativePath);
    }
}