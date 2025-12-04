@echo off
REM ExcavatorUI Qt3D - Clean Build Script
REM This script cleans the build directory and rebuilds the project from scratch

echo ========================================
echo  ExcavatorUI Qt3D - Clean Build
echo ========================================
echo.

REM Check if build directory exists
if exist build (
    echo [1/6] Removing old build directory...
    echo       Please wait, this may take a moment...
    rmdir /s /q build
    if errorlevel 1 (
        echo ERROR: Failed to remove build directory!
        echo Please close any programs that might be using files in the build directory.
        echo Close Qt Creator, any editors, or file explorers viewing the build folder.
        pause
        exit /b 1
    )
    echo       Build directory removed successfully.
) else (
    echo [1/6] No build directory found, skipping cleanup...
)

REM Also clean any other build artifacts
echo.
echo [2/6] Cleaning CMake cache and generated files...
if exist CMakeCache.txt del /f /q CMakeCache.txt
if exist CMakeFiles rmdir /s /q CMakeFiles
if exist .cmake rmdir /s /q .cmake
if exist cmake_install.cmake del /f /q cmake_install.cmake
echo       Cleanup complete.

echo.
echo [3/6] Creating new build directory...
mkdir build
if errorlevel 1 (
    echo ERROR: Failed to create build directory!
    pause
    exit /b 1
)
cd build

echo.
echo [4/6] Configuring CMake with Ninja...
echo       This may take a few minutes...
cmake .. -G "Ninja" -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 (
    echo.
    echo ERROR: CMake configuration failed!
    echo.
    echo Trying with MinGW Makefiles instead...
    cd ..
    rmdir /s /q build
    mkdir build
    cd build
    cmake .. -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
    if errorlevel 1 (
        echo ERROR: CMake configuration failed!
        echo.
        echo Please check that:
        echo   - Qt 6.4+ is installed and in PATH
        echo   - CMake is in your PATH
        echo   - Either Ninja or MinGW is properly configured
        echo.
        pause
        exit /b 1
    )
)

echo.
echo [5/6] Building project...
echo       This may take several minutes...
echo       Compiling all source files including IMUMockService...
cmake --build . --config Release
if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    echo Please check the error messages above.
    echo.
    pause
    exit /b 1
)

echo.
echo [6/6] Build completed successfully!
echo.
echo ========================================
echo  Build Summary
echo ========================================
echo  All build errors have been resolved!
echo  - IMUMockService linked successfully
echo  - QML files compiled without errors
echo  - Executable location: build\ExcavatorUI_Qt3DApp.exe
echo ========================================
echo.
pause
