package com.sibehgoodbank.common.security;

import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.*;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

/**
 * Advanced Encryption Service using AES-256-GCM and RSA-4096
 * Implements secure encryption for sensitive banking data
 */
@Service
public class EncryptionService {

    private static final String AES_ALGORITHM = "AES/GCM/NoPadding";
    private static final String RSA_ALGORITHM = "RSA/ECB/OAEPWithSHA-256AndMGF1Padding";
    private static final int GCM_IV_LENGTH = 12;
    private static final int GCM_TAG_LENGTH = 128;
    private static final int AES_KEY_SIZE = 256;
    private static final int RSA_KEY_SIZE = 4096;

    static {
        Security.addProvider(new BouncyCastleProvider());
    }

    @Value("${encryption.master-key:DEFAULT_MASTER_KEY_CHANGE_IN_PRODUCTION}")
    private String masterKey;

    private KeyPair rsaKeyPair;

    public EncryptionService() {
        try {
            this.rsaKeyPair = generateRSAKeyPair();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Failed to initialize RSA key pair", e);
        }
    }

    // ==================== AES-256-GCM Encryption ====================

    /**
     * Encrypts data using AES-256-GCM
     * Returns Base64 encoded: IV + Ciphertext + Auth Tag
     */
    public String encryptAES(String plaintext) {
        try {
            SecretKey key = deriveAESKey(masterKey);
            byte[] iv = generateSecureRandom(GCM_IV_LENGTH);
            
            Cipher cipher = Cipher.getInstance(AES_ALGORITHM);
            GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            cipher.init(Cipher.ENCRYPT_MODE, key, parameterSpec);
            
            byte[] ciphertext = cipher.doFinal(plaintext.getBytes(StandardCharsets.UTF_8));
            
            // Combine IV + Ciphertext
            ByteBuffer byteBuffer = ByteBuffer.allocate(iv.length + ciphertext.length);
            byteBuffer.put(iv);
            byteBuffer.put(ciphertext);
            
            return Base64.getEncoder().encodeToString(byteBuffer.array());
        } catch (Exception e) {
            throw new SecurityException("AES encryption failed", e);
        }
    }

