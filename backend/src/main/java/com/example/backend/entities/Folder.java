package com.example.backend.entities;
import java.time.Instant;
import java.util.UUID;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Table (name = "tb_folder")
@Entity 
@NoArgsConstructor 
@AllArgsConstructor 
@Data 
public class Folder {
    @Id @GeneratedValue (strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne (fetch = FetchType.LAZY)
    @JoinColumn (name = "user_id", nullable = false)
    @OnDelete (action = OnDeleteAction.CASCADE)
    private User user;

    @Column (name = "folder_name")
    private String folderName;

    @Column (name = "doc_count", nullable = false)
    private int docCount;

    @Column (name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column (name = "updated_at")
    private Instant updatedAt;

    @Column (name = "deleted_at")
    private Instant deletedAt;

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
