#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QQuickStyle>
#include <QIcon>
#include <QColor>
#include <QTimer>
#include "src/database/DatabaseManager.h"
#include "src/auth/AuthService.h"
#include "src/sensors/IMUMockService.h"
#include "src/config/ConfigManager.h"
#include "src/map/TileImageProvider.h"

// GDAL-dependent features (optional)
#ifdef HAVE_GDAL
#include "src/bathymetry/BathymetricDataLoader.h"
#include "src/bathymetry/BathymetricMeshGenerator.h"
#endif

int main(int argc, char *argv[])
{
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

    // Register OSM tile image provider (with proper HTTP headers)
    engine.addImageProvider("osmtiles", new TileImageProvider());

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

#ifdef HAVE_GDAL
    // BathymetricDataLoader'ı QML'e expose et (sadece GDAL varsa)
    engine.rootContext()->setContextProperty("bathymetryLoader", &bathymetryLoader);
#endif

    // Login window'u yükle
    const QUrl loginUrl(QStringLiteral("qrc:/ExcavatorUI_Qt3D/src/auth/LoginWindow.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [loginUrl](QObject *obj, const QUrl &objUrl) {
        if (!obj && loginUrl == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(loginUrl);

    // Login başarılı olduğunda dashboard'u aç
    QObject::connect(&authService, &AuthService::loginSucceeded, [&engine]() {
        qDebug() << "Login başarılı, dashboard açılıyor...";

        // Dashboard URL'i
        const QUrl dashboardUrl(QStringLiteral("qrc:/ExcavatorUI_Qt3D/src/views/Main.qml"));

        // Dashboard'u yükle
        engine.load(dashboardUrl);

        // Window oluşturulduğunda background'u ayarla
        QTimer::singleShot(0, [&engine]() {
            const auto rootObjects = engine.rootObjects();
            for (auto obj : rootObjects) {
                QQuickWindow *window = qobject_cast<QQuickWindow*>(obj);
                if (window) {
                    window->setColor(QColor(0x1a, 0x1a, 0x1a));
                }
            }
        });
    });

    // Logout olduğunda login ekranına dön
    QObject::connect(&authService, &AuthService::loggedOut, [&engine, loginUrl]() {
        qDebug() << "Logout yapıldı, login ekranına dönülüyor...";

        // Tüm mevcut QML objelerini temizle
        const auto rootObjects = engine.rootObjects();
        for (auto obj : rootObjects) {
            if (obj) {
                obj->deleteLater();
            }
        }

        // Engine'i temizle
        engine.clearComponentCache();

        // Login window'u tekrar yükle
        engine.load(loginUrl);
    });

    return app.exec();
}
