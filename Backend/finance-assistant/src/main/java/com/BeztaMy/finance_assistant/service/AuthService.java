package com.BeztaMy.finance_assistant.service;

import com.BeztaMy.finance_assistant.dto.AuthResponse;
import com.BeztaMy.finance_assistant.dto.LoginRequest;
import com.BeztaMy.finance_assistant.dto.RegisterRequest;
import com.BeztaMy.finance_assistant.entity.User;
import com.BeztaMy.finance_assistant.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    @Autowired
    public AuthService(UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            AuthenticationManager authenticationManager) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
    }

    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setTelephone(request.getTelephone());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        if (request.getProfilePicture() != null) {
            try {
                user.setProfilePicture(java.util.Base64.getDecoder().decode(request.getProfilePicture()));
            } catch (IllegalArgumentException e) {
                // Ignore invalid base64
            }
        }

        user.setStatus(request.getStatus() != null ? request.getStatus() : "ACTIVE");

        userRepository.save(user);

        String jwtToken = jwtService.generateToken(user);

        String profilePictureBase64 = user.getProfilePicture() != null
                ? java.util.Base64.getEncoder().encodeToString(user.getProfilePicture())
                : null;

        return new AuthResponse(jwtToken, user.getEmail(), user.getFirstName(), user.getLastName(), user.getId(),
                profilePictureBase64);
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()));

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

        String jwtToken = jwtService.generateToken(user);

        String profilePictureBase64 = user.getProfilePicture() != null
                ? java.util.Base64.getEncoder().encodeToString(user.getProfilePicture())
                : null;

        return new AuthResponse(jwtToken, user.getEmail(), user.getFirstName(), user.getLastName(), user.getId(),
                profilePictureBase64);

    }
}
