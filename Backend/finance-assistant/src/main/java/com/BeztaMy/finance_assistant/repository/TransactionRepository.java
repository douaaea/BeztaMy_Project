package com.BeztaMy.finance_assistant.repository;

import com.BeztaMy.finance_assistant.entity.Transaction;
import com.BeztaMy.finance_assistant.enums.TransactionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {

    List<Transaction> findByUserId(Long userId);

    List<Transaction> findByUserIdAndType(Long userId, TransactionType type);

    List<Transaction> findByUserIdAndTransactionDateBetween(
            Long userId, LocalDate startDate, LocalDate endDate);

    List<Transaction> findByUserIdAndCategory_Id(Long userId, Long categoryId);

    List<Transaction> findByIsRecurringAndIsActiveAndNextExecutionDate(
            Boolean isRecurring, Boolean isActive, LocalDate date);

    @Query("SELECT t FROM Transaction t WHERE t.userId = :userId " +
            "AND t.transactionDate BETWEEN :startDate AND :endDate " +
            "AND (:categoryId IS NULL OR t.category.id = :categoryId) " +
            "AND (:type IS NULL OR t.type = :type)")
    List<Transaction> findByFilters(@Param("userId") Long userId,
                                    @Param("startDate") LocalDate startDate,
                                    @Param("endDate") LocalDate endDate,
                                    @Param("categoryId") Long categoryId,
                                    @Param("type") TransactionType type);
}
