package com.sibehgoodbank.accountservice.repository;

import com.sibehgoodbank.accountservice.entity.Account;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import jakarta.persistence.LockModeType;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Account repository with optimistic locking support
 */
@Repository
public interface AccountRepository extends JpaRepository<Account, UUID> {

    Optional<Account> findByAccountNumber(String accountNumber);

    List<Account> findByUserId(UUID userId);

    Page<Account> findByUserId(UUID userId, Pageable pageable);

    List<Account> findByUserIdAndStatus(UUID userId, Account.AccountStatus status);

    Optional<Account> findByUserIdAndIsPrimaryTrue(UUID userId);

    boolean existsByAccountNumber(String accountNumber);

    @Query("SELECT a FROM Account a WHERE a.userId = :userId AND a.currency = :currency")
    List<Account> findByUserIdAndCurrency(@Param("userId") UUID userId, @Param("currency") Account.Currency currency);

    // Pessimistic lock for critical balance updates
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT a FROM Account a WHERE a.accountNumber = :accountNumber")
    Optional<Account> findByAccountNumberForUpdate(@Param("accountNumber") String accountNumber);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT a FROM Account a WHERE a.id = :id")
    Optional<Account> findByIdForUpdate(@Param("id") UUID id);

    @Modifying
    @Query("UPDATE Account a SET a.dailyTransferUsed = 0")
    void resetAllDailyTransferLimits();

    @Modifying
    @Query("UPDATE Account a SET a.status = :status WHERE a.id = :accountId")
    void updateStatus(@Param("accountId") UUID accountId, @Param("status") Account.AccountStatus status);

    @Query("SELECT SUM(a.balance) FROM Account a WHERE a.userId = :userId AND a.currency = :currency")
    BigDecimal getTotalBalanceByUserAndCurrency(@Param("userId") UUID userId, @Param("currency") Account.Currency currency);

    @Query("SELECT a FROM Account a WHERE a.status = 'ACTIVE' AND a.lastTransactionAt < :dormantDate")
    List<Account> findDormantAccounts(@Param("dormantDate") java.time.LocalDateTime dormantDate);

    @Query("SELECT COUNT(a) FROM Account a WHERE a.userId = :userId AND a.status = 'ACTIVE'")
    long countActiveAccountsByUserId(@Param("userId") UUID userId);
}
