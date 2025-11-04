package com.fmahadybd.backend.mapper;

import com.fmahadybd.backend.dto.ProductRequestDTO;
import com.fmahadybd.backend.dto.ProductResponseDTO;
import com.fmahadybd.backend.entity.Product;

public class ProductMapper {

    private ProductMapper() {
        // Private constructor to prevent instantiation
    }

    public static ProductResponseDTO toResponseDTO(Product product) {
        if (product == null) {
            return null;
        }

        return ProductResponseDTO.builder()
                .id(product.getId())
                .name(product.getName())
                .category(product.getCategory())
                .description(product.getDescription())
                .price(product.getPrice())
                .costPrice(product.getCostPrice())
                .totalPrice(product.getTotalPrice())
                .isDeliveryRequired(product.getIsDeliveryRequired())
                .dateAdded(product.getDateAdded())
                .imageFilePaths(product.getImageFilePaths())
                .soldByAgentName(product.getSoldByAgent() != null ? product.getSoldByAgent().getName() : null)
                .whoRequestName(product.getWhoRequest() != null ? product.getWhoRequest().getName() : null)
                .whoRequestId(product.getWhoRequest() != null ? product.getWhoRequest().getId() : null) // ✅ ADD THIS
                .build();
    }

    // Optional: If you need to convert RequestDTO to Entity
    public static Product toEntity(ProductRequestDTO dto) {
        if (dto == null) {
            return null;
        }

        return Product.builder()
                .name(dto.getName())
                .category(dto.getCategory())
                .description(dto.getDescription())
                .price(dto.getPrice())
                .costPrice(dto.getCostPrice())
                .isDeliveryRequired(dto.getIsDeliveryRequired())
                .build();
    }
}