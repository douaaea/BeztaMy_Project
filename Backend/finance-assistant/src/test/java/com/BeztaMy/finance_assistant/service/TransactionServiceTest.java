package com.BeztaMy.finance_assistant.service;

import com.BeztaMy.finance_assistant.entity.Category;
import com.BeztaMy.finance_assistant.entity.Transaction;
import com.BeztaMy.finance_assistant.enums.TransactionType;
import com.BeztaMy.finance_assistant.repository.TransactionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TransactionServiceTest {

    @Mock
    private TransactionRepository transactionRepository;

    @InjectMocks
    private TransactionService transactionService;

    private Category testCategory;
    private Transaction testTransaction;
    private Long userId;

    @BeforeEach
    void setUp() {
        userId = 1L;

        testCategory = new Category();
        testCategory.setId(1L);
        testCategory.setName("Food");
        testCategory.setType("EXPENSE");
        testCategory.setIsDefault(true);
        testCategory.setCreatedAt(LocalDateTime.now());

        testTransaction = new Transaction();
        testTransaction.setId(1L);
        testTransaction.setUserId(userId);
        testTransaction.setCategory(testCategory);
        testTransaction.setType(TransactionType.EXPENSE);
        testTransaction.setAmount(new BigDecimal("100.50"));
        testTransaction.setDescription("Grocery shopping");
        testTransaction.setTransactionDate(LocalDate.now());
        testTransaction.setIsRecurring(false);
        testTransaction.setIsActive(true);
        testTransaction.setCreatedAt(LocalDateTime.now());
        testTransaction.setUpdatedAt(LocalDateTime.now());
    }

    @Test
    void getAllTransactionsByUser_ShouldReturnTransactions() {
        List<Transaction> expectedTransactions = Arrays.asList(testTransaction);
        when(transactionRepository.findByUserId(userId)).thenReturn(expectedTransactions);

        List<Transaction> result = transactionService.getAllTransactionsByUser(userId);

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals(testTransaction.getId(), result.get(0).getId());
        verify(transactionRepository, times(1)).findByUserId(userId);
    }

    @Test
    void getTransactionById_ShouldReturnTransaction() {
        when(transactionRepository.findById(1L)).thenReturn(Optional.of(testTransaction));

        Optional<Transaction> result = transactionService.getTransactionById(1L);

        assertTrue(result.isPresent());
        assertEquals(testTransaction.getId(), result.get().getId());
        verify(transactionRepository, times(1)).findById(1L);
    }

    @Test
    void createTransaction_ShouldSaveAndReturnTransaction() {
        when(transactionRepository.save(any(Transaction.class))).thenReturn(testTransaction);

        Transaction result = transactionService.createTransaction(testTransaction);

        assertNotNull(result);
        assertEquals(testTransaction.getId(), result.getId());
        verify(transactionRepository, times(1)).save(testTransaction);
    }

    @Test
    void updateTransaction_ShouldUpdateAndReturnTransaction() {
        Transaction updatedDetails = new Transaction();
        updatedDetails.setCategory(testCategory);
        updatedDetails.setType(TransactionType.EXPENSE);
        updatedDetails.setAmount(new BigDecimal("200.00"));
        updatedDetails.setDescription("Updated description");
        updatedDetails.setTransactionDate(LocalDate.now());
        updatedDetails.setIsRecurring(false);
        updatedDetails.setIsActive(true);

        when(transactionRepository.findById(1L)).thenReturn(Optional.of(testTransaction));
        when(transactionRepository.save(any(Transaction.class))).thenReturn(testTransaction);

        Transaction result = transactionService.updateTransaction(1L, updatedDetails);

        assertNotNull(result);
        verify(transactionRepository, times(1)).findById(1L);
        verify(transactionRepository, times(1)).save(any(Transaction.class));
    }

    @Test
    void updateTransaction_ShouldThrowException_WhenNotFound() {
        when(transactionRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> {
            transactionService.updateTransaction(999L, testTransaction);
        });
    }

    @Test
    void deleteTransaction_ShouldDeleteTransaction() {
        when(transactionRepository.existsById(1L)).thenReturn(true);
        doNothing().when(transactionRepository).deleteById(1L);

        transactionService.deleteTransaction(1L);

        verify(transactionRepository, times(1)).existsById(1L);
        verify(transactionRepository, times(1)).deleteById(1L);
    }

    @Test
    void deleteTransaction_ShouldThrowException_WhenNotFound() {
        when(transactionRepository.existsById(999L)).thenReturn(false);

        assertThrows(RuntimeException.class, () -> {
            transactionService.deleteTransaction(999L);
        });
    }

    @Test
    void getCurrentBalance_ShouldCalculateCorrectly() {
        Transaction income = new Transaction();
        income.setType(TransactionType.INCOME);
        income.setAmount(new BigDecimal("5000.00"));
        income.setUserId(userId);
        income.setCategory(testCategory);
        income.setTransactionDate(LocalDate.now());

        Transaction expense = new Transaction();
        expense.setType(TransactionType.EXPENSE);
        expense.setAmount(new BigDecimal("2000.00"));
        expense.setUserId(userId);
        expense.setCategory(testCategory);
        expense.setTransactionDate(LocalDate.now());

        when(transactionRepository.findByUserId(userId))
                .thenReturn(Arrays.asList(income, expense));

        Map<String, Object> result = transactionService.getCurrentBalance(userId);

        assertNotNull(result);
        assertEquals(new BigDecimal("5000.00"), result.get("totalIncome"));
        assertEquals(new BigDecimal("2000.00"), result.get("totalExpense"));
        assertEquals(new BigDecimal("3000.00"), result.get("currentBalance"));
    }

    @Test
    void getMonthlySummary_ShouldReturnCorrectData() {
        Transaction januaryIncome = new Transaction();
        januaryIncome.setType(TransactionType.INCOME);
        januaryIncome.setAmount(new BigDecimal("1500.00"));
        januaryIncome.setUserId(userId);
        januaryIncome.setCategory(testCategory);
        januaryIncome.setTransactionDate(LocalDate.of(2024, 1, 15));

        Transaction januaryExpense = new Transaction();
        januaryExpense.setType(TransactionType.EXPENSE);
        januaryExpense.setAmount(new BigDecimal("1200.00"));
        januaryExpense.setUserId(userId);
        januaryExpense.setCategory(testCategory);
        januaryExpense.setTransactionDate(LocalDate.of(2024, 1, 20));

        when(transactionRepository.findByUserId(userId))
                .thenReturn(Arrays.asList(januaryIncome, januaryExpense));

        List<Map<String, Object>> result = transactionService.getMonthlySummary(userId, 2024);

        assertNotNull(result);
        assertEquals(12, result.size());

        Map<String, Object> januaryData = result.get(0);
        assertEquals("Jan", januaryData.get("month"));
        assertEquals(new BigDecimal("1500.00"), januaryData.get("income"));
        assertEquals(new BigDecimal("1200.00"), januaryData.get("expense"));
    }

    @Test
    void getRecentTransactions_ShouldReturnLimitedSortedTransactions() {
        Transaction t1 = new Transaction();
        t1.setId(1L);
        t1.setTransactionDate(LocalDate.of(2024, 1, 1));
        t1.setUserId(userId);
        t1.setCategory(testCategory);
        t1.setType(TransactionType.EXPENSE);
        t1.setAmount(new BigDecimal("100.00"));

        Transaction t2 = new Transaction();
        t2.setId(2L);
        t2.setTransactionDate(LocalDate.of(2024, 1, 15));
        t2.setUserId(userId);
        t2.setCategory(testCategory);
        t2.setType(TransactionType.INCOME);
        t2.setAmount(new BigDecimal("200.00"));

        Transaction t3 = new Transaction();
        t3.setId(3L);
        t3.setTransactionDate(LocalDate.of(2024, 1, 10));
        t3.setUserId(userId);
        t3.setCategory(testCategory);
        t3.setType(TransactionType.EXPENSE);
        t3.setAmount(new BigDecimal("150.00"));

        when(transactionRepository.findByUserId(userId))
                .thenReturn(Arrays.asList(t1, t2, t3));

        List<Transaction> result = transactionService.getRecentTransactions(userId, 2);

        assertNotNull(result);
        assertEquals(2, result.size());
        assertEquals(2L, result.get(0).getId());
        assertEquals(3L, result.get(1).getId());
    }

    @Test
    void getSpendingByCategory_ShouldCalculatePercentages() {
        Category foodCategory = new Category();
        foodCategory.setId(1L);
        foodCategory.setName("Food");
        foodCategory.setType("EXPENSE");

        Category transportCategory = new Category();
        transportCategory.setId(2L);
        transportCategory.setName("Transport");
        transportCategory.setType("EXPENSE");

        Transaction t1 = new Transaction();
        t1.setType(TransactionType.EXPENSE);
        t1.setAmount(new BigDecimal("400.00"));
        t1.setUserId(userId);
        t1.setCategory(foodCategory);
        t1.setTransactionDate(LocalDate.now());

        Transaction t2 = new Transaction();
        t2.setType(TransactionType.EXPENSE);
        t2.setAmount(new BigDecimal("600.00"));
        t2.setUserId(userId);
        t2.setCategory(transportCategory);
        t2.setTransactionDate(LocalDate.now());

        when(transactionRepository.findByUserId(userId))
                .thenReturn(Arrays.asList(t1, t2));

        Map<String, Object> result = transactionService.getSpendingByCategory(userId, null, null);

        assertNotNull(result);
        assertEquals(new BigDecimal("1000.00"), result.get("totalSpending"));

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> categories = (List<Map<String, Object>>) result.get("categories");
        assertEquals(2, categories.size());
    }
}
