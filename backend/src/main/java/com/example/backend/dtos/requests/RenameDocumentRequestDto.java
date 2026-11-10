package com.example.backend.dtos.requests;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RenameDocumentRequestDto(
    @NotBlank (message = "Document name is required!")
    @Size (max = 255, message = "Document name is too long")
    String docName
) {}