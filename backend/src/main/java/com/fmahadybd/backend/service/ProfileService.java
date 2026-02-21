package com.fmahadybd.backend.service;

import com.fmahadybd.backend.dto.ProfileDTO;
import com.fmahadybd.backend.dto.UpdateProfileDTO;
import com.fmahadybd.backend.entity.User;
import com.fmahadybd.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    /**
     * Get user profile by username (extracted from JWT token)
     */
    public ProfileDTO getProfileByUsername(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found with username: " + username));
        
        return convertToProfileDTO(user);
    }

    /**
     * Update user's own profile
     * Users can only update: firstname, lastname, and password
     * Cannot change: role, status, username, referenceId
     */
    public ProfileDTO updateProfile(String username, UpdateProfileDTO updateProfileDTO) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found with username: " + username));

        // Update firstname if provided
        if (updateProfileDTO.getFirstname() != null && !updateProfileDTO.getFirstname().trim().isEmpty()) {
            user.setFirstname(updateProfileDTO.getFirstname().trim());
        }

        // Update lastname if provided
        if (updateProfileDTO.getLastname() != null && !updateProfileDTO.getLastname().trim().isEmpty()) {
            user.setLastname(updateProfileDTO.getLastname().trim());
        }

        // Update password if provided
        if (updateProfileDTO.getPassword() != null && !updateProfileDTO.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(updateProfileDTO.getPassword()));
        }

        User updatedUser = userRepository.save(user);
        return convertToProfileDTO(updatedUser);
    }

    /**
     * Convert User entity to ProfileDTO
     */
    private ProfileDTO convertToProfileDTO(User user) {
        return ProfileDTO.builder()
                .id(user.getId())
                .firstname(user.getFirstname())
                .lastname(user.getLastname())
                .username(user.getUsername())
                .role(user.getRole().name())
                .status(user.getStatus().name())
                .referenceId(user.getReferenceId())
                .createdDate(user.getCreatedDate())
                .lastModifiedDate(user.getLastModifiedDate())
                .build();
    }
}