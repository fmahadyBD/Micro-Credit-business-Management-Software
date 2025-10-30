package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import static java.io.File.separator;
import static java.lang.System.currentTimeMillis;

@Service
@Slf4j
@RequiredArgsConstructor
public class FileStorageService {

    @Value("${application.file.uploads.photos-output-path:uploads}")
    private String fileUploadPath;

    /**
     * Save product image
     */
    public String saveProductImage(MultipartFile sourceFile, Long productId) {
        final String fileUploadSubPath = "products" + separator + productId;
        return uploadFile(sourceFile, fileUploadSubPath);
    }

    /**
     * Generic file upload method
     */
    public String saveFile(MultipartFile sourceFile, Long entityId, String folder) {
        final String fileUploadSubPath = folder + separator + entityId;
        return uploadFile(sourceFile, fileUploadSubPath);
    }

    private String uploadFile(MultipartFile sourceFile, String fileUploadSubPath) {
        try {
            final String finalUploadPath = fileUploadPath + separator + fileUploadSubPath;
            File targetFolder = new File(finalUploadPath);

            if (!targetFolder.exists() && !targetFolder.mkdirs()) {
                log.warn("Failed to create folder: " + targetFolder);
                return null;
            }

            final String fileExtension = getFileExtension(sourceFile.getOriginalFilename());
            String targetFilePath = finalUploadPath + separator + currentTimeMillis() + "." + fileExtension;
            Path targetPath = Paths.get(targetFilePath);

            Files.write(targetPath, sourceFile.getBytes());
            log.info("File saved to: " + targetFilePath);
            return targetFilePath;
        } catch (IOException e) {
            log.error("File was not saved", e);
            throw new RuntimeException("Could not store file: " + e.getMessage());
        }
    }

    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.isEmpty()) return "";
        int lastDotIndex = fileName.lastIndexOf(".");
        if (lastDotIndex == -1) return "";
        return fileName.substring(lastDotIndex + 1).toLowerCase();
    }

    /**
     * Delete file if it exists
     */
    public void deleteFile(String filePath) {
        if (filePath != null && !filePath.isEmpty()) {
            try {
                // Try to delete using absolute path first
                Files.deleteIfExists(Paths.get(filePath));
                
                // Also try to delete using relative path from uploads directory
                String relativePath = fileUploadPath + File.separator + filePath;
                Files.deleteIfExists(Paths.get(relativePath));
                
                log.info("Deleted file: " + filePath);
            } catch (IOException e) {
                log.warn("Failed to delete file: " + filePath, e);
            }
        }
    }
}