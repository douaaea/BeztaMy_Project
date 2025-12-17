package com.BeztaMy.finance_assistant.controller;

import com.BeztaMy.finance_assistant.dto.CategoryRequest;
import com.BeztaMy.finance_assistant.entity.Category;
import com.BeztaMy.finance_assistant.service.CategoryService;
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

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;


@SpringBootTest
@AutoConfigureMockMvc
class CategoryControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
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
    @WithMockUser
    void getCategories_ShouldReturnCategoriesList() throws Exception {
        List<Category> categories = Arrays.asList(testCategory);
        when(categoryService.getCategoriesForUser(userId, null)).thenReturn(categories);

        mockMvc.perform(get("/api/categories")
                        .param("userId", userId.toString())
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].name").value("Food"));

        verify(categoryService, times(1)).getCategoriesForUser(userId, null);
    }

    @Test
    @WithMockUser
    void getCategories_WithType_ShouldReturnFilteredCategories() throws Exception {
        List<Category> categories = Arrays.asList(testCategory);
        when(categoryService.getCategoriesForUser(userId, "EXPENSE")).thenReturn(categories);

        mockMvc.perform(get("/api/categories")
                        .param("userId", userId.toString())
                        .param("type", "EXPENSE")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].type").value("EXPENSE"));

        verify(categoryService, times(1)).getCategoriesForUser(userId, "EXPENSE");
    }

    @Test
    @WithMockUser
    void createCategory_ShouldReturnCreatedCategory() throws Exception {
        when(categoryService.createCategory(eq(userId), any(CategoryRequest.class))).thenReturn(testCategory);

        mockMvc.perform(post("/api/categories")
                        .with(csrf())
                        .param("userId", userId.toString())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(categoryRequest)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.name").value("Food"));

        verify(categoryService, times(1)).createCategory(eq(userId), any(CategoryRequest.class));
    }

    @Test
    @WithMockUser
    void updateCategory_ShouldReturnUpdatedCategory() throws Exception {
        when(categoryService.updateCategory(eq(1L), eq(userId), any(CategoryRequest.class)))
                .thenReturn(testCategory);

        mockMvc.perform(put("/api/categories/1")
                        .with(csrf())
                        .param("userId", userId.toString())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(categoryRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.name").value("Food"));

        verify(categoryService, times(1)).updateCategory(eq(1L), eq(userId), any(CategoryRequest.class));
    }

    @Test
    @WithMockUser
    void deleteCategory_ShouldReturnSuccessMessage() throws Exception {
        doNothing().when(categoryService).deleteCategory(1L, userId);

        mockMvc.perform(delete("/api/categories/1")
                        .with(csrf())
                        .param("userId", userId.toString())
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().string("Category deleted successfully"));

        verify(categoryService, times(1)).deleteCategory(1L, userId);
    }

    @Test
    @WithMockUser
    void testEndpoint_ShouldReturnTestMessage() throws Exception {
        mockMvc.perform(get("/api/categories/test")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(content().string("Category API is working!"));
    }
}
