package com.sibehgoodbank.userservice.repository;

import com.sibehgoodbank.userservice.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * User repository with custom queries for banking operations
 */
@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

    Optional<User> findByEmail(String email);

    Optional<User> findByPhoneNumber(String phoneNumber);

    boolean existsByEmail(String email);

    boolean existsByPhoneNumber(String phoneNumber);

    @Query("SELECT u FROM User u WHERE u.status = :status")
    Page<User> findByStatus(@Param("status") User.UserStatus status, Pageable pageable);

    @Query("SELECT u FROM User u WHERE u.tier = :tier")
    Page<User> findByTier(@Param("tier") User.UserTier tier, Pageable pageable);

    @Query("SELECT u FROM User u WHERE u.fullName LIKE %:name% OR u.email LIKE %:name%")
    Page<User> searchByNameOrEmail(@Param("name") String name, Pageable pageable);

    @Query("SELECT u FROM User u WHERE u.createdAt BETWEEN :startDate AND :endDate")
    List<User> findUsersRegisteredBetween(
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);

    @Query("SELECT u FROM User u WHERE u.lastLoginAt < :date AND u.status = 'ACTIVE'")
    List<User> findInactiveUsers(@Param("date") LocalDateTime date);

    @Query("SELECT COUNT(u) FROM User u WHERE u.status = :status")
    long countByStatus(@Param("status") User.UserStatus status);

    @Query("SELECT COUNT(u) FROM User u WHERE u.tier = :tier")
    long countByTier(@Param("tier") User.UserTier tier);

    @Modifying
    @Query("UPDATE User u SET u.failedLoginAttempts = 0, u.lockedUntil = null WHERE u.id = :userId")
    void resetFailedLoginAttempts(@Param("userId") UUID userId);

    @Modifying
    @Query("UPDATE User u SET u.status = :status WHERE u.id = :userId")
    void updateStatus(@Param("userId") UUID userId, @Param("status") User.UserStatus status);

    @Modifying
    @Query("UPDATE User u SET u.lastLoginAt = :loginTime WHERE u.id = :userId")
    void updateLastLogin(@Param("userId") UUID userId, @Param("loginTime") LocalDateTime loginTime);

    @Query("SELECT u FROM User u WHERE u.emailVerified = false AND u.createdAt < :cutoffDate")
    List<User> findUnverifiedUsersOlderThan(@Param("cutoffDate") LocalDateTime cutoffDate);

    @Query("SELECT u FROM User u WHERE :role MEMBER OF u.roles")
    List<User> findByRole(@Param("role") String role);
}
