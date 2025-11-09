package com.fmahadybd.backend.config;

import com.fmahadybd.backend.entity.Role;
import com.fmahadybd.backend.entity.User;
import com.fmahadybd.backend.entity.UserStatus;
import com.fmahadybd.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class DatabaseInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        // Check if admin user already exists
        if (userRepository.findByUsername("admin@admin.com").isEmpty()) {
            // Create admin user
            User admin = User.builder()
                    .username("admin@admin.com")
                    .password(passwordEncoder.encode("@Fahim220032@"))
                    .role(Role.ADMIN)
                    .enabled(true)
                    .referenceId(0L)
                    .status(UserStatus.ACTIVE)
                    .build();
            
            userRepository.save(admin);
            log.info("✅ Admin user created successfully");
            log.info("   Username: admin@admin.com");
            log.info("   Password: @Fahim220032@");
        } else {
            log.info("ℹ️  Admin user already exists");
        }

        // Optional: Create test users
        // createTestUserIfNotExists("agent1", "admin123", Role.AGENT);
        // createTestUserIfNotExists("shareholder1", "admin123", Role.SHAREHOLDER);
        // createTestUserIfNotExists("user1", "admin123", Role.USER);
    }

    private void createTestUserIfNotExists(String username, String password, Role role) {
        if (userRepository.findByUsername(username).isEmpty()) {
            User user = User.builder()
                    .username(username)
                    .password(passwordEncoder.encode(password))
                    .role(role)
                    .referenceId(0L)
                    .status(UserStatus.ACTIVE)
                    .build();
            
            userRepository.save(user);
            log.info("✅ Test user created: {} ({})", username, role);
        }
    }
}