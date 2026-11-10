package com.example.backend.repositories;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import com.example.backend.entities.Document;

public interface DocumentRepository extends JpaRepository<Document, UUID> {
    Optional<Document> findByIdAndFolderUserId(UUID id, UUID userId);
    Page<Document> findByFolderIdAndDeletedAtIsNull(UUID folderId, Pageable pageable);
    Page<Document> findByFolderUserIdAndDeletedAtIsNotNull(UUID userId, Pageable pageable);
    List<Document> findByFolderId(UUID folderId);
    long countByFolderIdAndDeletedAtIsNull(UUID folderId);
}