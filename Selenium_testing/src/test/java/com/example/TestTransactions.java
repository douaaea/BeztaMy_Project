package com.example;

import org.junit.Assert;
import org.junit.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.support.ui.ExpectedConditions;
import java.time.Duration;

public class TestTransactions {

    String baseUrl = "http://localhost:63456";

    private void login(WebDriver driver, WebDriverWait wait) throws InterruptedException {
        driver.get(baseUrl + "/#/login");
        wait.until(ExpectedConditions.presenceOfElementLocated(By.tagName("flt-scene-host")));
        Thread.sleep(2000);

        WebElement emailField = wait.until(ExpectedConditions.presenceOfElementLocated(
                By.xpath("//input[@type='email' or contains(@placeholder, 'email')]")));
        WebElement passwordField = driver.findElement(By.xpath("//input[@type='password']"));

        emailField.sendKeys("douaa@douaa.com");
        passwordField.sendKeys("douaa");

        driver.findElement(By.xpath("//button[contains(., 'Sign In')]")).click();
        Thread.sleep(3000);
    }

    @Test
    public void testListeTransactions() {
        // TRX-01 : Liste transactions
        WebDriver driver = new ChromeDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));

        try {
            login(driver, wait);
            driver.get(baseUrl + "/#/transactions");
            wait.until(ExpectedConditions.presenceOfElementLocated(By.tagName("flt-scene-host")));
            Thread.sleep(2000);

            // Verify transactions page loaded
            String currentUrl = driver.getCurrentUrl();
            Assert.assertTrue("Should be on transactions page", currentUrl.contains("transactions"));

        } catch (Exception e) {
            e.printStackTrace();
            Assert.fail("Test failed: " + e.getMessage());
        } finally {
            driver.quit();
        }
    }

    @Test
    public void testAjoutIncome() {
        // TRX-02 : Ajout Income
        WebDriver driver = new ChromeDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));

        try {
            login(driver, wait);
            driver.get(baseUrl + "/#/add-entry");
            wait.until(ExpectedConditions.presenceOfElementLocated(By.tagName("flt-scene-host")));
            Thread.sleep(2000);

            // Find type selector (Income/Expense)
            WebElement incomeButton = wait.until(ExpectedConditions.presenceOfElementLocated(
                    By.xpath("//button[contains(., 'Income') or contains(., 'INCOME')]")));
            incomeButton.click();
            Thread.sleep(500);

            // Find amount field
            WebElement amountField = driver.findElement(
                    By.xpath(
                            "//input[@type='number' or contains(@placeholder, 'amount') or contains(@placeholder, 'Amount')]"));
            amountField.sendKeys("1500");

            // Find description field
            WebElement descField = driver.findElement(
                    By.xpath(
                            "//input[contains(@placeholder, 'description') or contains(@placeholder, 'Description')]"));
            descField.sendKeys("Freelance");

            // Submit
            WebElement submitBtn = driver.findElement(
                    By.xpath("//button[contains(., 'Save') or contains(., 'Add') or contains(., 'Create')]"));
            submitBtn.click();

            Thread.sleep(2000);

            // Verification - should redirect or show success
            String pageSource = driver.getPageSource();
            Assert.assertTrue("Should show success or redirect",
                    pageSource.contains("Success") || driver.getCurrentUrl().contains("transactions"));

        } catch (Exception e) {
            e.printStackTrace();
            Assert.fail("Test failed: " + e.getMessage());
        } finally {
            driver.quit();
        }
    }

    @Test
    public void testAjoutExpense() {
        // TRX-03 : Ajout Expense
        WebDriver driver = new ChromeDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));

        try {
            login(driver, wait);
            driver.get(baseUrl + "/#/add-entry");
            wait.until(ExpectedConditions.presenceOfElementLocated(By.tagName("flt-scene-host")));
            Thread.sleep(2000);

            // Select Expense
            WebElement expenseButton = wait.until(ExpectedConditions.presenceOfElementLocated(
                    By.xpath("//button[contains(., 'Expense') or contains(., 'EXPENSE')]")));
            expenseButton.click();
            Thread.sleep(500);

            // Amount
            WebElement amountField = driver.findElement(
                    By.xpath("//input[@type='number' or contains(@placeholder, 'amount')]"));
            amountField.sendKeys("50");

            // Description
            WebElement descField = driver.findElement(
                    By.xpath("//input[contains(@placeholder, 'description')]"));
            descField.sendKeys("Restaurant");

            // Submit
            WebElement submitBtn = driver.findElement(
                    By.xpath("//button[contains(., 'Save') or contains(., 'Add')]"));
            submitBtn.click();

            Thread.sleep(2000);

            // Verification
            String pageSource = driver.getPageSource();
            Assert.assertTrue("Should show success or redirect",
                    pageSource.contains("Success") || driver.getCurrentUrl().contains("transactions"));

        } catch (Exception e) {
            e.printStackTrace();
            Assert.fail("Test failed: " + e.getMessage());
        } finally {
            driver.quit();
        }
    }
}
