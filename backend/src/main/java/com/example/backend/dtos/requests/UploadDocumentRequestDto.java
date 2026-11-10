package com.example.backend.dtos.requests;
import org.springframework.web.multipart.MultipartFile;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record UploadDocumentRequestDto(
    @NotNull (message = "Image is requried!")   MultipartFile file,
    @NotBlank (message = "Document name is required!") @Size (max = 255, message = "Document name must be less than 255 digits") String docName,
    @NotBlank @Pattern (regexp = "km|en|km\\+en", message = "Language must be Khmer or English or Khmer + English") String language
) {}