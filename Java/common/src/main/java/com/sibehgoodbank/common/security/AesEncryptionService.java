package com.sibehgoodbank.common.security;

import lombok.extern.slf4j.Slf4j;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.springframework.stereotype.Component;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.ByteBuffer;
import java.security.SecureRandom;
import java.security.Security;
import java.util.Base64;

/**
 * AES-256-GCM encryption service for sensitive data encryption.
 * Uses Bouncy Castle provider for enhanced security features.
 */
@Component
@Slf4j
public class AesEncryptionService {

    private static final String ALGORITHM = "AES/GCM/NoPadding";
    private static final int KEY_SIZE = 256;
    private static final int IV_SIZE = 12; // 96 bits for GCM
    private static final int TAG_SIZE = 128; // 128 bits authentication tag
    
    private final SecureRandom secureRandom;

    static {
        Security.addProvider(new BouncyCastleProvider());
    }

    public AesEncryptionService() {
        this.secureRandom = new SecureRandom();
    }

    /**
     * Generate a new AES-256 secret key.
     *
     * @return Base64 encoded secret key
     */
    public String generateKey() {
        try {
            KeyGenerator keyGen = KeyGenerator.getInstance("AES");
            keyGen.init(KEY_SIZE, secureRandom);
            SecretKey key = keyGen.generateKey();
            return Base64.getEncoder().encodeToString(key.getEncoded());
        } catch (Exception e) {
            log.error("Error generating AES key", e);
            throw new EncryptionException("Failed to generate encryption key", e);
        }
    }

    /**
     * Encrypt data using AES-256-GCM.
     *
     * @param plaintext The data to encrypt
     * @param base64Key Base64 encoded AES key
     * @return Base64 encoded ciphertext (IV + encrypted data + auth tag)
     */
    public String encrypt(String plaintext, String base64Key) {
        try {
            byte[] keyBytes = Base64.getDecoder().decode(base64Key);
            SecretKey key = new SecretKeySpec(keyBytes, "AES");
            
            // Generate random IV
            byte[] iv = new byte[IV_SIZE];
            secureRandom.nextBytes(iv);
            
            Cipher cipher = Cipher.getInstance(ALGORITHM, "BC");
            GCMParameterSpec gcmSpec = new GCMParameterSpec(TAG_SIZE, iv);
            cipher.init(Cipher.ENCRYPT_MODE, key, gcmSpec);
            
            byte[] ciphertext = cipher.doFinal(plaintext.getBytes());
            
            // Prepend IV to ciphertext
            ByteBuffer byteBuffer = ByteBuffer.allocate(iv.length + ciphertext.length);
            byteBuffer.put(iv);
            byteBuffer.put(ciphertext);
            
            return Base64.getEncoder().encodeToString(byteBuffer.array());
        } catch (Exception e) {
            log.error("Encryption failed", e);
            throw new EncryptionException("Failed to encrypt data", e);
        }
    }

    /**
     * Decrypt data using AES-256-GCM.
     *
     * @param ciphertext Base64 encoded ciphertext (IV + encrypted data + auth tag)
     * @param base64Key Base64 encoded AES key
     * @return Decrypted plaintext
     */
    public String decrypt(String ciphertext, String base64Key) {
        try {
            byte[] keyBytes = Base64.getDecoder().decode(base64Key);
            SecretKey key = new SecretKeySpec(keyBytes, "AES");
            
            byte[] encryptedData = Base64.getDecoder().decode(ciphertext);
            
            // Extract IV from the beginning
            ByteBuffer byteBuffer = ByteBuffer.wrap(encryptedData);
            byte[] iv = new byte[IV_SIZE];
            byteBuffer.get(iv);
            byte[] ciphertextBytes = new byte[byteBuffer.remaining()];
            byteBuffer.get(ciphertextBytes);
            
            Cipher cipher = Cipher.getInstance(ALGORITHM, "BC");
            GCMParameterSpec gcmSpec = new GCMParameterSpec(TAG_SIZE, iv);
            cipher.init(Cipher.DECRYPT_MODE, key, gcmSpec);
            
            byte[] plaintext = cipher.doFinal(ciphertextBytes);
            return new String(plaintext);
        } catch (Exception e) {
            log.error("Decryption failed", e);
            throw new EncryptionException("Failed to decrypt data", e);
        }
    }

    /**
     * Encrypt sensitive data with additional authenticated data (AAD).
     *
     * @param plaintext The data to encrypt
     * @param base64Key Base64 encoded AES key
     * @param aad Additional authenticated data (not encrypted, but authenticated)
     * @return Base64 encoded ciphertext
     */
    public String encryptWithAad(String plaintext, String base64Key, String aad) {
        try {
            byte[] keyBytes = Base64.getDecoder().decode(base64Key);
            SecretKey key = new SecretKeySpec(keyBytes, "AES");
            
            byte[] iv = new byte[IV_SIZE];
            secureRandom.nextBytes(iv);
            
            Cipher cipher = Cipher.getInstance(ALGORITHM, "BC");
            GCMParameterSpec gcmSpec = new GCMParameterSpec(TAG_SIZE, iv);
            cipher.init(Cipher.ENCRYPT_MODE, key, gcmSpec);
            cipher.updateAAD(aad.getBytes());
            
            byte[] ciphertext = cipher.doFinal(plaintext.getBytes());
            
            ByteBuffer byteBuffer = ByteBuffer.allocate(iv.length + ciphertext.length);
            byteBuffer.put(iv);
            byteBuffer.put(ciphertext);
            
            return Base64.getEncoder().encodeToString(byteBuffer.array());
        } catch (Exception e) {
            log.error("Encryption with AAD failed", e);
            throw new EncryptionException("Failed to encrypt data with AAD", e);
        }
    }

    /**
     * Decrypt sensitive data with additional authenticated data (AAD).
     *
     * @param ciphertext Base64 encoded ciphertext
     * @param base64Key Base64 encoded AES key
     * @param aad Additional authenticated data (must match what was used during encryption)
     * @return Decrypted plaintext
     */
    public String decryptWithAad(String ciphertext, String base64Key, String aad) {
        try {
            byte[] keyBytes = Base64.getDecoder().decode(base64Key);
            SecretKey key = new SecretKeySpec(keyBytes, "AES");
            
            byte[] encryptedData = Base64.getDecoder().decode(ciphertext);
            
            ByteBuffer byteBuffer = ByteBuffer.wrap(encryptedData);
            byte[] iv = new byte[IV_SIZE];
            byteBuffer.get(iv);
            byte[] ciphertextBytes = new byte[byteBuffer.remaining()];
            byteBuffer.get(ciphertextBytes);
            
            Cipher cipher = Cipher.getInstance(ALGORITHM, "BC");
            GCMParameterSpec gcmSpec = new GCMParameterSpec(TAG_SIZE, iv);
            cipher.init(Cipher.DECRYPT_MODE, key, gcmSpec);
            cipher.updateAAD(aad.getBytes());
            
            byte[] plaintext = cipher.doFinal(ciphertextBytes);
            return new String(plaintext);
        } catch (Exception e) {
            log.error("Decryption with AAD failed", e);
            throw new EncryptionException("Failed to decrypt data with AAD", e);
        }
    }
}
