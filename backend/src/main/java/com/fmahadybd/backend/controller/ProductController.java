package com.fmahadybd.backend.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.fmahadybd.backend.entity.Product;
import com.fmahadybd.backend.service.ProductService;

import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    // Create product without images
    @PostMapping
    public ResponseEntity<Product> createProduct(@Valid @RequestBody Product product) {
        Product savedProduct = productService.saveProduct(product);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedProduct);
    }

    // Create product with images
    @PostMapping(value = "/with-images", consumes = "multipart/form-data")
    public ResponseEntity<Product> createProductWithImages(
            @Valid @RequestPart("product") Product product,
            @RequestPart(value = "images", required = false) MultipartFile[] images) {
        
        Product savedProduct = productService.saveWithImages(product, images);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedProduct);
    }

    // Add images to existing product
    @PostMapping(value = "/{id}/images", consumes = "multipart/form-data")
    public ResponseEntity<?> uploadProductImages(
            @PathVariable Long id,
            @RequestPart("images") MultipartFile[] images) {
        
        productService.uploadProductImages(images, id);
        return ResponseEntity.accepted().build();
    }

    // Get all products
    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts() {
        List<Product> products = productService.getAllProducts();
        return ResponseEntity.ok(products);
    }

    // Get product by ID
    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id) {
        return productService.getProductById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // Update product
    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(
            @PathVariable Long id,
            @Valid @RequestBody Product product) {
        
        Product updatedProduct = productService.updateProduct(id, product);
        return ResponseEntity.ok(updatedProduct);
    }

    // Delete product
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
        return ResponseEntity.noContent().build();
    }

    // Delete product image
    @DeleteMapping("/{id}/images")
    public ResponseEntity<Void> deleteProductImage(
            @PathVariable Long id,
            @RequestParam String filePath) {
        
        productService.deleteProductImage(id, filePath);
        return ResponseEntity.noContent().build();
    }
}