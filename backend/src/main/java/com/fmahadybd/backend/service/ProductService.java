package com.fmahadybd.backend.service;

import com.fmahadybd.backend.dto.ProductRequestDTO;
import com.fmahadybd.backend.dto.ProductResponseDTO;
import com.fmahadybd.backend.entity.MainBalance;
import com.fmahadybd.backend.entity.Product;
import com.fmahadybd.backend.mapper.ProductMapper;
import com.fmahadybd.backend.repository.AgentRepository;
import com.fmahadybd.backend.repository.MainBalanceRepository;
import com.fmahadybd.backend.repository.MemberRepository;
import com.fmahadybd.backend.repository.ProductRepository;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;
    private final FileStorageService fileStorageService;
    private final AgentRepository agentRepository;
    private final MemberRepository memberRepository;
    private final MainBalanceRepository mainBalanceRepository;

    private final String folder = "products";

    /** Create product without images */
    @Transactional
    public ProductResponseDTO createProduct(ProductRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Product data cannot be null");
        }

        Product product = mapToEntity(dto);
        product.setDateAdded(LocalDate.now());

        MainBalance mb = getMainBalance();
        double balance = mb.getTotalBalance();

        double requested_amount = dto.getCostPrice() + dto.getPrice();

        // Check available balance before creating product
        if (requested_amount > balance) {
            throw new RuntimeException("Insufficient main balance to create product. Available: "
                    + balance + ", Required: " + dto.getCostPrice() + dto.getPrice());
        }

        // Deduct cost from main balance
        mb.setTotalBalance(balance - requested_amount);
        mb.setTotalProductCost(mb.getTotalProductCost() + requested_amount);
        mainBalanceRepository.save(mb);

        // Save product
        Product savedProduct = productRepository.save(product);

        // log.info("Product '{}' created successfully. Deducted cost: {}. Remaining
        // balance: {}",
        // savedProduct.getName(), dto.getCostPrice(), mb.getTotalBalance());

        return ProductMapper.toResponseDTO(savedProduct);
    }

    public ProductResponseDTO createProductWithImages(ProductRequestDTO dto, MultipartFile[] images) {
        Product product = mapToEntity(dto);
        product.setDateAdded(LocalDate.now());

        // Save images if any
        if (images != null && images.length > 0) {
            Arrays.stream(images)
                    .filter(image -> !image.isEmpty())
                    .forEach(image -> {
                        String filePath = fileStorageService.saveFile(image, 0L, folder);
                        product.getImageFilePaths().add(filePath);
                    });
        }

        // Product product = mapToEntity(dto);
        product.setDateAdded(LocalDate.now());

        MainBalance mb = getMainBalance();
        double balance = mb.getTotalBalance();

        double requested_amount = dto.getCostPrice() + dto.getPrice();

        // Check available balance before creating product
        if (requested_amount > balance) {
            throw new RuntimeException("Insufficient main balance to create product. Available: "
                    + balance + ", Required: " + dto.getCostPrice() + dto.getPrice());
        }

        // Deduct cost from main balance
        mb.setTotalBalance(balance - requested_amount);
        mb.setTotalProductCost(mb.getTotalProductCost() + requested_amount);
        mainBalanceRepository.save(mb);

        Product saved = productRepository.save(product);
        return ProductMapper.toResponseDTO(saved);
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
    public List<ProductResponseDTO> getAllProducts() {
        return productRepository.findAll()
                .stream()
                .map(ProductMapper::toResponseDTO)
                .collect(Collectors.toList());
    }

    /** Get product by ID */
    public ProductResponseDTO getProductById(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with ID: " + id));
        return ProductMapper.toResponseDTO(product);
    }

    @Transactional
    public ProductResponseDTO updateProduct(Long id, ProductRequestDTO dto) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with ID: " + id));

        // Store old cost for balance adjustment
        double oldCostPrice = product.getCostPrice() + product.getPrice();

        // Update product fields
        product.setName(dto.getName());
        product.setCategory(dto.getCategory());
        product.setDescription(dto.getDescription());
        product.setPrice(dto.getPrice());
        product.setCostPrice(dto.getCostPrice());
        product.setIsDeliveryRequired(dto.getIsDeliveryRequired() != null ? dto.getIsDeliveryRequired() : false);

        // Update relationships
        if (dto.getSoldByAgentId() != null) {
            agentRepository.findById(dto.getSoldByAgentId()).ifPresent(product::setSoldByAgent);
        } else {
            product.setSoldByAgent(null);
        }

        if (dto.getWhoRequestId() != null) {
            memberRepository.findById(dto.getWhoRequestId()).ifPresent(product::setWhoRequest);
        } else {
            product.setWhoRequest(null);
        }

        // Adjust main balance
        MainBalance mb = getMainBalance();
        double balance = mb.getTotalBalance();

        // Refund old cost first
        balance += oldCostPrice;
        double total_product_cost = mb.getTotalProductCost() + oldCostPrice;

        // Check if new cost can be covered
        if (dto.getCostPrice() > balance) {
            throw new RuntimeException("Insufficient main balance to update product. Available: "
                    + balance + ", Required: " + dto.getCostPrice() + dto.getPrice());
        }

        // Deduct new cost

        mb.setTotalProductCost(total_product_cost + dto.getCostPrice());
        mb.setTotalBalance(balance - dto.getCostPrice());
        mainBalanceRepository.save(mb);

        // Save updated product
        Product updated = productRepository.save(product);

        return ProductMapper.toResponseDTO(updated);
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

    /** Helper method to map DTO to Entity */
    private Product mapToEntity(ProductRequestDTO dto) {
        Product product = new Product();
        product.setName(dto.getName());
        product.setCategory(dto.getCategory());
        product.setDescription(dto.getDescription());
        product.setPrice(dto.getPrice());
        product.setCostPrice(dto.getCostPrice());
        product.setIsDeliveryRequired(dto.getIsDeliveryRequired() != null ? dto.getIsDeliveryRequired() : false);

        if (dto.getSoldByAgentId() != null) {
            agentRepository.findById(dto.getSoldByAgentId()).ifPresent(product::setSoldByAgent);
        }

        if (dto.getWhoRequestId() != null) {
            memberRepository.findById(dto.getWhoRequestId()).ifPresent(product::setWhoRequest);
        }

        return product;
    }

    private MainBalance getMainBalance() {
        return mainBalanceRepository.findAll().stream().findFirst()
                .orElseGet(() -> mainBalanceRepository.save(
                        MainBalance.builder()
                                .totalBalance(0.0)
                                .totalInvestment(0.0)
                                .totalWithdrawal(0.0)
                                .totalProductCost(0.0)
                                .totalMaintenanceCost(0.0)
                                .totalInstallmentReturn(0.0)
                                .build()));
    }
}