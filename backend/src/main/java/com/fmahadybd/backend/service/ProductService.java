package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.fmahadybd.backend.entity.Product;
import com.fmahadybd.backend.repository.ProductRepository;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@Slf4j
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;
    private final FileStorageService fileStorageService;

    public Product saveProduct(Product product) {
        return productRepository.save(product);
    }

    public List<Product> getAllProducts() {
        return productRepository.findAllWithAgent();
    }

    public Optional<Product> getProductById(Long id) {
        return productRepository.findByIdWithAgent(id);
    }

    public void deleteProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        
        if (product.getImageFilePaths() != null) {
            for (String imagePath : product.getImageFilePaths()) {
                fileStorageService.deleteFile(imagePath);
            }
        }
        
        productRepository.deleteById(id);
    }
    
    public Product updateProduct(Long id, Product productDetails) {
        Product existingProduct = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        
        if (productDetails.getName() != null) {
            existingProduct.setName(productDetails.getName());
        }
        if (productDetails.getCategory() != null) {
            existingProduct.setCategory(productDetails.getCategory());
        }
        if (productDetails.getDescription() != null) {
            existingProduct.setDescription(productDetails.getDescription());
        }
        if (productDetails.getPrice() != null) {
            existingProduct.setPrice(productDetails.getPrice());
        }
        if (productDetails.getCostPrice() != null) {
            existingProduct.setCostPrice(productDetails.getCostPrice());
        }
        if (productDetails.getStock() != null) {
            existingProduct.setStock(productDetails.getStock());
        }
        if (productDetails.getStatus() != null) {
            existingProduct.setStatus(productDetails.getStatus());
        }
        if (productDetails.getIsDeliveryRequired() != null) {
            existingProduct.setIsDeliveryRequired(productDetails.getIsDeliveryRequired());
        }
        if (productDetails.getSoldByAgent() != null) {
            existingProduct.setSoldByAgent(productDetails.getSoldByAgent());
        }
        
        return productRepository.save(existingProduct);
    }

    // Save product with images - FIXED VERSION
    public Product saveWithImages(Product product, MultipartFile[] images) {
        // First save the product to get an ID
        Product savedProduct = productRepository.save(product);
        
        if (images != null && images.length > 0) {
            List<String> imagePaths = new ArrayList<>();
            for (MultipartFile image : images) {
                // Save the file and get absolute path
                String absolutePath = fileStorageService.saveFile(image, savedProduct.getId(), "products");
                if (absolutePath != null) {
                    // Convert to relative web path
                    String relativePath = convertToRelativePath(absolutePath, savedProduct.getId());
                    imagePaths.add(relativePath);
                }
            }
            savedProduct.setImageFilePaths(imagePaths);
            return productRepository.save(savedProduct);
        }
        return savedProduct;
    }

    // Upload images to existing product - FIXED VERSION
    public void uploadProductImages(MultipartFile[] images, Long productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + productId));
        
        List<String> currentImages = product.getImageFilePaths();
        if (currentImages == null) {
            currentImages = new ArrayList<>();
        }
        
        for (MultipartFile image : images) {
            // Save the file and get absolute path
            String absolutePath = fileStorageService.saveFile(image, productId, "products");
            if (absolutePath != null) {
                // Convert to relative web path
                String relativePath = convertToRelativePath(absolutePath, productId);
                currentImages.add(relativePath);
            }
        }
        
        product.setImageFilePaths(currentImages);
        productRepository.save(product);
    }

    // Delete product image
    public void deleteProductImage(Long productId, String filePath) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + productId));
        
        List<String> currentImages = product.getImageFilePaths();
        if (currentImages != null) {
            currentImages.remove(filePath);
            product.setImageFilePaths(currentImages);
            productRepository.save(product);
        }
        
        fileStorageService.deleteFile(filePath);
    }

    /**
     * Convert absolute file path to relative web path
     * Example: uploads/products/1/12345.jpg -> /uploads/products/1/12345.jpg
     */
    private String convertToRelativePath(String absolutePath, Long productId) {
        if (absolutePath == null || absolutePath.isEmpty()) {
            return "";
        }
        
        // Extract filename from absolute path
        String fileName = getFileNameFromPath(absolutePath);
        
        // Build relative web path
        return "/uploads/products/" + productId + "/" + fileName;
    }

    private String getFileNameFromPath(String filePath) {
        if (filePath == null || filePath.isEmpty()) return "";
        int lastSeparator = Math.max(
            filePath.lastIndexOf("/"), 
            filePath.lastIndexOf("\\")
        );
        return lastSeparator >= 0 ? filePath.substring(lastSeparator + 1) : filePath;
    }
}