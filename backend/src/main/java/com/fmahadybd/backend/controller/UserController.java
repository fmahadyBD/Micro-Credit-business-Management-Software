package com.fmahadybd.backend.controller;

import com.fmahadybd.backend.entity.DeletedUser;
import com.fmahadybd.backend.entity.User;
import com.fmahadybd.backend.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/users")
@Tag(name = "users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    /** Create a new user with validation */
    @PostMapping
    @Operation(summary = "Create a new user")
    public ResponseEntity<?> createUser(@Valid @RequestBody User user, BindingResult result) {
        if (result.hasErrors()) {
            String errorMessage = result.getAllErrors().get(0).getDefaultMessage();
            return ResponseEntity.badRequest().body(errorMessage);
        }
        User savedUser = userService.saveUser(user);
        return ResponseEntity.ok(savedUser);
    }

    /** Get all users */
    @GetMapping
    @Operation(summary = "Get all users")
    public ResponseEntity<List<User>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    /** Get user by ID using orElseThrow */
    @GetMapping("/{id}")
    @Operation(summary = "Get user by ID")
    public ResponseEntity<?> getUserById(@PathVariable Long id) {
        try {
            User user = userService.getUserById(id)
                    .orElseThrow(() -> new RuntimeException("User not found with ID: " + id));
            return ResponseEntity.ok(user);
        } catch (RuntimeException e) {
            return ResponseEntity.status(404).body(e.getMessage());
        }
    }

    /** Update existing user with validation and orElseThrow */
    @PutMapping("/{id}")
    @Operation(summary = "Update existing user")
    public ResponseEntity<?> updateUser(@PathVariable Long id, @Valid @RequestBody User updatedUser,
            BindingResult result) {
        if (result.hasErrors()) {
            String errorMessage = result.getAllErrors().get(0).getDefaultMessage();
            return ResponseEntity.badRequest().body(errorMessage);
        }

        try {
            User existingUser = userService.getUserById(id)
                    .orElseThrow(() -> new RuntimeException("User not found with ID: " + id));

            existingUser.setUsername(updatedUser.getUsername());
            existingUser.setPassword(updatedUser.getPassword());
            existingUser.setRole(updatedUser.getRole());
            existingUser.setReferenceId(updatedUser.getReferenceId());
            existingUser.setStatus(updatedUser.getStatus());

            User savedUser = userService.saveUser(existingUser);
            return ResponseEntity.ok(savedUser);
        } catch (RuntimeException e) {
            return ResponseEntity.status(404).body(e.getMessage());
        }
    }

    /** Delete user by ID safely using orElseThrow */
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete user by ID (moves to deleted_users table)")
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
        try {
            userService.deleteUser(id);
            return ResponseEntity.ok("User deleted and stored in DeletedUser table successfully");
        } catch (RuntimeException e) {
            return ResponseEntity.status(404).body(e.getMessage());
        }
    }

    @GetMapping("/deleted")
    @Operation(summary = "Get all deleted users (deletion history)")
    public ResponseEntity<List<DeletedUser>> getDeletedUsers() {
        List<DeletedUser> deletedUsers = userService.getAllDeletedUsers();
        if (deletedUsers.isEmpty()) {
            return ResponseEntity.ok().body(List.of());
        }
        return ResponseEntity.ok(deletedUsers);
    }

}
