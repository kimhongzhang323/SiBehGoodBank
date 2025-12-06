package com.sibehgoodbank.userservice.repository;

import com.sibehgoodbank.userservice.entity.RefreshToken;
import com.sibehgoodbank.userservice.entity.User;
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
 * Repository for managing refresh tokens
 */
@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {

    Optional<RefreshToken> findByToken(String token);

    Optional<RefreshToken> findByTokenAndRevokedFalse(String token);

    List<RefreshToken> findByUserAndRevokedFalse(User user);

    List<RefreshToken> findByUserIdAndRevokedFalse(UUID userId);

    @Query("SELECT rt FROM RefreshToken rt WHERE rt.user.id = :userId AND rt.deviceId = :deviceId AND rt.revoked = false")
    Optional<RefreshToken> findActiveTokenByUserAndDevice(
            @Param("userId") UUID userId,
            @Param("deviceId") String deviceId);

    @Modifying
    @Query("UPDATE RefreshToken rt SET rt.revoked = true, rt.revokedAt = :revokedAt, rt.revokedReason = :reason WHERE rt.user.id = :userId")
    void revokeAllByUserId(
            @Param("userId") UUID userId,
            @Param("revokedAt") LocalDateTime revokedAt,
            @Param("reason") String reason);

    @Modifying
    @Query("UPDATE RefreshToken rt SET rt.revoked = true, rt.revokedAt = :revokedAt, rt.revokedReason = :reason WHERE rt.token = :token")
    void revokeByToken(
            @Param("token") String token,
            @Param("revokedAt") LocalDateTime revokedAt,
            @Param("reason") String reason);

    @Modifying
    @Query("DELETE FROM RefreshToken rt WHERE rt.expiresAt < :date")
    void deleteExpiredTokens(@Param("date") LocalDateTime date);

    @Query("SELECT COUNT(rt) FROM RefreshToken rt WHERE rt.user.id = :userId AND rt.revoked = false")
    long countActiveTokensByUserId(@Param("userId") UUID userId);

    @Query("SELECT rt FROM RefreshToken rt WHERE rt.expiresAt < :date AND rt.revoked = false")
    List<RefreshToken> findExpiredTokens(@Param("date") LocalDateTime date);
}
