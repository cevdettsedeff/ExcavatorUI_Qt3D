#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QQuickStyle>
#include <QIcon>
#include <QColor>
#include <QTimer>
#include <QDir>
#include <QDebug>
#include "src/database/DatabaseManager.h"
#include "src/auth/AuthService.h"
#include "src/sensors/IMUMockService.h"
#include "src/config/ConfigManager.h"
#include "src/map/TileImageProvider.h"
#include "src/map/OfflineTileManager.h"
#include "src/i18n/TranslationService.h"
#include "src/theme/ThemeManager.h"

// GDAL-dependent features (optional)
#ifdef HAVE_GDAL
#include "src/bathymetry/BathymetricDataLoader.h"
#include "src/bathymetry/BathymetricMeshGenerator.h"
#endif

int main(int argc, char *argv[])
{
    // Qt Virtual Keyboard'u etkinleştir (dokunmatik ekran desteği)
    // AppRoot.qml tek bir kalıcı InputPanel içerir - crash sorunu çözüldü
    qputenv("QT_IM_MODULE", "qtvirtualkeyboard");

    QQuickStyle::setStyle("Basic");
    QGuiApplication app(argc, argv);

    // Set default window background color to match loading screen
    QQuickWindow::setDefaultAlphaBuffer(true);

    // Set application window icon (visible in window title bar and taskbar)
    app.setWindowIcon(QIcon(":/ExcavatorUI_Qt3D/resources/icons/app_icon.ico"));

    // Veritabanını başlat
    DatabaseManager& dbManager = DatabaseManager::instance();
    if (!dbManager.initialize()) {
        qCritical() << "Veritabanı başlatılamadı!";
        return -1;
    }

    // AuthService oluştur
    AuthService authService;

    // IMU Mock Service oluştur
    IMUMockService imuService;

    // ConfigManager oluştur ve yükle
    ConfigManager configManager;
    configManager.setConfigPath("config/bathymetry_config.json");
    configManager.loadConfig();

    // Son kullanılan projeyi otomatik yükle
    if (configManager.loadLastProject()) {
        qDebug() << "Last project loaded successfully:" << configManager.projectName();
    } else {
        qDebug() << "No previous project to load";
    }

    // Debug: Working directory ve maps klasörü kontrolü
    QString workingDir = QDir::currentPath();
    QString mapsPath = QDir(workingDir).filePath("maps");
    qDebug() << "========================================";
    qDebug() << "Working Directory:" << workingDir;
    qDebug() << "Maps Path:" << mapsPath;
    qDebug() << "Maps Exists:" << QDir(mapsPath).exists();
    if (QDir(mapsPath).exists()) {
        qDebug() << "Maps Contents:" << QDir(mapsPath).entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    }
    qDebug() << "========================================";

    // TileImageProvider oluştur (online tile loading için)
    TileImageProvider* tileImageProvider = new TileImageProvider();
    // Kullanıcının yerel tile klasörünü ayarla
    tileImageProvider->setStaticTileDirectory("maps");

    // OfflineTileManager oluştur (harita offline indirme için)
    OfflineTileManager offlineTileManager;
    // Kullanıcının yerel tile klasörünü ayarla
    offlineTileManager.setStaticTileDirectory("maps");

    // Connect tile provider changes: when offline manager changes provider, update image provider too
    QObject::connect(&offlineTileManager, &OfflineTileManager::tileProviderChanged, [&]() {
        QString provider = offlineTileManager.tileProvider();
        tileImageProvider->setTileProvider(provider);
        qDebug() << "Synchronized tile provider to:" << provider;
    });

#ifdef HAVE_GDAL
    // BathymetricDataLoader oluştur (sadece GDAL varsa)
    BathymetricDataLoader bathymetryLoader;
    // Config'den ayarları uygula
    if (configManager.isLoaded()) {
        bathymetryLoader.setTileSize(configManager.tileSize());
        // VRT path QML'den set edilecek
    }
#endif

    // QML Engine oluştur
    QQmlApplicationEngine engine;

    // QML module import path ekle (Loader ile yüklenen dosyalar için)
    engine.addImportPath("qrc:/");

    // TranslationService oluştur (Qt Linguist based)
    TranslationService translationService(&app, &engine);

    // ThemeManager oluştur
    ThemeManager themeManager;

    // Register tile image provider (supports OSM and CartoDB)
    engine.addImageProvider("osmtiles", tileImageProvider);

#ifdef HAVE_GDAL
    // QML types'ı kaydet (sadece GDAL varsa)
    qmlRegisterType<BathymetricMeshGenerator>("BathymetryComponents", 1, 0, "BathymetricMeshGenerator");
#endif

    // AuthService'i QML'e expose et
    engine.rootContext()->setContextProperty("authService", &authService);

    // IMU Mock Service'i QML'e expose et
    engine.rootContext()->setContextProperty("imuService", &imuService);

    // ConfigManager'ı QML'e expose et
    engine.rootContext()->setContextProperty("configManager", &configManager);

    // OfflineTileManager'ı QML'e expose et
    engine.rootContext()->setContextProperty("offlineTileManager", &offlineTileManager);

    // TranslationService'i QML'e expose et
    engine.rootContext()->setContextProperty("translationService", &translationService);

    // ThemeManager'ı QML'e expose et
    engine.rootContext()->setContextProperty("themeManager", &themeManager);

#ifdef HAVE_GDAL
    // BathymetricDataLoader'ı QML'e expose et (sadece GDAL varsa)
    engine.rootContext()->setContextProperty("bathymetryLoader", &bathymetryLoader);
#endif

    // AppRoot'u yükle - tek kalıcı window, Login/Dashboard Loader ile yönetilir
    // Bu yapı VirtualKeyboard InputPanel crash'ini önler
    const QUrl appRootUrl(QStringLiteral("qrc:/ExcavatorUI_Qt3D/src/AppRoot.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [appRootUrl](QObject *obj, const QUrl &objUrl) {
        if (!obj && appRootUrl == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(appRootUrl);

    return app.exec();
}
