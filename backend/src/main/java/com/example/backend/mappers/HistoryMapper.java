package com.example.backend.mappers;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;
import org.mapstruct.MappingConstants.ComponentModel;
import com.example.backend.dtos.responses.HistoryResponseDto;
import com.example.backend.entities.History;

@Mapper (
     componentModel = ComponentModel.SPRING,
     unmappedSourcePolicy = ReportingPolicy.IGNORE
)
public interface HistoryMapper {
    @Mapping (source = "folder.id", target = "folderId")
    @Mapping (source = "document.id", target = "documentId")
    HistoryResponseDto toResponse(History history);
}
