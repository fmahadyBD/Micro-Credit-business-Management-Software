package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.Token;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Repository
public interface TokenRepository extends JpaRepository<Token, Long> {
    
    @Query("SELECT t FROM Token t WHERE t.user.id = :userId AND (t.expired = false AND t.revoked = false)")
    List<Token> findAllValidTokensByUser(Long userId);
    
    Optional<Token> findByToken(String token);
    
    @Query("SELECT t FROM Token t WHERE t.user.username = :username AND (t.expired = false AND t.revoked = false)")
    List<Token> findAllValidTokensByUsername(String username);
    
    @Modifying
    @Transactional
    @Query("UPDATE Token t SET t.expired = true, t.revoked = true WHERE t.user.username = :username AND (t.expired = false OR t.revoked = false)")
    void revokeAllUserTokens(@Param("username") String username);
    
    @Query("SELECT t FROM Token t WHERE t.user.id = :userId")
    List<Token> findByUserId(Long userId);
    
    @Modifying
    @Transactional
    @Query("DELETE FROM Token t WHERE t.expired = true OR t.revoked = true")
    void deleteExpiredAndRevokedTokens();
}