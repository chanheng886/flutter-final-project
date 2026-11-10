package com.example.backend.dtos.requests;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record FolderRequestDto(
    @NotBlank (message = "Folder name is required!")
    @Size (max = 100, message = "Folder name must be less than 100 characters")
    String folderName
) {}
