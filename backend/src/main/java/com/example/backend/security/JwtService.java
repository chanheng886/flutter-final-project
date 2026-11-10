package com.example.backend.security;
import java.util.Date;
import java.util.UUID;
import java.util.function.Function;

import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

@Service 
public class JwtService {
    @Value ("${application.security.jwt.secret-key}")
    private String secretKey;

    @Value ("${application.security.jwt.expiration}")
    private long jwtExpiration;

    public String generateToken(UUID id, String email, String username){
        return Jwts.builder()
            .subject(id.toString())
            .claim("email", email)
            .claim("username", username)
            .issuedAt(new Date(System.currentTimeMillis()))
            .expiration(new Date(System.currentTimeMillis() + jwtExpiration))
            .signWith(getSigningKey())
            .compact();
    }

    public UUID extractUserId(String token){
        return UUID.fromString(extractClaim(token, Claims::getSubject));
    }

    public String extractEmail(String token){
        return extractClaim(token, claims -> claims.get("email", String.class));
    }

    public String extractUsername(String token){
        return extractClaim(token, claims -> claims.get("username", String.class));
    }

    private boolean isTokenExpired(String token){
        return extractClaim(token, Claims::getExpiration).before(new Date());
    }

    public boolean isTokenValid(String token, UserDetails userDetails){
        final String email = extractEmail(token);
        return (email.equals(userDetails.getUsername())) && !isTokenExpired(token);
    }

    public boolean isTokenValid(String token){
        return !isTokenExpired(token);
    }
    
    // Extract cliams one by one
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver){
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    // Extract all claims
    private Claims extractAllClaims(String token){
        return Jwts.parser()
            .verifyWith(getSigningKey())
            .build()
            .parseSignedClaims(token)
            .getPayload();
    }

    private SecretKey getSigningKey(){
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
