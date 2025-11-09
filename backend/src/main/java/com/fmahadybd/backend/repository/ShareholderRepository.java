package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.Shareholder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface ShareholderRepository extends JpaRepository<Shareholder, Long> {

       /**
        * Find shareholders by status
        */
       List<Shareholder> findByStatus(String status);

       /**
        * Count shareholders by status
        */
       long countByStatus(String status);

       /**
        * Find shareholder by phone number
        */
       Optional<Shareholder> findByPhone(String phone);

       /**
        * Find shareholder by NID card
        */
       Optional<Shareholder> findByNidCard(String nidCard);

       /**
        * Find shareholders by name containing (case insensitive)
        */
       List<Shareholder> findByNameContainingIgnoreCase(String name);

       /**
        * Find shareholders by zila
        */
       List<Shareholder> findByZila(String zila);

       /**
        * Find shareholders by role
        */
       List<Shareholder> findByRole(String role);

       /**
        * Check if phone exists
        */
       boolean existsByPhone(String phone);

       /**
        * Check if NID card exists
        */
       boolean existsByNidCard(String nidCard);

       /**
        * Find shareholders with shares greater than
        */
       @Query("SELECT s FROM Shareholder s WHERE s.totalShare > :shares")
       List<Shareholder> findByTotalShareGreaterThan(@Param("shares") Integer shares);

       /**
        * Find shareholders with investment greater than
        */
       @Query("SELECT s FROM Shareholder s WHERE s.investment > :amount")
       List<Shareholder> findByInvestmentGreaterThan(@Param("amount") Double amount);

       /**
        * Find shareholders with balance greater than
        */
       @Query("SELECT s FROM Shareholder s WHERE s.currentBalance > :balance")
       List<Shareholder> findByCurrentBalanceGreaterThan(@Param("balance") Double balance);

       /**
        * Get total investment across all shareholders
        */
       @Query("SELECT COALESCE(SUM(s.investment), 0.0) FROM Shareholder s")
       Double getTotalInvestment();

       /**
        * Get total earnings across all shareholders
        */
       @Query("SELECT COALESCE(SUM(s.totalEarning), 0.0) FROM Shareholder s")
       Double getTotalEarnings();

       /**
        * Get total balance across all shareholders
        */
       @Query("SELECT COALESCE(SUM(s.currentBalance), 0.0) FROM Shareholder s")
       Double getTotalBalance();

       /**
        * Get total shares across all shareholders
        */
       @Query("SELECT COALESCE(SUM(s.totalShare), 0) FROM Shareholder s")
       Integer getTotalShares();

       /**
        * Find shareholders joined between dates
        */
       @Query("SELECT s FROM Shareholder s WHERE s.joinDate BETWEEN :startDate AND :endDate")
       List<Shareholder> findByJoinDateBetween(@Param("startDate") LocalDate startDate,
                     @Param("endDate") LocalDate endDate);

       /**
        * Find shareholders with zero balance
        */
       @Query("SELECT s FROM Shareholder s WHERE s.currentBalance = 0 OR s.currentBalance IS NULL")
       List<Shareholder> findWithZeroBalance();

       /**
        * Find shareholders with pending balance
        */
       @Query("SELECT s FROM Shareholder s WHERE s.currentBalance > 0")
       List<Shareholder> findWithPendingBalance();

       /**
        * Get shareholders ordered by total earnings descending
        */
       @Query("SELECT s FROM Shareholder s ORDER BY s.totalEarning DESC")
       List<Shareholder> findAllOrderByTotalEarningDesc();

       /**
        * Get shareholders ordered by investment descending
        */
       @Query("SELECT s FROM Shareholder s ORDER BY s.investment DESC")
       List<Shareholder> findAllOrderByInvestmentDesc();

       /**
        * Get top N shareholders by earnings
        */
       @Query("SELECT s FROM Shareholder s ORDER BY s.totalEarning DESC")
       List<Shareholder> findTopByEarnings();

       /**
        * Get top N shareholders by investment
        */
       @Query("SELECT s FROM Shareholder s ORDER BY s.investment DESC")
       List<Shareholder> findTopByInvestment();

       /**
        * Find shareholders with ROI above threshold
        */
       @Query("SELECT s FROM Shareholder s WHERE s.investment > 0 AND (s.totalEarning / s.investment * 100) > :roiThreshold")
       List<Shareholder> findByROIGreaterThan(@Param("roiThreshold") Double roiThreshold);

       /**
        * Get average investment
        */
       @Query("SELECT COALESCE(AVG(s.investment), 0.0) FROM Shareholder s")
       Double getAverageInvestment();

       /**
        * Get average earnings
        */
       @Query("SELECT COALESCE(AVG(s.totalEarning), 0.0) FROM Shareholder s")
       Double getAverageEarnings();

       /**
        * Get average balance
        */
       @Query("SELECT COALESCE(AVG(s.currentBalance), 0.0) FROM Shareholder s")
       Double getAverageBalance();

       /**
        * Find shareholders by status and minimum investment
        */
       @Query("SELECT s FROM Shareholder s WHERE s.status = :status AND s.investment >= :minInvestment")
       List<Shareholder> findByStatusAndMinInvestment(@Param("status") String status,
                     @Param("minInvestment") Double minInvestment);

       /**
        * Find shareholders who joined in current year
        */
       @Query("SELECT s FROM Shareholder s WHERE FUNCTION('YEAR', s.joinDate) = FUNCTION('YEAR', CURRENT_DATE)")
       List<Shareholder> findJoinedThisYear();

       /**
        * Find shareholders who joined in specific year
        */
       @Query("SELECT s FROM Shareholder s WHERE FUNCTION('YEAR', s.joinDate) = :year")
       List<Shareholder> findByJoinYear(@Param("year") int year);

       /**
        * Count shareholders who joined in specific year
        */
       @Query("SELECT COUNT(s) FROM Shareholder s WHERE FUNCTION('YEAR', s.joinDate) = :year")
       long countByJoinYear(@Param("year") int year);

       /**
        * Get shareholders summary statistics
        */
       @Query("SELECT " +
                     "COUNT(s), " +
                     "COALESCE(SUM(s.investment), 0.0), " +
                     "COALESCE(SUM(s.totalEarning), 0.0), " +
                     "COALESCE(SUM(s.currentBalance), 0.0), " +
                     "COALESCE(SUM(s.totalShare), 0), " +
                     "COALESCE(AVG(s.investment), 0.0), " +
                     "COALESCE(AVG(s.totalEarning), 0.0) " +
                     "FROM Shareholder s")
       Object[] getShareholderStatistics();

       /**
        * Find shareholders by multiple criteria
        */
       @Query("SELECT s FROM Shareholder s WHERE " +
                     "(:status IS NULL OR s.status = :status) AND " +
                     "(:role IS NULL OR s.role = :role) AND " +
                     "(:zila IS NULL OR s.zila = :zila)")
       List<Shareholder> findByCriteria(
                     @Param("status") String status,
                     @Param("role") String role,
                     @Param("zila") String zila);

       /**
        * Search shareholders by name, phone, or NID
        */
       @Query("SELECT s FROM Shareholder s WHERE " +
                     "LOWER(s.name) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
                     "s.phone LIKE CONCAT('%', :searchTerm, '%') OR " +
                     "s.nidCard LIKE CONCAT('%', :searchTerm, '%')")
       List<Shareholder> searchShareholders(@Param("searchTerm") String searchTerm);

       /**
        * Find shareholders with earnings but no current balance
        */
       @Query("SELECT s FROM Shareholder s WHERE s.totalEarning > 0 AND (s.currentBalance = 0 OR s.currentBalance IS NULL)")
       List<Shareholder> findWithEarningsButNoBalance();

       /**
        * Find recent shareholders (last N days)
        */
       @Query("SELECT s FROM Shareholder s WHERE s.joinDate >= :date ORDER BY s.joinDate DESC")
       List<Shareholder> findRecentShareholders(@Param("date") LocalDate date);

       /**
        * Get shareholders with complete profile (all fields filled)
        */
       @Query("SELECT s FROM Shareholder s WHERE " +
                     "s.name IS NOT NULL AND " +
                     "s.phone IS NOT NULL AND " +
                     "s.nidCard IS NOT NULL AND " +
                     "s.nominee IS NOT NULL AND " +
                     "s.zila IS NOT NULL AND " +
                     "s.house IS NOT NULL")
       List<Shareholder> findWithCompleteProfile();

       /**
        * Get shareholders with incomplete profile
        */
       @Query("SELECT s FROM Shareholder s WHERE " +
                     "s.name IS NULL OR " +
                     "s.phone IS NULL OR " +
                     "s.nidCard IS NULL OR " +
                     "s.nominee IS NULL OR " +
                     "s.zila IS NULL OR " +
                     "s.house IS NULL")
       List<Shareholder> findWithIncompleteProfile();

       Optional<Shareholder> findByUserId(Long userId);

       /**
        * Check if userId exists
        */
       boolean existsByUserId(Long userId);

       Optional<Shareholder> findByEmail(String email);


}