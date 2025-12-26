"""
E2E Test for BeztaMy Flutter Web App using PyAutoGUI
This test performs: Sign Up -> Logout -> Login -> Dashboard -> Transactions
"""
import pyautogui
import time
import subprocess
import sys

# Disable fail-safe (moving mouse to corner won't stop the script)
pyautogui.FAILSAFE = False
# Add small pause between PyAutoGUI calls for stability
pyautogui.PAUSE = 0.5

# Configuration
APP_URL = "http://localhost:62935/#/login"
CHROME_PATH = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
WAIT_SHORT = 1
WAIT_MEDIUM = 2
WAIT_LONG = 4

def log(message):
    """Print timestamped log message"""
    print(f"[{time.strftime('%H:%M:%S')}] {message}")

def wait_and_click(x, y, description=""):
    """Move to position, wait, and click"""
    log(f"Clicking: {description} at ({x}, {y})")
    pyautogui.moveTo(x, y, duration=0.5)
    time.sleep(0.3)
    pyautogui.click()
    time.sleep(WAIT_SHORT)

def type_text(text, description=""):
    """Type text with delay between characters"""
    log(f"Typing: {description}")
    pyautogui.write(text, interval=0.1)
    time.sleep(WAIT_SHORT)

def main():
    log("Starting E2E Test")
    
    # Generate unique credentials
    timestamp = int(time.time())
    email = f"testuser_{timestamp}@example.com"
    password = "password123"
    
    log(f"Test credentials: {email} / {password}")
    
    # Launch Chrome with app
    log("Launching Chrome...")
    subprocess.Popen([CHROME_PATH, f"--new-window", APP_URL])
    time.sleep(WAIT_LONG)
    
    # Maximize window
    pyautogui.hotkey('win', 'up')
    time.sleep(WAIT_SHORT)
    
    # CLICK CENTER TO FOCUS BROSWER CONTENT
    # This prevents typing into the address bar
    log("Focusing browser content...")
    pyautogui.click(960, 540) 
    time.sleep(WAIT_MEDIUM)
    
    try:
        # === SIGN UP ===
        log("=== STARTING SIGN UP ===")
        
        # Click "Create an account" link (990, 512)
        # ADJUST THESE COORDS if it clicks the address bar!
        wait_and_click(990, 512, "Create an account link")
        time.sleep(WAIT_MEDIUM)
        
        # Fill First Name
        # CLICK FIRST TO FOCUS INPUT
        wait_and_click(700, 350, "First Name field")
        type_text("Test", "First Name")
        
        # Fill Last Name
        pyautogui.press('tab')
        time.sleep(0.3)
        type_text("User", "Last Name")
        
        # Fill Email
        pyautogui.press('tab')
        time.sleep(0.3)
        type_text(email, "Email")
        
        # Fill Phone
        pyautogui.press('tab')
        time.sleep(0.3)
        type_text("1234567890", "Phone")
        
        # Fill Status
        pyautogui.press('tab')
        time.sleep(0.3)
        type_text("Tester", "Status")
        
        # Fill Password
        pyautogui.press('tab')
        time.sleep(0.3)
        type_text(password, "Password")
        
        # Fill Confirm Password
        pyautogui.press('tab')
        time.sleep(0.3)
        type_text(password, "Confirm Password")
        
        # Accept Terms checkbox
        pyautogui.press('tab')
        time.sleep(0.3)
        pyautogui.press('space')
        time.sleep(WAIT_SHORT)
        
        # Click Create Account button
        wait_and_click(960, 750, "Create Account button")
        time.sleep(WAIT_LONG)
        
        log("Sign up completed, waiting for dashboard...")
        time.sleep(WAIT_LONG)
        
        # === LOGOUT ===
        log("=== STARTING LOGOUT ===")
        
        # Click Log Out in sidebar
        wait_and_click(200, 600, "Log Out button")
        time.sleep(WAIT_MEDIUM)
        
        log("Logged out successfully")
        
        # === LOGIN ===
        log("=== STARTING LOGIN ===")
        
        # Click Email field (924, 255)
        wait_and_click(924, 255, "Email field")
        type_text(email, "Email for login")
        
        # Click Password field (924, 347)
        pyautogui.press('tab')
        time.sleep(0.3)
        # Or click directly: wait_and_click(924, 347, "Password field")
        type_text(password, "Password for login")
        
        # Click Sign In button (924, 463)
        wait_and_click(924, 463, "Sign In button")
        time.sleep(WAIT_LONG)
        
        log("Login completed")
        
        # === DASHBOARD ===
        log("=== VERIFYING DASHBOARD ===")
        time.sleep(WAIT_MEDIUM)
        
        # Scroll down
        pyautogui.scroll(-3)
        time.sleep(WAIT_SHORT)
        
        # Scroll up
        pyautogui.scroll(3)
        time.sleep(WAIT_SHORT)
        
        # === TRANSACTIONS ===
        log("=== NAVIGATING TO TRANSACTIONS ===")
        
        # Click Transactions in sidebar
        wait_and_click(200, 300, "Transactions menu")
        time.sleep(WAIT_MEDIUM)
        
        # Click Add Entry
        wait_and_click(200, 350, "Add Entry menu")
        time.sleep(WAIT_MEDIUM)
        
        # Select Income
        wait_and_click(800, 300, "Income choice")
        time.sleep(WAIT_SHORT)
        
        # Enter Amount
        wait_and_click(700, 400, "Amount field")
        type_text("1500", "Amount")
        
        # Enter Description
        pyautogui.press('tab')
        time.sleep(0.3)
        type_text("Weekly Salary", "Description")
        
        # Click Save button
        wait_and_click(960, 700, "Save Transaction button")
        time.sleep(WAIT_LONG)
        
        log("=== TEST COMPLETED SUCCESSFULLY ===")
        
    except Exception as e:
        log(f"ERROR: {str(e)}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == "__main__":
    # Safety: 5 second delay to position windows
    log("Starting in 5 seconds... Position your windows now!")
    time.sleep(5)
    
    exit_code = main()
    
    log(f"Test finished with exit code: {exit_code}")
    sys.exit(exit_code)
