package com.BeztaMy.finance_assistant.dto;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class AuthResponseTest {

    @Test
    void testNoArgsConstructor() {
        AuthResponse response = new AuthResponse();
        assertNotNull(response);
    }

    @Test
    void testAllArgsConstructor() {
        AuthResponse response = new AuthResponse(
                "jwt-token",
                "test@example.com",
                "John",
                "Doe",
                1L,
                "base64-image"
        );

        assertEquals("jwt-token", response.getToken());
        assertEquals("test@example.com", response.getEmail());
        assertEquals("John", response.getFirstName());
        assertEquals("Doe", response.getLastName());
        assertEquals(1L, response.getUserId());
        assertEquals("base64-image", response.getProfilePicture());
    }

    @Test
    void testSettersAndGetters() {
        AuthResponse response = new AuthResponse();

        response.setToken("new-token");
        response.setEmail("new@example.com");
        response.setFirstName("Jane");
        response.setLastName("Smith");
        response.setUserId(2L);
        response.setProfilePicture("new-image");

        assertEquals("new-token", response.getToken());
        assertEquals("new@example.com", response.getEmail());
        assertEquals("Jane", response.getFirstName());
        assertEquals("Smith", response.getLastName());
        assertEquals(2L, response.getUserId());
        assertEquals("new-image", response.getProfilePicture());
    }

    @Test
    void testNullValues() {
        AuthResponse response = new AuthResponse(null, null, null, null, null, null);

        assertNull(response.getToken());
        assertNull(response.getEmail());
        assertNull(response.getFirstName());
        assertNull(response.getLastName());
        assertNull(response.getUserId());
        assertNull(response.getProfilePicture());
    }
}
