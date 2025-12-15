package com.BeztaMy.finance_assistant.dto;

import java.time.LocalDateTime;

public class UserProfileResponse {
    private Long id;
    private String email;
    private String firstName;
    private String lastName;
    private String telephone;
    private String status;
    private String profilePicture;
    private LocalDateTime createdAt;
    private Double monthlyBudget;
    private String riskTolerance;
    private String financialGoals;

    public UserProfileResponse() {
    }

    public UserProfileResponse(Long id, String email, String firstName, String lastName,
            String telephone, String status, String profilePicture, LocalDateTime createdAt,
            Double monthlyBudget, String riskTolerance, String financialGoals) {
        this.id = id;
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.telephone = telephone;
        this.status = status;
        this.profilePicture = profilePicture;
        this.createdAt = createdAt;
        this.monthlyBudget = monthlyBudget;
        this.riskTolerance = riskTolerance;
        this.financialGoals = financialGoals;
    }

    // Getters et Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getTelephone() {
        return telephone;
    }

    public void setTelephone(String telephone) {
        this.telephone = telephone;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getProfilePicture() {
        return profilePicture;
    }

    public void setProfilePicture(String profilePicture) {
        this.profilePicture = profilePicture;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Double getMonthlyBudget() {
        return monthlyBudget;
    }

    public void setMonthlyBudget(Double monthlyBudget) {
        this.monthlyBudget = monthlyBudget;
    }

    public String getRiskTolerance() {
        return riskTolerance;
    }

    public void setRiskTolerance(String riskTolerance) {
        this.riskTolerance = riskTolerance;
    }

    public String getFinancialGoals() {
        return financialGoals;
    }

    public void setFinancialGoals(String financialGoals) {
        this.financialGoals = financialGoals;
    }
}
