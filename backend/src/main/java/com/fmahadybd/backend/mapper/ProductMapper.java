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

        ProductResponseDTO.ProductResponseDTOBuilder builder = ProductResponseDTO.builder()
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
                .soldByAgentName(product.getSoldByAgent() != null ? product.getSoldByAgent().getName() : null);

        // Add full member information if whoRequest exists
        if (product.getWhoRequest() != null) {
            builder
                .whoRequestId(product.getWhoRequest().getId())
                .whoRequestName(product.getWhoRequest().getName())
                .whoRequestPhone(product.getWhoRequest().getPhone())
                .whoRequestNidCardNumber(product.getWhoRequest().getNidCardNumber())
                .whoRequestVillage(product.getWhoRequest().getVillage())
                .whoRequestZila(product.getWhoRequest().getZila());
        }

        return builder.build();
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