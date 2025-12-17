package com.BeztaMy.finance_assistant.dto;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class LoginRequestTest {

    @Test
    void testNoArgsConstructor() {
        LoginRequest request = new LoginRequest();
        assertNotNull(request);
    }

    @Test
    void testAllArgsConstructor() {
        LoginRequest request = new LoginRequest("test@example.com", "password123");

        assertEquals("test@example.com", request.getEmail());
        assertEquals("password123", request.getPassword());
    }

    @Test
    void testSettersAndGetters() {
        LoginRequest request = new LoginRequest();

        request.setEmail("user@example.com");
        request.setPassword("securePassword");

        assertEquals("user@example.com", request.getEmail());
        assertEquals("securePassword", request.getPassword());
    }

    @Test
    void testNullValues() {
        LoginRequest request = new LoginRequest(null, null);

        assertNull(request.getEmail());
        assertNull(request.getPassword());
    }

    @Test
    void testEmptyValues() {
        LoginRequest request = new LoginRequest("", "");

        assertEquals("", request.getEmail());
        assertEquals("", request.getPassword());
    }
}
