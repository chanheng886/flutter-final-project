package com.example.backend.repositories;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import com.example.backend.entities.User;

public interface UserRepository extends JpaRepository<User, UUID> {
    boolean existsByEmailIgnoreCase(String email);
    boolean existsByUsernameIgnoreCase(String username);
    boolean existsByPhone(String phone);

    Optional<User> findByEmailIgnoreCaseOrUsernameIgnoreCase(String email, String username);
}