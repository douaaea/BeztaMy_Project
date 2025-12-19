package com.BeztaMy.finance_assistant.controller;

import com.BeztaMy.finance_assistant.dto.ChangePasswordRequest;
import com.BeztaMy.finance_assistant.dto.UpdateProfileRequest;
import com.BeztaMy.finance_assistant.entity.User;
import com.BeztaMy.finance_assistant.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class UserControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private UserRepository userRepository;

    @MockBean
    private PasswordEncoder passwordEncoder;

    private User testUser;
    private UpdateProfileRequest updateProfileRequest;
    private ChangePasswordRequest changePasswordRequest;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setEmail("test@example.com");
        testUser.setFirstName("John");
        testUser.setLastName("Doe");
        testUser.setTelephone("1234567890");
        testUser.setPassword("encodedPassword");
        testUser.setStatus("ACTIVE");
        testUser.setCreatedAt(LocalDateTime.now());
        testUser.setMonthlyBudget(5000.0);
        testUser.setRiskTolerance("MODERATE");
        testUser.setFinancialGoals("Save for retirement");

        updateProfileRequest = new UpdateProfileRequest();
        updateProfileRequest.setFirstName("Jane");
        updateProfileRequest.setLastName("Smith");
        updateProfileRequest.setMonthlyBudget(6000.0);

        changePasswordRequest = new ChangePasswordRequest("currentPassword", "newPassword");
    }

    @Test
    @WithMockUser(username = "test@example.com")
    void getProfile_ShouldReturnUserProfile() throws Exception {
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));

        mockMvc.perform(get("/api/users/profile")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.email").value("test@example.com"))
                .andExpect(jsonPath("$.firstName").value("John"))
                .andExpect(jsonPath("$.lastName").value("Doe"))
                .andExpect(jsonPath("$.monthlyBudget").value(5000.0))
                .andExpect(jsonPath("$.riskTolerance").value("MODERATE"));

        verify(userRepository, times(1)).findByEmail("test@example.com");
    }

    @Test
    @WithMockUser(username = "test@example.com")
    void updateProfile_ShouldUpdateAndReturnSuccess() throws Exception {
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        mockMvc.perform(put("/api/users/profile")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateProfileRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Profile updated successfully"));

        verify(userRepository, times(1)).findByEmail("test@example.com");
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    @WithMockUser(username = "test@example.com")
    void updateProfile_WithInvalidBase64_ShouldStillUpdate() throws Exception {
        updateProfileRequest.setProfilePicture("invalid-base64!@#$");

        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        mockMvc.perform(put("/api/users/profile")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateProfileRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Profile updated successfully"));

        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    @WithMockUser(username = "test@example.com")
    void changePassword_WithCorrectCurrentPassword_ShouldSucceed() throws Exception {
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches("currentPassword", "encodedPassword")).thenReturn(true);
        when(passwordEncoder.encode("newPassword")).thenReturn("newEncodedPassword");
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        mockMvc.perform(put("/api/users/change-password")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(changePasswordRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Password changed successfully"));

        verify(userRepository, times(1)).findByEmail("test@example.com");
        verify(passwordEncoder, times(1)).matches("currentPassword", "encodedPassword");
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    @WithMockUser(username = "test@example.com")
    void changePassword_WithIncorrectCurrentPassword_ShouldFail() throws Exception {
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches("currentPassword", "encodedPassword")).thenReturn(false);

        mockMvc.perform(put("/api/users/change-password")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(changePasswordRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Incorrect current password"));

        verify(userRepository, times(1)).findByEmail("test@example.com");
        verify(passwordEncoder, times(1)).matches("currentPassword", "encodedPassword");
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    @WithMockUser(username = "test@example.com")
    void deleteProfile_ShouldDeleteUser() throws Exception {
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));
        doNothing().when(userRepository).delete(testUser);

        mockMvc.perform(delete("/api/users/profile")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().string("Account deleted successfully"));

        verify(userRepository, times(1)).findByEmail("test@example.com");
        verify(userRepository, times(1)).delete(testUser);
    }

    @Test
    @WithMockUser(username = "nonexistent@example.com")
    void getProfile_WithNonExistentUser_ShouldReturnError() throws Exception {
        when(userRepository.findByEmail("nonexistent@example.com")).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/users/profile")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().is5xxServerError());

        verify(userRepository, times(1)).findByEmail("nonexistent@example.com");
    }
}
