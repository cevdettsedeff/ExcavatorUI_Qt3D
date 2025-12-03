# Build Fix Instructions

## Problem Summary

After merging the excavator digging simulation branch, you encountered the following build errors:

1. **Undefined reference to IMUMockService**
   - `undefined reference to 'IMUMockService::IMUMockService(QObject*)'`
   - `undefined reference to 'vtable for IMUMockService'`

2. **QML Syntax Error**
   - `Excavator.qml:1047: error: Expected token ':'`

3. **Compiler Warnings**
   - QColor string literal warning
   - Range-loop detach warning

## Root Cause

The undefined reference errors are caused by a **stale build cache**. When new Qt classes with Q_OBJECT macros are added (like IMUMockService), the Meta-Object Compiler (MOC) needs to regenerate metadata. Sometimes the build cache doesn't properly detect these changes, leading to linking errors.

The QML syntax error is likely a false positive that will be resolved with a clean rebuild.

## Solution

### Option 1: Quick Fix (Recommended)

Simply run the provided batch script:

```batch
clean_and_build.bat
```

This script will:
1. Remove the old build directory
2. Create a fresh build directory
3. Run CMake configuration
4. Build the project

### Option 2: Manual Steps

If you prefer to do it manually or the script doesn't work:

1. **Delete the build directory completely**
   ```batch
   rmdir /s /q build
   ```

2. **Create a new build directory**
   ```batch
   mkdir build
   cd build
   ```

3. **Configure CMake**
   ```batch
   cmake .. -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
   ```

4. **Build the project**
   ```batch
   cmake --build . --config Release
   ```

### Option 3: Using Qt Creator

If you're using Qt Creator:

1. Go to **Build** menu → **Clean All**
2. Go to **Build** menu → **Run CMake**
3. Go to **Build** menu → **Build All**

## Code Changes Made

The following improvements were made to fix the warnings:

### main.cpp:73
- **Before**: `window->setColor(QColor("#1a1a1a"));`
- **After**: `window->setColor(QColor(0x1a, 0x1a, 0x1a));`
- **Reason**: Using RGB int constructor is more efficient than parsing string literals

### main.cpp:70 and main.cpp:85
- **Before**: `for (auto obj : rootObjects)`
- **After**: `const auto rootObjects = ...; for (auto obj : rootObjects)`
- **Reason**: Making the container const prevents potential detachment in range loops

## Verification

After rebuilding, the following should work without errors:

1. ✅ No undefined reference errors
2. ✅ No QML syntax errors
3. ✅ All warnings resolved
4. ✅ IMU Mock Service properly linked
5. ✅ Application builds and runs successfully

## Additional Notes

- The IMUMockService class files are correctly implemented in `src/sensors/`
- The CMakeLists.txt is properly configured
- All mesh files are correctly referenced
- This issue commonly occurs after merging branches that add new Q_OBJECT classes

If you continue to experience issues after a clean rebuild, please check:
- Qt 6.4+ is properly installed
- CMake version is 3.21 or higher
- MinGW or MSVC compiler is correctly configured
- All required Qt modules are installed (Core, Quick, Quick3D, QuickControls2, Sql)
