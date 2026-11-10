package com.example.backend.repositories;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import com.example.backend.entities.Folder;

public interface FolderRepository extends JpaRepository<Folder, UUID> {
    Folder findByUserIdAndId(UUID userId, UUID id);
    Folder findByUserIdAndFolderName(UUID userId, String folderName);
    Optional<Folder> findByIdAndUserId(UUID id, UUID userId);
    Page<Folder> findByUserIdAndDeletedAtIsNull(UUID userId, Pageable pageable);   
    Page<Folder> findByUserIdAndDeletedAtIsNotNull(UUID userId, Pageable pageable);
    List<Folder> findByDeletedAtBefore(Instant cutoff);
}