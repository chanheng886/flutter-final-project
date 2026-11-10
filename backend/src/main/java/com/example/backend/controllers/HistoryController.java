package com.example.backend.controllers;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.example.backend.dtos.responses.HistoryResponseDto;
import com.example.backend.entities.Document;
import com.example.backend.entities.Folder;
import com.example.backend.entities.User;
import com.example.backend.enums.HistoryAction;
import com.example.backend.services.HistoryService;
import lombok.RequiredArgsConstructor;

@RestController 
@RequestMapping ("/api/v1/history")
@RequiredArgsConstructor 
public class HistoryController {
    private final HistoryService historyService;
    @GetMapping 
    public ResponseEntity<Page<HistoryResponseDto>> list(@AuthenticationPrincipal User user,Pageable pageable){
        return ResponseEntity.ok(historyService.list(user.getId(), pageable));
    }
}