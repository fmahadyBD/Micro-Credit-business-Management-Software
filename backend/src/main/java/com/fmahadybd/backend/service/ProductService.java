package com.fmahadybd.backend.service;

import com.fmahadybd.backend.dto.ProductRequestDTO;
import com.fmahadybd.backend.dto.ProductResponseDTO;
import com.fmahadybd.backend.entity.MainBalance;
import com.fmahadybd.backend.entity.Product;
import com.fmahadybd.backend.entity.TransactionHistory;
import com.fmahadybd.backend.mapper.ProductMapper;
import com.fmahadybd.backend.repository.AgentRepository;
import com.fmahadybd.backend.repository.MainBalanceRepository;
import com.fmahadybd.backend.repository.MemberRepository;
import com.fmahadybd.backend.repository.ProductRepository;
import com.fmahadybd.backend.repository.TransactionHistoryRepository;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.time.LocalDateTime;
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
    private final TransactionHistoryRepository transactionHistoryRepository;

    private final String folder = "products";

    /** Create product without images */
    @Transactional
    public ProductResponseDTO createProduct(ProductRequestDTO dto, String performedBy) {
        if (dto == null) {
            throw new IllegalArgumentException("পণ্যের ডেটা খালি হতে পারে না");
        }

        Product product = mapToEntity(dto);
        product.setDateAdded(LocalDate.now());

        MainBalance currentBalance = getMainBalance();
        Double balance = currentBalance.getTotalBalance();

        Double requestedAmount = dto.getCostPrice() + dto.getPrice();

        // Check available balance before creating product
        if (requestedAmount > balance) {
            throw new RuntimeException("পণ্য তৈরি করার জন্য পর্যাপ্ত ব্যালেন্স নেই। উপলব্ধ: "
                    + balance + ", প্রয়োজন: " + requestedAmount);
        }

        // Create new MainBalance record instead of updating existing one
        MainBalance newBalance = createNewMainBalanceRecord(currentBalance);
        
        // Update balances for product cost
        newBalance.setTotalBalance(balance - requestedAmount);
        newBalance.setTotalProductCost(currentBalance.getTotalProductCost() + requestedAmount);
        newBalance.setWhoChanged(performedBy);
        newBalance.setReason("নতুন পণ্য তৈরি: " + product.getName());
        
        // Save new balance record
        MainBalance savedBalance = mainBalanceRepository.save(newBalance);

        // Save product
        Product savedProduct = productRepository.save(product);

        // Create transaction history
        createTransactionHistory(
            "PRODUCT_COST",
            requestedAmount,
            "পণ্য ক্রয়: " + product.getName() + " | খরচ: " + requestedAmount + " টাকা",
            null,
            null,
            performedBy
        );

        return ProductMapper.toResponseDTO(savedProduct);
    }

    public ProductResponseDTO createProductWithImages(ProductRequestDTO dto, MultipartFile[] images, String performedBy) {
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

        MainBalance currentBalance = getMainBalance();
        Double balance = currentBalance.getTotalBalance();

        Double requestedAmount = dto.getCostPrice() + dto.getPrice();

        // Check available balance before creating product
        if (requestedAmount > balance) {
            throw new RuntimeException("পণ্য তৈরি করার জন্য পর্যাপ্ত ব্যালেন্স নেই। উপলব্ধ: "
                    + balance + ", প্রয়োজন: " + requestedAmount);
        }

        // Create new MainBalance record
        MainBalance newBalance = createNewMainBalanceRecord(currentBalance);
        
        // Update balances for product cost
        newBalance.setTotalBalance(balance - requestedAmount);
        newBalance.setTotalProductCost(currentBalance.getTotalProductCost() + requestedAmount);
        newBalance.setWhoChanged(performedBy);
        newBalance.setReason("ছবিসহ নতুন পণ্য তৈরি: " + product.getName());
        
        // Save new balance record
        mainBalanceRepository.save(newBalance);

        Product savedProduct = productRepository.save(product);

        // Create transaction history
        createTransactionHistory(
            "PRODUCT_COST",
            requestedAmount,
            "ছবিসহ পণ্য ক্রয়: " + product.getName() + " | খরচ: " + requestedAmount + " টাকা",
            null,
            null,
            performedBy
        );

        return ProductMapper.toResponseDTO(savedProduct);
    }

    /** Upload additional images for existing product */
    public void uploadProductImages(MultipartFile[] images, Long productId, String performedBy) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("পণ্য খুঁজে পাওয়া যায়নি ID: " + productId));

        if (images != null && images.length > 0) {
            Arrays.stream(images)
                    .filter(image -> !image.isEmpty())
                    .forEach(image -> {
                        String filePath = fileStorageService.saveFile(image, productId, folder);
                        product.getImageFilePaths().add(filePath);
                    });

            productRepository.save(product);

            // Create transaction for image upload (optional - if it has cost)
            createTransactionHistory(
                "MAINTENANCE", // or create new type "PRODUCT_MAINTENANCE"
                0.0, // or actual cost if images have storage cost
                "পণ্যের ছবি আপলোড করা হয়েছে: " + product.getName(),
                null,
                null,
                performedBy
            );
        }
    }

    /** Delete specific image from product */
    public void deleteProductImage(Long productId, String filePath, String performedBy) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("পণ্য খুঁজে পাওয়া যায়নি ID: " + productId));

        if (product.getImageFilePaths().remove(filePath)) {
            fileStorageService.deleteFile(filePath);
            productRepository.save(product);

            // Create transaction for image deletion
            createTransactionHistory(
                "MAINTENANCE",
                0.0,
                "পণ্য থেকে ছবি ডিলিট করা হয়েছে: " + product.getName() + " | ফাইল: " + filePath,
                null,
                null,
                performedBy
            );
        } else {
            throw new RuntimeException("এই পণ্যের জন্য ছবি খুঁজে পাওয়া যায়নি: " + filePath);
        }
    }

    /** Get all products */
    public List<ProductResponseDTO> getAllProducts() {
        List<Product> products = productRepository.findAll();
        System.out.println("সমস্ত পণ্য পাওয়া গেছে: " + products.size() + " টি");
        return products.stream()
                .map(ProductMapper::toResponseDTO)
                .collect(Collectors.toList());
    }

    /** Get product by ID */
    public ProductResponseDTO getProductById(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("পণ্য খুঁজে পাওয়া যায়নি ID: " + id));
        System.out.println("পণ্য পাওয়া গেছে ID: " + id + " - " + product.getName());
        return ProductMapper.toResponseDTO(product);
    }

    @Transactional
    public ProductResponseDTO updateProduct(Long id, ProductRequestDTO dto, String performedBy) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("পণ্য খুঁজে পাওয়া যায়নি ID: " + id));

        // Store old cost for balance adjustment
        Double oldCostPrice = product.getCostPrice() + product.getPrice();
        Double newCostPrice = dto.getCostPrice() + dto.getPrice();

        // Get current balance
        MainBalance currentBalance = getMainBalance();
        Double currentTotalBalance = currentBalance.getTotalBalance();
        Double currentTotalProductCost = currentBalance.getTotalProductCost();

        // Calculate balance adjustment
        Double balanceAdjustment = newCostPrice - oldCostPrice;

        // Check if adjustment can be covered
        if (balanceAdjustment > 0 && balanceAdjustment > currentTotalBalance) {
            throw new RuntimeException("পণ্য আপডেট করার জন্য পর্যাপ্ত ব্যালেন্স নেই। উপলব্ধ: "
                    + currentTotalBalance + ", প্রয়োজনীয় সমন্বয়: " + balanceAdjustment);
        }

        // Create new MainBalance record
        MainBalance newBalance = createNewMainBalanceRecord(currentBalance);
        
        // Update balances
        newBalance.setTotalBalance(currentTotalBalance - balanceAdjustment);
        newBalance.setTotalProductCost(currentTotalProductCost + balanceAdjustment);
        newBalance.setWhoChanged(performedBy);
        newBalance.setReason("পণ্য আপডেট: " + product.getName() + " -> " + dto.getName());
        
        // Save new balance record
        mainBalanceRepository.save(newBalance);

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

        // Save updated product
        Product updated = productRepository.save(product);

        // Create transaction history for the adjustment
        if (balanceAdjustment != 0) {
            String transactionType = balanceAdjustment > 0 ? "PRODUCT_COST" : "ADJUSTMENT";
            String description = String.format(
                "পণ্য খরচ সমন্বয়: %s | পুরানো খরচ: %.2f টাকা | নতুন খরচ: %.2f টাকা | সমন্বয়: %.2f টাকা",
                product.getName(), oldCostPrice, newCostPrice, balanceAdjustment
            );
            
            createTransactionHistory(
                transactionType,
                Math.abs(balanceAdjustment),
                description,
                null,
                null,
                performedBy
            );
        }

        System.out.println("পণ্য আপডেট করা হয়েছে ID: " + id);
        return ProductMapper.toResponseDTO(updated);
    }

    /** Delete product with image cleanup and balance adjustment */
    @Transactional
    public void deleteProduct(Long id, String performedBy) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("পণ্য খুঁজে পাওয়া যায়নি ID: " + id));

        // Calculate refund amount
        Double refundAmount = product.getCostPrice() + product.getPrice();

        // Get current balance and create new record
        MainBalance currentBalance = getMainBalance();
        MainBalance newBalance = createNewMainBalanceRecord(currentBalance);
        
        // Update balances (refund the product cost)
        newBalance.setTotalBalance(currentBalance.getTotalBalance() + refundAmount);
        newBalance.setTotalProductCost(currentBalance.getTotalProductCost() - refundAmount);
        newBalance.setWhoChanged(performedBy);
        newBalance.setReason("পণ্য ডিলিট: " + product.getName() + " | ফেরত: " + refundAmount + " টাকা");
        
        // Save new balance record
        mainBalanceRepository.save(newBalance);

        // Delete all associated images
        if (product.getImageFilePaths() != null) {
            product.getImageFilePaths().forEach(fileStorageService::deleteFile);
        }

        // Create transaction history for refund
        createTransactionHistory(
            "ADJUSTMENT",
            refundAmount,
            "পণ্য ডিলিট ফেরত: " + product.getName() + " | Amount: " + refundAmount + " টাকা",
            null,
            null,
            performedBy
        );

        // Delete product
        productRepository.deleteById(id);
        System.out.println("পণ্য ডিলিট করা হয়েছে ID: " + id + " - " + product.getName());
    }

    /** Helper method to create new MainBalance record */
    private MainBalance createNewMainBalanceRecord(MainBalance currentBalance) {
        return MainBalance.builder()
                .totalBalance(currentBalance.getTotalBalance())
                .totalInvestment(currentBalance.getTotalInvestment())
                .totalProductCost(currentBalance.getTotalProductCost())
                .totalMaintenanceCost(currentBalance.getTotalMaintenanceCost())
                .totalInstallmentReturn(currentBalance.getTotalInstallmentReturn())
                .totalEarnings(currentBalance.getTotalEarnings())
                .whoChanged(currentBalance.getWhoChanged())
                .reason("পূর্ববর্তী ব্যালেন্স থেকে নতুন রেকর্ড তৈরি করা হয়েছে")
                .build();
    }

    /** Helper method to create transaction history */
    private void createTransactionHistory(String type, Double amount, String description, 
                                       Long shareholderId, Long memberId, String performedBy) {
        TransactionHistory transaction = TransactionHistory.builder()
                .type(type)
                .amount(amount)
                .description(description)
                .shareholderId(shareholderId)
                .memberId(memberId)
                .timestamp(LocalDateTime.now())
                .build();
        
        transactionHistoryRepository.save(transaction);
    }

    /** Helper method to get current main balance */
    private MainBalance getMainBalance() {
        return mainBalanceRepository.findTopByOrderByIdDesc()
                .orElseGet(() -> MainBalance.builder()
                        .totalBalance(0.0)
                        .totalInvestment(0.0)
                        .totalProductCost(0.0)
                        .totalMaintenanceCost(0.0)
                        .totalInstallmentReturn(0.0)
                        .totalEarnings(0.0)
                        .whoChanged("system")
                        .reason("প্রাথমিক ব্যালেন্স")
                        .build());
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
}