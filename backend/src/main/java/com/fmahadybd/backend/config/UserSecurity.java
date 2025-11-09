package com.fmahadybd.backend.config;

import com.fmahadybd.backend.entity.User;
import com.fmahadybd.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

@Component("userSecurity")
@RequiredArgsConstructor
public class UserSecurity {

    private final UserRepository userRepository;

    public boolean isOwnProfile(Authentication authentication, Long userId) {
        String currentUsername = authentication.getName();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return user.getUsername().equals(currentUsername);
    }
}