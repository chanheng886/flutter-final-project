package com.example.backend.controllers;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.example.backend.dtos.requests.RenameDocumentRequestDto;
import com.example.backend.dtos.requests.UploadDocumentRequestDto;
import com.example.backend.dtos.responses.DocumentResponseDto;
import com.example.backend.entities.User;
import com.example.backend.services.DocumentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RequestMapping ("/api/v1/documents")
@RequiredArgsConstructor 
@RestController 
public class DocumentController {
    private final DocumentService documentService;

    @GetMapping
    public ResponseEntity<Page<DocumentResponseDto>> listAllDocuments(
        @AuthenticationPrincipal User user,
        Pageable pageable
    ){
        Page<DocumentResponseDto> res = documentService.listAll(user.getId(), pageable);
        return ResponseEntity.ok(res);
    }

    @PostMapping (value = "/folders/{folderId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<DocumentResponseDto> uploadImage(
        @AuthenticationPrincipal User user, 
        @PathVariable UUID folderId,
        @Valid @ModelAttribute UploadDocumentRequestDto dto
    ){
        DocumentResponseDto res = documentService.upload(user.getId(), folderId, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(res);
    }

    @PatchMapping ("/{docId}")
    public ResponseEntity<DocumentResponseDto> renameDocument(
        @AuthenticationPrincipal User user,
        @PathVariable UUID docId,
        @Valid @RequestBody RenameDocumentRequestDto dto
    ){
        DocumentResponseDto res = documentService.rename(user.getId(), docId, dto);
        return ResponseEntity.ok(res);
    }

    @PostMapping ("/{docId}/restore")
    public ResponseEntity<DocumentResponseDto> restoreDocument(
        @AuthenticationPrincipal User user,
        @PathVariable UUID docId
    ){
        DocumentResponseDto res = documentService.restore(user.getId(), docId);
        return ResponseEntity.ok(res);
    }

    @DeleteMapping ("/{docId}")
    public ResponseEntity<Void> deleteDocumentForever(
        @AuthenticationPrincipal User user,
        @PathVariable UUID docId){
        documentService.deleteForever(user.getId(), docId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping ("/{docId}/trash")
    public ResponseEntity<Void> moveDocumentToTrash(
        @AuthenticationPrincipal User user,
        @PathVariable UUID docId
    ){
        documentService.moveToTrash(user.getId(), docId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping ("/folders/{folderId}")
    public ResponseEntity<Page<DocumentResponseDto>> listAllDocument(
        @AuthenticationPrincipal User user,
        @PathVariable UUID folderId, 
        Pageable pageable
    ){
        Page<DocumentResponseDto> res = documentService.list(user.getId(), folderId, pageable);
        return ResponseEntity.ok(res);
    } 

    @GetMapping ("/trash")
    public ResponseEntity<Page<DocumentResponseDto>> listDocumentTrashed(
        @AuthenticationPrincipal User user, 
        Pageable pageable
    ){
        Page<DocumentResponseDto> res = documentService.listTrashed(user.getId(), pageable);
        return ResponseEntity.ok(res);
    }

    @GetMapping ("/{docId}")
    public ResponseEntity<DocumentResponseDto> getDocumentById(
        @AuthenticationPrincipal User user,
        @PathVariable UUID docId
    ){
        DocumentResponseDto res = documentService.get(user.getId(), docId);
        return ResponseEntity.ok(res);
    }
}
