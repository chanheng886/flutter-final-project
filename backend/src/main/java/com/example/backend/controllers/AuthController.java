package com.example.backend.controllers;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.example.backend.dtos.requests.LoginRequestDto;
import com.example.backend.dtos.requests.RegisterRequestDto;
import com.example.backend.dtos.responses.AuthResponseDto;
import com.example.backend.services.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController  
@RequiredArgsConstructor 
@RequestMapping ("/api/v1/auth")
public class AuthController {
    private final AuthService authService;

    @PostMapping ("/register")
    public ResponseEntity<AuthResponseDto> userRegister(@Valid @RequestBody RegisterRequestDto dto){
        AuthResponseDto res = authService.register(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(res);
    }

    @PostMapping ("/login")
    public ResponseEntity<AuthResponseDto> userLogin(@Valid @RequestBody LoginRequestDto dto){
        AuthResponseDto res = authService.login(dto);
        return ResponseEntity.ok(res);
    }
}