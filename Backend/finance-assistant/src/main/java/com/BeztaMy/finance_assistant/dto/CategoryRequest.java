package com.BeztaMy.finance_assistant.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class CategoryRequest {

    @NotBlank(message = "Name is required")
    @Size(max = 100, message = "Name must be at most 100 characters")
    private String name;

    @NotBlank(message = "Type is required")   // "INCOME" ou "EXPENSE"
    private String type;

    @Size(max = 100, message = "Icon must be at most 100 characters")
    private String icon;

    public CategoryRequest() {}

    public CategoryRequest(String name, String type, String icon) {
        this.name = name;
        this.type = type;
        this.icon = icon;
    }

    public String getName() {
        return name;
    }

    public String getType() {
        return type;
    }

    public String getIcon() {
        return icon;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setType(String type) {
        this.type = type;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }
}
