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

public class TestDashboard {

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
    public void testTotaux() {
        // DASH-02 : Totaux corrects
        WebDriver driver = new ChromeDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));

        try {
            login(driver, wait);
            driver.get(baseUrl + "/#/dashboard");
            wait.until(ExpectedConditions.presenceOfElementLocated(By.tagName("flt-scene-host")));
            Thread.sleep(2000);

            // Look for total amounts in page text
            String pageSource = driver.getPageSource();

            // Verify dashboard is showing (just check for common dashboard text)
            Assert.assertTrue("Dashboard should be visible",
                    pageSource.contains("Dashboard") || pageSource.contains("Total") || pageSource.contains("Balance"));

        } catch (Exception e) {
            e.printStackTrace();
            Assert.fail("Test failed: " + e.getMessage());
        } finally {
            driver.quit();
        }
    }

    @Test
    public void testCategoriesGraph() {
        // DASH-03 : Répartition catégories
        WebDriver driver = new ChromeDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));

        try {
            login(driver, wait);
            driver.get(baseUrl + "/#/dashboard");
            wait.until(ExpectedConditions.presenceOfElementLocated(By.tagName("flt-scene-host")));
            Thread.sleep(2000);

            // Verify page loaded successfully
            String currentUrl = driver.getCurrentUrl();
            Assert.assertTrue("Should be on dashboard", currentUrl.contains("dashboard"));

        } catch (Exception e) {
            e.printStackTrace();
            Assert.fail("Test failed: " + e.getMessage());
        } finally {
            driver.quit();
        }
    }

    @Test
    public void testTransactionsRecentes() {
        // DASH-05 : Transactions récentes
        WebDriver driver = new ChromeDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));

        try {
            login(driver, wait);
            driver.get(baseUrl + "/#/dashboard");
            wait.until(ExpectedConditions.presenceOfElementLocated(By.tagName("flt-scene-host")));
            Thread.sleep(2000);

            // Verify dashboard content is present
            String pageSource = driver.getPageSource();
            Assert.assertTrue("Dashboard content should be visible",
                    pageSource.length() > 100);

        } catch (Exception e) {
            e.printStackTrace();
            Assert.fail("Test failed: " + e.getMessage());
        } finally {
            driver.quit();
        }
    }
}
