package com.example.backend.services;

import java.nio.file.Path;

import org.springframework.web.multipart.MultipartFile;

public interface StorageService {
    String save(MultipartFile file, String subDir);
    void delete(String relativePath);   
    Path load(String relativePath);
}
