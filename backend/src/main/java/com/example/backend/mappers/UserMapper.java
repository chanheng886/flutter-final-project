package com.example.backend.mappers;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants;
import org.mapstruct.ReportingPolicy;
import com.example.backend.dtos.requests.RegisterRequestDto;
import com.example.backend.dtos.responses.UserResponseDto;
import com.example.backend.entities.User;

@Mapper (
    componentModel = MappingConstants.ComponentModel.SPRING,
    unmappedSourcePolicy = ReportingPolicy.IGNORE
)
public interface UserMapper {
    @Mapping (target = "id", ignore = true)
    @Mapping (target = "role", ignore = true)
    @Mapping (target = "passwordHash", ignore = true)
    User toEntity(RegisterRequestDto dto);
    @Mapping (source = "displayUsername", target = "username")
    UserResponseDto toResponse(User user);
}