package com.example.backend.dtos.responses;

import java.time.Instant;
import java.util.UUID;

import com.example.backend.enums.HistoryAction;
import com.example.backend.enums.ItemType;

public record HistoryResponseDto(
    UUID id,
    UUID userId,
    UUID folderId,
    UUID documentId,
    ItemType itemType,
    String folderName,
    String docName,
    Integer docCount,
    HistoryAction action,
    Instant createdAt
) {}
