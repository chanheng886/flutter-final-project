package com.example.backend.dtos.requests;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegisterRequestDto(
    @NotBlank (message = "email is required!")
    @Email (message = "Invalid email, please try again with another email!")
    String email,
    String username,
    @Schema (example = "0123456789", nullable = true)
    String phone,
    @NotBlank (message = "Password is required!")
    @Size (min = 6, max = 12, message = "Password must around 6 - 12 digits || characters")
    String passwordHash,
    @NotBlank (message = "Password is required!")
    String confirmedPassword
) {
    public RegisterRequestDto{
        if(email!=null) email = email.trim().toLowerCase();
        username = (username == null || username.isBlank()) ? null : username.trim();
        phone = (phone == null || phone.isBlank()) ? null : phone.trim();
    }
    @AssertTrue (message = "Passwords do not match")
    public boolean isPasswordMatch(){
        return passwordHash != null && passwordHash.equals(confirmedPassword);
    }
}