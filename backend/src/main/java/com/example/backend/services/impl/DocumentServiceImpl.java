package com.example.backend.services.impl;
import java.time.Instant;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import com.example.backend.dtos.requests.RenameDocumentRequestDto;
import com.example.backend.dtos.requests.UploadDocumentRequestDto;
import com.example.backend.dtos.responses.DocumentResponseDto;
import com.example.backend.entities.Document;
import com.example.backend.entities.Folder;
import com.example.backend.mappers.DocumentMapper;
import com.example.backend.repositories.DocumentRepository;
import com.example.backend.repositories.FolderRepository;
import com.example.backend.services.DocumentService;
import com.example.backend.services.StorageService;
import lombok.RequiredArgsConstructor;

@Service 
@RequiredArgsConstructor 
public class DocumentServiceImpl implements DocumentService {
    private final DocumentMapper documentMapper;
    private final FolderRepository folderRepository;
    private final DocumentRepository documentRepository;
    private final StorageService storageService;

    @Transactional
    @Override 
    public DocumentResponseDto upload(UUID userId,UUID folderId, UploadDocumentRequestDto dto){
        Folder folder = findOwnFolder(userId, folderId);
        
        if(folder.getDeletedAt() != null){
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Folder is in trash");
        }
        validateImage(dto.file());
        String imagePath = storageService.save(dto.file(), "document");
        try{
            Document doc = new Document();
            doc.setFolder(folder);
            doc.setDocName(dto.docName());
            doc.setLanguage(dto.language());
            doc.setImagePath(imagePath);
            
            documentRepository.saveAndFlush(doc);
            
            folder.setDocCount(folder.getDocCount() + 1);
            return  documentMapper.toResponse(doc);
            
        }catch(RuntimeException e){
            try{
                storageService.delete(imagePath);
            }catch(RuntimeException ignore){

            }
            throw e;
        }
    }

    @Transactional 
    @Override 
    public void moveToTrash(UUID userId, UUID docId){
        Document doc = findOwnDocument(userId, docId);
        if(doc.getDeletedAt() != null){
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Document is in trash");
        }
        doc.setDeletedAt(Instant.now());
        Folder folder = doc.getFolder();
        folder.setDocCount(Math.max(0, folder.getDocCount() -1));
    }
    
    @Transactional 
    @Override 
    public DocumentResponseDto restore(UUID userId, UUID docId){
        Document doc = findOwnDocument(userId, docId);
        if(doc.getDeletedAt() == null){
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Document is not in trash");
        }
        Folder folder  = doc.getFolder();
        if(folder.getDeletedAt() != null){
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Restore the folder first");
        }
        doc.setDeletedAt(null);
        folder.setDocCount(folder.getDocCount() + 1);
        return documentMapper.toResponse(doc);
    }

    @Transactional 
    @Override 
    public DocumentResponseDto rename(UUID userId, UUID docId, RenameDocumentRequestDto dto){
        Document doc = findOwnDocument(userId, docId);
        doc.setDocName(dto.docName());
        return documentMapper.toResponse(doc);
    }

    @Transactional 
    @Override 
    public void deleteForever(UUID userId, UUID docId){
        Document doc = findOwnDocument(userId, docId);
        if(doc.getDeletedAt() == null){
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Move document to trash first, before delete the document forever");
        }
        String imagePath = doc.getImagePath();
        documentRepository.delete(doc);
        storageService.delete(imagePath);
    }

    @Transactional (readOnly = true) 
    @Override 
    public Page<DocumentResponseDto> list(UUID userId,UUID folderId, Pageable pageable){
        findOwnFolder(userId, folderId);
        return documentRepository.findByFolderIdAndDeletedAtIsNull(folderId, pageable)
            .map(documentMapper::toResponse);
    }

    @Transactional (readOnly = true)
    @Override
    public Page<DocumentResponseDto> listAll(UUID userId, Pageable pageable){
        return documentRepository.findByFolderUserIdAndDeletedAtIsNull(userId, pageable)
            .map(documentMapper::toResponse);
    }

    @Transactional (readOnly = true)
    @Override 
    public Page<DocumentResponseDto> listTrashed(UUID userId, Pageable pageable){
        return documentRepository.findByFolderUserIdAndDeletedAtIsNotNull(userId, pageable)
            .map(documentMapper::toResponse);
    }

    @Transactional (readOnly = true)
    @Override 
    public DocumentResponseDto get(UUID userId, UUID docId){
        return documentMapper.toResponse(findOwnDocument(userId, docId));
    }

    
    private void validateImage(MultipartFile file){
        if(file == null || file.isEmpty()){
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "File is empty");
        }
    }

    private Folder findOwnFolder(UUID userId, UUID folderId){
        return folderRepository.findByIdAndUserId(folderId, userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found!"));
    }
    private Document findOwnDocument(UUID userId, UUID docId){
        return documentRepository.findByIdAndFolderUserId(docId, userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Document not found!"));
    }   
}