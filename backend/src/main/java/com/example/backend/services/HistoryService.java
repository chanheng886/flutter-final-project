package com.example.backend.services;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.example.backend.dtos.responses.HistoryResponseDto;
import com.example.backend.entities.Document;
import com.example.backend.entities.Folder;
import com.example.backend.enums.HistoryAction;

public interface HistoryService {
    void recordFolder(UUID userId, Folder folder, HistoryAction action);
    void recordDocument(UUID userId, Document doc, HistoryAction action);
    Page<HistoryResponseDto> list(UUID userId, Pageable pageable);
}
