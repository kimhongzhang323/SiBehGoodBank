package com.sibehgoodbank.common.security;

import lombok.extern.slf4j.Slf4j;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.springframework.stereotype.Component;

import javax.crypto.Cipher;
import java.security.*;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

/**
 * RSA-4096 encryption service for asymmetric encryption operations.
 * Used for key exchange and encrypting sensitive tokens.
 */
@Component
@Slf4j
public class RsaEncryptionService {

    private static final String ALGORITHM = "RSA/ECB/OAEPWithSHA-256AndMGF1Padding";
    private static final int KEY_SIZE = 4096;

    static {
        Security.addProvider(new BouncyCastleProvider());
    }

    /**
     * Generate a new RSA-4096 key pair.
     *
     * @return RsaKeyPair containing Base64 encoded public and private keys
     */
    public RsaKeyPair generateKeyPair() {
        try {
            KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA", "BC");
            keyGen.initialize(KEY_SIZE, new SecureRandom());
            KeyPair keyPair = keyGen.generateKeyPair();

            String publicKey = Base64.getEncoder().encodeToString(keyPair.getPublic().getEncoded());
            String privateKey = Base64.getEncoder().encodeToString(keyPair.getPrivate().getEncoded());

            return new RsaKeyPair(publicKey, privateKey);
        } catch (Exception e) {
            log.error("Error generating RSA key pair", e);
            throw new EncryptionException("Failed to generate RSA key pair", e);
        }
    }

    /**
     * Encrypt data using RSA public key.
     *
     * @param plaintext The data to encrypt
     * @param base64PublicKey Base64 encoded RSA public key
     * @return Base64 encoded ciphertext
     */
    public String encrypt(String plaintext, String base64PublicKey) {
        try {
            byte[] keyBytes = Base64.getDecoder().decode(base64PublicKey);
            X509EncodedKeySpec keySpec = new X509EncodedKeySpec(keyBytes);
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");
            PublicKey publicKey = keyFactory.generatePublic(keySpec);

            Cipher cipher = Cipher.getInstance(ALGORITHM, "BC");
            cipher.init(Cipher.ENCRYPT_MODE, publicKey);

            byte[] ciphertext = cipher.doFinal(plaintext.getBytes());
            return Base64.getEncoder().encodeToString(ciphertext);
        } catch (Exception e) {
            log.error("RSA encryption failed", e);
            throw new EncryptionException("Failed to encrypt data with RSA", e);
        }
    }

    /**
     * Decrypt data using RSA private key.
     *
     * @param ciphertext Base64 encoded ciphertext
     * @param base64PrivateKey Base64 encoded RSA private key
     * @return Decrypted plaintext
     */
    public String decrypt(String ciphertext, String base64PrivateKey) {
        try {
            byte[] keyBytes = Base64.getDecoder().decode(base64PrivateKey);
            PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(keyBytes);
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");
            PrivateKey privateKey = keyFactory.generatePrivate(keySpec);

            Cipher cipher = Cipher.getInstance(ALGORITHM, "BC");
            cipher.init(Cipher.DECRYPT_MODE, privateKey);

            byte[] plaintext = cipher.doFinal(Base64.getDecoder().decode(ciphertext));
            return new String(plaintext);
        } catch (Exception e) {
            log.error("RSA decryption failed", e);
            throw new EncryptionException("Failed to decrypt data with RSA", e);
        }
    }

    /**
     * Sign data using RSA private key.
     *
     * @param data The data to sign
     * @param base64PrivateKey Base64 encoded RSA private key
     * @return Base64 encoded signature
     */
    public String sign(String data, String base64PrivateKey) {
        try {
            byte[] keyBytes = Base64.getDecoder().decode(base64PrivateKey);
            PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(keyBytes);
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");
            PrivateKey privateKey = keyFactory.generatePrivate(keySpec);

            Signature signature = Signature.getInstance("SHA256withRSA", "BC");
            signature.initSign(privateKey);
            signature.update(data.getBytes());

            byte[] signatureBytes = signature.sign();
            return Base64.getEncoder().encodeToString(signatureBytes);
        } catch (Exception e) {
            log.error("RSA signing failed", e);
            throw new EncryptionException("Failed to sign data with RSA", e);
        }
    }

    /**
     * Verify signature using RSA public key.
     *
     * @param data The original data
     * @param base64Signature Base64 encoded signature
     * @param base64PublicKey Base64 encoded RSA public key
     * @return true if signature is valid
     */
    public boolean verify(String data, String base64Signature, String base64PublicKey) {
        try {
            byte[] keyBytes = Base64.getDecoder().decode(base64PublicKey);
            X509EncodedKeySpec keySpec = new X509EncodedKeySpec(keyBytes);
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");
            PublicKey publicKey = keyFactory.generatePublic(keySpec);

            Signature signature = Signature.getInstance("SHA256withRSA", "BC");
            signature.initVerify(publicKey);
            signature.update(data.getBytes());

            return signature.verify(Base64.getDecoder().decode(base64Signature));
        } catch (Exception e) {
            log.error("RSA signature verification failed", e);
            return false;
        }
    }

    /**
     * Container for RSA key pair.
     */
    public record RsaKeyPair(String publicKey, String privateKey) {}
}
