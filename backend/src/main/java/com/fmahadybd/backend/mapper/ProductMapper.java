package com.fmahadybd.backend.mapper;

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
                .build();
    }
}
