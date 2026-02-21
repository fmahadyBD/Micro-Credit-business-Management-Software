package com.fmahadybd.backend.auth;

import com.fmahadybd.backend.entity.Token;
import com.fmahadybd.backend.entity.TokenType;
import com.fmahadybd.backend.repository.TokenRepository;
import com.fmahadybd.backend.entity.Role;
import com.fmahadybd.backend.entity.User;
import com.fmahadybd.backend.entity.UserStatus;
import com.fmahadybd.backend.repository.UserRepository;
import com.fmahadybd.backend.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class AuthenticationService {

    private final UserRepository userRepository;
    private final TokenRepository tokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final Random random = new Random();

    @Transactional
    public void register(RegistrationRequest request) {
        // Check if user already exists with this email
        if (userRepository.findByUsername(request.getEmail()).isPresent()) {
            throw new IllegalStateException("User with email '" + request.getEmail() + "' already exists");
        }

        var user = User.builder()
                .firstname(request.getFirstname())
                .lastname(request.getLastname())
                .username(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(Role.USER)
                .referenceId(0L)
                .status(UserStatus.ACTIVE)
                .accountLocked(false)
                .enabled(true)
                .build();

        userRepository.save(user);
    }

    @Transactional
    public AuthenticationResponse authenticate(AuthenticationRequest request) {
        try {
            // Authenticate user credentials using email as username
            var auth = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getEmail(),
                            request.getPassword()
                    )
            );

            // Generate JWT token with claims
            var claims = new HashMap<String, Object>();
            var user = ((User) auth.getPrincipal());
            claims.put("username", user.getUsername());
            claims.put("role", user.getRole().name());
            claims.put("fullName", user.getFullName());
            // Add unique identifiers to prevent duplicate tokens
            claims.put("rnd", random.nextLong());
            claims.put("ts", System.currentTimeMillis());

            var jwtToken = jwtService.generateToken(claims, user);
            
            // Revoke all existing tokens for this user
            revokeAllUserTokens(user);
            
            // Save the new token
            saveUserToken(user, jwtToken);
            
            return AuthenticationResponse.builder()
                    .token(jwtToken)
                    .build();
                    
        } catch (BadCredentialsException e) {
            throw new BadCredentialsException("Invalid email or password");
        } catch (UsernameNotFoundException e) {
            throw new UsernameNotFoundException("User not found with email: " + request.getEmail());
        }
    }

    private void saveUserToken(User user, String jwtToken) {
        // First, check if there's already a valid token for this user and update it
        var existingValidTokens = tokenRepository.findAllValidTokensByUser(user.getId());
        
        if (!existingValidTokens.isEmpty()) {
            // Update the first valid token instead of creating a new one
            var existingToken = existingValidTokens.get(0);
            existingToken.setToken(jwtToken);
            existingToken.setExpired(false);
            existingToken.setRevoked(false);
            tokenRepository.save(existingToken);
            
            // Revoke any additional valid tokens (shouldn't happen, but just in case)
            if (existingValidTokens.size() > 1) {
                for (int i = 1; i < existingValidTokens.size(); i++) {
                    var extraToken = existingValidTokens.get(i);
                    extraToken.setExpired(true);
                    extraToken.setRevoked(true);
                }
                tokenRepository.saveAll(existingValidTokens.subList(1, existingValidTokens.size()));
            }
        } else {
            // Create new token if no valid tokens exist
            var token = Token.builder()
                    .user(user)
                    .token(jwtToken)
                    .tokenType(TokenType.BEARER)
                    .expired(false)
                    .revoked(false)
                    .build();
            tokenRepository.save(token);
        }
    }

    private void revokeAllUserTokens(User user) {
        var validUserTokens = tokenRepository.findAllValidTokensByUser(user.getId());
        if (validUserTokens.isEmpty()) return;
        
        validUserTokens.forEach(token -> {
            token.setExpired(true);
            token.setRevoked(true);
        });
        
        tokenRepository.saveAll(validUserTokens);
    }
}