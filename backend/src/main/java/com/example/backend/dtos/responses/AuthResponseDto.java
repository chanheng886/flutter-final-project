package com.example.backend.dtos.responses;

/**
 * AuthResponseDto
 */
public record AuthResponseDto(
    String token,
    UserResponseDto user
) {}