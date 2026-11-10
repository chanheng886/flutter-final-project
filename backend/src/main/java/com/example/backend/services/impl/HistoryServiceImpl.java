package com.example.backend.services.impl;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.server.ResponseStatusException;

import com.example.backend.dtos.responses.HistoryResponseDto;
import com.example.backend.entities.Document;
import com.example.backend.entities.Folder;
import com.example.backend.entities.History;
import com.example.backend.enums.HistoryAction;
import com.example.backend.enums.ItemType;
import com.example.backend.mappers.HistoryMapper;
import com.example.backend.repositories.HistoryRepository;
import com.example.backend.repositories.UserRepository;
import com.example.backend.services.HistoryService;

import lombok.RequiredArgsConstructor;

@Service 
@RequiredArgsConstructor 
public class HistoryServiceImpl implements HistoryService {
    private final HistoryRepository historyRepository;
    private final UserRepository userRepository;
    private final HistoryMapper historyMapper;

    @Transactional 
    @Override 
    public void recordFolder(UUID userId, Folder folder, HistoryAction action){
        History h = new History();
        h.setUser(userRepository.getReferenceById(userId));
        h.setItemType(ItemType.FOLDER);
        h.setAction(action);
        h.setFolderName(folder.getFolderName());
        h.setDocumentCount(folder.getDocCount());
        if(action != HistoryAction.DELETED){
            h.setFolder(folder);
        }
        historyRepository.save(h);
    }

    @Transactional 
    @Override 
    public void recordDocument(UUID userId, Document doc, HistoryAction action){
        Folder folder = doc.getFolder();
        History h = new History();
        h.setUser(userRepository.getReferenceById(userId));
        h.setItemType(ItemType.DOCUMENT);
        h.setAction(action);
        h.setFolderName(folder.getFolderName());
        h.setDocumentName(doc.getDocName());
        h.setFolder(folder);
        if(action != HistoryAction.DELETED){
            h.setDocument(doc);
        }
        historyRepository.save(h);
    }  

    @Transactional (readOnly = true)
    @Override 
    public Page<HistoryResponseDto> list(UUID userId, Pageable pageable){
        return historyRepository
            .findByUserIdOrderByCreatedAtDesc(userId, pageable)
            .map(historyMapper::toResponse);
     }
    
}
