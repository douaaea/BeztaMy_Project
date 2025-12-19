@echo off
REM Script to update Selenium test port number
REM Usage: update_port.bat <new_port_number>

if "%1"=="" (
    echo Error: Please provide port number
    echo Usage: update_port.bat 12345
    exit /b 1
)

set NEW_PORT=%1
set OLD_PORT=62935

echo Updating port from %OLD_PORT% to %NEW_PORT%...

powershell -Command "(Get-Content 'src\test\java\com\example\TestAuthentification.java') -replace 'localhost:%OLD_PORT%', 'localhost:%NEW_PORT%' | Set-Content 'src\test\java\com\example\TestAuthentification.java'"
powershell -Command "(Get-Content 'src\test\java\com\example\TestDashboard.java') -replace 'localhost:%OLD_PORT%', 'localhost:%NEW_PORT%' | Set-Content 'src\test\java\com\example\TestDashboard.java'"
powershell -Command "(Get-Content 'src\test\java\com\example\TestTransactions.java') -replace 'localhost:%OLD_PORT%', 'localhost:%NEW_PORT%' | Set-Content 'src\test\java\com\example\TestTransactions.java'"
powershell -Command "(Get-Content 'src\test\java\com\example\TestAddEntry.java') -replace 'localhost:%OLD_PORT%', 'localhost:%NEW_PORT%' | Set-Content 'src\test\java\com\example\TestAddEntry.java'"
powershell -Command "(Get-Content 'src\test\java\com\example\TestProfil.java') -replace 'localhost:%OLD_PORT%', 'localhost:%NEW_PORT%' | Set-Content 'src\test\java\com\example\TestProfil.java'"
powershell -Command "(Get-Content 'src\test\java\com\example\TestEndToEnd.java') -replace 'localhost:%OLD_PORT%', 'localhost:%NEW_PORT%' | Set-Content 'src\test\java\com\example\TestEndToEnd.java'"

echo Done! All test files updated to use port %NEW_PORT%
