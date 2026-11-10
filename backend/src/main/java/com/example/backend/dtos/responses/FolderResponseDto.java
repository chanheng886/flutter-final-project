package com.example.backend.dtos.responses;
import java.time.Instant;
import java.util.UUID;

public record FolderResponseDto(
    UUID id,
    UUID userId,
    String folderName,
    Integer docCount,
    Instant createdAt,
    Instant updatedAt,
    Instant deletedAt
) {}
