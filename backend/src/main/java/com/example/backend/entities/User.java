package com.example.backend.entities;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import com.example.backend.enums.UserRoles;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Table (name = "tb_user")
@Entity 
@Data 
@NoArgsConstructor 
@AllArgsConstructor 
public class User implements UserDetails {
    @Id @GeneratedValue (strategy = GenerationType.UUID)
    private UUID id;

    @Column (unique = true)
    private String username;
    
    @Column (unique = true, nullable = false)
    private String email;

    @Column (unique = true)
    private String phone;

    @Column (name = "password_hash")
    private String passwordHash;
    
    @Enumerated (EnumType.STRING)
    private UserRoles role = UserRoles.USER;

    @Override 
    public Collection<? extends GrantedAuthority> getAuthorities(){
        return List.of(new SimpleGrantedAuthority("ROLE_" + role.name()));
    }

    @Override 
    public String getPassword(){
        return passwordHash;
    }

    @Override 
    public String getUsername(){
        return email;
    }

    public String getDisplayUsername(){
        return username;
    }
}