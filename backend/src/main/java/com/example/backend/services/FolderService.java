package com.example.backend.services;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import com.example.backend.dtos.requests.FolderRequestDto;
import com.example.backend.dtos.responses.FolderResponseDto;

public interface FolderService {
    FolderResponseDto create(UUID userId, FolderRequestDto dto);
    FolderResponseDto update(UUID userId,UUID id, FolderRequestDto dto);
    void moveToTrash(UUID userId, UUID id);
    FolderResponseDto restore(UUID userId, UUID id);
    void deleteForever(UUID userId, UUID id);

    Page<FolderResponseDto> list(UUID userId, Pageable pageable);
    Page<FolderResponseDto> listTrash(UUID userId, Pageable pageable);
    FolderResponseDto get(UUID userId, UUID id);
}