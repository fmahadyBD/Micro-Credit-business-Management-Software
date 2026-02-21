package com.fmahadybd.backend.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fmahadybd.backend.dto.ProductRequestDTO;
import com.fmahadybd.backend.dto.ProductResponseDTO;
import com.fmahadybd.backend.service.ProductService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.security.Principal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/products")
@Tag(name = "products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    // ---------------- CREATE ----------------

    @PostMapping
    @Operation(summary = "Create product without images")
    public ResponseEntity<Map<String, Object>> createProduct(
            @Valid @RequestBody ProductRequestDTO productRequestDTO,
            Principal principal) { // Add Principal parameter

        Map<String, Object> response = new HashMap<>();
        try {
            String performedBy = principal.getName(); // Get current username
            ProductResponseDTO savedProduct = productService.createProduct(productRequestDTO, performedBy);
            response.put("success", true);
            response.put("message", "Product created successfully!");
            response.put("product", savedProduct);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    @PostMapping(value = "/with-images", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Create product with images")
    public ResponseEntity<Map<String, Object>> createProductWithImages(
            @RequestPart("product") @Valid String productJson,
            @RequestPart(value = "images", required = false) MultipartFile[] images,
            Principal principal) { // Add Principal parameter

        Map<String, Object> response = new HashMap<>();
        try {
            ProductRequestDTO productDTO = objectMapper.readValue(productJson, ProductRequestDTO.class);
            String performedBy = principal.getName(); // Get current username
            ProductResponseDTO savedProduct = productService.createProductWithImages(productDTO, images, performedBy);

            response.put("success", true);
            response.put("message", "Product created successfully!");
            response.put("product", savedProduct);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // ---------------- IMAGES ----------------

    @PostMapping(value = "/{id}/images", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload product images")
    public ResponseEntity<Map<String, Object>> uploadProductImages(
            @PathVariable Long id,
            @RequestPart("images") MultipartFile[] images,
            Principal principal) { // Add Principal parameter

        Map<String, Object> response = new HashMap<>();
        try {
            String performedBy = principal.getName(); // Get current username
            productService.uploadProductImages(images, id, performedBy);
            response.put("success", true);
            response.put("message", "Images uploaded successfully!");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error uploading images: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    @DeleteMapping("/{id}/images")
    @Operation(summary = "Delete product image")
    public ResponseEntity<Map<String, Object>> deleteProductImage(
            @PathVariable Long id,
            @RequestParam String filePath,
            Principal principal) { // Add Principal parameter

        Map<String, Object> response = new HashMap<>();
        try {
            String performedBy = principal.getName(); // Get current username
            productService.deleteProductImage(id, filePath, performedBy);
            response.put("success", true);
            response.put("message", "Image deleted successfully!");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error deleting image: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // ---------------- READ ----------------

    @GetMapping
    @Operation(summary = "Get all products")
    public ResponseEntity<List<ProductResponseDTO>> getAllProducts() {
        try {
            List<ProductResponseDTO> products = productService.getAllProducts();
            return ResponseEntity.ok(products);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(List.of());
        }
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get product by ID")
    public ResponseEntity<?> getProductById(@PathVariable Long id) {
        try {
            ProductResponseDTO product = productService.getProductById(id);
            return ResponseEntity.ok(product);
        } catch (RuntimeException e) {
            return ResponseEntity.status(404).body(createErrorResponse(e.getMessage()));
        }
    }

    // ---------------- UPDATE ----------------

    @PutMapping("/{id}")
    @Operation(summary = "Update product")
    public ResponseEntity<Map<String, Object>> updateProduct(
            @PathVariable Long id,
            @Valid @RequestBody ProductRequestDTO productRequestDTO,
            Principal principal) {

        Map<String, Object> response = new HashMap<>();
        try {
            String performedBy = principal.getName();

            // Log the update attempt
            System.out.println("Updating product ID: " + id + " with data: " + productRequestDTO);

            ProductResponseDTO updatedProduct = productService.updateProduct(id, productRequestDTO, performedBy);

            response.put("success", true);
            response.put("message", "Product updated successfully!");
            response.put("product", updatedProduct);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.out.println("Error updating product ID: " + id + " - " + e.getMessage());
            response.put("success", false);
            response.put("message", "Error updating product: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // ---------------- DELETE ----------------

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete product")
    public ResponseEntity<Map<String, Object>> deleteProduct(
            @PathVariable Long id,
            Principal principal) { // Add Principal parameter

        Map<String, Object> response = new HashMap<>();
        try {
            String performedBy = principal.getName(); // Get current username
            productService.deleteProduct(id, performedBy);
            response.put("success", true);
            response.put("message", "Product deleted successfully!");
            response.put("id", id);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(404).body(createErrorResponse(e.getMessage()));
        }
    }

    /** Helper methods */
    private Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> resp = new HashMap<>();
        resp.put("success", false);
        resp.put("message", message);
        return resp;
    }
}