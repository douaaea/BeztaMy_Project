package com.BeztaMy.finance_assistant.service;

import com.BeztaMy.finance_assistant.entity.Transaction;
import com.BeztaMy.finance_assistant.enums.TransactionType;
import com.BeztaMy.finance_assistant.repository.TransactionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class TransactionService {

    private final TransactionRepository transactionRepository;

    @Autowired
    public TransactionService(TransactionRepository transactionRepository) {
        this.transactionRepository = transactionRepository;
    }

    // Random color assignment for categories
    private String getRandomCategoryColor(int index) {
        String[] colors = {
                "#42A5F5", // Blue
                "#66BB6A", // Green
                "#FFA726", // Orange
                "#AB47BC", // Purple
                "#EF5350", // Red
                "#26C6DA", // Cyan
                "#FFCA28", // Amber
                "#EC407A", // Pink
                "#7E57C2", // Deep Purple
                "#29B6F6", // Light Blue
                "#8BC34A", // Light Green
                "#FF7043", // Deep Orange
                "#5C6BC0", // Indigo
                "#FFA726"  // Orange
        };

        // Simply cycle through colors based on index
        return colors[index % colors.length];
    }

    // ============ EXISTING CRUD METHODS ============

    public List<Transaction> getAllTransactionsByUser(Long userId) {
        return transactionRepository.findByUserId(userId);
    }

    public Optional<Transaction> getTransactionById(Long id) {
        return transactionRepository.findById(id);
    }

    @Transactional
    public Transaction createTransaction(Transaction transaction) {
        return transactionRepository.save(transaction);
    }

    @Transactional
    public Transaction updateTransaction(Long id, Transaction transactionDetails) {
        Transaction transaction = transactionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Transaction not found with id: " + id));

        transaction.setCategory(transactionDetails.getCategory());
        transaction.setType(transactionDetails.getType());
        transaction.setAmount(transactionDetails.getAmount());
        transaction.setDescription(transactionDetails.getDescription());
        transaction.setLocation(transactionDetails.getLocation());
        transaction.setTransactionDate(transactionDetails.getTransactionDate());
        transaction.setIsRecurring(transactionDetails.getIsRecurring());
        transaction.setFrequency(transactionDetails.getFrequency());
        transaction.setNextExecutionDate(transactionDetails.getNextExecutionDate());
        transaction.setEndDate(transactionDetails.getEndDate());
        transaction.setIsActive(transactionDetails.getIsActive());

        return transactionRepository.save(transaction);
    }

    @Transactional
    public void deleteTransaction(Long id) {
        if (!transactionRepository.existsById(id)) {
            throw new RuntimeException("Transaction not found with id: " + id);
        }
        transactionRepository.deleteById(id);
    }

    public List<Transaction> getTransactionsByFilters(
            Long userId, LocalDate startDate, LocalDate endDate,
            Long categoryId, TransactionType type) {
        return transactionRepository.findByFilters(userId, startDate, endDate, categoryId, type);
    }

    public List<Transaction> getTransactionsByType(Long userId, TransactionType type) {
        return transactionRepository.findByUserIdAndType(userId, type);
    }

    public List<Transaction> getTransactionsByCategory(Long userId, Long categoryId) {
        return transactionRepository.findByUserIdAndCategory_Id(userId, categoryId);
    }

    // ============ DASHBOARD DATA FOR FLUTTER ============

    /**
     * Flutter expects: { "totalIncome": 5000.00, "totalExpense": 2000.00, "currentBalance": 3000.00 }
     */
    public Map<String, Object> getCurrentBalance(Long userId) {
        List<Transaction> transactions = transactionRepository.findByUserId(userId);

        BigDecimal totalIncome = transactions.stream()
                .filter(t -> t.getType() == TransactionType.INCOME)
                .map(Transaction::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalExpense = transactions.stream()
                .filter(t -> t.getType() == TransactionType.EXPENSE)
                .map(Transaction::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Map<String, Object> balance = new HashMap<>();
        balance.put("totalIncome", totalIncome);
        balance.put("totalExpense", totalExpense);
        balance.put("currentBalance", totalIncome.subtract(totalExpense));

        return balance;
    }

    /**
     * Flutter expects: [ { "month": "Jan", "income": 1500.00, "expense": 1200.00 }, ... ]
     * For Income vs Expenses Bar Chart
     */
    public List<Map<String, Object>> getMonthlySummary(Long userId, int year) {
        List<Transaction> transactions = transactionRepository.findByUserId(userId);

        transactions = transactions.stream()
                .filter(t -> t.getTransactionDate().getYear() == year)
                .collect(Collectors.toList());

        Map<Integer, List<Transaction>> byMonth = transactions.stream()
                .collect(Collectors.groupingBy(t -> t.getTransactionDate().getMonthValue()));

        List<Map<String, Object>> monthlyData = new ArrayList<>();
        String[] months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

        for (int i = 1; i <= 12; i++) {
            List<Transaction> monthTransactions = byMonth.getOrDefault(i, new ArrayList<>());

            BigDecimal income = monthTransactions.stream()
                    .filter(t -> t.getType() == TransactionType.INCOME)
                    .map(Transaction::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            BigDecimal expense = monthTransactions.stream()
                    .filter(t -> t.getType() == TransactionType.EXPENSE)
                    .map(Transaction::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            Map<String, Object> monthData = new HashMap<>();
            monthData.put("month", months[i-1]);
            monthData.put("income", income);
            monthData.put("expense", expense);
            monthlyData.add(monthData);
        }

        return monthlyData;
    }

    /**
     * Flutter expects: List of recent Transaction objects
     * For Recent Transactions list
     */
    public List<Transaction> getRecentTransactions(Long userId, int limit) {
        List<Transaction> allTransactions = transactionRepository.findByUserId(userId);
        return allTransactions.stream()
                .sorted((t1, t2) -> t2.getTransactionDate().compareTo(t1.getTransactionDate()))
                .limit(limit)
                .collect(Collectors.toList());
    }

    /**
     * Flutter expects: {
     *   "totalSpending": 5000.00,
     *   "categories": [
     *     { "label": "Food", "value": 40.0, "color": "#42A5F5" }
     *   ]
     * }
     * For Spending Categories Pie Chart (RANDOM COLORS)
     */
    public Map<String, Object> getSpendingByCategory(Long userId, LocalDate startDate, LocalDate endDate) {
        List<Transaction> transactions = transactionRepository.findByUserId(userId);

        if (startDate != null && endDate != null) {
            transactions = transactions.stream()
                    .filter(t -> !t.getTransactionDate().isBefore(startDate) &&
                            !t.getTransactionDate().isAfter(endDate))
                    .collect(Collectors.toList());
        }

        List<Transaction> expenses = transactions.stream()
                .filter(t -> t.getType() == TransactionType.EXPENSE)
                .collect(Collectors.toList());

        BigDecimal totalSpending = expenses.stream()
                .map(Transaction::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Map<String, List<Transaction>> byCategory = expenses.stream()
                .collect(Collectors.groupingBy(t -> t.getCategory().getName()));

        List<Map<String, Object>> categories = new ArrayList<>();
        int index = 0;

        for (Map.Entry<String, List<Transaction>> entry : byCategory.entrySet()) {
            BigDecimal categoryTotal = entry.getValue().stream()
                    .map(Transaction::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            double percentage = totalSpending.compareTo(BigDecimal.ZERO) > 0
                    ? categoryTotal.divide(totalSpending, 4, RoundingMode.HALF_UP)
                    .multiply(new BigDecimal("100")).doubleValue()
                    : 0;

            Map<String, Object> categoryData = new HashMap<>();
            categoryData.put("label", entry.getKey());
            categoryData.put("value", Math.round(percentage));
            // Assign random color based on index
            categoryData.put("color", getRandomCategoryColor(index));
            categories.add(categoryData);
            index++;
        }

        Map<String, Object> result = new HashMap<>();
        result.put("totalSpending", totalSpending);
        result.put("categories", categories);

        return result;
    }

    /**
     * Flutter expects: [ { "month": 0, "balance": 1000.0 }, { "month": 1, "balance": 1500.0 }, ... ]
     * For Financial Trends Line Chart
     */
    public List<Map<String, Object>> getFinancialTrends(Long userId, LocalDate startDate, LocalDate endDate) {
        List<Transaction> transactions = transactionRepository.findByUserId(userId);

        transactions = transactions.stream()
                .filter(t -> !t.getTransactionDate().isBefore(startDate) &&
                        !t.getTransactionDate().isAfter(endDate))
                .sorted((t1, t2) -> t1.getTransactionDate().compareTo(t2.getTransactionDate()))
                .collect(Collectors.toList());

        // Group by month for the line chart
        Map<Integer, BigDecimal> monthlyBalances = new LinkedHashMap<>();
        BigDecimal cumulativeBalance = BigDecimal.ZERO;

        for (Transaction t : transactions) {
            if (t.getType() == TransactionType.INCOME) {
                cumulativeBalance = cumulativeBalance.add(t.getAmount());
            } else {
                cumulativeBalance = cumulativeBalance.subtract(t.getAmount());
            }

            int month = t.getTransactionDate().getMonthValue() - 1; // 0-indexed for Flutter chart
            monthlyBalances.put(month, cumulativeBalance);
        }

        List<Map<String, Object>> trends = new ArrayList<>();
        for (Map.Entry<Integer, BigDecimal> entry : monthlyBalances.entrySet()) {
            Map<String, Object> point = new HashMap<>();
            point.put("month", entry.getKey());
            point.put("balance", entry.getValue().doubleValue());
            trends.add(point);
        }

        return trends;
    }
}
