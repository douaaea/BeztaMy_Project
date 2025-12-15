package com.BeztaMy.finance_assistant.repository;

import com.BeztaMy.finance_assistant.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {

    List<Category> findByUserId(Long userId);

    Optional<Category> findByUserIdAndNameIgnoreCase(Long userId, String name);

    @Query("SELECT c FROM Category c " +
            "WHERE (c.userId = :userId OR c.isDefault = true)")
    List<Category> findAllForUser(@Param("userId") Long userId);

    @Query("SELECT c FROM Category c " +
            "WHERE (c.userId = :userId OR c.isDefault = true) " +
            "AND c.type = :type")
    List<Category> findAllForUserAndType(@Param("userId") Long userId,
                                         @Param("type") String type);

    @Query("SELECT c FROM Category c " +
            "WHERE c.id = :id AND (c.userId = :userId OR c.isDefault = true)")
    Optional<Category> findByIdAndVisibleToUser(@Param("id") Long id,
                                                @Param("userId") Long userId);
}
