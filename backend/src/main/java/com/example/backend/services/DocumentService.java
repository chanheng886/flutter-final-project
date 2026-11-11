package com.example.backend.services;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import com.example.backend.dtos.requests.RenameDocumentRequestDto;
import com.example.backend.dtos.requests.UploadDocumentRequestDto;
import com.example.backend.dtos.responses.DocumentResponseDto;

public interface DocumentService {
    DocumentResponseDto upload(UUID userId,UUID folderId, UploadDocumentRequestDto dto);
    DocumentResponseDto rename(UUID userId, UUID docId, RenameDocumentRequestDto dto);
    void moveToTrash(UUID userId, UUID docId);
    DocumentResponseDto restore(UUID userId, UUID docId);
    void deleteForever(UUID userId, UUID docId);

    Page<DocumentResponseDto> list(UUID userId,UUID folderId, Pageable pageable);
    Page<DocumentResponseDto> listAll(UUID userId, Pageable pageable);
    Page<DocumentResponseDto> listTrashed(UUID userId, Pageable pageable);
    DocumentResponseDto get(UUID userId, UUID docId);
}
