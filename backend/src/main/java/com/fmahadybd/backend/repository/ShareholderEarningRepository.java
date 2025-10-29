package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.ShareholderEarning;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.time.YearMonth;
import java.util.List;
import java.util.Optional;

@Repository
public interface ShareholderEarningRepository extends JpaRepository<ShareholderEarning, Long> {
    
    List<ShareholderEarning> findByShareholderIdOrderByMonthDesc(Long shareholderId);
    
    Optional<ShareholderEarning> findByShareholderIdAndMonth(Long shareholderId, YearMonth month);
    
    boolean existsByShareholderIdAndMonth(Long shareholderId, YearMonth month);
    
    List<ShareholderEarning> findByMonth(YearMonth month);
    
    @Modifying
    @Transactional
    @Query("DELETE FROM ShareholderEarning se WHERE se.month = :month")
    void deleteByMonth(@Param("month") YearMonth month);
}
