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
)

qt_add_executable(ExcavatorUI_Qt3DApp
    main.cpp
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
        src/Main.qml
        src/ExcavatorView.qml
        src/MapView.qml
        src/Excavator.qml
    RESOURCES
        ${MESH_FILES}
        resources/textures/deniz.png
        resources/textures/toprak.png
)

target_link_libraries(ExcavatorUI_Qt3DApp PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Quick3D
    Qt6::QuickControls2
)

set_target_properties(ExcavatorUI_Qt3DApp PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

install(TARGETS ExcavatorUI_Qt3DApp
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
