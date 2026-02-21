package com.fmahadybd.backend.controller;

import com.fmahadybd.backend.dto.ProfileDTO;
import com.fmahadybd.backend.dto.UpdateProfileDTO;
import com.fmahadybd.backend.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;

    /**
     * Get current user's profile from JWT token
     * The Authentication object is automatically populated by Spring Security
     */
    @GetMapping
    public ResponseEntity<ProfileDTO> getMyProfile(Authentication authentication) {
        String username = authentication.getName(); // Extract username from JWT
        ProfileDTO profile = profileService.getProfileByUsername(username);
        return ResponseEntity.ok(profile);
    }

    /**
     * Update current user's profile
     * Users can only update their own firstname, lastname, and password
     * Cannot change role, status, or username
     */
    @PutMapping
    public ResponseEntity<ProfileDTO> updateMyProfile(
            Authentication authentication,
            @RequestBody UpdateProfileDTO updateProfileDTO
    ) {
        String username = authentication.getName(); // Extract username from JWT
        ProfileDTO updatedProfile = profileService.updateProfile(username, updateProfileDTO);
        return ResponseEntity.ok(updatedProfile);
    }
}