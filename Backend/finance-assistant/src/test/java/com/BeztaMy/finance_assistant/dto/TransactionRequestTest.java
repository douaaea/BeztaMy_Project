package com.BeztaMy.finance_assistant.dto;

import com.BeztaMy.finance_assistant.enums.Frequency;
import com.BeztaMy.finance_assistant.enums.TransactionType;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

class TransactionRequestTest {

    @Test
    void testNoArgsConstructor() {
        TransactionRequest request = new TransactionRequest();
        assertNotNull(request);
        assertEquals(false, request.getIsRecurring());
    }

    @Test
    void testAllArgsConstructor() {
        LocalDate date = LocalDate.now();
        LocalDate endDate = LocalDate.now().plusMonths(6);

        TransactionRequest request = new TransactionRequest(
                1L,
                TransactionType.EXPENSE,
                new BigDecimal("100.50"),
                "Grocery shopping",
                "Supermarket",
                date,
                true,
                Frequency.MONTHLY,
                endDate,
                null,
                true);

        assertEquals(1L, request.getCategoryId());
        assertEquals(TransactionType.EXPENSE, request.getType());
        assertEquals(new BigDecimal("100.50"), request.getAmount());
        assertEquals("Grocery shopping", request.getDescription());
        assertEquals("Supermarket", request.getLocation());
        assertEquals(date, request.getTransactionDate());
        assertTrue(request.getIsRecurring());
        assertEquals(Frequency.MONTHLY, request.getFrequency());
        assertEquals(Frequency.MONTHLY, request.getFrequency());
        assertEquals(endDate, request.getEndDate());
        assertNull(request.getNextExecutionDate());
        assertTrue(request.getIsActive());
    }

    @Test
    void testSettersAndGetters() {
        TransactionRequest request = new TransactionRequest();
        LocalDate date = LocalDate.of(2024, 1, 15);

        request.setCategoryId(2L);
        request.setType(TransactionType.INCOME);
        request.setAmount(new BigDecimal("5000.00"));
        request.setDescription("Salary");
        request.setLocation("Office");
        request.setTransactionDate(date);
        request.setIsRecurring(true);
        request.setFrequency(Frequency.MONTHLY);
        request.setEndDate(date.plusYears(1));

        assertEquals(2L, request.getCategoryId());
        assertEquals(TransactionType.INCOME, request.getType());
        assertEquals(new BigDecimal("5000.00"), request.getAmount());
        assertEquals("Salary", request.getDescription());
        assertEquals("Office", request.getLocation());
        assertEquals(date, request.getTransactionDate());
        assertTrue(request.getIsRecurring());
        assertEquals(Frequency.MONTHLY, request.getFrequency());
        assertEquals(date.plusYears(1), request.getEndDate());
    }

    @Test
    void testExpenseTransaction() {
        TransactionRequest request = new TransactionRequest();
        request.setType(TransactionType.EXPENSE);
        request.setAmount(new BigDecimal("50.25"));
        request.setIsRecurring(false);

        assertEquals(TransactionType.EXPENSE, request.getType());
        assertEquals(new BigDecimal("50.25"), request.getAmount());
        assertFalse(request.getIsRecurring());
    }

    @Test
    void testIncomeTransaction() {
        TransactionRequest request = new TransactionRequest();
        request.setType(TransactionType.INCOME);
        request.setAmount(new BigDecimal("3000.00"));

        assertEquals(TransactionType.INCOME, request.getType());
        assertEquals(new BigDecimal("3000.00"), request.getAmount());
    }

    @Test
    void testRecurringTransaction() {
        TransactionRequest request = new TransactionRequest();
        request.setIsRecurring(true);
        request.setFrequency(Frequency.WEEKLY);
        request.setEndDate(LocalDate.now().plusMonths(3));

        assertTrue(request.getIsRecurring());
        assertEquals(Frequency.WEEKLY, request.getFrequency());
        assertNotNull(request.getEndDate());
    }

    @Test
    void testNonRecurringTransaction() {
        TransactionRequest request = new TransactionRequest();
        request.setIsRecurring(false);

        assertFalse(request.getIsRecurring());
        assertNull(request.getFrequency());
        assertNull(request.getEndDate());
    }

    @Test
    void testNullOptionalFields() {
        TransactionRequest request = new TransactionRequest();
        request.setCategoryId(1L);
        request.setType(TransactionType.EXPENSE);
        request.setAmount(new BigDecimal("10.00"));
        request.setTransactionDate(LocalDate.now());

        assertNull(request.getDescription());
        assertNull(request.getLocation());
        assertNull(request.getFrequency());
        assertNull(request.getEndDate());
    }

    @Test
    void testAllFrequencies() {
        TransactionRequest request = new TransactionRequest();

        request.setFrequency(Frequency.DAILY);
        assertEquals(Frequency.DAILY, request.getFrequency());

        request.setFrequency(Frequency.WEEKLY);
        assertEquals(Frequency.WEEKLY, request.getFrequency());

        request.setFrequency(Frequency.MONTHLY);
        assertEquals(Frequency.MONTHLY, request.getFrequency());

        request.setFrequency(Frequency.YEARLY);
        assertEquals(Frequency.YEARLY, request.getFrequency());
    }
}
