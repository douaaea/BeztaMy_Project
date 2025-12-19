package com.BeztaMy.finance_assistant.dto;

import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

class UserProfileResponseTest {

    @Test
    void testNoArgsConstructor() {
        UserProfileResponse response = new UserProfileResponse();
        assertNotNull(response);
    }

    @Test
    void testAllArgsConstructor() {
        LocalDateTime now = LocalDateTime.now();

        UserProfileResponse response = new UserProfileResponse(
                1L,
                "test@example.com",
                "John",
                "Doe",
                "1234567890",
                "ACTIVE",
                "base64-image",
                now,
                5000.0,
                "MODERATE",
                "Save for retirement"
        );

        assertEquals(1L, response.getId());
        assertEquals("test@example.com", response.getEmail());
        assertEquals("John", response.getFirstName());
        assertEquals("Doe", response.getLastName());
        assertEquals("1234567890", response.getTelephone());
        assertEquals("ACTIVE", response.getStatus());
        assertEquals("base64-image", response.getProfilePicture());
        assertEquals(now, response.getCreatedAt());
        assertEquals(5000.0, response.getMonthlyBudget());
        assertEquals("MODERATE", response.getRiskTolerance());
        assertEquals("Save for retirement", response.getFinancialGoals());
    }

    @Test
    void testSettersAndGetters() {
        UserProfileResponse response = new UserProfileResponse();
        LocalDateTime timestamp = LocalDateTime.of(2024, 1, 1, 12, 0);

        response.setId(2L);
        response.setEmail("user@example.com");
        response.setFirstName("Jane");
        response.setLastName("Smith");
        response.setTelephone("9876543210");
        response.setStatus("ACTIVE");
        response.setProfilePicture("profile-pic");
        response.setCreatedAt(timestamp);
        response.setMonthlyBudget(3000.0);
        response.setRiskTolerance("LOW");
        response.setFinancialGoals("Buy a car");

        assertEquals(2L, response.getId());
        assertEquals("user@example.com", response.getEmail());
        assertEquals("Jane", response.getFirstName());
        assertEquals("Smith", response.getLastName());
        assertEquals("9876543210", response.getTelephone());
        assertEquals("ACTIVE", response.getStatus());
        assertEquals("profile-pic", response.getProfilePicture());
        assertEquals(timestamp, response.getCreatedAt());
        assertEquals(3000.0, response.getMonthlyBudget());
        assertEquals("LOW", response.getRiskTolerance());
        assertEquals("Buy a car", response.getFinancialGoals());
    }

    @Test
    void testNullOptionalFields() {
        UserProfileResponse response = new UserProfileResponse();

        response.setId(1L);
        response.setEmail("test@example.com");
        response.setFirstName("John");
        response.setLastName("Doe");
        response.setTelephone("1234567890");
        response.setStatus("ACTIVE");
        response.setCreatedAt(LocalDateTime.now());

        assertNotNull(response.getId());
        assertNotNull(response.getEmail());
        assertNull(response.getProfilePicture());
        assertNull(response.getMonthlyBudget());
        assertNull(response.getRiskTolerance());
        assertNull(response.getFinancialGoals());
    }

    @Test
    void testWithProfilePicture() {
        UserProfileResponse response = new UserProfileResponse();
        response.setProfilePicture("data:image/png;base64,iVBORw0KGgoAAAANS");

        assertNotNull(response.getProfilePicture());
        assertTrue(response.getProfilePicture().startsWith("data:image"));
    }

    @Test
    void testRiskToleranceLevels() {
        UserProfileResponse response = new UserProfileResponse();

        response.setRiskTolerance("LOW");
        assertEquals("LOW", response.getRiskTolerance());

        response.setRiskTolerance("MODERATE");
        assertEquals("MODERATE", response.getRiskTolerance());

        response.setRiskTolerance("HIGH");
        assertEquals("HIGH", response.getRiskTolerance());
    }

    @Test
    void testMonthlyBudgetRange() {
        UserProfileResponse response = new UserProfileResponse();

        response.setMonthlyBudget(0.0);
        assertEquals(0.0, response.getMonthlyBudget());

        response.setMonthlyBudget(10000.0);
        assertEquals(10000.0, response.getMonthlyBudget());

        response.setMonthlyBudget(99999.99);
        assertEquals(99999.99, response.getMonthlyBudget());
    }

    @Test
    void testCreatedAtTimestamp() {
        UserProfileResponse response = new UserProfileResponse();
        LocalDateTime past = LocalDateTime.of(2020, 1, 1, 0, 0);
        LocalDateTime future = LocalDateTime.of(2030, 12, 31, 23, 59);

        response.setCreatedAt(past);
        assertEquals(past, response.getCreatedAt());

        response.setCreatedAt(future);
        assertEquals(future, response.getCreatedAt());
    }

    @Test
    void testCompleteProfile() {
        LocalDateTime now = LocalDateTime.now();
        UserProfileResponse response = new UserProfileResponse(
                100L,
                "complete@example.com",
                "Complete",
                "User",
                "5551234567",
                "ACTIVE",
                "complete-profile-pic",
                now,
                7500.50,
                "HIGH",
                "Invest in real estate and stocks"
        );

        assertNotNull(response.getId());
        assertNotNull(response.getEmail());
        assertNotNull(response.getFirstName());
        assertNotNull(response.getLastName());
        assertNotNull(response.getTelephone());
        assertNotNull(response.getStatus());
        assertNotNull(response.getProfilePicture());
        assertNotNull(response.getCreatedAt());
        assertNotNull(response.getMonthlyBudget());
        assertNotNull(response.getRiskTolerance());
        assertNotNull(response.getFinancialGoals());
    }
}
