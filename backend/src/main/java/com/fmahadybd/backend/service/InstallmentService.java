package com.fmahadybd.backend.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.fmahadybd.backend.dto.InstallmentCreateDTO;
import com.fmahadybd.backend.dto.InstallmentResponseDTO;
import com.fmahadybd.backend.dto.InstallmentUpdateDTO;
import com.fmahadybd.backend.entity.*;
import com.fmahadybd.backend.mapper.InstallmentMapper;
import com.fmahadybd.backend.repository.*;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class InstallmentService {

    private final InstallmentRepository installmentRepository;
    private final FileStorageService fileStorageService;
    private final InstallmentMapper installmentMapper;
    private final ProductRepository productRepository;
    private final AgentRepository agentRepository;
    private final MemberRepository memberRepository;

    private final MainBalanceRepository mainBalanceRepository;
    private final TransactionHistoryRepository transactionHistoryRepository;

    private final String folder = "installment";

    @Transactional
    public InstallmentResponseDTO createInstallment(InstallmentCreateDTO dto , String performedBy) {
        Installment installment = mapToEntity(dto);

        // Validate advanced payment
        if (installment.getAdvanced_paid() < 0) {
            throw new IllegalArgumentException("অ্যাডভান্সড পেমেন্ট নেগেটিভ হতে পারে না");
        }

        MainBalance currentBalance = getMainBalance();
        Double balance = currentBalance.getTotalBalance();
        MainBalance newBalance = createNewMainBalanceRecord(currentBalance);
        double advancedPayment = dto.getAdvanced_paid();
        newBalance.setTotalBalance(balance + advancedPayment);
        newBalance.setTotalInstallmentReturn(currentBalance.getTotalInstallmentReturn() + advancedPayment);
        newBalance.setTotalEarnings(currentBalance.getTotalEarnings()+balance*.15);
        newBalance.setWhoChanged(performedBy);
        String memberViaInstallment = memberRepository.findById(dto.getMemberId())
        .map(Member::getName)
        .orElse("অজানা সদস্য");
        newBalance.setReason("ইন্সটলমেন্টের অ্যাডভান্সড পেমেন্ট যোগ করা হয়েছে: " + memberViaInstallment);
        MainBalance savedBalance = mainBalanceRepository.save(newBalance);
        Installment savedInstallment = save(installment);
        createTransactionHistory(
                "ADVANCED_PAYMENT",
                advancedPayment,
                "নতুন ইন্সটলমেন্ট তৈরি হয়েছে: " + memberViaInstallment + " | অ্যাডভান্সড: " + advancedPayment + " টাকা",
                null,
                dto.getMemberId(),
                performedBy);

        
        log.info("ইন্সটলমেন্ট তৈরি হয়েছে ID: {}", savedInstallment.getId());
        return installmentMapper.toResponseDTO(savedInstallment);
    }

    @Transactional
    public InstallmentResponseDTO createInstallmentWithImages(
            InstallmentCreateDTO dto, MultipartFile[] images,
            String performedBy) {

        Installment installment = mapToEntity(dto);

        // Validate advanced payment
        if (installment.getAdvanced_paid() < 0) {
            throw new IllegalArgumentException("অ্যাডভান্সড পেমেন্ট নেগেটিভ হতে পারে না");
        }

        MainBalance currentBalance = getMainBalance();
        Double balance = currentBalance.getTotalBalance();
        MainBalance newBalance = createNewMainBalanceRecord(currentBalance);
        double advancedPayment = dto.getAdvanced_paid();
        newBalance.setTotalBalance(balance + advancedPayment);
        newBalance.setTotalInstallmentReturn(currentBalance.getTotalInstallmentReturn() + advancedPayment);
        newBalance.setTotalEarnings(currentBalance.getTotalEarnings()+balance*.15);
        newBalance.setWhoChanged(performedBy);
        String memberViaInstallment = memberRepository.findById(dto.getMemberId())
        .map(Member::getName)
        .orElse("অজানা সদস্য");
        newBalance.setReason("ইন্সটলমেন্টের অ্যাডভান্সড পেমেন্ট যোগ করা হয়েছে: " + memberViaInstallment);
        MainBalance savedBalance = mainBalanceRepository.save(newBalance);
        Installment savedInstallment = save(installment);
        createTransactionHistory(
                "ADVANCED_PAYMENT",
                advancedPayment,
                "নতুন ইন্সটলমেন্ট তৈরি হয়েছে: " + memberViaInstallment + " | অ্যাডভান্সড: " + advancedPayment + " টাকা",
                null,
                dto.getMemberId(),
                performedBy);

        // Upload images if any
        if (images != null && images.length > 0) {
            uploadInstallmentImages(images, savedInstallment.getId());
            savedInstallment = installmentRepository.findById(savedInstallment.getId())
                    .orElse(savedInstallment);
        }

        log.info("ইন্সটলমেন্ট তৈরি হয়েছে ছবিসহ ID: {}", savedInstallment.getId());
        return installmentMapper.toResponseDTO(savedInstallment);
    }

    private Installment mapToEntity(InstallmentCreateDTO dto) {
        // Get product and auto-set member from product
        Product product = productRepository.findById(dto.getProductId())
                .orElseThrow(() -> new RuntimeException("পণ্য খুঁজে পাওয়া যায়নি ID: " + dto.getProductId()));

        // Get agent
        Agent agent = agentRepository.findById(dto.getAgentId())
                .orElseThrow(() -> new RuntimeException("এজেন্ট খুঁজে পাওয়া যায়নি ID: " + dto.getAgentId()));

        Installment installment = new Installment();
        installment.setProduct(product);
        installment.setMember(product.getWhoRequest());
        installment.setTotalAmountOfProduct(dto.getTotalAmountOfProduct());
        installment.setOtherCost(dto.getOtherCost() != null ? dto.getOtherCost() : 0.0);
        installment.setAdvanced_paid(dto.getAdvanced_paid());
        installment.setInstallmentMonths(dto.getInstallmentMonths());
        installment.setInterestRate(dto.getInterestRate() != null ? dto.getInterestRate() : 15.0);
        installment.setStatus(
                dto.getStatus() != null ? InstallmentStatus.valueOf(dto.getStatus()) : InstallmentStatus.PENDING);
        installment.setGiven_product_agent(agent);
        installment.setCreatedTime(LocalDateTime.now());

        return installment;
    }

    public Installment save(Installment installment) {
        validateInstallment(installment);
        calculateInstallmentAmounts(installment);
        setProductDeliveryRequired(installment);

        Installment savedInstallment = installmentRepository.save(installment);
        return savedInstallment;
    }

    private void validateInstallment(Installment installment) {
        if (installment.getMember() == null)
            throw new IllegalArgumentException("সদস্য প্রয়োজন - পণ্যের সাথে কোন সদস্য যুক্ত নেই");
        if (installment.getTotalAmountOfProduct() == null || installment.getTotalAmountOfProduct() < 0)
            throw new IllegalArgumentException("বৈধ মোট Amount প্রয়োজন");
        if (installment.getInstallmentMonths() != null && installment.getInstallmentMonths() <= 0)
            throw new IllegalArgumentException("ইন্সটলমেন্ট মাস ০ এর বেশি হতে হবে");
        if (installment.getGiven_product_agent() == null)
            throw new IllegalArgumentException("এজেন্ট প্রয়োজন");
    }

    private void calculateInstallmentAmounts(Installment installment) {
        Double total = installment.getTotalAmountOfProduct() != null ? installment.getTotalAmountOfProduct() : 0.0;
        Double other = installment.getOtherCost() != null ? installment.getOtherCost() : 0.0;
        Double advance = installment.getAdvanced_paid() != null ? installment.getAdvanced_paid() : 0.0;
        Double interest = installment.getInterestRate() != null ? installment.getInterestRate() : 15.0;

        // Calculate total with interest
        Double totalWithInterest = total + (total * interest / 100);

        // Calculate total amount needed to be paid (before advance)
        Double totalAmountToPay = totalWithInterest + other;

        // Calculate monthly installment if months are specified
        if (installment.getInstallmentMonths() != null && installment.getInstallmentMonths() > 0) {
            // First calculate remaining after advance
            Double remainingBeforeAdjustment = Math.max(totalAmountToPay - advance, 0.0);

            // Calculate monthly payment (rounded up to integer)
            Integer monthlyPayment = (int) Math.ceil(remainingBeforeAdjustment / installment.getInstallmentMonths());

            // Calculate adjusted total (must be divisible by months)
            Integer adjustedRemainingTotal = monthlyPayment * installment.getInstallmentMonths();

            // Calculate the difference
            Double difference = adjustedRemainingTotal - remainingBeforeAdjustment;

            // Store the adjusted values
            installment.setMonthlyInstallmentAmount(monthlyPayment.doubleValue());
            installment.setNeedPaidAmount(adjustedRemainingTotal.doubleValue());

            // Important: Store the actual advance paid (not adjusted)
            // The difference will be handled as "overpayment" or part of the calculation
            // Don't modify advance_paid here as it's already processed in main balance

            log.info(
                    "ইন্সটলমেন্ট ক্যালকুলেট করা হয়েছে - মূল মোট: {}, অ্যাডভান্সড পর: {}, মাসিক: {}, সমন্বয়কৃত পরিশোধযোগ্য: {}, রাউন্ডিং পার্থক্য: {}",
                    totalAmountToPay, remainingBeforeAdjustment, monthlyPayment, adjustedRemainingTotal, difference);
        } else {
            // No monthly installments, just set the remaining amount
            Double remainingAmount = Math.max(totalAmountToPay - advance, 0.0);
            installment.setNeedPaidAmount(remainingAmount);
            installment.setMonthlyInstallmentAmount(0.0);

            log.info("ইন্সটলমেন্ট ক্যালকুলেট করা হয়েছে (মাসিক নেই) - মোট: {}, পরিশোধযোগ্য: {}",
                    totalAmountToPay, remainingAmount);
        }
    }

    private void setProductDeliveryRequired(Installment installment) {
        Product product = installment.getProduct();
        if (product != null) {
            product.setIsDeliveryRequired(true);
            productRepository.save(product);
        }
    }

    private void logTransaction(String type, double amount, String desc, Long memberId) {
        TransactionHistory txn = TransactionHistory.builder()
                .type(type)
                .amount(amount)
                .description(desc)
                .memberId(memberId)
                .timestamp(LocalDateTime.now())
                .build();
        transactionHistoryRepository.save(txn);
    }

    public void uploadInstallmentImages(MultipartFile[] files, Long installmentId) {
        Installment installment = installmentRepository.findById(installmentId)
                .orElseThrow(() -> new RuntimeException("ইন্সটলমেন্ট খুঁজে পাওয়া যায়নি ID: " + installmentId));

        List<String> savedFilePaths = new ArrayList<>();
        for (MultipartFile file : files) {
            if (!file.isEmpty()) {
                String filePath = fileStorageService.saveFile(file, installmentId, folder);
                if (filePath != null)
                    savedFilePaths.add(filePath);
            }
        }

        List<String> currentPaths = installment.getImageFilePaths();
        if (currentPaths == null)
            currentPaths = new ArrayList<>();
        currentPaths.addAll(savedFilePaths);
        installment.setImageFilePaths(currentPaths);

        installmentRepository.save(installment);
        log.info("ইন্সটলমেন্টের ছবি আপলোড করা হয়েছে ID: {}", installmentId);
    }

    @Transactional
    public InstallmentResponseDTO update(Long id, InstallmentUpdateDTO dto, String performedBy) {
        Installment existing = installmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("ইন্সটলমেন্ট খুঁজে পাওয়া যায়নি ID: " + id));

        MainBalance currentBalance = getMainBalance();
        Double balance = currentBalance.getTotalBalance();
        MainBalance newBalance = createNewMainBalanceRecord(currentBalance);

        double existingAdvancedPayment = existing.getAdvanced_paid();

        if(dto.getAdvanced_paid() > 0){
            currentBalance.setTotalBalance(currentBalance.getTotalBalance()- existingAdvancedPayment);
            currentBalance.setTotalEarnings(currentBalance.getTotalEarnings()-existing.getAdvanced_paid()*.15);
            currentBalance.setTotalInstallmentReturn(currentBalance.getTotalInstallmentReturn() -existing.getAdvanced_paid());
        }

        double advancedPayment = dto.getAdvanced_paid();

        newBalance.setTotalBalance(balance + advancedPayment);
        newBalance.setTotalInstallmentReturn(currentBalance.getTotalInstallmentReturn() + advancedPayment);
        newBalance.setTotalEarnings(currentBalance.getTotalEarnings()+balance*.15);

        newBalance.setWhoChanged(performedBy);
        String memberViaInstallment = existing.getMember().getName();
        // .map(Member::getName)
        // .orElse("অজানা সদস্য");
        newBalance.setReason("ইন্সটলমেন্টের অ্যাডভান্সড পেমেন্ট আপডেট করা হয়েছে: " + memberViaInstallment);
        MainBalance savedBalance = mainBalanceRepository.save(newBalance);
        createTransactionHistory(
                "UPDATE_INSTALLMENT",
                advancedPayment,
                "ইন্সটলমেন্ট আপডেট করা হয়েছে: " + memberViaInstallment + " | অ্যাডভান্সড: " + advancedPayment + " টাকা",
                null,
                existing.getMember().getId(),
                performedBy);

        updateFields(existing, dto);
        calculateInstallmentAmounts(existing);

        Installment updated = installmentRepository.save(existing);
        log.info("ইন্সটলমেন্ট আপডেট করা হয়েছে ID: {}", id);
        return installmentMapper.toResponseDTO(updated);
    }

    private void updateFields(Installment existing, InstallmentUpdateDTO dto) {
        if (dto.getTotalAmountOfProduct() != null)
            existing.setTotalAmountOfProduct(dto.getTotalAmountOfProduct());
        if (dto.getOtherCost() != null)
            existing.setOtherCost(dto.getOtherCost());
        if (dto.getAdvanced_paid() != null)
            existing.setAdvanced_paid(dto.getAdvanced_paid());
        if (dto.getInstallmentMonths() != null)
            existing.setInstallmentMonths(dto.getInstallmentMonths());
        if (dto.getInterestRate() != null)
            existing.setInterestRate(dto.getInterestRate());
        if (dto.getStatus() != null)
            existing.setStatus(dto.getStatus());
    }

    @Transactional(readOnly = true)
    public List<InstallmentResponseDTO> searchInstallments(String keyword) {
        List<Installment> results = installmentRepository.searchInstallments(keyword);
        log.info("ইন্সটলমেন্ট খুঁজা হয়েছে: {}", keyword);
        return installmentMapper.toResponseDTOList(results);
    }

    @Transactional(readOnly = true)
    public List<InstallmentResponseDTO> findAll() {
        List<Installment> installments = installmentRepository.findAll();
        log.info("সমস্ত ইন্সটলমেন্ট পাওয়া গেছে: {} টি", installments.size());
        return installmentMapper.toResponseDTOList(installments);
    }

    @Transactional(readOnly = true)
    public Optional<InstallmentResponseDTO> findById(Long id) {
        log.info("ইন্সটলমেন্ট খুঁজছি ID: {}", id);
        return installmentRepository.findById(id)
                .map(installmentMapper::toResponseDTO);
    }

    public Optional<Installment> findEntityById(Long id) {
        return installmentRepository.findById(id);
    }

    public void delete(Long id) {
        Installment installment = installmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("ইন্সটলমেন্ট খুঁজে পাওয়া যায়নি ID: " + id));
        installmentRepository.delete(installment);
        log.info("ইন্সটলমেন্ট ডিলিট করা হয়েছে ID: {}", id);
    }

    public void deleteInstallmentImage(Long installmentId, String filePath) {
        Installment installment = installmentRepository.findById(installmentId)
                .orElseThrow(() -> new RuntimeException("ইন্সটলমেন্ট খুঁজে পাওয়া যায়নি ID: " + installmentId));

        List<String> paths = installment.getImageFilePaths();
        if (paths != null && paths.remove(filePath)) {
            installment.setImageFilePaths(paths);
            installmentRepository.save(installment);
            log.info("ইন্সটলমেন্টের ছবি ডিলিট করা হয়েছে ID: {}", installmentId);
        }
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
}