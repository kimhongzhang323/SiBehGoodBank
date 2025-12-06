package com.sibehgoodbank.userservice.exception;

/**
 * Exception thrown for invalid credentials
 */
public class InvalidCredentialsException extends RuntimeException {
    public InvalidCredentialsException(String message) {
        super(message);
    }
}
