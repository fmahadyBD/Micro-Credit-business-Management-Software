package com.fmahadybd.backend.auth;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController 
@RequestMapping("auth") 
@RequiredArgsConstructor 
@Tag(name = "Authentication") // Used for grouping API documentation in Swagger.
public class AuthenticationController {

    private final AuthenticationService service;

    @PostMapping("/register") 
    @ResponseStatus(HttpStatus.ACCEPTED) // Sets the response status to 202 Accepted.
    public ResponseEntity<?> register(
            @RequestBody @Valid RegistrationRequest request // Extracts request body and validates it.
    ) {
        service.register(request); 
        return ResponseEntity.accepted().build(); // Returns 202 Accepted response.
    }

    @PostMapping("/authenticate") 
    public ResponseEntity<AuthenticationResponse> authenticate(
            @RequestBody AuthenticationRequest request // Extracts request body.
    ) {
        return ResponseEntity.ok(service.authenticate(request)); // Returns the authentication response.
    }
}