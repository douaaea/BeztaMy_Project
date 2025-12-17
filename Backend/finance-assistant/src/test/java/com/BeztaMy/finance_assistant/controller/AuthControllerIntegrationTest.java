package com.BeztaMy.finance_assistant.controller;

import com.BeztaMy.finance_assistant.dto.AuthResponse;
import com.BeztaMy.finance_assistant.dto.LoginRequest;
import com.BeztaMy.finance_assistant.dto.RegisterRequest;
import com.BeztaMy.finance_assistant.service.AuthService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class AuthControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AuthService authService;

    private RegisterRequest registerRequest;
    private LoginRequest loginRequest;
    private AuthResponse authResponse;

    @BeforeEach
    void setUp() {
        registerRequest = new RegisterRequest();
        registerRequest.setEmail("test@example.com");
        registerRequest.setFirstName("John");
        registerRequest.setLastName("Doe");
        registerRequest.setTelephone("1234567890");
        registerRequest.setPassword("password123");
        registerRequest.setStatus("ACTIVE");

        loginRequest = new LoginRequest("test@example.com", "password123");

        authResponse = new AuthResponse(
                "jwt-token",
                "test@example.com",
                "John",
                "Doe",
                1L,
                null
        );
    }

    @Test
    void register_ShouldReturnAuthResponse() throws Exception {
        when(authService.register(any(RegisterRequest.class))).thenReturn(authResponse);

        mockMvc.perform(post("/api/auth/register")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").value("jwt-token"))
                .andExpect(jsonPath("$.email").value("test@example.com"))
                .andExpect(jsonPath("$.firstName").value("John"));

        verify(authService, times(1)).register(any(RegisterRequest.class));
    }

    @Test
    void register_ShouldReturnBadRequest_WhenEmailExists() throws Exception {
        when(authService.register(any(RegisterRequest.class)))
                .thenThrow(new RuntimeException("Email already exists"));

        mockMvc.perform(post("/api/auth/register")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(content().string("Error: Email already exists"));

        verify(authService, times(1)).register(any(RegisterRequest.class));
    }

    @Test
    void login_ShouldReturnAuthResponse() throws Exception {
        when(authService.login(any(LoginRequest.class))).thenReturn(authResponse);

        mockMvc.perform(post("/api/auth/login")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").value("jwt-token"))
                .andExpect(jsonPath("$.email").value("test@example.com"));

        verify(authService, times(1)).login(any(LoginRequest.class));
    }

    @Test
    void login_ShouldReturnUnauthorized_WhenInvalidCredentials() throws Exception {
        when(authService.login(any(LoginRequest.class)))
                .thenThrow(new RuntimeException("Invalid credentials"));

        mockMvc.perform(post("/api/auth/login")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isUnauthorized())
                .andExpect(content().string("Error: Invalid credentials"));

        verify(authService, times(1)).login(any(LoginRequest.class));
    }

    @Test
    void testEndpoint_ShouldReturnTestMessage() throws Exception {
        mockMvc.perform(get("/api/auth/test")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().string("Authentication API is working!"));
    }
}
