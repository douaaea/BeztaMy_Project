package com.BeztaMy.finance_assistant.dto;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class ChangePasswordRequestTest {

    @Test
    void testNoArgsConstructor() {
        ChangePasswordRequest request = new ChangePasswordRequest();
        assertNotNull(request);
    }

    @Test
    void testAllArgsConstructor() {
        ChangePasswordRequest request = new ChangePasswordRequest("oldPassword123", "newPassword456");

        assertEquals("oldPassword123", request.getCurrentPassword());
        assertEquals("newPassword456", request.getNewPassword());
    }

    @Test
    void testSettersAndGetters() {
        ChangePasswordRequest request = new ChangePasswordRequest();

        request.setCurrentPassword("currentPass");
        request.setNewPassword("newPass");

        assertEquals("currentPass", request.getCurrentPassword());
        assertEquals("newPass", request.getNewPassword());
    }

    @Test
    void testNullValues() {
        ChangePasswordRequest request = new ChangePasswordRequest(null, null);

        assertNull(request.getCurrentPassword());
        assertNull(request.getNewPassword());
    }

    @Test
    void testEmptyValues() {
        ChangePasswordRequest request = new ChangePasswordRequest("", "");

        assertEquals("", request.getCurrentPassword());
        assertEquals("", request.getNewPassword());
    }

    @Test
    void testDifferentPasswords() {
        ChangePasswordRequest request = new ChangePasswordRequest();
        request.setCurrentPassword("password1");
        request.setNewPassword("password2");

        assertNotEquals(request.getCurrentPassword(), request.getNewPassword());
    }
}
