package com.example.backend.dtos.responses;

import java.time.Instant;
import java.util.UUID;

public record OcrResultResponseDto(
    UUID id,
    UUID documentId,
    String rawText,
    String aiCorrectedText,
    String boundingBox,
    double confidenceScore,
    String engineUsed,
    Integer ocrLatencyMs,
    Instant createdAt,
    Instant updatedAt
) {}
