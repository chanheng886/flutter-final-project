package com.example.backend.dtos.responses;
import java.time.Instant;
import java.util.UUID;

public record DocumentResponseDto(
    UUID id,
    UUID folderId,
    String docName,
    String content,
    String language,
    Instant createdAt,
    Instant updatedAt
) {}
