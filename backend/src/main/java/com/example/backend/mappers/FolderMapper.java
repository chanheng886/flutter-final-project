package com.example.backend.mappers;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants;
import org.mapstruct.MappingTarget;
import org.mapstruct.ReportingPolicy;
import com.example.backend.dtos.requests.FolderRequestDto;
import com.example.backend.dtos.responses.FolderResponseDto;
import com.example.backend.entities.Folder;

@Mapper (
    componentModel = MappingConstants.ComponentModel.SPRING,
    unmappedSourcePolicy = ReportingPolicy.IGNORE
)
public interface FolderMapper {
    @BeanMapping (ignoreByDefault = true)
    @Mapping (source = "folderName", target = "folderName")
    Folder toEntity(FolderRequestDto dto);    

    @BeanMapping (ignoreByDefault = true)
    @Mapping (source = "folderName", target = "folderName")
    void toUpdate(FolderRequestDto dto, @MappingTarget Folder folder);
    FolderResponseDto toResponseDto(Folder folder);
}