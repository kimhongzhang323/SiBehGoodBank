package com.sibehgoodbank.common.security;

import org.springframework.security.crypto.argon2.Argon2PasswordEncoder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.util.Base64;

/**
 * Password hashing service using Argon2id (primary) and BCrypt (fallback)
 * Argon2id is the winner of the Password Hashing Competition and recommended for new applications
 */
@Service
public class PasswordService {

    // Argon2id parameters (memory-hard, resistant to GPU/ASIC attacks)
    private static final int SALT_LENGTH = 16;
    private static final int HASH_LENGTH = 32;
    private static final int PARALLELISM = 1;
    private static final int MEMORY = 65536; // 64 MB
    private static final int ITERATIONS = 3;

    private final Argon2PasswordEncoder argon2Encoder;
    private final BCryptPasswordEncoder bcryptEncoder;
    private final SecureRandom secureRandom;

    public PasswordService() {
        this.argon2Encoder = new Argon2PasswordEncoder(SALT_LENGTH, HASH_LENGTH, PARALLELISM, MEMORY, ITERATIONS);
        this.bcryptEncoder = new BCryptPasswordEncoder(12); // Cost factor 12
        this.secureRandom = new SecureRandom();
    }

    /**
     * Hashes a password using Argon2id
     * @param rawPassword The plain text password
     * @return The hashed password
     */
    public String hashPassword(String rawPassword) {
        return argon2Encoder.encode(rawPassword);
    }

    /**
     * Verifies a password against a hash
     * Supports both Argon2id and BCrypt for backward compatibility
     * @param rawPassword The plain text password to verify
     * @param encodedPassword The stored hash
     * @return true if the password matches
     */
    public boolean verifyPassword(String rawPassword, String encodedPassword) {
        if (encodedPassword == null || rawPassword == null) {
            return false;
        }

        // Check if it's an Argon2 hash
        if (encodedPassword.startsWith("$argon2")) {
            return argon2Encoder.matches(rawPassword, encodedPassword);
        }
        
        // Fall back to BCrypt for legacy passwords
        if (encodedPassword.startsWith("$2a$") || encodedPassword.startsWith("$2b$") || encodedPassword.startsWith("$2y$")) {
            return bcryptEncoder.matches(rawPassword, encodedPassword);
        }

        return false;
    }

    /**
     * Checks if a password hash needs to be upgraded (e.g., from BCrypt to Argon2)
     * @param encodedPassword The stored hash
     * @return true if the hash should be upgraded
     */
    public boolean needsUpgrade(String encodedPassword) {
        if (encodedPassword == null) {
            return false;
        }
        
        // Upgrade BCrypt to Argon2
        if (encodedPassword.startsWith("$2a$") || encodedPassword.startsWith("$2b$") || encodedPassword.startsWith("$2y$")) {
            return true;
        }

        // Check if Argon2 parameters need upgrade
        return argon2Encoder.upgradeEncoding(encodedPassword);
    }

    /**
     * Generates a secure random salt
     * @return Base64 encoded salt
     */
    public String generateSalt() {
        byte[] salt = new byte[SALT_LENGTH];
        secureRandom.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }

    /**
     * Generates a secure random password
     * @param length The desired password length
     * @return A random password
     */
    public String generateRandomPassword(int length) {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
        StringBuilder password = new StringBuilder();
        for (int i = 0; i < length; i++) {
            password.append(chars.charAt(secureRandom.nextInt(chars.length())));
        }
        return password.toString();
    }

    /**
     * Generates a secure PIN (numeric only)
     * @param length PIN length (typically 4-6)
     * @return A random PIN
     */
    public String generateSecurePIN(int length) {
        StringBuilder pin = new StringBuilder();
        for (int i = 0; i < length; i++) {
            pin.append(secureRandom.nextInt(10));
        }
        return pin.toString();
    }

    /**
     * Generates a secure OTP
     * @param length OTP length
     * @return A random OTP
     */
    public String generateOTP(int length) {
        return generateSecurePIN(length);
    }

    /**
     * Hash password with BCrypt (legacy support)
     */
    public String hashPasswordBCrypt(String rawPassword) {
        return bcryptEncoder.encode(rawPassword);
    }

    /**
     * Validates password strength
     * @param password The password to validate
     * @return PasswordStrength result
     */
    public PasswordStrength validatePasswordStrength(String password) {
        if (password == null || password.length() < 8) {
            return new PasswordStrength(false, 0, "Password must be at least 8 characters");
        }

        int score = 0;
        StringBuilder feedback = new StringBuilder();

        // Length check
        if (password.length() >= 8) score += 1;
        if (password.length() >= 12) score += 1;
        if (password.length() >= 16) score += 1;

        // Complexity checks
        if (password.matches(".*[a-z].*")) score += 1;
        if (password.matches(".*[A-Z].*")) score += 1;
        if (password.matches(".*[0-9].*")) score += 1;
        if (password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?].*")) score += 1;

        // Penalty for common patterns
        if (password.matches(".*(.)(\\1{2,}).*")) {
            score -= 1;
            feedback.append("Avoid repeated characters. ");
        }
        if (password.matches(".*(?:012|123|234|345|456|567|678|789|890|abc|bcd|cde|def).*")) {
            score -= 1;
            feedback.append("Avoid sequential characters. ");
        }

        boolean isStrong = score >= 5;
        if (!isStrong) {
            if (!password.matches(".*[A-Z].*")) feedback.append("Add uppercase letters. ");
            if (!password.matches(".*[a-z].*")) feedback.append("Add lowercase letters. ");
            if (!password.matches(".*[0-9].*")) feedback.append("Add numbers. ");
            if (!password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?].*")) 
                feedback.append("Add special characters. ");
        }

        return new PasswordStrength(isStrong, Math.max(0, Math.min(score, 7)), feedback.toString().trim());
    }

    public record PasswordStrength(boolean isStrong, int score, String feedback) {
        public String getStrengthLevel() {
            if (score <= 2) return "Weak";
            if (score <= 4) return "Fair";
            if (score <= 5) return "Good";
            return "Strong";
        }
    }
}
