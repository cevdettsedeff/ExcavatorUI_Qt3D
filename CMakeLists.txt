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

# QtLocation for OpenStreetMap (optional, for simplified map view)
find_package(Qt6 COMPONENTS Location QUIET)
if(Qt6Location_FOUND)
    message(STATUS "✓ Qt6 Location found - Map features enabled")
    set(HAVE_QTLOCATION TRUE)
else()
    message(WARNING "✗ Qt6 Location not found - Map features will be limited")
    message(WARNING "  Install: Qt Maintenance Tool → Add Components → Qt Location")
    set(HAVE_QTLOCATION FALSE)
endif()

# Find GDAL library for bathymetric data processing
# Windows: Set GDAL_ROOT environment variable or use -DGDAL_ROOT=C:/OSGeo4W64
if(WIN32)
    # Try common Windows GDAL installation paths
    if(NOT DEFINED GDAL_ROOT)
        set(GDAL_ROOT_HINTS
            "C:/OSGeo4W64"
            "C:/OSGeo4W"
            "$ENV{GDAL_ROOT}"
            "$ENV{CONDA_PREFIX}"
            "$ENV{VCPKG_ROOT}/installed/x64-windows"
        )
        foreach(hint ${GDAL_ROOT_HINTS})
            if(EXISTS "${hint}")
                set(GDAL_ROOT "${hint}")
                message(STATUS "Found potential GDAL installation at: ${hint}")
                break()
            endif()
        endforeach()
    endif()

    # Set hints for FindGDAL
    if(DEFINED GDAL_ROOT)
        set(GDAL_INCLUDE_DIR "${GDAL_ROOT}/include" CACHE PATH "GDAL include directory")
        set(GDAL_LIBRARY "${GDAL_ROOT}/lib/gdal_i.lib" CACHE FILEPATH "GDAL library")
        list(APPEND CMAKE_PREFIX_PATH "${GDAL_ROOT}")
    endif()
endif()

find_package(GDAL)

if(GDAL_FOUND)
    message(STATUS "✓ GDAL found: ${GDAL_VERSION}")
    message(STATUS "  Include: ${GDAL_INCLUDE_DIRS}")
    message(STATUS "  Libraries: ${GDAL_LIBRARIES}")
    set(HAVE_GDAL TRUE)
    add_compile_definitions(HAVE_GDAL)
