package com.BeztaMy.finance_assistant.controller;

import com.BeztaMy.finance_assistant.dto.TransactionRequest;
import com.BeztaMy.finance_assistant.entity.Category;
import com.BeztaMy.finance_assistant.entity.Transaction;
import com.BeztaMy.finance_assistant.enums.TransactionType;
import com.BeztaMy.finance_assistant.repository.CategoryRepository;
import com.BeztaMy.finance_assistant.service.TransactionService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class TransactionControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private TransactionService transactionService;

    @MockBean
    private CategoryRepository categoryRepository;

    private Category testCategory;
    private Transaction testTransaction;
    private TransactionRequest transactionRequest;
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

        transactionRequest = new TransactionRequest();
        transactionRequest.setCategoryId(1L);
        transactionRequest.setType(TransactionType.EXPENSE);
        transactionRequest.setAmount(new BigDecimal("100.50"));
        transactionRequest.setDescription("Grocery shopping");
        transactionRequest.setTransactionDate(LocalDate.now());
        transactionRequest.setIsRecurring(false);
    }

    @Test
    @WithMockUser
    void getTransactions_ShouldReturnTransactionList() throws Exception {
        List<Transaction> transactions = Arrays.asList(testTransaction);
        when(transactionService.getAllTransactionsByUser(userId)).thenReturn(transactions);

        mockMvc.perform(get("/api/transactions")
                        .param("userId", userId.toString())
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].description").value("Grocery shopping"));

        verify(transactionService, times(1)).getAllTransactionsByUser(userId);
    }

    @Test
    @WithMockUser
    void getTransactionById_ShouldReturnTransaction() throws Exception {
        when(transactionService.getTransactionById(1L)).thenReturn(Optional.of(testTransaction));

        mockMvc.perform(get("/api/transactions/1")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.description").value("Grocery shopping"));

        verify(transactionService, times(1)).getTransactionById(1L);
    }

    @Test
    @WithMockUser
    void createTransaction_ShouldReturnCreatedTransaction() throws Exception {
        when(categoryRepository.findById(1L)).thenReturn(Optional.of(testCategory));
        when(transactionService.createTransaction(any(Transaction.class))).thenReturn(testTransaction);

        mockMvc.perform(post("/api/transactions")
                        .with(csrf())
                        .param("userId", userId.toString())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(transactionRequest)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.description").value("Grocery shopping"));

        verify(categoryRepository, times(1)).findById(1L);
        verify(transactionService, times(1)).createTransaction(any(Transaction.class));
    }

    @Test
    @WithMockUser
    void updateTransaction_ShouldReturnUpdatedTransaction() throws Exception {
        when(categoryRepository.findById(1L)).thenReturn(Optional.of(testCategory));
        when(transactionService.updateTransaction(eq(1L), any(Transaction.class))).thenReturn(testTransaction);

        mockMvc.perform(put("/api/transactions/1")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(transactionRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1));

        verify(categoryRepository, times(1)).findById(1L);
        verify(transactionService, times(1)).updateTransaction(eq(1L), any(Transaction.class));
    }

    @Test
    @WithMockUser
    void deleteTransaction_ShouldReturnSuccessMessage() throws Exception {
        doNothing().when(transactionService).deleteTransaction(1L);

        mockMvc.perform(delete("/api/transactions/1")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Transaction deleted successfully"));

        verify(transactionService, times(1)).deleteTransaction(1L);
    }

    @Test
    @WithMockUser
    void getCurrentBalance_ShouldReturnBalanceData() throws Exception {
        Map<String, Object> balanceData = new HashMap<>();
        balanceData.put("totalIncome", new BigDecimal("5000.00"));
        balanceData.put("totalExpense", new BigDecimal("2000.00"));
        balanceData.put("currentBalance", new BigDecimal("3000.00"));

        when(transactionService.getCurrentBalance(userId)).thenReturn(balanceData);

        mockMvc.perform(get("/api/transactions/dashboard/balance")
                        .param("userId", userId.toString())
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalIncome").value(5000.00))
                .andExpect(jsonPath("$.totalExpense").value(2000.00))
                .andExpect(jsonPath("$.currentBalance").value(3000.00));

        verify(transactionService, times(1)).getCurrentBalance(userId);
    }

    @Test
    @WithMockUser
    void getMonthlySummary_ShouldReturnMonthlySummaryData() throws Exception {
        Map<String, Object> januaryData = new HashMap<>();
        januaryData.put("month", "Jan");
        januaryData.put("income", new BigDecimal("1500.00"));
        januaryData.put("expense", new BigDecimal("1200.00"));

        List<Map<String, Object>> summaryData = Arrays.asList(januaryData);

        when(transactionService.getMonthlySummary(userId, 2024)).thenReturn(summaryData);

        mockMvc.perform(get("/api/transactions/dashboard/monthly-summary")
                        .param("userId", userId.toString())
                        .param("year", "2024")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].month").value("Jan"))
                .andExpect(jsonPath("$[0].income").value(1500.00))
                .andExpect(jsonPath("$[0].expense").value(1200.00));

        verify(transactionService, times(1)).getMonthlySummary(userId, 2024);
    }

    @Test
    @WithMockUser
    void getRecentTransactions_ShouldReturnRecentTransactions() throws Exception {
        List<Transaction> recentTransactions = Arrays.asList(testTransaction);
        when(transactionService.getRecentTransactions(userId, 5)).thenReturn(recentTransactions);

        mockMvc.perform(get("/api/transactions/dashboard/recent")
                        .param("userId", userId.toString())
                        .param("limit", "5")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(1));

        verify(transactionService, times(1)).getRecentTransactions(userId, 5);
    }

    @Test
    @WithMockUser
    void getSpendingCategories_ShouldReturnSpendingData() throws Exception {
        Map<String, Object> categoryData = new HashMap<>();
        categoryData.put("label", "Food");
        categoryData.put("value", 40);
        categoryData.put("color", "#42A5F5");

        Map<String, Object> spendingData = new HashMap<>();
        spendingData.put("totalSpending", new BigDecimal("1000.00"));
        spendingData.put("categories", Arrays.asList(categoryData));

        when(transactionService.getSpendingByCategory(eq(userId), any(), any())).thenReturn(spendingData);

        mockMvc.perform(get("/api/transactions/dashboard/spending-categories")
                        .param("userId", userId.toString())
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalSpending").value(1000.00))
                .andExpect(jsonPath("$.categories[0].label").value("Food"));

        verify(transactionService, times(1)).getSpendingByCategory(eq(userId), any(), any());
    }

    @Test
    @WithMockUser
    void getFinancialTrends_ShouldReturnTrendsData() throws Exception {
        Map<String, Object> trendData = new HashMap<>();
        trendData.put("month", 0);
        trendData.put("balance", 1000.0);

        List<Map<String, Object>> trendsData = Arrays.asList(trendData);

        when(transactionService.getFinancialTrends(eq(userId), any(LocalDate.class), any(LocalDate.class)))
                .thenReturn(trendsData);

        mockMvc.perform(get("/api/transactions/dashboard/financial-trends")
                        .param("userId", userId.toString())
                        .param("startDate", "2024-01-01")
                        .param("endDate", "2024-12-31")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].month").value(0))
                .andExpect(jsonPath("$[0].balance").value(1000.0));

        verify(transactionService, times(1)).getFinancialTrends(eq(userId), any(LocalDate.class), any(LocalDate.class));
    }
}
