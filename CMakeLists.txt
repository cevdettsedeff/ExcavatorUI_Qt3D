cmake_minimum_required(VERSION 3.21)  # Minimum Qt 6.2+ için
project(ExcavatorUI_Qt3D VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS
    Core
    Quick
    Quick3D
    QuickControls2
    Sql
)

# GDAL kütüphanesini bul (opsiyonel - yoksa fallback mode)
find_package(GDAL QUIET)
if(GDAL_FOUND)
    message(STATUS "✓ GDAL found: ${GDAL_VERSION}")
    add_compile_definitions(HAS_GDAL)
else()
    message(STATUS "✗ GDAL not found - GeoTIFF loader will use fallback mode")
    message(STATUS "  Install GDAL: sudo apt-get install libgdal-dev (Linux)")
    message(STATUS "  Install GDAL: brew install gdal (macOS)")
endif()

# Platform-specific icon
set(APP_ICON "")
if(WIN32)
    set(APP_ICON "${CMAKE_CURRENT_SOURCE_DIR}/resources/icons/app_icon.rc")

    # Dosya var mı kontrol et
    if(EXISTS "${APP_ICON}")
        message(STATUS "✓ Windows icon bulundu: ${APP_ICON}")
    else()
        message(WARNING "✗ Windows icon bulunamadı: ${APP_ICON}")
        set(APP_ICON "")  # Dosya yoksa boş bırak
    endif()
elseif(APPLE)
    set(APP_ICON "${CMAKE_CURRENT_SOURCE_DIR}/resources/icons/app_icon.icns")
endif()

qt_add_executable(ExcavatorUI_Qt3DApp
    main.cpp
    src/database/DatabaseManager.h
    src/database/DatabaseManager.cpp
    src/auth/AuthService.h
    src/auth/AuthService.cpp
    ${APP_ICON}
)

# Tüm mesh dosyalarını bul
file(GLOB MESH_FILES
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    "resources/meshes/*.mesh"
)

# Debug: Kaç mesh dosyası bulundu göster
list(LENGTH MESH_FILES MESH_COUNT)
message(STATUS "Bulunan mesh dosyası sayısı: ${MESH_COUNT}")

# İlk 5 dosyayı göster (debug için)
list(SUBLIST MESH_FILES 0 5 FIRST_MESHES)
message(STATUS "İlk mesh dosyaları: ${FIRST_MESHES}")

qt_add_qml_module(ExcavatorUI_Qt3DApp
    URI ExcavatorUI_Qt3D
    VERSION 1.0
    QML_FILES
        # Auth views
        src/auth/LoginWindow.qml
        src/auth/LoginView.qml
        src/auth/RegisterView.qml
        # Main views
        src/views/Main.qml
        src/views/ExcavatorView.qml
        src/views/MapView.qml
        src/views/BathymetricMapView.qml
        # 3D Components
        src/components/Excavator.qml
        src/components/Grid3D.qml
        src/components/BathymetricPlane.qml
    SOURCES
        # C++ sınıfları QML'e expose etmek için
        src/geotiff/GeoTIFFLoader.h
        src/geotiff/GeoTIFFLoader.cpp
        src/map/MapTileManager.h
        src/map/MapTileManager.cpp
        src/tracking/ExcavatorTracker.h
        src/tracking/ExcavatorTracker.cpp
    RESOURCES
        ${MESH_FILES}
        resources/textures/deniz.png
        resources/textures/toprak.png
        resources/icons/app_icon.ico
)

target_link_libraries(ExcavatorUI_Qt3DApp PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Quick3D
    Qt6::QuickControls2
    Qt6::Sql
)

# GDAL varsa link et
if(GDAL_FOUND)
    target_link_libraries(ExcavatorUI_Qt3DApp PRIVATE ${GDAL_LIBRARIES})
    target_include_directories(ExcavatorUI_Qt3DApp PRIVATE ${GDAL_INCLUDE_DIRS})
endif()

set_target_properties(ExcavatorUI_Qt3DApp PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

install(TARGETS ExcavatorUI_Qt3DApp
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
