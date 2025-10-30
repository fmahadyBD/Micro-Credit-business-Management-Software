package com.fmahadybd.backend.service;

import com.fmahadybd.backend.entity.Product;
import com.fmahadybd.backend.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;
    private final FileStorageService fileStorageService;
    
    private final String folder = "products";

    /** Create product without images */
    public Product saveProduct(Product product) {
        product.setDateAdded(LocalDate.now());
        return productRepository.save(product);
    }

    /** Create product with images */
    public Product saveWithImages(Product product, MultipartFile[] images) {
        product.setDateAdded(LocalDate.now());
        
        if (images != null && images.length > 0) {
            Arrays.stream(images)
                  .filter(image -> !image.isEmpty())
                  .forEach(image -> {
                      String filePath = fileStorageService.saveFile(image, 0L, folder);
                      product.getImageFilePaths().add(filePath);
                  });
        }
        
        return productRepository.save(product);
    }

    /** Upload additional images for existing product */
    public void uploadProductImages(MultipartFile[] images, Long productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found with ID: " + productId));

        if (images != null && images.length > 0) {
            Arrays.stream(images)
                  .filter(image -> !image.isEmpty())
                  .forEach(image -> {
                      String filePath = fileStorageService.saveFile(image, productId, folder);
                      product.getImageFilePaths().add(filePath);
                  });
            
            productRepository.save(product);
        }
    }

    /** Delete specific image from product */
    public void deleteProductImage(Long productId, String filePath) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found with ID: " + productId));

        if (product.getImageFilePaths().remove(filePath)) {
            fileStorageService.deleteFile(filePath);
            productRepository.save(product);
        } else {
            throw new RuntimeException("Image not found for this product: " + filePath);
        }
    }

    /** Get all products */
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    /** Get product by ID */
    public Optional<Product> getProductById(Long id) {
        return productRepository.findById(id);
    }

    /** Update product */
    public Product updateProduct(Long id, Product updatedProduct) {
        return productRepository.findById(id).map(product -> {
            product.setName(updatedProduct.getName());
            product.setCategory(updatedProduct.getCategory());
            product.setDescription(updatedProduct.getDescription());
            product.setPrice(updatedProduct.getPrice());
            product.setCostPrice(updatedProduct.getCostPrice());
            product.setIsDeliveryRequired(updatedProduct.getIsDeliveryRequired());
            product.setSoldByAgent(updatedProduct.getSoldByAgent());
            product.setWhoRequest(updatedProduct.getWhoRequest());
            
            return productRepository.save(product);
        }).orElseThrow(() -> new RuntimeException("Product not found with ID: " + id));
    }

    /** Delete product with image cleanup */
    public void deleteProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with ID: " + id));

        // Delete all associated images
        if (product.getImageFilePaths() != null) {
            product.getImageFilePaths().forEach(fileStorageService::deleteFile);
        }

        productRepository.deleteById(id);
    }
}