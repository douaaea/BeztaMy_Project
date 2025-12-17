package com.BeztaMy.finance_assistant.dto;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class RegisterRequestTest {

    @Test
    void testNoArgsConstructor() {
        RegisterRequest request = new RegisterRequest();
        assertNotNull(request);
    }

    @Test
    void testSettersAndGetters() {
        RegisterRequest request = new RegisterRequest();

        request.setEmail("test@example.com");
        request.setFirstName("John");
        request.setLastName("Doe");
        request.setTelephone("1234567890");
        request.setPassword("password123");
        request.setProfilePicture("base64-image");
        request.setStatus("ACTIVE");

        assertEquals("test@example.com", request.getEmail());
        assertEquals("John", request.getFirstName());
        assertEquals("Doe", request.getLastName());
        assertEquals("1234567890", request.getTelephone());
        assertEquals("password123", request.getPassword());
        assertEquals("base64-image", request.getProfilePicture());
        assertEquals("ACTIVE", request.getStatus());
    }

    @Test
    void testAllFieldsSet() {
        RegisterRequest request = new RegisterRequest();
        request.setEmail("user@example.com");
        request.setFirstName("Jane");
        request.setLastName("Smith");
        request.setTelephone("9876543210");
        request.setPassword("securePass");
        request.setProfilePicture(null);
        request.setStatus("INACTIVE");

        assertNotNull(request.getEmail());
        assertNotNull(request.getFirstName());
        assertNotNull(request.getLastName());
        assertNotNull(request.getTelephone());
        assertNotNull(request.getPassword());
        assertNull(request.getProfilePicture());
        assertEquals("INACTIVE", request.getStatus());
    }

    @Test
    void testNullValues() {
        RegisterRequest request = new RegisterRequest();

        assertNull(request.getEmail());
        assertNull(request.getFirstName());
        assertNull(request.getLastName());
        assertNull(request.getTelephone());
        assertNull(request.getPassword());
        assertNull(request.getProfilePicture());
        assertNull(request.getStatus());
    }

    @Test
    void testEmptyStringValues() {
        RegisterRequest request = new RegisterRequest();

        request.setEmail("");
        request.setFirstName("");
        request.setLastName("");
        request.setTelephone("");
        request.setPassword("");
        request.setStatus("");

        assertEquals("", request.getEmail());
        assertEquals("", request.getFirstName());
        assertEquals("", request.getLastName());
        assertEquals("", request.getTelephone());
        assertEquals("", request.getPassword());
        assertEquals("", request.getStatus());
    }
}
