package com.example.backend.repositories;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import com.example.backend.entities.OcrResult;

public interface OcrResultRepository extends JpaRepository<OcrResult, UUID> {
        Optional<OcrResult> findByDocumentIdAndDocumentFolderUserId(UUID documentId, UUID userId);
}