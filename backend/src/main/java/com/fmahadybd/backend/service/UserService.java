package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import com.fmahadybd.backend.entity.User;
import com.fmahadybd.backend.repository.UserRepository;
import jakarta.transaction.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class UserService {

    private final UserRepository userRepository;

    /** Create or update user */
    public User saveUser(User user) {
        return userRepository.save(user);
    }

    /** Get all users */
    public List<User> getAllUsers() {
        return userRepository.findAll();
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
    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }
}
