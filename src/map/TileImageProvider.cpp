#include "TileImageProvider.h"
#include <QNetworkRequest>
#include <QEventLoop>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QDebug>
#include <QThread>
#include <QRandomGenerator>

TileImageProvider::TileImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Pixmap)
    , m_networkManager(new QNetworkAccessManager())
    , m_userAgent("ExcavatorUI/1.0 (Qt6 Application; https://github.com/yourcompany/excavator)")
    , m_memoryCache(50)  // Cache 50 tiles in memory (about 3MB at 256x256)
{
    // Set default cache directory
    QString cacheDir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    m_cacheDirectory = cacheDir + "/osm_tiles";

    // Create cache directory if it doesn't exist
    QDir().mkpath(m_cacheDirectory);

    qDebug() << "TileImageProvider initialized";
    qDebug() << "  User-Agent:" << m_userAgent;
    qDebug() << "  Cache directory:" << m_cacheDirectory;
}

TileImageProvider::~TileImageProvider()
{
    delete m_networkManager;
}

void TileImageProvider::setUserAgent(const QString &userAgent)
{
    m_userAgent = userAgent;
}

void TileImageProvider::setCacheDirectory(const QString &path)
{
    m_cacheDirectory = path;
    QDir().mkpath(m_cacheDirectory);
}

void TileImageProvider::setMaxCacheSize(int megabytes)
{
    m_memoryCache.setMaxCost(megabytes);
}

QPixmap TileImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    // Parse tile coordinates from id: "z/x/y" format
    QStringList parts = id.split('/');
    if (parts.size() != 3) {
        qWarning() << "Invalid tile ID format:" << id << "(expected z/x/y)";
        if (size) *size = QSize(256, 256);
        return QPixmap(256, 256);  // Return empty pixmap
    }

    bool ok1, ok2, ok3;
    int z = parts[0].toInt(&ok1);
    int x = parts[1].toInt(&ok2);
    int y = parts[2].toInt(&ok3);

    if (!ok1 || !ok2 || !ok3) {
        qWarning() << "Invalid tile coordinates:" << id;
        if (size) *size = QSize(256, 256);
        return QPixmap(256, 256);
    }

    // Load tile
    QPixmap pixmap = loadTile(z, x, y);

    if (size) {
        *size = pixmap.size();
    }

    return pixmap;
}

QPixmap TileImageProvider::loadTile(int z, int x, int y)
{
    QString tileKey = QString("%1/%2/%3").arg(z).arg(x).arg(y);

    // Check memory cache first
    {
        QMutexLocker locker(&m_cacheMutex);
        QPixmap *cached = m_memoryCache.object(tileKey);
        if (cached) {
            return *cached;
        }
    }

    // Check disk cache
    QString cachePath = getCachePath(z, x, y);
    if (QFile::exists(cachePath)) {
        QPixmap pixmap(cachePath);
        if (!pixmap.isNull()) {
            // Add to memory cache
            QMutexLocker locker(&m_cacheMutex);
            m_memoryCache.insert(tileKey, new QPixmap(pixmap), 1);
            return pixmap;
        }
    }

    // Download tile
    QString url = getTileUrl(z, x, y);
    QPixmap pixmap = downloadTile(url);

    if (!pixmap.isNull()) {
        // Save to disk cache
        QDir().mkpath(QFileInfo(cachePath).absolutePath());
        pixmap.save(cachePath, "PNG");

        // Add to memory cache
        QMutexLocker locker(&m_cacheMutex);
        m_memoryCache.insert(tileKey, new QPixmap(pixmap), 1);
    }

    return pixmap;
}

QString TileImageProvider::getTileUrl(int z, int x, int y)
{
    // Use one of OSM's tile servers (a, b, or c)
    QStringList servers = {"a", "b", "c"};
    int serverIndex = QRandomGenerator::global()->bounded(servers.size());
    QString server = servers[serverIndex];

    return QString("https://%1.tile.openstreetmap.org/%2/%3/%4.png")
        .arg(server)
        .arg(z)
        .arg(x)
        .arg(y);
}

QString TileImageProvider::getCachePath(int z, int x, int y)
{
    return QString("%1/%2/%3/%4.png")
        .arg(m_cacheDirectory)
        .arg(z)
        .arg(x)
        .arg(y);
}

QPixmap TileImageProvider::downloadTile(const QString &url)
{
    QNetworkRequest request(url);

    // CRITICAL: Set proper headers to comply with OSM tile usage policy
    // See: https://operations.osmfoundation.org/policies/tiles/
    request.setHeader(QNetworkRequest::UserAgentHeader, m_userAgent);
    request.setRawHeader("Referer", "https://github.com/yourcompany/excavator");

    QNetworkReply *reply = m_networkManager->get(request);

    // Wait for download to complete (synchronous in image provider)
    QEventLoop loop;
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    QPixmap pixmap;

    if (reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        pixmap.loadFromData(data);

        if (pixmap.isNull()) {
            qWarning() << "Failed to load pixmap from data for URL:" << url;
        }
    } else {
        qWarning() << "Network error downloading tile:" << url;
        qWarning() << "  Error:" << reply->errorString();

        // Create a placeholder tile with error indication
        pixmap = QPixmap(256, 256);
        pixmap.fill(QColor("#E5E3DF"));
    }

    reply->deleteLater();
    return pixmap;
}
