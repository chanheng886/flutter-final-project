package com.example.backend.repositories;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import com.example.backend.entities.History;

public interface HistoryRepository extends JpaRepository<History, UUID> {
    Page<History> findByUserIdOrderByCreatedAtDesc(UUID userId, Pageable pageable);
}