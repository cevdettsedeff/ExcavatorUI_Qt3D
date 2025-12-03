@echo off
REM ExcavatorUI Qt3D - Clean Build Script
REM This script cleans the build directory and rebuilds the project from scratch

echo ========================================
echo  ExcavatorUI Qt3D - Clean Build
echo ========================================
echo.

REM Check if build directory exists
if exist build (
    echo [1/5] Removing old build directory...
    rmdir /s /q build
    if errorlevel 1 (
        echo ERROR: Failed to remove build directory!
        echo Please close any programs that might be using files in the build directory.
        pause
        exit /b 1
    )
    echo       Build directory removed successfully.
) else (
    echo [1/5] No build directory found, skipping cleanup...
)

echo.
echo [2/5] Creating new build directory...
mkdir build
if errorlevel 1 (
    echo ERROR: Failed to create build directory!
    pause
    exit /b 1
)
cd build

echo.
echo [3/5] Configuring CMake...
echo       This may take a few minutes...
cmake .. -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 (
    echo ERROR: CMake configuration failed!
    echo Please check that:
    echo   - Qt 6.4+ is installed
    echo   - CMake is in your PATH
    echo   - MinGW is properly configured
    pause
    exit /b 1
)

echo.
echo [4/5] Building project...
echo       This may take several minutes...
cmake --build . --config Release
if errorlevel 1 (
    echo ERROR: Build failed!
    echo Please check the error messages above.
    pause
    exit /b 1
)

echo.
echo [5/5] Build completed successfully!
echo.
echo ========================================
echo  Build Summary
echo ========================================
echo  Executable location: build\ExcavatorUI_Qt3DApp.exe
echo ========================================
echo.
pause
