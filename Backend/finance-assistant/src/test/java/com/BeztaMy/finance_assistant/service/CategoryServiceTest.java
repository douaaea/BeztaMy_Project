package com.BeztaMy.finance_assistant.service;

import com.BeztaMy.finance_assistant.dto.CategoryRequest;
import com.BeztaMy.finance_assistant.entity.Category;
import com.BeztaMy.finance_assistant.repository.CategoryRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CategoryServiceTest {

    @Mock
    private CategoryRepository categoryRepository;

    @InjectMocks
    private CategoryService categoryService;

    private Category testCategory;
    private CategoryRequest categoryRequest;
    private Long userId;

    @BeforeEach
    void setUp() {
        userId = 1L;

        testCategory = new Category();
        testCategory.setId(1L);
        testCategory.setUserId(userId);
        testCategory.setName("Food");
        testCategory.setType("EXPENSE");
        testCategory.setIcon("food_icon");
        testCategory.setIsDefault(false);
        testCategory.setCreatedAt(LocalDateTime.now());

        categoryRequest = new CategoryRequest();
        categoryRequest.setName("Food");
        categoryRequest.setType("EXPENSE");
        categoryRequest.setIcon("food_icon");
    }

    @Test
    void getCategoriesForUser_WithoutType_ShouldReturnAllCategories() {
        List<Category> expectedCategories = Arrays.asList(testCategory);
        when(categoryRepository.findAllForUser(userId)).thenReturn(expectedCategories);

        List<Category> result = categoryService.getCategoriesForUser(userId, null);

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals(testCategory.getId(), result.get(0).getId());
        verify(categoryRepository, times(1)).findAllForUser(userId);
        verify(categoryRepository, never()).findAllForUserAndType(anyLong(), anyString());
    }

    @Test
    void getCategoriesForUser_WithType_ShouldReturnFilteredCategories() {
        List<Category> expectedCategories = Arrays.asList(testCategory);
        when(categoryRepository.findAllForUserAndType(userId, "EXPENSE")).thenReturn(expectedCategories);

        List<Category> result = categoryService.getCategoriesForUser(userId, "EXPENSE");

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("EXPENSE", result.get(0).getType());
        verify(categoryRepository, times(1)).findAllForUserAndType(userId, "EXPENSE");
        verify(categoryRepository, never()).findAllForUser(anyLong());
    }

    @Test
    void createCategory_ShouldCreateAndReturnCategory() {
        when(categoryRepository.findByUserIdAndNameIgnoreCase(userId, "Food")).thenReturn(Optional.empty());
        when(categoryRepository.save(any(Category.class))).thenReturn(testCategory);

        Category result = categoryService.createCategory(userId, categoryRequest);

        assertNotNull(result);
        assertEquals("Food", result.getName());
        verify(categoryRepository, times(1)).findByUserIdAndNameIgnoreCase(userId, "Food");
        verify(categoryRepository, times(1)).save(any(Category.class));
    }

    @Test
    void createCategory_ShouldThrowException_WhenNameExists() {
        when(categoryRepository.findByUserIdAndNameIgnoreCase(userId, "Food"))
                .thenReturn(Optional.of(testCategory));

        assertThrows(RuntimeException.class, () -> {
            categoryService.createCategory(userId, categoryRequest);
        });

        verify(categoryRepository, times(1)).findByUserIdAndNameIgnoreCase(userId, "Food");
        verify(categoryRepository, never()).save(any(Category.class));
    }

    @Test
    void updateCategory_ShouldUpdateAndReturnCategory() {
        CategoryRequest updateRequest = new CategoryRequest();
        updateRequest.setName("Updated Food");
        updateRequest.setType("EXPENSE");
        updateRequest.setIcon("new_icon");

        when(categoryRepository.findByIdAndVisibleToUser(1L, userId)).thenReturn(Optional.of(testCategory));
        when(categoryRepository.save(any(Category.class))).thenReturn(testCategory);

        Category result = categoryService.updateCategory(1L, userId, updateRequest);

        assertNotNull(result);
        verify(categoryRepository, times(1)).findByIdAndVisibleToUser(1L, userId);
        verify(categoryRepository, times(1)).save(any(Category.class));
    }

    @Test
    void updateCategory_ShouldThrowException_WhenCategoryNotFound() {
        when(categoryRepository.findByIdAndVisibleToUser(999L, userId)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> {
            categoryService.updateCategory(999L, userId, categoryRequest);
        });

        verify(categoryRepository, times(1)).findByIdAndVisibleToUser(999L, userId);
        verify(categoryRepository, never()).save(any(Category.class));
    }

    @Test
    void updateCategory_ShouldThrowException_WhenCategoryIsDefault() {
        testCategory.setIsDefault(true);
        when(categoryRepository.findByIdAndVisibleToUser(1L, userId)).thenReturn(Optional.of(testCategory));

        assertThrows(RuntimeException.class, () -> {
            categoryService.updateCategory(1L, userId, categoryRequest);
        });

        verify(categoryRepository, times(1)).findByIdAndVisibleToUser(1L, userId);
        verify(categoryRepository, never()).save(any(Category.class));
    }

    @Test
    void deleteCategory_ShouldDeleteCategory() {
        when(categoryRepository.findByIdAndVisibleToUser(1L, userId)).thenReturn(Optional.of(testCategory));
        doNothing().when(categoryRepository).delete(testCategory);

        categoryService.deleteCategory(1L, userId);

        verify(categoryRepository, times(1)).findByIdAndVisibleToUser(1L, userId);
        verify(categoryRepository, times(1)).delete(testCategory);
    }

    @Test
    void deleteCategory_ShouldThrowException_WhenCategoryNotFound() {
        when(categoryRepository.findByIdAndVisibleToUser(999L, userId)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> {
            categoryService.deleteCategory(999L, userId);
        });

        verify(categoryRepository, times(1)).findByIdAndVisibleToUser(999L, userId);
        verify(categoryRepository, never()).delete(any(Category.class));
    }

    @Test
    void deleteCategory_ShouldThrowException_WhenCategoryIsDefault() {
        testCategory.setIsDefault(true);
        when(categoryRepository.findByIdAndVisibleToUser(1L, userId)).thenReturn(Optional.of(testCategory));

        assertThrows(RuntimeException.class, () -> {
            categoryService.deleteCategory(1L, userId);
        });

        verify(categoryRepository, times(1)).findByIdAndVisibleToUser(1L, userId);
        verify(categoryRepository, never()).delete(any(Category.class));
    }
}
