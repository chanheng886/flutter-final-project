package com.example.backend.dtos.requests;
import jakarta.validation.constraints.NotBlank;

public record LoginRequestDto(
    @NotBlank (message = "Email or username is required!")
    String identifier,
    @NotBlank (message = "Password is required!")
    String password
) {
    public LoginRequestDto{
        identifier = identifier == null ? null : identifier.trim();
    }
}
