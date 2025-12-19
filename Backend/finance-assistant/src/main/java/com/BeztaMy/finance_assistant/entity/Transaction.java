package com.BeztaMy.finance_assistant.entity;

import com.BeztaMy.finance_assistant.enums.TransactionType;
import com.BeztaMy.finance_assistant.enums.Frequency;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Entity
@Table(name = "transactions")
@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TransactionType type;

    @Column(nullable = false, precision = 19, scale = 2)
    private BigDecimal amount;

    private String description;

    @Column(length = 1000)
    private String location;

    @Column(nullable = false)
    private LocalDate transactionDate;

    @Column(nullable = false)
    private Boolean isRecurring = false;

    @Enumerated(EnumType.STRING)
    private Frequency frequency;

    private LocalDate nextExecutionDate;

    private LocalDate endDate;

    private Boolean isActive = true;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Constructeurs
    public Transaction() {
    }

    // si tu veux garder un constructeur complet, tu le fais avec Category (pas
    // categoryId)
    public Transaction(Long id,
            Long userId,
            Category category,
            TransactionType type,
            BigDecimal amount,
            String description,
            String location,
            LocalDate transactionDate,
            Boolean isRecurring,
            Frequency frequency,
            LocalDate nextExecutionDate,
            LocalDate endDate,
            Boolean isActive,
            LocalDateTime createdAt,
            LocalDateTime updatedAt) {
        this.id = id;
        this.userId = userId;
        this.category = category;
        this.type = type;
        this.amount = amount;
        this.description = description;
        this.location = location;
        this.transactionDate = transactionDate;
        this.isRecurring = isRecurring;
        this.frequency = frequency;
        this.nextExecutionDate = nextExecutionDate;
        this.endDate = endDate;
        this.isActive = isActive;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters
    public Long getId() {
        return id;
    }

    public Long getUserId() {
        return userId;
    }

    public Category getCategory() {
        return category;
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

    public LocalDate getNextExecutionDate() {
        return nextExecutionDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    // Setters
    public void setId(Long id) {
        this.id = id;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public void setCategory(Category category) {
        this.category = category;
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

    public void setNextExecutionDate(LocalDate nextExecutionDate) {
        this.nextExecutionDate = nextExecutionDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
