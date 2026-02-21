package com.fmahadybd.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.fmahadybd.backend.entity.Installment;

@Repository
public interface InstallmentRepository extends JpaRepository<Installment, Long> {

    @Query("""
                SELECT DISTINCT i FROM Installment i
                WHERE
                    LOWER(i.member.name) LIKE LOWER(CONCAT('%', :keyword, '%'))
                    OR LOWER(i.product.name) LIKE LOWER(CONCAT('%', :keyword, '%'))
                    OR LOWER(i.member.phone) LIKE LOWER(CONCAT('%', :keyword, '%'))
            """)
    List<Installment> searchInstallments(@Param("keyword") String keyword);

}