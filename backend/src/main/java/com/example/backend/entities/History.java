package com.example.backend.entities;

import java.time.Instant;
import java.util.UUID;

import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import com.example.backend.enums.HistoryAction;
import com.example.backend.enums.ItemType;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Table (name = "tb_history")
@NoArgsConstructor 
@AllArgsConstructor 
@Data 
@Entity 
public class History {
    @Id @GeneratedValue (strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne (fetch = FetchType.LAZY, optional = false)
    @JoinColumn (name = "user_id", nullable = false)
    @OnDelete (action = OnDeleteAction.CASCADE)
    private User user;

    @ManyToOne (fetch = FetchType.LAZY, optional = false)
    @JoinColumn (name = "folder_id")
    @OnDelete (action = OnDeleteAction.SET_NULL)
    private Folder folder;

    @ManyToOne (fetch = FetchType.LAZY, optional = false)
    @JoinColumn (name = "document_id")
    @OnDelete (action = OnDeleteAction.SET_NULL)
    private Document document;

    @Enumerated (EnumType.STRING)
    @Column (name = "item_type", nullable = false)
    private ItemType itemType;

    @Column (name = "folder_name", nullable = false)
    private String folderName;

    @Column (name = "document_name", nullable = false)
    private String documentName;

    @Column (name = "document_count")
    private Integer documentCount;

    @Enumerated (EnumType.STRING)
    @Column (name = "action", nullable = false)
    private HistoryAction action;

    @Column (name = "createdAt", updatable = false)
    private Instant createdAt;

    @PrePersist 
    void onCreate(){
        createdAt = Instant.now();
    }
    
}
