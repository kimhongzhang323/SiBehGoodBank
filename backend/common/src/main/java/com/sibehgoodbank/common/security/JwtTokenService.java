package com.sibehgoodbank.common.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.*;

/**
 * JWT Token Service for authentication and authorization
 * Supports access tokens, refresh tokens, and API keys
 */
@Service
public class JwtTokenService {

    private final SecretKey accessTokenKey;
    private final SecretKey refreshTokenKey;

    @Value("${jwt.access-token-expiration:15}")
    private int accessTokenExpirationMinutes;

    @Value("${jwt.refresh-token-expiration:7}")
    private int refreshTokenExpirationDays;

    @Value("${jwt.issuer:sibehgoodbank}")
    private String issuer;

    public JwtTokenService(
            @Value("${jwt.access-secret:your-256-bit-secret-key-for-access-tokens-min-32-chars}") String accessSecret,
            @Value("${jwt.refresh-secret:your-256-bit-secret-key-for-refresh-tokens-min-32-chars}") String refreshSecret) {
        this.accessTokenKey = Keys.hmacShaKeyFor(accessSecret.getBytes(StandardCharsets.UTF_8));
        this.refreshTokenKey = Keys.hmacShaKeyFor(refreshSecret.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * Generates an access token for the user
     */
    public String generateAccessToken(String userId, String email, Set<String> roles, Map<String, Object> additionalClaims) {
        Instant now = Instant.now();
        Instant expiration = now.plus(accessTokenExpirationMinutes, ChronoUnit.MINUTES);

        JwtBuilder builder = Jwts.builder()
                .id(UUID.randomUUID().toString())
                .subject(userId)
                .issuer(issuer)
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiration))
                .claim("email", email)
                .claim("roles", roles)
                .claim("type", "access");

        if (additionalClaims != null) {
            additionalClaims.forEach(builder::claim);
        }

        return builder.signWith(accessTokenKey, Jwts.SIG.HS256).compact();
    }

    public String generateAccessToken(String userId, String email, Set<String> roles) {
        return generateAccessToken(userId, email, roles, null);
    }

    /**
     * Generates a refresh token
     */
    public String generateRefreshToken(String userId) {
        Instant now = Instant.now();
        Instant expiration = now.plus(refreshTokenExpirationDays, ChronoUnit.DAYS);

        return Jwts.builder()
                .id(UUID.randomUUID().toString())
                .subject(userId)
                .issuer(issuer)
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiration))
                .claim("type", "refresh")
                .signWith(refreshTokenKey, Jwts.SIG.HS256)
                .compact();
    }

    /**
     * Generates a token pair (access + refresh)
     */
    public TokenPair generateTokenPair(String userId, String email, Set<String> roles) {
        String accessToken = generateAccessToken(userId, email, roles);
        String refreshToken = generateRefreshToken(userId);
        return new TokenPair(accessToken, refreshToken, accessTokenExpirationMinutes * 60);
    }

    /**
     * Validates an access token and returns claims
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
            throw new TokenExpiredException("Access token has expired", e);
        } catch (JwtException e) {
            throw new InvalidTokenException("Invalid access token", e);
        }
    }

    /**
     * Validates a refresh token and returns claims
     */
    public Claims validateRefreshToken(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(refreshTokenKey)
                    .requireIssuer(issuer)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            if (!"refresh".equals(claims.get("type"))) {
                throw new InvalidTokenException("Token is not a refresh token");
            }
            return claims;
        } catch (ExpiredJwtException e) {
            throw new TokenExpiredException("Refresh token has expired", e);
        } catch (JwtException e) {
            throw new InvalidTokenException("Invalid refresh token", e);
        }
    }

    /**
     * Refreshes the token pair using a valid refresh token
     */
    public TokenPair refreshTokens(String refreshToken, String email, Set<String> roles) {
        Claims claims = validateRefreshToken(refreshToken);
        String userId = claims.getSubject();
        return generateTokenPair(userId, email, roles);
    }

    /**
     * Extracts user ID from token without validation (for logging purposes)
     */
    public String extractUserIdUnsafe(String token) {
        try {
            String[] parts = token.split("\\.");
            if (parts.length == 3) {
                String payload = new String(Base64.getUrlDecoder().decode(parts[1]));
                // Simple extraction - in production use proper JSON parsing
                int subStart = payload.indexOf("\"sub\":\"") + 7;
                int subEnd = payload.indexOf("\"", subStart);
                return payload.substring(subStart, subEnd);
            }
        } catch (Exception ignored) {}
        return null;
    }

    /**
     * Checks if token is expired without throwing exception
     */
    public boolean isTokenExpired(String token, boolean isRefreshToken) {
        try {
            SecretKey key = isRefreshToken ? refreshTokenKey : accessTokenKey;
            Jwts.parser().verifyWith(key).build().parseSignedClaims(token);
            return false;
        } catch (ExpiredJwtException e) {
            return true;
        } catch (Exception e) {
            return true;
        }
    }

    /**
     * Gets expiration time from token
     */
    public Date getExpirationTime(String token, boolean isRefreshToken) {
        SecretKey key = isRefreshToken ? refreshTokenKey : accessTokenKey;
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload()
                .getExpiration();
    }

    // ==================== API Key Generation ====================

    /**
     * Generates a long-lived API key for service-to-service communication
     */
    public String generateApiKey(String serviceId, String serviceName, int expirationDays) {
        Instant now = Instant.now();
        Instant expiration = now.plus(expirationDays, ChronoUnit.DAYS);

        return Jwts.builder()
                .id(UUID.randomUUID().toString())
                .subject(serviceId)
                .issuer(issuer)
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiration))
                .claim("serviceName", serviceName)
                .claim("type", "api_key")
                .signWith(accessTokenKey, Jwts.SIG.HS256)
                .compact();
    }

    public Claims validateApiKey(String apiKey) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(accessTokenKey)
                    .requireIssuer(issuer)
                    .build()
                    .parseSignedClaims(apiKey)
                    .getPayload();

            if (!"api_key".equals(claims.get("type"))) {
                throw new InvalidTokenException("Token is not an API key");
            }
            return claims;
        } catch (ExpiredJwtException e) {
            throw new TokenExpiredException("API key has expired", e);
        } catch (JwtException e) {
            throw new InvalidTokenException("Invalid API key", e);
        }
    }

    // ==================== Inner Classes ====================

    public record TokenPair(String accessToken, String refreshToken, long expiresIn) {}

    public static class TokenExpiredException extends RuntimeException {
        public TokenExpiredException(String message) {
            super(message);
        }
        public TokenExpiredException(String message, Throwable cause) {
            super(message, cause);
        }
    }

    public static class InvalidTokenException extends RuntimeException {
        public InvalidTokenException(String message) {
            super(message);
        }
        public InvalidTokenException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
