package com.BeztaMy.finance_assistant.dto;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class CategoryRequestTest {

    @Test
    void testNoArgsConstructor() {
        CategoryRequest request = new CategoryRequest();
        assertNotNull(request);
    }

    @Test
    void testAllArgsConstructor() {
        CategoryRequest request = new CategoryRequest("Food", "EXPENSE", "food_icon");

        assertEquals("Food", request.getName());
        assertEquals("EXPENSE", request.getType());
        assertEquals("food_icon", request.getIcon());
    }

    @Test
    void testSettersAndGetters() {
        CategoryRequest request = new CategoryRequest();

        request.setName("Transport");
        request.setType("EXPENSE");
        request.setIcon("car_icon");

        assertEquals("Transport", request.getName());
        assertEquals("EXPENSE", request.getType());
        assertEquals("car_icon", request.getIcon());
    }

    @Test
    void testIncomeCategory() {
        CategoryRequest request = new CategoryRequest("Salary", "INCOME", "money_icon");

        assertEquals("Salary", request.getName());
        assertEquals("INCOME", request.getType());
        assertEquals("money_icon", request.getIcon());
    }

    @Test
    void testNullIcon() {
        CategoryRequest request = new CategoryRequest("Entertainment", "EXPENSE", null);

        assertEquals("Entertainment", request.getName());
        assertEquals("EXPENSE", request.getType());
        assertNull(request.getIcon());
    }

    @Test
    void testEmptyValues() {
        CategoryRequest request = new CategoryRequest("", "", "");

        assertEquals("", request.getName());
        assertEquals("", request.getType());
        assertEquals("", request.getIcon());
    }

    @Test
    void testLongName() {
        String longName = "A".repeat(100);
        CategoryRequest request = new CategoryRequest(longName, "EXPENSE", "icon");

        assertEquals(longName, request.getName());
        assertEquals(100, request.getName().length());
    }
}
