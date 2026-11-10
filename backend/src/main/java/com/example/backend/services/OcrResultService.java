package com.example.backend.services;

import java.util.UUID;

import com.example.backend.dtos.responses.OcrResultResponseDto;

public interface OcrResultService {
    OcrResultResponseDto scan(UUID userId, UUID docId);
    OcrResultResponseDto get(UUID userId, UUID docId);
}
