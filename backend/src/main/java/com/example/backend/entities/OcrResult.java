package com.example.backend.entities;

import java.sql.SQLType;
import java.time.Instant;
import java.util.UUID;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import org.hibernate.type.SqlTypes;
import org.hibernate.type.format.jakartajson.JsonBJsonFormatMapper;
import io.swagger.v3.core.util.Json;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Table (name = "tb_ocr_result")
@NoArgsConstructor 
@AllArgsConstructor 
@Entity 
@Data
public class OcrResult {
    @Id @GeneratedValue (strategy = GenerationType.UUID)    
    private UUID id;

    @OneToOne (fetch = FetchType.LAZY)
    @JoinColumn (name = "document_id", nullable = false, unique = true)
    @OnDelete (action = OnDeleteAction.CASCADE)
    private Document document;

    @Column (name = "raw_text", columnDefinition = "text", nullable = false)
    private String rawText;

    @Column (name = "ai_corrected_text", columnDefinition = "text")
    private String aiCorrectedText;

    @JdbcTypeCode (SqlTypes.JSON)
    @Column (name = "bounding_box", columnDefinition = "jsonb")
    private String boundingBox;

    @Column (name = "confidence_score", nullable = false)
    private double confidenceScore;

    @Column (name = "engine_used")
    private String engineUsed;

    @Column (name = "ocr_latency_ms")
    private Integer ocrLatencyMs;

    @Column (name = "created_at", updatable=false, nullable = false)
    private Instant createdAt;

    @Column (name = "updated_at", nullable = false)
    private Instant updatedAt;

    @PrePersist 
    void onCreate(){
        createdAt = Instant.now();
        updatedAt = createdAt;
    }

    @PreUpdate 
    void onUpdate(){
        updatedAt = Instant.now();
    }
}
