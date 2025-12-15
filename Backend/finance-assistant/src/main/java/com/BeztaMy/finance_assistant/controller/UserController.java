package com.BeztaMy.finance_assistant.controller;

import com.BeztaMy.finance_assistant.dto.ChangePasswordRequest;
import com.BeztaMy.finance_assistant.dto.UpdateProfileRequest;
import com.BeztaMy.finance_assistant.dto.UserProfileResponse;
import com.BeztaMy.finance_assistant.entity.User;
import com.BeztaMy.finance_assistant.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserRepository userRepository;
    private final org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;

    @Autowired
    public UserController(UserRepository userRepository,
            org.springframework.security.crypto.password.PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping("/profile")
    public ResponseEntity<?> getProfile() {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            String email = authentication.getName();

            User user = userRepository.findByEmail(email)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            String profilePictureBase64 = user.getProfilePicture() != null
                    ? java.util.Base64.getEncoder().encodeToString(user.getProfilePicture())
                    : null;

            UserProfileResponse response = new UserProfileResponse(
                    user.getId(),
                    user.getEmail(),
                    user.getFirstName(),
                    user.getLastName(),
                    user.getTelephone(),
                    user.getStatus(),
                    profilePictureBase64,
                    user.getCreatedAt(),
                    user.getMonthlyBudget(),
                    user.getRiskTolerance(),
                    user.getFinancialGoals());

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(@RequestBody UpdateProfileRequest request) {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            String email = authentication.getName();

            User user = userRepository.findByEmail(email)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            if (request.getFirstName() != null) {
                user.setFirstName(request.getFirstName());
            }
            if (request.getLastName() != null) {
                user.setLastName(request.getLastName());
            }
            if (request.getTelephone() != null) {
                user.setTelephone(request.getTelephone());
            }
            if (request.getStatus() != null) {
                user.setStatus(request.getStatus());
            }
            if (request.getProfilePicture() != null) {
                try {
                    user.setProfilePicture(java.util.Base64.getDecoder().decode(request.getProfilePicture()));
                } catch (IllegalArgumentException e) {
                    // Ignore invalid base64
                }
            }
            if (request.getMonthlyBudget() != null) {
                user.setMonthlyBudget(request.getMonthlyBudget());
            }
            if (request.getRiskTolerance() != null) {
                user.setRiskTolerance(request.getRiskTolerance());
            }
            if (request.getFinancialGoals() != null) {
                user.setFinancialGoals(request.getFinancialGoals());
            }

            userRepository.save(user);

            // Return JSON object
            java.util.Map<String, String> response = new java.util.HashMap<>();
            response.put("message", "Profile updated successfully");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            java.util.Map<String, String> error = new java.util.HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }

    @PutMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody ChangePasswordRequest request) {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            String email = authentication.getName();

            User user = userRepository.findByEmail(email)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
                java.util.Map<String, String> response = new java.util.HashMap<>();
                response.put("message", "Incorrect current password");
                return ResponseEntity.badRequest().body(response);
            }

            user.setPassword(passwordEncoder.encode(request.getNewPassword()));
            userRepository.save(user);

            java.util.Map<String, String> response = new java.util.HashMap<>();
            response.put("message", "Password changed successfully");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }

    @DeleteMapping("/profile")
    public ResponseEntity<?> deleteProfile() {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            String email = authentication.getName();

            User user = userRepository.findByEmail(email)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            userRepository.delete(user);

            return ResponseEntity.ok("Account deleted successfully");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }
}