else()
    message(WARNING "✗ GDAL not found - Bathymetric features will be disabled")
    message(WARNING "  Advanced bathymetric visualization will not be available")
    message(WARNING "  Using simplified OpenStreetMap view instead")
    set(HAVE_GDAL FALSE)
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
    src/sensors/IMUMockService.h
    src/sensors/IMUMockService.cpp
    src/config/ConfigManager.h
    src/config/ConfigManager.cpp
    src/bathymetry/BathymetricDataLoader.h
    src/bathymetry/BathymetricDataLoader.cpp
    src/bathymetry/TileLoadTask.h
    src/bathymetry/TileLoadTask.cpp
    src/bathymetry/BathymetricMeshGenerator.h
    src/bathymetry/BathymetricMeshGenerator.cpp
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
        src/views/SimpleMapView.qml
        src/views/BathymetricMapView.qml
        src/views/BathymetricMapView_V2.qml
        src/views/BathymetricMapView_V3.qml
        src/views/UserManagementView.qml
        src/views/ProfileView.qml
        # 3D Components
        src/components/Excavator.qml
        src/components/Grid3D.qml
        src/components/BathymetricPlane.qml
        src/components/LoadingScreen.qml
    RESOURCES
        ${MESH_FILES}
        resources/textures/deniz.png
        resources/textures/toprak.png
        resources/icons/app_icon.ico
        RESOURCES resources/meshes/caterpillar_390F_LME__ARM_390F_LME_mesh.mesh resources/meshes/caterpillar_390F_LME__ARM_CYLINDER_BORE_390F_LME_mesh.mesh resources/meshes/caterpillar_390F_LME__ARM_CYLINDER_PIN_390F_LME__PIN_BOLT_3_mesh.mesh resources/meshes/caterpillar_390F_LME__ARM_CYLINDER_PIN_390F_LME__PIN_BOLT_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__ARM_CYLINDER_PIN_390F_LME_001_mesh.mesh resources/meshes/caterpillar_390F_LME__ARM_CYLINDER_PIN_390F_LME_mesh.mesh resources/meshes/caterpillar_390F_LME__ARM_PIN_390F_LME__PIN_BOLT_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__ARM_PIN_390F_LME_mesh.mesh resources/meshes/caterpillar_390F_LME__ARM_PISTON_ROB_390F_LME__ARM_ROB_CLEVIS_3_mesh.mesh resources/meshes/caterpillar_390F_LME__ARM_PISTON_ROB_390F_LME_mesh.mesh resources/meshes/caterpillar_390F_LME__BOOM_390F_LME__BOOM_CYLINDER_PIN_390F__PI_mesh.mesh resources/meshes/caterpillar_390F_LME__BOOM_390F_LME__BOOM_CYLINDER_PIN_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__BOOM_390F_LME_mesh.mesh resources/meshes/caterpillar_390F_LME__BOOM_BORE_PIN_390F__PIN_BOLT_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__BOOM_BORE_PIN_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__BOOM_CYLINDER_BORE_390F_LME_mesh.mesh resources/meshes/caterpillar_390F_LME__BOOM_PIN_390F__PIN_BOLT_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__BOOM_PIN_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__BOOM_PISTON_ROB_390F_LME__BOOM_ROB_CLEVIS_mesh.mesh resources/meshes/caterpillar_390F_LME__BOOM_PISTON_ROB_390F_LME_mesh.mesh resources/meshes/caterpillar_390F_LME__BUCKET_390F_LME__BUCKET_BOLT_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__BUCKET_390F_LME_mesh.mesh resources/meshes/caterpillar_390F_LME__BUCKET_CYLINDER_BORE_390F_LME_mesh.mesh resources/meshes/caterpillar_390F_LME__BUCKET_CYLINDER_PIN_390F_LME__PIN_BOLT_39_mesh.mesh resources/meshes/caterpillar_390F_LME__BUCKET_CYLINDER_PIN_390F_LME_mesh.mesh resources/meshes/caterpillar_390F_LME__BUCKET_LINK_390F_LME_mesh.mesh resources/meshes/caterpillar_390F_LME__BUCKET_PIN_390F_LME__PIN_BOLT_390F_001_mesh.mesh resources/meshes/caterpillar_390F_LME__BUCKET_PIN_390F_LME__PIN_BOLT_390F_002_mesh.mesh resources/meshes/caterpillar_390F_LME__BUCKET_PIN_390F_LME__PIN_BOLT_390F_003_mesh.mesh resources/meshes/caterpillar_390F_LME__BUCKET_PIN_390F_LME__PIN_BOLT_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__BUCKET_PIN_390F_LME_001_mesh.mesh resources/meshes/caterpillar_390F_LME__BUCKET_PIN_390F_LME_002_mesh.mesh resources/meshes/caterpillar_390F_LME__BUCKET_PIN_390F_LME_004_mesh.mesh resources/meshes/caterpillar_390F_LME__BUCKET_PIN_390F_LME_mesh.mesh resources/meshes/caterpillar_390F_LME__BUCKET_PISTON_ROB_390F_LME__BUCKET_ROB_CL_mesh.mesh resources/meshes/caterpillar_390F_LME__BUCKET_PISTON_ROB_390F_LME_mesh.mesh resources/meshes/caterpillar_390F_LME__CENTER_BEARING_390F__BEARING_BOLT_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__CENTER_BEARING_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__CHAIN_390F__TRACK_BU_mesh.mesh resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__CHAIN_390F__TRACK_LI_mesh.mesh resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__CHAIN_390F__TRACK_SH_001_mesh.mesh resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__CHAIN_390F__TRACK_SH_mesh.mesh resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__DRIVE_SPROCKET_390F__DRI_mesh.mesh resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__DRIVE_SPROCKET_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__FRONT_IDLER_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__TRACK_FRAME_390F__TRACK__mesh.mesh resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__TRACK_FRAME_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__TRACK_ROLLER_390F__ROLLE_mesh.mesh resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__TRACK_ROLLER_390F__TRACK_mesh.mesh resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__TRACK_ROLLER_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__CARRIER_ROLLER_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__CHAIN_390F__TRACK_BUSH__mesh.mesh resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__CHAIN_390F__TRACK_LINK__mesh.mesh resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__CHAIN_390F__TRACK_S_001_mesh.mesh resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__CHAIN_390F__TRACK_S_mesh.mesh resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__DRIVE_SPROCKET_390F__DR_mesh.mesh resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__DRIVE_SPROCKET_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__FRONT_IDLER_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__RIGHT_TRACK_FRAME_390F__mesh.mesh resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__RIGHT_TRACK_FRAME_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__TRACK_ROLLER_390F__ROLL_mesh.mesh resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__TRACK_ROLLER_390F__TRAC_mesh.mesh resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__TRACK_ROLLER_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__BONNET_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__CABINE__mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLA_001_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLA_002_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLA_003_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLA_004_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLA_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLASS_3_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__COUGHTERWEIGHT_390F__mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__COUGHTERWEIGHT_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__FUEL_TANK_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__LEFT_DOOR_390F_01_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__LEFT_DOOR_390F_02_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__LEFT_MODULE_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__MAIN_EXHAUST_390F__S_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__MAIN_EXHAUST_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__RIGHT_DOOR_390F_01_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__RIGHT_DOOR_390F_02_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__RIGHT_MODULE_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__SUPERSTRUCTURE_FRAME_mesh.mesh resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__TOP_SIDEWALK_390F_mesh.mesh resources/meshes/caterpillar_390F_LME__TIPPING_LINK_390F_LME_mesh.mesh resources/meshes/caterpillar_390F_LME__UNDERCARRIAGE_FRAME_390F__UNDERCARRIAGE_F_mesh.mesh resources/meshes/caterpillar_390F_LME__UNDERCARRIAGE_FRAME_390F_mesh.mesh resources/meshes/obj1_mesh.mesh resources/meshes/obj2_mesh.mesh resources/meshes/obj3_mesh.mesh resources/meshes/obj4_mesh.mesh resources/meshes/obj5_mesh.mesh resources/meshes/obj6_mesh.mesh resources/meshes/obj7_mesh.mesh resources/meshes/obj8_mesh.mesh resources/meshes/obj9_mesh.mesh resources/meshes/obj10_mesh.mesh resources/meshes/obj11_mesh.mesh resources/meshes/obj12_mesh.mesh resources/meshes/obj13_mesh.mesh resources/meshes/obj14_mesh.mesh resources/meshes/obj15_mesh.mesh resources/meshes/obj16_mesh.mesh resources/meshes/obj17_mesh.mesh resources/meshes/obj18_mesh.mesh resources/meshes/obj19_mesh.mesh resources/meshes/obj20_mesh.mesh resources/meshes/obj21_mesh.mesh resources/meshes/obj22_mesh.mesh resources/meshes/obj23_mesh.mesh resources/meshes/obj24_mesh.mesh resources/meshes/obj25_mesh.mesh resources/meshes/obj26_mesh.mesh resources/meshes/obj27_mesh.mesh resources/meshes/obj28_mesh.mesh resources/meshes/obj29_mesh.mesh resources/meshes/obj30_mesh.mesh resources/meshes/obj31_mesh.mesh resources/meshes/obj32_mesh.mesh resources/meshes/obj33_mesh.mesh resources/meshes/obj34_mesh.mesh resources/meshes/obj35_mesh.mesh resources/meshes/obj36_mesh.mesh resources/meshes/obj37_mesh.mesh resources/meshes/obj38_mesh.mesh resources/meshes/obj39_mesh.mesh resources/meshes/obj40_mesh.mesh resources/meshes/obj41_mesh.mesh resources/meshes/obj42_mesh.mesh resources/meshes/obj43_mesh.mesh resources/meshes/obj44_mesh.mesh resources/meshes/obj45_mesh.mesh resources/meshes/obj46_mesh.mesh resources/meshes/obj47_mesh.mesh resources/meshes/obj48_mesh.mesh resources/meshes/obj49_mesh.mesh resources/meshes/obj50_mesh.mesh resources/meshes/obj51_mesh.mesh resources/meshes/obj52_mesh.mesh resources/meshes/obj53_mesh.mesh resources/meshes/obj54_mesh.mesh resources/meshes/obj55_mesh.mesh resources/meshes/obj56_mesh.mesh resources/meshes/obj57_mesh.mesh resources/meshes/obj58_mesh.mesh resources/meshes/obj59_mesh.mesh resources/meshes/obj60_mesh.mesh resources/meshes/obj61_mesh.mesh resources/meshes/obj62_mesh.mesh resources/meshes/obj63_mesh.mesh resources/meshes/obj64_mesh.mesh resources/meshes/obj65_mesh.mesh resources/meshes/obj66_mesh.mesh resources/meshes/obj67_mesh.mesh resources/meshes/obj68_mesh.mesh resources/meshes/obj69_mesh.mesh resources/meshes/obj70_mesh.mesh resources/meshes/obj71_mesh.mesh resources/meshes/obj72_mesh.mesh resources/meshes/obj73_mesh.mesh resources/meshes/obj74_mesh.mesh resources/meshes/obj75_mesh.mesh resources/meshes/obj76_mesh.mesh resources/meshes/obj77_mesh.mesh resources/meshes/obj78_mesh.mesh resources/meshes/obj79_mesh.mesh resources/meshes/obj80_mesh.mesh resources/meshes/obj81_mesh.mesh resources/meshes/obj82_mesh.mesh resources/meshes/obj83_mesh.mesh resources/meshes/obj84_mesh.mesh resources/meshes/obj85_mesh.mesh resources/meshes/obj86_mesh.mesh resources/meshes/obj87_mesh.mesh resources/meshes/obj88_mesh.mesh resources/meshes/obj89_mesh.mesh resources/meshes/obj90_mesh.mesh resources/meshes/obj91_mesh.mesh resources/meshes/obj92_mesh.mesh resources/meshes/obj93_mesh.mesh resources/meshes/obj94_mesh.mesh resources/meshes/obj95_mesh.mesh resources/meshes/obj96_mesh.mesh resources/meshes/obj97_mesh.mesh resources/meshes/obj98_mesh.mesh resources/meshes/obj99_mesh.mesh resources/meshes/obj100_mesh.mesh resources/meshes/obj101_mesh.mesh resources/meshes/obj102_mesh.mesh resources/meshes/obj103_mesh.mesh resources/meshes/obj104_mesh.mesh resources/meshes/obj105_mesh.mesh resources/meshes/obj106_mesh.mesh resources/meshes/obj107_mesh.mesh resources/meshes/obj108_mesh.mesh resources/meshes/obj109_mesh.mesh resources/meshes/obj110_mesh.mesh resources/meshes/obj111_mesh.mesh resources/meshes/obj112_mesh.mesh resources/meshes/obj113_mesh.mesh resources/meshes/obj114_mesh.mesh resources/meshes/obj115_mesh.mesh resources/meshes/obj116_mesh.mesh resources/meshes/obj117_mesh.mesh resources/meshes/obj118_mesh.mesh resources/meshes/obj119_mesh.mesh resources/meshes/obj120_mesh.mesh resources/meshes/obj121_mesh.mesh resources/meshes/obj122_mesh.mesh resources/meshes/obj123_mesh.mesh resources/meshes/obj124_mesh.mesh resources/meshes/obj125_mesh.mesh resources/meshes/obj126_mesh.mesh resources/meshes/obj127_mesh.mesh resources/meshes/obj128_mesh.mesh resources/meshes/obj129_mesh.mesh resources/meshes/obj130_mesh.mesh resources/meshes/obj131_mesh.mesh resources/meshes/obj132_mesh.mesh resources/meshes/obj133_mesh.mesh resources/meshes/obj134_mesh.mesh resources/meshes/obj135_mesh.mesh resources/meshes/obj136_mesh.mesh resources/meshes/obj137_mesh.mesh resources/meshes/obj138_mesh.mesh resources/meshes/obj139_mesh.mesh resources/meshes/obj140_mesh.mesh resources/meshes/obj141_mesh.mesh resources/meshes/obj142_mesh.mesh resources/meshes/obj143_mesh.mesh resources/meshes/obj144_mesh.mesh resources/meshes/obj145_mesh.mesh resources/meshes/obj146_mesh.mesh resources/meshes/obj147_mesh.mesh resources/meshes/obj148_mesh.mesh resources/meshes/obj149_mesh.mesh resources/meshes/obj150_mesh.mesh resources/meshes/obj151_mesh.mesh resources/meshes/obj152_mesh.mesh resources/meshes/obj153_mesh.mesh resources/meshes/obj154_mesh.mesh resources/meshes/obj155_mesh.mesh resources/meshes/obj156_mesh.mesh resources/meshes/obj157_mesh.mesh resources/meshes/obj158_mesh.mesh resources/meshes/obj159_mesh.mesh resources/meshes/obj160_mesh.mesh resources/meshes/obj161_mesh.mesh resources/meshes/obj162_mesh.mesh resources/meshes/obj163_mesh.mesh resources/meshes/obj164_mesh.mesh resources/meshes/obj165_mesh.mesh resources/meshes/obj166_mesh.mesh resources/meshes/obj167_mesh.mesh resources/meshes/obj168_mesh.mesh resources/meshes/obj169_mesh.mesh resources/meshes/obj170_mesh.mesh resources/meshes/obj171_mesh.mesh resources/meshes/obj172_mesh.mesh resources/meshes/obj173_mesh.mesh resources/meshes/obj174_mesh.mesh resources/meshes/obj175_mesh.mesh resources/meshes/obj176_mesh.mesh resources/meshes/obj177_mesh.mesh resources/meshes/obj178_mesh.mesh resources/meshes/obj179_mesh.mesh resources/meshes/obj180_mesh.mesh resources/meshes/obj181_mesh.mesh resources/meshes/obj182_mesh.mesh resources/meshes/obj183_mesh.mesh resources/meshes/obj184_mesh.mesh resources/meshes/obj185_mesh.mesh resources/meshes/obj186_mesh.mesh resources/meshes/obj187_mesh.mesh resources/meshes/obj188_mesh.mesh resources/meshes/obj189_mesh.mesh resources/meshes/obj190_mesh.mesh resources/meshes/obj191_mesh.mesh resources/meshes/obj192_mesh.mesh resources/meshes/obj193_mesh.mesh resources/meshes/obj194_mesh.mesh resources/meshes/obj195_mesh.mesh resources/meshes/obj196_mesh.mesh resources/meshes/obj197_mesh.mesh resources/meshes/obj198_mesh.mesh resources/meshes/obj199_mesh.mesh resources/meshes/obj200_mesh.mesh resources/meshes/obj201_mesh.mesh resources/meshes/obj202_mesh.mesh resources/meshes/obj203_mesh.mesh resources/meshes/obj204_mesh.mesh resources/meshes/obj205_mesh.mesh resources/meshes/obj206_mesh.mesh resources/meshes/obj207_mesh.mesh resources/meshes/obj208_mesh.mesh resources/meshes/obj209_mesh.mesh resources/meshes/obj210_mesh.mesh resources/meshes/obj211_mesh.mesh resources/meshes/obj212_mesh.mesh resources/meshes/obj213_mesh.mesh resources/meshes/obj214_mesh.mesh resources/meshes/obj215_mesh.mesh resources/meshes/obj216_mesh.mesh resources/meshes/obj217_mesh.mesh resources/meshes/obj218_mesh.mesh resources/meshes/obj219_mesh.mesh resources/meshes/obj220_mesh.mesh resources/meshes/obj221_mesh.mesh resources/meshes/obj222_mesh.mesh resources/meshes/obj223_mesh.mesh resources/meshes/obj224_mesh.mesh resources/meshes/obj225_mesh.mesh resources/meshes/obj226_mesh.mesh resources/meshes/obj227_mesh.mesh resources/meshes/obj228_mesh.mesh resources/meshes/obj229_mesh.mesh resources/meshes/obj230_mesh.mesh resources/meshes/obj231_mesh.mesh resources/meshes/obj232_mesh.mesh resources/meshes/obj233_mesh.mesh resources/meshes/obj234_mesh.mesh resources/meshes/obj235_mesh.mesh resources/meshes/obj236_mesh.mesh resources/meshes/obj237_mesh.mesh resources/meshes/obj238_mesh.mesh resources/meshes/obj239_mesh.mesh resources/meshes/obj240_mesh.mesh resources/meshes/obj241_mesh.mesh resources/meshes/obj242_mesh.mesh resources/meshes/obj243_mesh.mesh resources/meshes/obj244_mesh.mesh resources/meshes/obj245_mesh.mesh resources/meshes/obj246_mesh.mesh resources/meshes/obj247_mesh.mesh resources/meshes/obj248_mesh.mesh resources/meshes/obj249_mesh.mesh resources/meshes/obj250_mesh.mesh resources/meshes/obj251_mesh.mesh resources/meshes/obj252_mesh.mesh resources/meshes/obj253_mesh.mesh resources/meshes/obj254_mesh.mesh resources/meshes/obj255_mesh.mesh resources/meshes/obj256_mesh.mesh resources/meshes/obj257_mesh.mesh resources/meshes/obj258_mesh.mesh resources/meshes/obj259_mesh.mesh resources/meshes/obj260_mesh.mesh resources/meshes/obj261_mesh.mesh resources/meshes/obj262_mesh.mesh resources/meshes/obj263_mesh.mesh resources/meshes/obj264_mesh.mesh resources/meshes/obj265_mesh.mesh resources/meshes/obj266_mesh.mesh resources/meshes/obj267_mesh.mesh
)

target_link_libraries(ExcavatorUI_Qt3DApp PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Quick3D
    Qt6::QuickControls2
    Qt6::Sql
)

# Link QtLocation if available
if(Qt6Location_FOUND)
    target_link_libraries(ExcavatorUI_Qt3DApp PRIVATE Qt6::Location)
endif()

# Link GDAL if available
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
