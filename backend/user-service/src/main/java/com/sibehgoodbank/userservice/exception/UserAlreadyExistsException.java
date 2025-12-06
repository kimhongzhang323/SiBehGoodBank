package com.sibehgoodbank.userservice.exception;

/**
 * Exception thrown when user already exists
 */
public class UserAlreadyExistsException extends RuntimeException {
    public UserAlreadyExistsException(String message) {
        super(message);
    }
}
