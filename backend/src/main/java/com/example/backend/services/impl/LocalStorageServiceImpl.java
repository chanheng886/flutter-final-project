package com.example.backend.services.impl;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import com.example.backend.services.StorageService;


@Service  
public class LocalStorageServiceImpl implements StorageService {
    private final Path rootDir;

    public LocalStorageServiceImpl(@Value ("${app.storage.root}") String root){
        this.rootDir = Paths.get(root).toAbsolutePath().normalize();
    }    

    @Override 
    public Path load(String relativePath){
        Path target = rootDir.resolve(relativePath).normalize();
        if(!target.startsWith(rootDir)){
            throw new IllegalArgumentException("Invalid Path");
        }
        return target;
    }

    @Override 
    public void delete(String relativePath){
        try{
            Files.deleteIfExists(load(relativePath));
        }catch(IOException e){
            throw new IllegalArgumentException("Could not delete file", e);
        }
    }

    private String getException(String fileName){
        if(fileName == null || !fileName.contains(".")){
            return "";
        }
        String ext = fileName.substring(fileName.lastIndexOf('.')).toLowerCase();
        return ext.matches("\\.[a-z0-9]{1,5}") ? ext : "";
    }

    @Override 
    public String save(MultipartFile file, String subDir){
        try{
            Path dir = rootDir.resolve(subDir).normalize();
        if(!dir.startsWith(rootDir)){
            throw new IllegalArgumentException("Invalid directory");
        }
        Files.createDirectories(dir);
        String fileName = UUID.randomUUID() + getException(file.getOriginalFilename());
        try(InputStream in = file.getInputStream()){
            Files.copy(in, dir.resolve(fileName));
        }
        return  subDir + "/" + fileName;
        } catch(IOException e){
            throw new IllegalArgumentException("Could not store file", e);
        }
    }
}