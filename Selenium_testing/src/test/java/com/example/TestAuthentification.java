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

public class TestAuthentification {

        // URL de base de l'application Flutter web
        String baseUrl = "http://localhost:63456";

        @Test
        public void testInscriptionOK() {
                // 1. Setup
                WebDriver driver = new ChromeDriver();
                WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));

                try {
                        // 2. Scénario : AUTH-01 Inscription
                        driver.get(baseUrl + "/#/signup");

                        // Wait for page to load
                        wait.until(ExpectedConditions.presenceOfElementLocated(By.tagName("flt-scene-host")));
                        Thread.sleep(2000); // Extra wait for Flutter rendering

                        // Find input fields by placeholder text using XPath
                        WebElement emailField = wait.until(ExpectedConditions.presenceOfElementLocated(
                                        By.xpath("//input[@aria-label='Email' or contains(@placeholder, 'email')]")));
                        WebElement passwordField = driver.findElement(
                                        By.xpath("//input[@type='password' or contains(@placeholder, 'password')]"));
                        WebElement firstNameField = driver.findElement(
                                        By.xpath("//input[@aria-label='First Name' or contains(@placeholder, 'First')]"));
                        WebElement lastNameField = driver.findElement(
                                        By.xpath("//input[@aria-label='Last Name' or contains(@placeholder, 'Last')]"));

                        // Fill form
                        emailField.sendKeys("nouveau@test.com");
                        passwordField.sendKeys("password123");
                        firstNameField.sendKeys("Jean");
                        lastNameField.sendKeys("Dupont");

                        // Find and click signup button
                        WebElement signupBtn = driver.findElement(
                                        By.xpath("//button[contains(., 'Sign Up') or contains(., 'Create Account')]"));
                        signupBtn.click();

                        // Wait for navigation or success message
                        Thread.sleep(3000);

                        // 3. Vérification - Check if redirected to dashboard or success shown
                        String currentUrl = driver.getCurrentUrl();
                        Assert.assertTrue("Should redirect to dashboard or show success",
                                        currentUrl.contains("dashboard") || driver.getPageSource().contains("Success"));

                } catch (Exception e) {
                        e.printStackTrace();
                        Assert.fail("Test failed: " + e.getMessage());
                } finally {
                        // 4. Teardown
                        driver.quit();
                }
        }

        @Test
        public void testLoginOK() {
                // 1. Setup
                WebDriver driver = new ChromeDriver();
                WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));

                try {
                        // 2. Scénario : AUTH-03 Login avec identifiants valides
                        driver.get(baseUrl + "/#/login");

                        // Wait for Flutter to render (simple sleep is more reliable)
                        Thread.sleep(5000);

                        // Find email and password fields
                        WebElement emailField = wait.until(ExpectedConditions.presenceOfElementLocated(
                                        By.xpath(
                                                        "//input[@type='email' or contains(@placeholder, 'email') or @aria-label='Email Address']")));
                        WebElement passwordField = driver.findElement(
                                        By.xpath("//input[@type='password']"));

                        // Enter credentials
                        emailField.sendKeys("douaa@douaa.com");
                        passwordField.sendKeys("admin2003");

                        // Click login button
                        WebElement loginBtn = driver.findElement(
                                        By.xpath("//button[contains(., 'Sign In') or contains(., 'Login')]"));
                        loginBtn.click();

                        // Wait for navigation
                        Thread.sleep(3000);

                        // 3. Vérification : Redirection vers Dashboard
                        String currentUrl = driver.getCurrentUrl();
                        Assert.assertTrue("Should be redirected to dashboard",
                                        currentUrl.contains("dashboard"));

                } catch (Exception e) {
                        e.printStackTrace();
                        Assert.fail("Test failed: " + e.getMessage());
                } finally {
                        driver.quit();
                }
        }

        @Test
        public void testLoginIncorrect() {
                // 1. Setup
                WebDriver driver = new ChromeDriver();
                WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));

                try {
                        // 2. Scénario : AUTH-04 Login avec mauvais mot de passe
                        driver.get(baseUrl + "/#/login");

                        // Wait for Flutter
                        wait.until(ExpectedConditions.presenceOfElementLocated(By.tagName("flt-scene-host")));
                        Thread.sleep(2000);

                        // Find fields
                        WebElement emailField = wait.until(ExpectedConditions.presenceOfElementLocated(
                                        By.xpath("//input[@type='email' or contains(@placeholder, 'email')]")));
                        WebElement passwordField = driver.findElement(By.xpath("//input[@type='password']"));

                        // Enter wrong credentials
                        emailField.sendKeys("douaa@douaa.com");
                        passwordField.sendKeys("wrongpassword");

                        // Click login
                        WebElement loginBtn = driver.findElement(
                                        By.xpath("//button[contains(., 'Sign In') or contains(., 'Login')]"));
                        loginBtn.click();

                        // Wait for error message
                        Thread.sleep(2000);

                        // 3. Vérification : Message d'erreur
                        String pageSource = driver.getPageSource();
                        Assert.assertTrue("Error message should be visible",
                                        pageSource.contains("Invalid") || pageSource.contains("incorrect") ||
                                                        pageSource.contains("Error") || pageSource.contains("failed"));

                } catch (Exception e) {
                        e.printStackTrace();
                        Assert.fail("Test failed: " + e.getMessage());
                } finally {
                        driver.quit();
                }
        }
}
