package com.example.backend.dtos.responses;
import java.util.UUID;

public record UserResponseDto(
    UUID id,
    String email,
    String username,
    String phone,
    String role
) {}
