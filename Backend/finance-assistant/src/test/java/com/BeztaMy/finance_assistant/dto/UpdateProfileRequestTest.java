package com.BeztaMy.finance_assistant.dto;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class UpdateProfileRequestTest {

    @Test
    void testNoArgsConstructor() {
        UpdateProfileRequest request = new UpdateProfileRequest();
        assertNotNull(request);
    }

    @Test
    void testSettersAndGetters() {
        UpdateProfileRequest request = new UpdateProfileRequest();

        request.setFirstName("John");
        request.setLastName("Doe");
        request.setTelephone("1234567890");
        request.setStatus("ACTIVE");
        request.setProfilePicture("base64-image");
        request.setMonthlyBudget(5000.0);
        request.setRiskTolerance("MODERATE");
        request.setFinancialGoals("Save for retirement");

        assertEquals("John", request.getFirstName());
        assertEquals("Doe", request.getLastName());
        assertEquals("1234567890", request.getTelephone());
        assertEquals("ACTIVE", request.getStatus());
        assertEquals("base64-image", request.getProfilePicture());
        assertEquals(5000.0, request.getMonthlyBudget());
        assertEquals("MODERATE", request.getRiskTolerance());
        assertEquals("Save for retirement", request.getFinancialGoals());
    }

    @Test
    void testNullValues() {
        UpdateProfileRequest request = new UpdateProfileRequest();

        assertNull(request.getFirstName());
        assertNull(request.getLastName());
        assertNull(request.getTelephone());
        assertNull(request.getStatus());
        assertNull(request.getProfilePicture());
        assertNull(request.getMonthlyBudget());
        assertNull(request.getRiskTolerance());
        assertNull(request.getFinancialGoals());
    }

    @Test
    void testPartialUpdate() {
        UpdateProfileRequest request = new UpdateProfileRequest();
        request.setFirstName("Jane");
        request.setMonthlyBudget(3000.0);

        assertEquals("Jane", request.getFirstName());
        assertEquals(3000.0, request.getMonthlyBudget());
        assertNull(request.getLastName());
        assertNull(request.getTelephone());
    }

    @Test
    void testRiskToleranceLevels() {
        UpdateProfileRequest request = new UpdateProfileRequest();

        request.setRiskTolerance("LOW");
        assertEquals("LOW", request.getRiskTolerance());

        request.setRiskTolerance("MODERATE");
        assertEquals("MODERATE", request.getRiskTolerance());

        request.setRiskTolerance("HIGH");
        assertEquals("HIGH", request.getRiskTolerance());
    }

    @Test
    void testMonthlyBudgetValues() {
        UpdateProfileRequest request = new UpdateProfileRequest();

        request.setMonthlyBudget(1000.0);
        assertEquals(1000.0, request.getMonthlyBudget());

        request.setMonthlyBudget(0.0);
        assertEquals(0.0, request.getMonthlyBudget());

        request.setMonthlyBudget(null);
        assertNull(request.getMonthlyBudget());
    }

    @Test
    void testFinancialGoals() {
        UpdateProfileRequest request = new UpdateProfileRequest();
        String longGoal = "Save $50,000 for a house down payment, invest in stocks, and build an emergency fund of 6 months expenses";

        request.setFinancialGoals(longGoal);
        assertEquals(longGoal, request.getFinancialGoals());
    }

    @Test
    void testStatusValues() {
        UpdateProfileRequest request = new UpdateProfileRequest();

        request.setStatus("ACTIVE");
        assertEquals("ACTIVE", request.getStatus());

        request.setStatus("INACTIVE");
        assertEquals("INACTIVE", request.getStatus());
    }
}
