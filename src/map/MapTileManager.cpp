#include "MapTileManager.h"
#include <QDebug>
#include <QPainter>
#include <QStandardPaths>
#include <QDir>
#include <cmath>

MapTileManager::MapTileManager(QObject *parent)
    : QObject(parent)
    , m_isOnline(false)
    , m_tileServerUrl("https://tile.openstreetmap.org/{z}/{x}/{y}.png")
{
    // Başlangıçta default texture oluştur
    generateAndSaveDefaultTexture();
}

MapTileManager::~MapTileManager()
{
}

void MapTileManager::setIsOnline(bool online)
{
    if (m_isOnline != online) {
        m_isOnline = online;
        emit isOnlineChanged();
        qDebug() << "MapTileManager: Online mode:" << m_isOnline;
    }
}

void MapTileManager::setTileServerUrl(const QString &url)
{
    if (m_tileServerUrl != url) {
        m_tileServerUrl = url;
        emit tileServerUrlChanged();
        qDebug() << "MapTileManager: Tile server URL:" << m_tileServerUrl;
    }
}

QString MapTileManager::generateDefaultTexture()
{
    generateAndSaveDefaultTexture();
    return m_baseLayerTexture;
}

void MapTileManager::generateAndSaveDefaultTexture()
{
    qDebug() << "MapTileManager: Generating default texture";

    // 1024x1024 texture oluştur
    QImage texture = createGridTexture(1024, 1024);

    // Temporary dosya yolu
    QString tempPath = getTempTexturePath();
    QDir().mkpath(QFileInfo(tempPath).absolutePath());

    // Texture'ı kaydet
    if (texture.save(tempPath)) {
        m_baseLayerTexture = tempPath;
        emit baseLayerTextureChanged();
        qDebug() << "MapTileManager: Default texture saved to:" << tempPath;
    } else {
        qWarning() << "MapTileManager: Failed to save default texture";
    }
}

QImage MapTileManager::createGridTexture(int width, int height)
{
    QImage image(width, height, QImage::Format_RGB32);
    QPainter painter(&image);

    // Arkaplan - su rengi (okyanus)
    painter.fillRect(0, 0, width, height, QColor("#A8DADC"));

    // Kara parçası (merkez) - basit bir şekil
    painter.setBrush(QColor("#F1FAEE"));
    painter.setPen(QPen(QColor("#457B9D"), 2));

    // Ana kara parçası (İstanbul benzeri)
    QPolygon landMass;
    landMass << QPoint(width * 0.3, height * 0.4)
             << QPoint(width * 0.5, height * 0.35)
             << QPoint(width * 0.7, height * 0.45)
             << QPoint(width * 0.6, height * 0.6)
             << QPoint(width * 0.4, height * 0.55);
    painter.drawPolygon(landMass);

    // Yollar
    painter.setPen(QPen(QColor("#E63946"), 3));
    painter.drawLine(width * 0.4, height * 0.45, width * 0.6, height * 0.5);
    painter.drawLine(width * 0.5, height * 0.4, width * 0.5, height * 0.55);

    // Grid çizgileri (ince)
    painter.setPen(QPen(QColor("#1D3557"), 1, Qt::DotLine));
    int gridSpacing = 50;

    for (int x = 0; x < width; x += gridSpacing) {
        painter.drawLine(x, 0, x, height);
    }

    for (int y = 0; y < height; y += gridSpacing) {
        painter.drawLine(0, y, width, y);
    }

    // Koordinat işaretleri
    painter.setPen(QColor("#1D3557"));
    painter.setFont(QFont("Arial", 8));

    // Enlem çizgileri
    for (int i = 1; i <= 4; i++) {
        int y = (height * i) / 5;
        painter.drawText(10, y - 5, QString("41.%1°N").arg(i));
    }

    // Boylam çizgileri
    for (int i = 1; i <= 4; i++) {
        int x = (width * i) / 5;
        painter.drawText(x - 30, height - 10, QString("28.%1°E").arg(i));
    }

    painter.end();
    return image;
}

QString MapTileManager::getTileUrl(double lat, double lon, int zoom)
{
    // OSM tile koordinatlarını hesapla
    // https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames

    int n = 1 << zoom; // 2^zoom

    double latRad = lat * M_PI / 180.0;
    int xtile = static_cast<int>((lon + 180.0) / 360.0 * n);
    int ytile = static_cast<int>((1.0 - std::asinh(std::tan(latRad)) / M_PI) / 2.0 * n);

    // URL şablonunu doldur
    QString url = m_tileServerUrl;
    url.replace("{z}", QString::number(zoom));
    url.replace("{x}", QString::number(xtile));
    url.replace("{y}", QString::number(ytile));

    qDebug() << "MapTileManager: Tile URL for" << lat << "," << lon << "zoom" << zoom << ":" << url;

    return url;
}

QString MapTileManager::getTempTexturePath() const
{
    QString tempDir = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
    return tempDir + "/excavator_ui/map_base_layer.png";
}
