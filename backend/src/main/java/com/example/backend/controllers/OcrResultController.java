package com.example.backend.controllers;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.example.backend.dtos.responses.OcrResultResponseDto;
import com.example.backend.entities.User;
import com.example.backend.services.OcrResultService;
import lombok.RequiredArgsConstructor;

@RestController 
@RequestMapping ("/api/v1/ocr_result")
@RequiredArgsConstructor 
public class OcrResultController {
    private final OcrResultService ocrResultService;

    @PostMapping ("/{docId}/scan")
    public ResponseEntity<OcrResultResponseDto> scanningDocument(@AuthenticationPrincipal User user, @PathVariable UUID docId){
        OcrResultResponseDto res = ocrResultService.scan(user.getId(), docId);
        return ResponseEntity.status(HttpStatus.CREATED).body(res);
    }

    @GetMapping ("/{docId}")
    public ResponseEntity<OcrResultResponseDto> get(@AuthenticationPrincipal User user,@PathVariable UUID docId){
        OcrResultResponseDto res = ocrResultService.get(user.getId(), docId);
        return ResponseEntity.ok(res);
    }
}