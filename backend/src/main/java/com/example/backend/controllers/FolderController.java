package com.example.backend.controllers;
import java.util.UUID;

import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.example.backend.dtos.requests.FolderRequestDto;
import com.example.backend.dtos.responses.FolderResponseDto;
import com.example.backend.entities.User;
import com.example.backend.services.FolderService;
import lombok.RequiredArgsConstructor;

@RestController 
@RequiredArgsConstructor 
@RequestMapping ("/api/v1/folder")
public class FolderController {
    private final FolderService folderService;

    @PostMapping 
    public ResponseEntity<FolderResponseDto> createFolder(@AuthenticationPrincipal User user, @RequestBody FolderRequestDto dto){
        FolderResponseDto res = folderService.create(user.getId(), dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(res);
    }

    @PatchMapping ("/{folderId}")
    public ResponseEntity<FolderResponseDto> renameFolder(@AuthenticationPrincipal User user, @PathVariable UUID folderId, @RequestBody FolderRequestDto dto){
        FolderResponseDto res = folderService.update(user.getId(), folderId, dto);
        return ResponseEntity.ok(res);
    }

    @DeleteMapping ("/{folderId}/trash") 
    public ResponseEntity<Void> moveFolderToTrash(@AuthenticationPrincipal User user,@PathVariable UUID folderId){
         folderService.moveToTrash(user.getId(), folderId);
         return ResponseEntity.noContent().build();
    }

    @PostMapping ("/{folderId}/restore")
    public ResponseEntity<FolderResponseDto> restoreFolder(@AuthenticationPrincipal User user, @PathVariable UUID folderId){
        FolderResponseDto res = folderService.restore(user.getId(), folderId);
        return ResponseEntity.status(HttpStatus.CREATED).body(res);
    }

    @PostMapping ("/{folderId}")
    public ResponseEntity<Void> deleteFolderForever(@AuthenticationPrincipal User user,@PathVariable UUID folderId){
        folderService.deleteForever(user.getId(), folderId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping 
    public ResponseEntity<Page<FolderResponseDto>> getAllFolder(
        @AuthenticationPrincipal User user,
        @ParameterObject 
        @PageableDefault (
            size = 20, sort = "createdAt", 
            direction = Sort.Direction.DESC) Pageable pageable){
        Page<FolderResponseDto> res = folderService.list(user.getId(), pageable);
        return ResponseEntity.ok(res);
    }

    @GetMapping ("/trash") 
    public ResponseEntity<Page<FolderResponseDto>> getTrashedFolder(@AuthenticationPrincipal User user,@PageableDefault (size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable){
        Page<FolderResponseDto> res = folderService.list(user.getId(), pageable);
        return ResponseEntity.ok(res);
    } 

    @GetMapping ("/{folderId}")
    public ResponseEntity<FolderResponseDto> getFolder(@AuthenticationPrincipal User user, @PathVariable UUID folderId){
        FolderResponseDto res = folderService.get(user.getId(), folderId);
        return ResponseEntity.ok(res);
    }
}
