package com.BeztaMy.finance_assistant.controller;

import com.BeztaMy.finance_assistant.dto.TransactionRequest;
import com.BeztaMy.finance_assistant.entity.Category;
import com.BeztaMy.finance_assistant.entity.Transaction;
import com.BeztaMy.finance_assistant.enums.TransactionType;
import com.BeztaMy.finance_assistant.repository.CategoryRepository;
import com.BeztaMy.finance_assistant.service.TransactionService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/transactions")
@CrossOrigin(origins = "*")
public class TransactionController {

    private final TransactionService transactionService;
    private final CategoryRepository categoryRepository;

    @Autowired
    public TransactionController(TransactionService transactionService,
            CategoryRepository categoryRepository) {
        this.transactionService = transactionService;
        this.categoryRepository = categoryRepository;
    }

    // ============ CRUD ENDPOINTS ============

    @GetMapping
    public ResponseEntity<List<Transaction>> getTransactions(
            @RequestParam Long userId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) TransactionType type) {

        if (startDate != null && endDate != null) {
            List<Transaction> transactions = transactionService.getTransactionsByFilters(
                    userId, startDate, endDate, categoryId, type);
            return ResponseEntity.ok(transactions);
        }

        List<Transaction> transactions = transactionService.getAllTransactionsByUser(userId);
        return ResponseEntity.ok(transactions);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Transaction> getTransactionById(@PathVariable Long id) {
        Transaction transaction = transactionService.getTransactionById(id)
                .orElseThrow(() -> new RuntimeException("Transaction not found with id: " + id));
        return ResponseEntity.ok(transaction);
    }

    @PostMapping
    public ResponseEntity<Transaction> createTransaction(
            @RequestParam Long userId,
            @Valid @RequestBody TransactionRequest request) {

        Transaction transaction = new Transaction();
        transaction.setUserId(userId);

        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Category not found with id: " + request.getCategoryId()));
        transaction.setCategory(category);
        transaction.setType(request.getType());
        transaction.setAmount(request.getAmount());
        transaction.setDescription(request.getDescription());
        transaction.setLocation(request.getLocation());
        transaction.setTransactionDate(request.getTransactionDate());
        transaction.setIsRecurring(request.getIsRecurring());
        transaction.setFrequency(request.getFrequency());
        transaction.setEndDate(request.getEndDate());

        if (request.getIsRecurring() != null && request.getIsRecurring()) {
            if (request.getNextExecutionDate() != null) {
                transaction.setNextExecutionDate(request.getNextExecutionDate());
            } else {
                transaction.setNextExecutionDate(request.getTransactionDate());
            }
            transaction.setIsActive(request.getIsActive() != null ? request.getIsActive() : true);
        } else {
            transaction.setIsActive(true); // Default active for non-recurring? Or relevant?
        }

        Transaction savedTransaction = transactionService.createTransaction(transaction);
        return new ResponseEntity<>(savedTransaction, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Transaction> updateTransaction(
            @PathVariable Long id,
            @Valid @RequestBody TransactionRequest request) {

        Transaction transactionDetails = new Transaction();
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Category not found with id: " + request.getCategoryId()));

        transactionDetails.setCategory(category);
        transactionDetails.setType(request.getType());
        transactionDetails.setAmount(request.getAmount());
        transactionDetails.setDescription(request.getDescription());
        transactionDetails.setLocation(request.getLocation());
        transactionDetails.setTransactionDate(request.getTransactionDate());
        transactionDetails.setIsRecurring(request.getIsRecurring());
        transactionDetails.setFrequency(request.getFrequency());

        transactionDetails.setEndDate(request.getEndDate());
        transactionDetails.setNextExecutionDate(request.getNextExecutionDate());
        transactionDetails.setIsActive(request.getIsActive());

        Transaction updatedTransaction = transactionService.updateTransaction(id, transactionDetails);
        return ResponseEntity.ok(updatedTransaction);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> deleteTransaction(@PathVariable Long id) {
        transactionService.deleteTransaction(id);
        Map<String, String> response = new java.util.HashMap<>();
        response.put("message", "Transaction deleted successfully");
        return ResponseEntity.ok(response);
    }

    // ============ FLUTTER DASHBOARD API ENDPOINTS ============

    /**
     * For: Total Current Balance Card
     * GET /api/transactions/dashboard/balance?userId=1
     * Returns: { "totalIncome": 5000.00, "totalExpense": 2000.00, "currentBalance":
     * 3000.00 }
     */
    @GetMapping("/dashboard/balance")
    public ResponseEntity<Map<String, Object>> getCurrentBalance(@RequestParam Long userId) {
        Map<String, Object> balance = transactionService.getCurrentBalance(userId);
        return ResponseEntity.ok(balance);
    }

    /**
     * For: Income vs Expenses Bar Chart
     * GET /api/transactions/dashboard/monthly-summary?userId=1&year=2024
     * Returns: [ { "month": "Jan", "income": 1500.00, "expense": 1200.00 }, ... ]
     */
    @GetMapping("/dashboard/monthly-summary")
    public ResponseEntity<List<Map<String, Object>>> getMonthlySummary(
            @RequestParam Long userId,
            @RequestParam int year) {
        List<Map<String, Object>> summary = transactionService.getMonthlySummary(userId, year);
        return ResponseEntity.ok(summary);
    }

    /**
     * For: Recent Transactions List
     * GET /api/transactions/dashboard/recent?userId=1&limit=5
     * Returns: List of Transaction objects
     */
    @GetMapping("/dashboard/recent")
    public ResponseEntity<List<Transaction>> getRecentTransactions(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "5") int limit) {
        List<Transaction> recent = transactionService.getRecentTransactions(userId, limit);
        return ResponseEntity.ok(recent);
    }

    /**
     * For: Spending Categories Pie Chart
     * GET /api/transactions/dashboard/spending-categories?userId=1
     * Returns: { "totalSpending": 5000.00, "categories":
     * [{"label":"Food","value":40,"color":"#42A5F5"}] }
     */
    @GetMapping("/dashboard/spending-categories")
    public ResponseEntity<Map<String, Object>> getSpendingCategories(
            @RequestParam Long userId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        Map<String, Object> spending = transactionService.getSpendingByCategory(userId, startDate, endDate);
        return ResponseEntity.ok(spending);
    }

    /**
     * For: Financial Trends Line Chart
     * GET
     * /api/transactions/dashboard/financial-trends?userId=1&startDate=2024-01-01&endDate=2024-12-31
     * Returns: [ { "month": 0, "balance": 1000.0 }, { "month": 1, "balance": 1500.0
     * }, ... ]
     */
    @GetMapping("/dashboard/financial-trends")
    public ResponseEntity<List<Map<String, Object>>> getFinancialTrends(
            @RequestParam Long userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        List<Map<String, Object>> trends = transactionService.getFinancialTrends(userId, startDate, endDate);
        return ResponseEntity.ok(trends);
    }
}
