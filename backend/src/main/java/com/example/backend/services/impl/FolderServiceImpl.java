package com.example.backend.services.impl;

import java.time.Instant;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import com.example.backend.dtos.requests.FolderRequestDto;
import com.example.backend.dtos.responses.FolderResponseDto;
import com.example.backend.entities.Folder;
import com.example.backend.mappers.FolderMapper;
import com.example.backend.repositories.FolderRepository;
import com.example.backend.repositories.UserRepository;
import com.example.backend.services.FolderService;

import lombok.RequiredArgsConstructor;

@Service 
@RequiredArgsConstructor 
public class FolderServiceImpl implements FolderService {
    private final FolderMapper folderMapper;
    private final FolderRepository folderRepository;
    private final UserRepository userRepository;


    @Transactional 
    @Override 
    public FolderResponseDto create(UUID userId, FolderRequestDto dto){
        Folder folder = folderMapper.toEntity(dto);
        folder.setUser(userRepository.getReferenceById(userId));
        Folder saved = folderRepository.save(folder);
        return folderMapper.toResponseDto(saved);
    }

    @Transactional 
    @Override 
    public FolderResponseDto update(UUID userId,UUID id, FolderRequestDto dto){
        Folder folder = findActive(userId, id);
        folderMapper.toUpdate(dto, folder);
        return folderMapper.toResponseDto(folder);
     }

     @Transactional 
     @Override 
     public void moveToTrash(UUID userId, UUID id){
        Folder folder = findActive(userId, id);
        folder.setDeletedAt(Instant.now());
     }

     @Transactional 
     @Override 
     public FolderResponseDto restore(UUID userId, UUID id){
        Folder folder = findTrashed(userId, id);
        folder.setDeletedAt(null);
        return folderMapper.toResponseDto(folder);
     }

     @Transactional
     @Override 
     public void deleteForever(UUID userId, UUID id){
        Folder folder = findTrashed(userId, id);
        folderRepository.delete(folder);
     }


     @Transactional 
     @Override 
     public Page<FolderResponseDto> list(UUID userId, Pageable pageable){
        return folderRepository
            .findByUserIdAndDeletedAtIsNull(userId, pageable)
            .map(folderMapper::toResponseDto);
     }

     @Transactional 
     @Override 
     public Page<FolderResponseDto> listTrash(UUID userId, Pageable pageable){
        return folderRepository
            .findByUserIdAndDeletedAtIsNotNull(userId, pageable)
            .map(folderMapper::toResponseDto);
     }

     @Transactional 
     @Override 
     public FolderResponseDto get(UUID userId, UUID id){
        return folderMapper.toResponseDto(findActive(userId, id));
     }


    private Folder find(UUID userId, UUID id){
        return folderRepository
            .findByIdAndUserId(id, userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found!"));
    }
    private Folder findActive(UUID userId, UUID id){
        Folder folder = find(userId, id);
        if(folder.getDeletedAt() != null){
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found!");
        }
        return folder;
    }
    private Folder findTrashed(UUID userId, UUID id){
        Folder folder = find(userId, id);
        if(folder.getDeletedAt() == null){
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Trashed Folder not found!");
        }
        return folder;
    }
}
