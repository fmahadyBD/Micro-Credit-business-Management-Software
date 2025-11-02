package com.fmahadybd.backend.controller;

import lombok.RequiredArgsConstructor;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fmahadybd.backend.dto.InstallmentResponseDTO;
import com.fmahadybd.backend.dto.InstallmentUpdateDTO;
import com.fmahadybd.backend.entity.Installment;
import com.fmahadybd.backend.mapper.InstallmentMapper;
import com.fmahadybd.backend.service.InstallmentService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/installments")
@RequiredArgsConstructor
@Tag(name = "Installment Management", description = "APIs for managing installments")
public class InstallmentController {

    private final InstallmentService installmentService;
    private final InstallmentMapper installmentMapper;

    @Autowired
    private ObjectMapper objectMapper;

    @PostMapping
    @Operation(summary = "Create new installment", description = "Creates a new installment without images")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Installment created successfully",
                    content = @Content(schema = @Schema(implementation = InstallmentResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Invalid input")
    })
    public ResponseEntity<InstallmentResponseDTO> createInstallment(@Valid @RequestBody Installment installment) {
        Installment savedInstallment = installmentService.save(installment);
        InstallmentResponseDTO responseDTO = installmentMapper.toResponseDTO(savedInstallment);
        return ResponseEntity.status(HttpStatus.CREATED).body(responseDTO);
    }

    @PostMapping(value = "/with-images", consumes = "multipart/form-data")
    @Operation(summary = "Create installment with images", description = "Creates a new installment with optional images")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Installment created successfully with images",
                    content = @Content(schema = @Schema(implementation = InstallmentResponseDTO.class))),
            @ApiResponse(responseCode = "400", description = "Invalid input")
    })
    public ResponseEntity<InstallmentResponseDTO> createInstallmentWithImages(
            @RequestPart("installment") String installmentJson,
            @RequestPart(value = "images", required = false) MultipartFile[] images) throws IOException {
        
        Installment installment = objectMapper.readValue(installmentJson, Installment.class);
        Installment savedInstallment = installmentService.saveWithImages(installment, images);
        InstallmentResponseDTO responseDTO = installmentMapper.toResponseDTO(savedInstallment);
        
        return ResponseEntity.status(HttpStatus.CREATED).body(responseDTO);
    }

    @PostMapping(value = "/{id}/images", consumes = "multipart/form-data")
    @Operation(summary = "Upload images to existing installment", description = "Uploads images to an existing installment")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "202", description = "Images uploaded successfully"),
            @ApiResponse(responseCode = "404", description = "Installment not found")
    })
    public ResponseEntity<Void> uploadInstallmentImages(
            @PathVariable Long id,
            @RequestPart("images") MultipartFile[] images) {

        installmentService.uploadInstallmentImages(images, id);
        return ResponseEntity.accepted().build();
    }

    @GetMapping
    @Operation(summary = "Get all installments", description = "Retrieves all installments")
    @ApiResponse(responseCode = "200", description = "List of installments retrieved successfully",
            content = @Content(schema = @Schema(implementation = InstallmentResponseDTO.class)))
    public ResponseEntity<List<InstallmentResponseDTO>> getAllInstallments() {
        List<InstallmentResponseDTO> installments = installmentService.findAll();
        return ResponseEntity.ok(installments);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get installment by ID", description = "Retrieves a specific installment by its ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Installment found",
                    content = @Content(schema = @Schema(implementation = InstallmentResponseDTO.class))),
            @ApiResponse(responseCode = "404", description = "Installment not found")
    })
    public ResponseEntity<InstallmentResponseDTO> getInstallmentById(@PathVariable Long id) {
        InstallmentResponseDTO installment = installmentService.findById(id)
                .orElseThrow(() -> new RuntimeException("Installment not found with id: " + id));
        return ResponseEntity.ok(installment);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update installment", description = "Updates an existing installment")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Installment updated successfully",
                    content = @Content(schema = @Schema(implementation = InstallmentResponseDTO.class))),
            @ApiResponse(responseCode = "404", description = "Installment not found")
    })
    public ResponseEntity<InstallmentResponseDTO> updateInstallment(
            @PathVariable Long id,
            @Valid @RequestBody InstallmentUpdateDTO installmentDTO) {

        InstallmentResponseDTO updatedInstallment = installmentService.update(id, installmentDTO);
        return ResponseEntity.ok(updatedInstallment);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete installment", description = "Deletes an installment by ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "204", description = "Installment deleted successfully"),
            @ApiResponse(responseCode = "404", description = "Installment not found")
    })
    public ResponseEntity<?> deleteInstallment(@PathVariable Long id) {
        try {
            installmentService.delete(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "Installment not found", "message", e.getMessage()));
        }
    }

    @GetMapping("/{id}/images")
    @Operation(summary = "Get installment images", description = "Retrieves all image paths for an installment")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Images retrieved successfully"),
            @ApiResponse(responseCode = "404", description = "Installment not found")
    })
    public ResponseEntity<?> getInstallmentImages(@PathVariable Long id) {
        try {
            Installment installment = installmentService.findEntityById(id)
                    .orElseThrow(() -> new RuntimeException("Installment not found with id: " + id));
            return ResponseEntity.ok(installment.getImageFilePaths());
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "Installment not found", "message", e.getMessage()));
        }
    }

    @GetMapping("/search")
    @Operation(summary = "Search installments", description = "Search installments by member name, product name, or phone number")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Search results retrieved successfully",
                    content = @Content(schema = @Schema(implementation = InstallmentResponseDTO.class))),
            @ApiResponse(responseCode = "404", description = "No results found")
    })
    public ResponseEntity<List<InstallmentResponseDTO>> searchInstallment(
            @RequestParam("keyword") String keyword) {

        List<InstallmentResponseDTO> results = installmentService.searchInstallments(keyword);
        
        if (results.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(List.of());
        }
        
        return ResponseEntity.ok(results);
    }
}