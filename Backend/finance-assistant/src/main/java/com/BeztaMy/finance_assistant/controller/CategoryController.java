package com.BeztaMy.finance_assistant.controller;

import com.BeztaMy.finance_assistant.entity.Category;
import com.BeztaMy.finance_assistant.dto.CategoryRequest;
import com.BeztaMy.finance_assistant.service.CategoryService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@CrossOrigin(origins = "*")
public class CategoryController {

    private final CategoryService categoryService;

    @Autowired
    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @GetMapping
    public ResponseEntity<List<Category>> getCategories(
            @RequestParam Long userId,
            @RequestParam(required = false) String type) {

        List<Category> categories = categoryService.getCategoriesForUser(userId, type);
        return ResponseEntity.ok(categories);
    }

    // POST /api/categories?userId=1
    @PostMapping
    public ResponseEntity<Category> createCategory(
            @RequestParam Long userId,
            @Valid @RequestBody CategoryRequest request) {

        Category category = categoryService.createCategory(userId, request);
        return new ResponseEntity<>(category, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Category> updateCategory(
            @PathVariable Long id,
            @RequestParam Long userId,
            @Valid @RequestBody CategoryRequest request) {

        Category updated = categoryService.updateCategory(id, userId, request);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteCategory(
            @PathVariable Long id,
            @RequestParam Long userId) {

        categoryService.deleteCategory(id, userId);
        return ResponseEntity.ok("Category deleted successfully");
    }

    @GetMapping("/test")
    public ResponseEntity<String> test() {
        return ResponseEntity.ok("Category API is working!");
    }
}
