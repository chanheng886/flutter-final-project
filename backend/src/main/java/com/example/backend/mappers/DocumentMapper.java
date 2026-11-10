package com.example.backend.mappers;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants;
import org.mapstruct.ReportingPolicy;

import com.example.backend.dtos.responses.DocumentResponseDto;
import com.example.backend.entities.Document;

@Mapper (
    componentModel = MappingConstants.ComponentModel.SPRING,
    unmappedSourcePolicy = ReportingPolicy.IGNORE
)
public interface DocumentMapper {
    @Mapping (source = "folder.id", target = "folderId")
    DocumentResponseDto toResponse(Document document);   
}
