import pyautogui
import time
import os

def get_mouse_position():
    print("Coordinates Finder Tool")
    print("=========================")
    print("This will help you find the X and Y coordinates for your screen.")
    print("Move your mouse to the target element and wait for the countdown.")
    print("Press Ctrl+C to stop.\n")
    
    try:
        while True:
            for i in range(3, 0, -1):
                print(f"Capturing in {i}...", end="\r")
                time.sleep(1)
            
            x, y = pyautogui.position()
            print(f"Captured: X={x}, Y={y}                                ")
            print("Next capture starting soon...\n")
            time.sleep(2)
    except KeyboardInterrupt:
        print("\nFinished.")

if __name__ == "__main__":
    get_mouse_position()
