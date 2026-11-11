package com.example.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.client.RestTemplate;

import com.example.backend.repositories.UserRepository;

@Configuration 
public class BeanConfig {
    @Bean 
    public PasswordEncoder passwordEncoder(){
        return new BCryptPasswordEncoder();
    }

    @Bean 
    public UserDetailsService userDetailService(UserRepository userRepository){
        return identifier -> userRepository
            .findByEmailIgnoreCaseOrUsernameIgnoreCase(identifier, identifier)
            .orElseThrow(() -> new UsernameNotFoundException("User not found!"));
    }

    @Bean
    public RestTemplate restTemplate(){
        return new RestTemplate();
    }
}
