package com.fmahadybd.backend.service;

import com.fmahadybd.backend.dto.UserDTO;
import com.fmahadybd.backend.dto.UpdateUserDTO;
import com.fmahadybd.backend.entity.Role;
import com.fmahadybd.backend.entity.User;
import com.fmahadybd.backend.entity.UserStatus;
import com.fmahadybd.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public List<UserDTO> getAllUsers() {
        return userRepository.findAll()
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public UserDTO getUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + id));
        return convertToDTO(user);
    }

    public UserDTO updateUser(Long id, UpdateUserDTO updateUserDTO) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + id));

        // Update fields if provided
        if (updateUserDTO.getFirstname() != null) {
            user.setFirstname(updateUserDTO.getFirstname());
        }
        if (updateUserDTO.getLastname() != null) {
            user.setLastname(updateUserDTO.getLastname());
        }
        if (updateUserDTO.getUsername() != null) {
            user.setUsername(updateUserDTO.getUsername());
        }
        if (updateUserDTO.getPassword() != null && !updateUserDTO.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(updateUserDTO.getPassword()));
        }
        if (updateUserDTO.getRole() != null) {
            user.setRole(Role.valueOf(updateUserDTO.getRole()));
        }
        if (updateUserDTO.getStatus() != null) {
            user.setStatus(UserStatus.valueOf(updateUserDTO.getStatus()));
        }
        if (updateUserDTO.getReferenceId() != null) {
            user.setReferenceId(updateUserDTO.getReferenceId());
        }

        User updatedUser = userRepository.save(user);
        return convertToDTO(updatedUser);
    }

    public void deleteUser(Long id) {
        if (!userRepository.existsById(id)) {
            throw new RuntimeException("User not found with id: " + id);
        }
        userRepository.deleteById(id);
    }

    public UserDTO updateUserStatus(Long id, String status) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + id));
        
        user.setStatus(UserStatus.valueOf(status));
        User updatedUser = userRepository.save(user);
        return convertToDTO(updatedUser);
    }

    private UserDTO convertToDTO(User user) {
        return UserDTO.builder()
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