package com.example.backend.services;

import com.example.backend.dtos.requests.LoginRequestDto;
import com.example.backend.dtos.requests.RegisterRequestDto;
import com.example.backend.dtos.responses.AuthResponseDto;

public interface AuthService {
    AuthResponseDto register(RegisterRequestDto dto);
    AuthResponseDto login(LoginRequestDto dto);
}
