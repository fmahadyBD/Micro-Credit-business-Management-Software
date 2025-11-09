package com.fmahadybd.backend.controller;

import com.fmahadybd.backend.dto.UserDTO;
import com.fmahadybd.backend.dto.UpdateUserDTO;
import com.fmahadybd.backend.entity.User;
import com.fmahadybd.backend.entity.UserStatus;
import com.fmahadybd.backend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    // ✅ Get all users - Only ADMIN can access
    @GetMapping
    // @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<UserDTO>> getAllUsers() {
        List<UserDTO> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }

    // ✅ Get one user - ADMIN or the user themselves
    @GetMapping("/{id}")
    // @PreAuthorize("hasRole('ADMIN') or @userSecurity.isOwnProfile(authentication, #id)")
    public ResponseEntity<UserDTO> getUserById(@PathVariable Long id) {
        UserDTO user = userService.getUserById(id);
        return ResponseEntity.ok(user);
    }

    // ✅ Update user - ADMIN or the user themselves
    @PutMapping("/{id}")
    // @PreAuthorize("hasRole('ADMIN') or @userSecurity.isOwnProfile(authentication, #id)")
    public ResponseEntity<UserDTO> updateUser(@PathVariable Long id, @RequestBody UpdateUserDTO updateUserDTO) {
        UserDTO updatedUser = userService.updateUser(id, updateUserDTO);
        return ResponseEntity.ok(updatedUser);
    }

    // ✅ Delete - Only ADMIN
    @DeleteMapping("/{id}")
    // @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }

    // ✅ Update status - Only ADMIN
    @PatchMapping("/{id}/status")
    // @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserDTO> updateStatus(
            @PathVariable Long id,
            @RequestParam("status") String status
    ) {
        UserDTO updatedUser = userService.updateUserStatus(id, status);
        return ResponseEntity.ok(updatedUser);
    }
}