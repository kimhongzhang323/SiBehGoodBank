package com.sibehgoodbank.transactionservice.repository;

import com.sibehgoodbank.transactionservice.entity.Transaction;
import com.sibehgoodbank.transactionservice.entity.Transaction.TransactionStatus;
import com.sibehgoodbank.transactionservice.entity.Transaction.TransactionType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import jakarta.persistence.LockModeType;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, UUID> {
    
    Optional<Transaction> findByReferenceNumber(String referenceNumber);
    
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT t FROM Transaction t WHERE t.id = :id")
    Optional<Transaction> findByIdWithLock(@Param("id") UUID id);
    
    // User transactions
    Page<Transaction> findByUserIdOrderByCreatedAtDesc(UUID userId, Pageable pageable);
    
    Page<Transaction> findByUserIdAndStatusOrderByCreatedAtDesc(
            UUID userId, TransactionStatus status, Pageable pageable);
    
    Page<Transaction> findByUserIdAndTransactionTypeOrderByCreatedAtDesc(
            UUID userId, TransactionType type, Pageable pageable);
    
    // Account transactions
    @Query("SELECT t FROM Transaction t WHERE t.fromAccountId = :accountId OR t.toAccountId = :accountId ORDER BY t.createdAt DESC")
    Page<Transaction> findByAccountId(@Param("accountId") UUID accountId, Pageable pageable);
    
    @Query("SELECT t FROM Transaction t WHERE (t.fromAccountId = :accountId OR t.toAccountId = :accountId) " +
           "AND t.createdAt BETWEEN :startDate AND :endDate ORDER BY t.createdAt DESC")
    Page<Transaction> findByAccountIdAndDateRange(
            @Param("accountId") UUID accountId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate,
            Pageable pageable);
    
    // Status-based queries
    List<Transaction> findByStatusAndCreatedAtBefore(TransactionStatus status, LocalDateTime dateTime);
    
    List<Transaction> findByStatusIn(List<TransactionStatus> statuses);
    
    @Query("SELECT t FROM Transaction t WHERE t.status = :status AND t.scheduledFor <= :now")
    List<Transaction> findScheduledTransactionsToProcess(
            @Param("status") TransactionStatus status,
            @Param("now") LocalDateTime now);
    
    // Fraud detection queries
    @Query("SELECT t FROM Transaction t WHERE t.isFlagged = true AND t.isReviewed = false ORDER BY t.riskScore DESC")
    Page<Transaction> findFlaggedTransactionsForReview(Pageable pageable);
    
    @Query("SELECT COUNT(t) FROM Transaction t WHERE t.userId = :userId AND t.createdAt >= :since")
    long countRecentTransactionsByUser(@Param("userId") UUID userId, @Param("since") LocalDateTime since);
    
    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t WHERE t.userId = :userId " +
           "AND t.transactionType IN :types AND t.status = 'COMPLETED' AND t.createdAt >= :since")
    BigDecimal sumAmountByUserAndTypesSince(
            @Param("userId") UUID userId,
            @Param("types") List<TransactionType> types,
            @Param("since") LocalDateTime since);
    
    // Analytics queries
    @Query("SELECT t.transactionType, COUNT(t), SUM(t.amount) FROM Transaction t " +
           "WHERE t.userId = :userId AND t.createdAt BETWEEN :start AND :end " +
           "GROUP BY t.transactionType")
    List<Object[]> getTransactionSummaryByType(
            @Param("userId") UUID userId,
            @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end);
    
    @Query("SELECT FUNCTION('DATE_TRUNC', 'day', t.createdAt), COUNT(t), SUM(t.amount) FROM Transaction t " +
           "WHERE t.userId = :userId AND t.createdAt BETWEEN :start AND :end " +
           "GROUP BY FUNCTION('DATE_TRUNC', 'day', t.createdAt) " +
           "ORDER BY FUNCTION('DATE_TRUNC', 'day', t.createdAt)")
    List<Object[]> getDailyTransactionStats(
            @Param("userId") UUID userId,
            @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end);
    
    @Query("SELECT COUNT(t) FROM Transaction t WHERE t.fromAccountId = :accountId AND t.status = 'COMPLETED' " +
           "AND t.createdAt >= :since")
    long countCompletedTransactionsFromAccount(
            @Param("accountId") UUID accountId,
            @Param("since") LocalDateTime since);
    
    // External reference lookup
    Optional<Transaction> findByExternalReferenceId(String externalReferenceId);
    
    // Bulk status check
    @Query("SELECT t.referenceNumber, t.status FROM Transaction t WHERE t.referenceNumber IN :referenceNumbers")
    List<Object[]> findStatusByReferenceNumbers(@Param("referenceNumbers") List<String> referenceNumbers);
}
