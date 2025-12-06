package com.sibehgoodbank.common.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.Map;
import java.util.UUID;

/**
 * JWT service for token generation and validation.
 * Supports access tokens, refresh tokens, and custom claims.
 */
@Component
@Slf4j
public class JwtService {

    private final SecretKey accessTokenKey;
    private final SecretKey refreshTokenKey;
    private final long accessTokenExpiration;
    private final long refreshTokenExpiration;
    private final String issuer;

    public JwtService(
            @Value("${jwt.access-token.secret:default-access-token-secret-key-must-be-at-least-256-bits-long}") String accessSecret,
            @Value("${jwt.refresh-token.secret:default-refresh-token-secret-key-must-be-at-least-256-bits-long}") String refreshSecret,
            @Value("${jwt.access-token.expiration:3600}") long accessExpiration,
            @Value("${jwt.refresh-token.expiration:604800}") long refreshExpiration,
            @Value("${jwt.issuer:sibehgoodbank}") String issuer
    ) {
        this.accessTokenKey = Keys.hmacShaKeyFor(accessSecret.getBytes(StandardCharsets.UTF_8));
        this.refreshTokenKey = Keys.hmacShaKeyFor(refreshSecret.getBytes(StandardCharsets.UTF_8));
        this.accessTokenExpiration = accessExpiration;
        this.refreshTokenExpiration = refreshExpiration;
        this.issuer = issuer;
    }

    /**
     * Generate an access token for a user.
     *
     * @param userId User's unique identifier
     * @param email User's email
     * @param role User's role
     * @param additionalClaims Additional claims to include
     * @return JWT access token
     */
    public String generateAccessToken(UUID userId, String email, String role, Map<String, Object> additionalClaims) {
        Instant now = Instant.now();
        Instant expiration = now.plus(accessTokenExpiration, ChronoUnit.SECONDS);

        JwtBuilder builder = Jwts.builder()
                .issuer(issuer)
                .subject(userId.toString())
                .claim("email", email)
                .claim("role", role)
                .claim("type", "access")
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiration))
                .id(UUID.randomUUID().toString());

        if (additionalClaims != null) {
            additionalClaims.forEach(builder::claim);
        }

        return builder.signWith(accessTokenKey).compact();
    }

    /**
     * Generate an access token with default claims.
     */
    public String generateAccessToken(UUID userId, String email, String role) {
        return generateAccessToken(userId, email, role, null);
    }

    /**
     * Generate a refresh token.
     *
     * @param userId User's unique identifier
     * @param tokenFamily Token family for refresh token rotation
     * @return JWT refresh token
     */
    public String generateRefreshToken(UUID userId, String tokenFamily) {
        Instant now = Instant.now();
        Instant expiration = now.plus(refreshTokenExpiration, ChronoUnit.SECONDS);

        return Jwts.builder()
                .issuer(issuer)
                .subject(userId.toString())
                .claim("type", "refresh")
                .claim("family", tokenFamily)
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiration))
                .id(UUID.randomUUID().toString())
                .signWith(refreshTokenKey)
                .compact();
    }

    /**
     * Validate and parse an access token.
     *
     * @param token JWT access token
     * @return Parsed claims
     */
    public Claims validateAccessToken(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(accessTokenKey)
                    .requireIssuer(issuer)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (ExpiredJwtException e) {
            log.warn("Access token expired: {}", e.getMessage());
            throw new JwtValidationException("Token has expired", e);
        } catch (JwtException e) {
            log.warn("Invalid access token: {}", e.getMessage());
            throw new JwtValidationException("Invalid token", e);
        }
    }

    /**
     * Validate and parse a refresh token.
     *
     * @param token JWT refresh token
     * @return Parsed claims
     */
    public Claims validateRefreshToken(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(refreshTokenKey)
                    .requireIssuer(issuer)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (ExpiredJwtException e) {
            log.warn("Refresh token expired: {}", e.getMessage());
            throw new JwtValidationException("Refresh token has expired", e);
        } catch (JwtException e) {
            log.warn("Invalid refresh token: {}", e.getMessage());
            throw new JwtValidationException("Invalid refresh token", e);
        }
    }

    /**
     * Extract user ID from token without full validation.
     * Useful for logging or debugging.
     *
     * @param token JWT token
     * @return User ID or null if extraction fails
     */
    public UUID extractUserId(String token) {
        try {
            String[] parts = token.split("\\.");
            if (parts.length >= 2) {
                String payload = new String(java.util.Base64.getUrlDecoder().decode(parts[1]));
                // Simple extraction - in production use proper JSON parsing
                int subStart = payload.indexOf("\"sub\":\"") + 7;
                int subEnd = payload.indexOf("\"", subStart);
                return UUID.fromString(payload.substring(subStart, subEnd));
            }
        } catch (Exception e) {
            log.debug("Failed to extract user ID from token", e);
        }
        return null;
    }

    /**
     * Check if a token is expired without throwing exception.
     *
     * @param token JWT token
     * @param isRefreshToken true if checking refresh token
     * @return true if token is expired
     */
    public boolean isTokenExpired(String token, boolean isRefreshToken) {
        try {
            SecretKey key = isRefreshToken ? refreshTokenKey : accessTokenKey;
            Jwts.parser().verifyWith(key).build().parseSignedClaims(token);
            return false;
        } catch (ExpiredJwtException e) {
            return true;
        } catch (JwtException e) {
            return true;
        }
    }

    /**
     * Get remaining time until token expiration.
     *
     * @param token JWT token
     * @param isRefreshToken true if checking refresh token
     * @return Remaining seconds until expiration, 0 if expired
     */
    public long getRemainingValidity(String token, boolean isRefreshToken) {
        try {
            SecretKey key = isRefreshToken ? refreshTokenKey : accessTokenKey;
            Claims claims = Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
            long expiration = claims.getExpiration().getTime();
            long remaining = (expiration - System.currentTimeMillis()) / 1000;
            return Math.max(0, remaining);
        } catch (JwtException e) {
            return 0;
        }
    }

    /**
     * Custom exception for JWT validation errors.
     */
    public static class JwtValidationException extends RuntimeException {
        public JwtValidationException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
