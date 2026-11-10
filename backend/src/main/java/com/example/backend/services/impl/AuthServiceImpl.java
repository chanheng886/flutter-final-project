package com.example.backend.services.impl;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import com.example.backend.dtos.requests.LoginRequestDto;
import com.example.backend.dtos.requests.RegisterRequestDto;
import com.example.backend.dtos.responses.AuthResponseDto;
import com.example.backend.entities.User;
import com.example.backend.mappers.UserMapper;
import com.example.backend.repositories.UserRepository;
import com.example.backend.security.JwtService;
import com.example.backend.services.AuthService;

import lombok.RequiredArgsConstructor;

@Service 
@RequiredArgsConstructor 
public class AuthServiceImpl implements AuthService {
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    

    @Transactional 
    @Override 
    public AuthResponseDto register(RegisterRequestDto dto){
        if(userRepository.existsByEmailIgnoreCase(dto.email())){
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email is already exists, please take another email!");
        }
        if(dto.phone() != null && userRepository.existsByPhone(dto.phone())){
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Phone is already exists, please try antoher phone!");
        }
        if(dto.username() != null && userRepository.existsByUsernameIgnoreCase(dto.username())){
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Username is already taken!");
        }

        User user = userMapper.toEntity(dto);
        user.setPasswordHash(passwordEncoder.encode(dto.passwordHash()));
        User saved = userRepository.save(user);

        return authBuild(saved);
    }

    @Transactional (readOnly = true) 
    @Override 
    public AuthResponseDto login(LoginRequestDto dto){
        User user = userRepository
            .findByEmailIgnoreCaseOrUsernameIgnoreCase(dto.identifier(), dto.identifier())
            .filter(u -> passwordEncoder.matches(dto.password(), u.getPasswordHash()))
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Ivalid email or password, please try again!"));
        
        return authBuild(user);
    }

    private AuthResponseDto authBuild(User user){
        String token = jwtService.generateToken(user.getId(), user.getEmail(), user.getUsername());
        return new AuthResponseDto(token, userMapper.toResponse(user));
    }
}