    /**
     * Decrypts AES-256-GCM encrypted data
     */
    public String decryptAES(String encryptedData) {
        try {
            byte[] decoded = Base64.getDecoder().decode(encryptedData);
            ByteBuffer byteBuffer = ByteBuffer.wrap(decoded);
            
            byte[] iv = new byte[GCM_IV_LENGTH];
            byteBuffer.get(iv);
            
            byte[] ciphertext = new byte[byteBuffer.remaining()];
            byteBuffer.get(ciphertext);
            
            SecretKey key = deriveAESKey(masterKey);
            Cipher cipher = Cipher.getInstance(AES_ALGORITHM);
            GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            cipher.init(Cipher.DECRYPT_MODE, key, parameterSpec);
            
            byte[] plaintext = cipher.doFinal(ciphertext);
            return new String(plaintext, StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new SecurityException("AES decryption failed", e);
        }
    }

    /**
     * Encrypts with custom key (for per-user encryption)
     */
    public String encryptAESWithKey(String plaintext, String customKey) {
        try {
            SecretKey key = deriveAESKey(customKey);
            byte[] iv = generateSecureRandom(GCM_IV_LENGTH);
            
            Cipher cipher = Cipher.getInstance(AES_ALGORITHM);
            GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            cipher.init(Cipher.ENCRYPT_MODE, key, parameterSpec);
            
            byte[] ciphertext = cipher.doFinal(plaintext.getBytes(StandardCharsets.UTF_8));
            
            ByteBuffer byteBuffer = ByteBuffer.allocate(iv.length + ciphertext.length);
            byteBuffer.put(iv);
            byteBuffer.put(ciphertext);
            
            return Base64.getEncoder().encodeToString(byteBuffer.array());
        } catch (Exception e) {
            throw new SecurityException("AES encryption with custom key failed", e);
        }
    }

    public String decryptAESWithKey(String encryptedData, String customKey) {
        try {
            byte[] decoded = Base64.getDecoder().decode(encryptedData);
            ByteBuffer byteBuffer = ByteBuffer.wrap(decoded);
            
            byte[] iv = new byte[GCM_IV_LENGTH];
            byteBuffer.get(iv);
            
            byte[] ciphertext = new byte[byteBuffer.remaining()];
            byteBuffer.get(ciphertext);
            
            SecretKey key = deriveAESKey(customKey);
            Cipher cipher = Cipher.getInstance(AES_ALGORITHM);
            GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            cipher.init(Cipher.DECRYPT_MODE, key, parameterSpec);
            
            byte[] plaintext = cipher.doFinal(ciphertext);
            return new String(plaintext, StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new SecurityException("AES decryption with custom key failed", e);
        }
    }

    // ==================== RSA-4096 Encryption ====================

    /**
     * Encrypts data using RSA-4096 with OAEP padding
     * Best for encrypting small data like AES keys
     */
    public String encryptRSA(String plaintext, PublicKey publicKey) {
        try {
            Cipher cipher = Cipher.getInstance(RSA_ALGORITHM);
            cipher.init(Cipher.ENCRYPT_MODE, publicKey);
            byte[] encrypted = cipher.doFinal(plaintext.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(encrypted);
        } catch (Exception e) {
            throw new SecurityException("RSA encryption failed", e);
        }
    }

    public String encryptRSA(String plaintext) {
        return encryptRSA(plaintext, rsaKeyPair.getPublic());
    }

    /**
     * Decrypts RSA encrypted data
     */
    public String decryptRSA(String encryptedData, PrivateKey privateKey) {
        try {
            Cipher cipher = Cipher.getInstance(RSA_ALGORITHM);
            cipher.init(Cipher.DECRYPT_MODE, privateKey);
            byte[] decrypted = cipher.doFinal(Base64.getDecoder().decode(encryptedData));
            return new String(decrypted, StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new SecurityException("RSA decryption failed", e);
        }
    }

    public String decryptRSA(String encryptedData) {
        return decryptRSA(encryptedData, rsaKeyPair.getPrivate());
    }

    // ==================== Hybrid Encryption (RSA + AES) ====================

    /**
     * Hybrid encryption: Generate random AES key, encrypt data with AES,
     * encrypt AES key with RSA. Best for large data.
     */
    public HybridEncryptedData encryptHybrid(String plaintext) {
        try {
            // Generate random AES key
            KeyGenerator keyGen = KeyGenerator.getInstance("AES");
            keyGen.init(AES_KEY_SIZE);
            SecretKey aesKey = keyGen.generateKey();
            String aesKeyBase64 = Base64.getEncoder().encodeToString(aesKey.getEncoded());
            
            // Encrypt data with AES
            byte[] iv = generateSecureRandom(GCM_IV_LENGTH);
            Cipher aesCipher = Cipher.getInstance(AES_ALGORITHM);
            GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            aesCipher.init(Cipher.ENCRYPT_MODE, aesKey, parameterSpec);
            byte[] encryptedData = aesCipher.doFinal(plaintext.getBytes(StandardCharsets.UTF_8));
            
            ByteBuffer byteBuffer = ByteBuffer.allocate(iv.length + encryptedData.length);
            byteBuffer.put(iv);
            byteBuffer.put(encryptedData);
            String encryptedDataBase64 = Base64.getEncoder().encodeToString(byteBuffer.array());
            
            // Encrypt AES key with RSA
            String encryptedAesKey = encryptRSA(aesKeyBase64);
            
            return new HybridEncryptedData(encryptedAesKey, encryptedDataBase64);
        } catch (Exception e) {
            throw new SecurityException("Hybrid encryption failed", e);
        }
    }

    public String decryptHybrid(HybridEncryptedData hybridData) {
        try {
            // Decrypt AES key with RSA
            String aesKeyBase64 = decryptRSA(hybridData.encryptedKey());
            byte[] aesKeyBytes = Base64.getDecoder().decode(aesKeyBase64);
            SecretKey aesKey = new SecretKeySpec(aesKeyBytes, "AES");
            
            // Decrypt data with AES
            byte[] decoded = Base64.getDecoder().decode(hybridData.encryptedData());
            ByteBuffer byteBuffer = ByteBuffer.wrap(decoded);
            
            byte[] iv = new byte[GCM_IV_LENGTH];
            byteBuffer.get(iv);
            
            byte[] ciphertext = new byte[byteBuffer.remaining()];
            byteBuffer.get(ciphertext);
            
            Cipher aesCipher = Cipher.getInstance(AES_ALGORITHM);
            GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            aesCipher.init(Cipher.DECRYPT_MODE, aesKey, parameterSpec);
            
            byte[] plaintext = aesCipher.doFinal(ciphertext);
            return new String(plaintext, StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new SecurityException("Hybrid decryption failed", e);
        }
    }

    // ==================== Digital Signatures ====================

    /**
     * Creates a digital signature using RSA-SHA256
     */
    public String sign(String data) {
        try {
            Signature signature = Signature.getInstance("SHA256withRSA");
            signature.initSign(rsaKeyPair.getPrivate());
            signature.update(data.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(signature.sign());
        } catch (Exception e) {
            throw new SecurityException("Digital signature failed", e);
        }
    }

    /**
     * Verifies a digital signature
     */
    public boolean verify(String data, String signatureBase64) {
        try {
            Signature signature = Signature.getInstance("SHA256withRSA");
            signature.initVerify(rsaKeyPair.getPublic());
            signature.update(data.getBytes(StandardCharsets.UTF_8));
            return signature.verify(Base64.getDecoder().decode(signatureBase64));
        } catch (Exception e) {
            return false;
        }
    }

    // ==================== Hashing ====================

    /**
     * SHA-256 hash
     */
    public String hash(String data) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(data.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new SecurityException("Hashing failed", e);
        }
    }

    /**
     * SHA-512 hash for extra security
     */
    public String hashSHA512(String data) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-512");
            byte[] hash = digest.digest(data.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new SecurityException("SHA-512 hashing failed", e);
        }
    }

    // ==================== Key Management ====================

    public KeyPair generateRSAKeyPair() throws NoSuchAlgorithmException {
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
        keyGen.initialize(RSA_KEY_SIZE, new SecureRandom());
        return keyGen.generateKeyPair();
    }

    public String generateAESKey() {
        try {
            KeyGenerator keyGen = KeyGenerator.getInstance("AES");
            keyGen.init(AES_KEY_SIZE);
            SecretKey key = keyGen.generateKey();
            return Base64.getEncoder().encodeToString(key.getEncoded());
        } catch (NoSuchAlgorithmException e) {
            throw new SecurityException("AES key generation failed", e);
        }
    }

    public PublicKey getPublicKey() {
        return rsaKeyPair.getPublic();
    }

    public String getPublicKeyBase64() {
        return Base64.getEncoder().encodeToString(rsaKeyPair.getPublic().getEncoded());
    }

    public PublicKey decodePublicKey(String publicKeyBase64) {
        try {
            byte[] keyBytes = Base64.getDecoder().decode(publicKeyBase64);
            X509EncodedKeySpec spec = new X509EncodedKeySpec(keyBytes);
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");
            return keyFactory.generatePublic(spec);
        } catch (Exception e) {
            throw new SecurityException("Failed to decode public key", e);
        }
    }

    public PrivateKey decodePrivateKey(String privateKeyBase64) {
        try {
            byte[] keyBytes = Base64.getDecoder().decode(privateKeyBase64);
            PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(keyBytes);
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");
            return keyFactory.generatePrivate(spec);
        } catch (Exception e) {
            throw new SecurityException("Failed to decode private key", e);
        }
    }

    // ==================== Utility Methods ====================

    private SecretKey deriveAESKey(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            return new SecretKeySpec(hash, "AES");
        } catch (NoSuchAlgorithmException e) {
            throw new SecurityException("Key derivation failed", e);
        }
    }

    private byte[] generateSecureRandom(int length) {
        byte[] bytes = new byte[length];
        new SecureRandom().nextBytes(bytes);
        return bytes;
    }

    /**
     * Generates a secure random token (for session tokens, API keys, etc.)
     */
    public String generateSecureToken(int length) {
        byte[] bytes = generateSecureRandom(length);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    // ==================== Inner Classes ====================

    public record HybridEncryptedData(String encryptedKey, String encryptedData) {}
}
