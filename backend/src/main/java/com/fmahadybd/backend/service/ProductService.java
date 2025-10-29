package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.fmahadybd.backend.entity.Product;
import com.fmahadybd.backend.repository.ProductRepository;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;
    
    // Define your image upload directory
    private final String UPLOAD_DIR = "uploads/products/";

    public Product saveProduct(Product product) {
        return productRepository.save(product);
    }

    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    public Optional<Product> getProductById(Long id) {
        return productRepository.findById(id);
    }

    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
    }
    
    // Update product method
    public Product updateProduct(Long id, Product productDetails) {
        Product existingProduct = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        
        // Update fields
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

    // Save product with images
    public Product saveWithImages(Product product, MultipartFile[] images) {
        if (images != null && images.length > 0) {
            List<String> imagePaths = new ArrayList<>();
            for (MultipartFile image : images) {
                String filePath = saveImage(image);
                if (filePath != null) {
                    imagePaths.add(filePath);
                }
            }
            product.setImageFilePaths(imagePaths);
        }
        return productRepository.save(product);
    }

    // Upload images to existing product
    public void uploadProductImages(MultipartFile[] images, Long productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + productId));
        
        List<String> currentImages = product.getImageFilePaths();
        if (currentImages == null) {
            currentImages = new ArrayList<>();
        }
        
        for (MultipartFile image : images) {
            String filePath = saveImage(image);
            if (filePath != null) {
                currentImages.add(filePath);
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
        
        // Delete physical file
        try {
            Path path = Paths.get(filePath);
            Files.deleteIfExists(path);
        } catch (IOException e) {
            System.err.println("Failed to delete image file: " + filePath);
        }
    }

    private String saveImage(MultipartFile image) {
        try {
            // Create upload directory if it doesn't exist
            Path uploadPath = Paths.get(UPLOAD_DIR);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            
            // Generate unique filename
            String fileName = UUID.randomUUID().toString() + "_" + image.getOriginalFilename();
            Path filePath = uploadPath.resolve(fileName);
            
            // Save file
            Files.copy(image.getInputStream(), filePath);
            
            return filePath.toString();
        } catch (IOException e) {
            System.err.println("Failed to save image: " + e.getMessage());
            return null;
        }
    }
}