package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.fmahadybd.backend.entity.DeletedUser;
import com.fmahadybd.backend.entity.User;
import com.fmahadybd.backend.repository.DeletedUserRepository;
import com.fmahadybd.backend.repository.UserRepository;
import jakarta.transaction.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class UserService {

    private final UserRepository userRepository;
    private final DeletedUserRepository deletedUserRepository;

    /** Create or update user */
    public User saveUser(User user) {
        return userRepository.save(user);
    }


    /** Get all users */
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }
     public List<DeletedUser> getAllDeletedUsers() {
        return deletedUserRepository.findAll();
    }


    /** Get user by ID */
    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    /** Get user by username */
    public Optional<User> getUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    /** Delete user by ID */
    // public void deleteUser(Long id) {
    // userRepository.deleteById(id);
    // }

    /** Delete user and store in deleted_users table */
    public void deleteUser(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + id));

        // Create DeletedUser object
        DeletedUser deletedUser = DeletedUser.builder()
                .originalUserId(user.getId())
                .username(user.getUsername())
                .password(user.getPassword())
                .role(user.getRole() != null ? user.getRole().name() : null)
                .referenceId(user.getReferenceId())
                .status(user.getStatus().name())
                .deletedAt(LocalDateTime.now())
                .build();

        // Save to deleted_users table
        deletedUserRepository.save(deletedUser);

        // Delete from users table
        userRepository.deleteById(id);
    }
    
}
