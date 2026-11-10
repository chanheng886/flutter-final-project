package com.example.backend.mappers;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;
import org.mapstruct.MappingConstants.ComponentModel;

import com.example.backend.dtos.responses.OcrResultResponseDto;
import com.example.backend.entities.OcrResult;

@Mapper (
    componentModel = ComponentModel.SPRING,
    unmappedSourcePolicy = ReportingPolicy.IGNORE
)
public interface OcrResultMapper {
    @Mapping (source = "document.id", target = "documentId")
    OcrResultResponseDto toResponse(OcrResult ocrResult);    
}
