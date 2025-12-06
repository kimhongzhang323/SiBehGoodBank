package com.sibehgoodbank.userservice.dto;

import jakarta.validation.constraints.Size;
import lombok.*;

/**
 * Update profile request DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateProfileRequest {

    @Size(max = 100, message = "Full name must not exceed 100 characters")
    private String fullName;

    @Size(max = 50, message = "Nickname must not exceed 50 characters")
    private String nickname;

    @Size(max = 500, message = "Address must not exceed 500 characters")
    private String address;

    @Size(max = 100, message = "City must not exceed 100 characters")
    private String city;

    @Size(max = 100, message = "State must not exceed 100 characters")
    private String state;

    @Size(max = 20, message = "Postal code must not exceed 20 characters")
    private String postalCode;

    @Size(max = 255, message = "Profile image URL must not exceed 255 characters")
    private String profileImageUrl;
}
