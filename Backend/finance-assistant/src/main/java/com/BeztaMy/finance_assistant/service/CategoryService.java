package com.BeztaMy.finance_assistant.service;

import com.BeztaMy.finance_assistant.entity.Category;
import com.BeztaMy.finance_assistant.dto.CategoryRequest;
import com.BeztaMy.finance_assistant.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class CategoryService {

    private final CategoryRepository categoryRepository;

    @Autowired
    public CategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    public List<Category> getCategoriesForUser(Long userId, String type) {
        if (type != null && !type.isEmpty()) {
            return categoryRepository.findAllForUserAndType(userId, type);
        }
        return categoryRepository.findAllForUser(userId);
    }

    @Transactional
    public Category createCategory(Long userId, CategoryRequest request) {
        categoryRepository.findByUserIdAndNameIgnoreCase(userId, request.getName())
                .ifPresent(c -> {
                    throw new RuntimeException("Category with this name already exists for user");
                });

        Category category = new Category();
        category.setUserId(userId);
        category.setName(request.getName());
        category.setType(request.getType());
        category.setIcon(request.getIcon());
        category.setIsDefault(false);
        category.setCreatedAt(LocalDateTime.now());

        return categoryRepository.save(category);
    }

    @Transactional
    public Category updateCategory(Long id, Long userId, CategoryRequest request) {
        Category existing = categoryRepository.findByIdAndVisibleToUser(id, userId)
                .orElseThrow(() -> new RuntimeException("Category not found"));

        if (Boolean.TRUE.equals(existing.getIsDefault())) {
            throw new RuntimeException("Default categories cannot be modified");
        }

        existing.setName(request.getName());
        existing.setType(request.getType());
        existing.setIcon(request.getIcon());

        return categoryRepository.save(existing);
    }

    @Transactional
    public void deleteCategory(Long id, Long userId) {
        Category existing = categoryRepository.findByIdAndVisibleToUser(id, userId)
                .orElseThrow(() -> new RuntimeException("Category not found"));

        if (Boolean.TRUE.equals(existing.getIsDefault())) {
            throw new RuntimeException("Default categories cannot be deleted");
        }

        categoryRepository.delete(existing);
    }
}
