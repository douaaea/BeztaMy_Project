package com.BeztaMy.finance_assistant.dto;

import com.BeztaMy.finance_assistant.enums.TransactionType;
import com.BeztaMy.finance_assistant.enums.Frequency;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;

public class TransactionRequest {

    @NotNull(message = "Category ID is required")
    private Long categoryId;

    @NotNull(message = "Type is required")
    private TransactionType type;

    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "Amount must be greater than 0")
    private BigDecimal amount;

    private String description;

    private String location;

    @NotNull(message = "Transaction date is required")
    private LocalDate transactionDate;

    private Boolean isRecurring = false;

    private Frequency frequency;

    private LocalDate endDate;

    private LocalDate nextExecutionDate;

    private Boolean isActive = true;

    public TransactionRequest() {
    }

    public TransactionRequest(Long categoryId,
            TransactionType type,
            BigDecimal amount,
            String description,
            String location,
            LocalDate transactionDate,
            Boolean isRecurring,
            Frequency frequency,
            LocalDate endDate,
            LocalDate nextExecutionDate,
            Boolean isActive) {

        this.categoryId = categoryId;
        this.type = type;
        this.amount = amount;
        this.description = description;
        this.location = location;
        this.transactionDate = transactionDate;
        this.isRecurring = isRecurring;
        this.frequency = frequency;
        this.frequency = frequency;
        this.endDate = endDate;
        this.nextExecutionDate = nextExecutionDate;
        this.isActive = isActive;
    }

    public Long getCategoryId() {
        return categoryId;
    }

    public TransactionType getType() {
        return type;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public String getDescription() {
        return description;
    }

    public String getLocation() {
        return location;
    }

    public LocalDate getTransactionDate() {
        return transactionDate;
    }

    public Boolean getIsRecurring() {
        return isRecurring;
    }

    public Frequency getFrequency() {
        return frequency;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
    }

    public void setType(TransactionType type) {
        this.type = type;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public void setTransactionDate(LocalDate transactionDate) {
        this.transactionDate = transactionDate;
    }

    public void setIsRecurring(Boolean isRecurring) {
        this.isRecurring = isRecurring;
    }

    public void setFrequency(Frequency frequency) {
        this.frequency = frequency;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public LocalDate getNextExecutionDate() {
        return nextExecutionDate;
    }

    public void setNextExecutionDate(LocalDate nextExecutionDate) {
        this.nextExecutionDate = nextExecutionDate;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
}
