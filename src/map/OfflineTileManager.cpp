#include "OfflineTileManager.h"
#include <QNetworkRequest>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <QDirIterator>
#include <QtMath>
#include <QDebug>
#include <QThread>

OfflineTileManager::OfflineTileManager(QObject *parent)
    : QObject(parent)
    , m_isDownloading(false)
    , m_totalTiles(0)
    , m_downloadedTiles(0)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_currentReply(nullptr)
    , m_maxConcurrentDownloads(2)  // OSM policy: max 2 concurrent connections
    , m_activeDownloads(0)
    , m_userAgent("ExcavatorUI/1.0 (Qt6 Application; Offline Map Download)")
    , m_tileProvider("osm")  // Default to OSM
{
    // Set default cache directory
    QString cacheDir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    m_cacheDirectory = cacheDir + "/osm_tiles";
    QDir().mkpath(m_cacheDirectory);

    qDebug() << "OfflineTileManager initialized";
    qDebug() << "  Cache directory:" << m_cacheDirectory;
    qDebug() << "  Tile provider:" << m_tileProvider;
}

OfflineTileManager::~OfflineTileManager()
{
    cancelDownload();
}

void OfflineTileManager::setCacheDirectory(const QString &path)
{
    if (m_cacheDirectory != path) {
        m_cacheDirectory = path;
        QDir().mkpath(m_cacheDirectory);
        emit cacheDirectoryChanged();
    }
}

void OfflineTileManager::setTileProvider(const QString &provider)
{
    QString normalizedProvider = provider.toLower();
    if (m_tileProvider != normalizedProvider) {
        m_tileProvider = normalizedProvider;

        // Update cache directory based on provider
        QString cacheDir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
        if (m_tileProvider == "cartodb") {
            m_cacheDirectory = cacheDir + "/cartodb_tiles";
        } else {
            m_cacheDirectory = cacheDir + "/osm_tiles";
        }
        QDir().mkpath(m_cacheDirectory);

        qDebug() << "Tile provider changed to:" << m_tileProvider;
        qDebug() << "  Cache directory:" << m_cacheDirectory;

        emit tileProviderChanged();
        emit cacheDirectoryChanged();
        emit cacheSizeChanged();
    }
}

qint64 OfflineTileManager::cacheSize() const
{
    qint64 size = 0;
    QDirIterator it(m_cacheDirectory, QDir::Files, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        it.next();
        size += it.fileInfo().size();
    }
    return size;
}

QString OfflineTileManager::formatCacheSize() const
{
    qint64 size = cacheSize();
    if (size < 1024) {
        return QString("%1 B").arg(size);
    } else if (size < 1024 * 1024) {
        return QString("%1 KB").arg(size / 1024);
    } else if (size < 1024 * 1024 * 1024) {
        return QString("%1 MB").arg(size / (1024 * 1024));
    } else {
        return QString("%1 GB").arg(size / (1024.0 * 1024.0 * 1024.0), 0, 'f', 2);
    }
}

// Coordinate conversion functions
int OfflineTileManager::lonToTileX(double lon, int zoom)
{
    return static_cast<int>(floor((lon + 180.0) / 360.0 * (1 << zoom)));
}

int OfflineTileManager::latToTileY(double lat, int zoom)
{
    double latRad = lat * M_PI / 180.0;
    return static_cast<int>(floor((1.0 - asinh(tan(latRad)) / M_PI) / 2.0 * (1 << zoom)));
}

double OfflineTileManager::tileXToLon(int x, int zoom)
{
    return x / static_cast<double>(1 << zoom) * 360.0 - 180.0;
}

double OfflineTileManager::tileYToLat(int y, int zoom)
{
    double n = M_PI - 2.0 * M_PI * y / static_cast<double>(1 << zoom);
    return 180.0 / M_PI * atan(0.5 * (exp(n) - exp(-n)));
}

QString OfflineTileManager::getTileUrl(int z, int x, int y)
{
    if (m_tileProvider == "cartodb") {
        // CartoDB Positron tile servers
        QStringList servers = {"a", "b", "c", "d"};
        QString server = servers[(x + y) % servers.size()];
        return QString("https://%1.basemaps.cartocdn.com/light_all/%2/%3/%4.png")
            .arg(server).arg(z).arg(x).arg(y);
    } else {
        // OSM tile servers (default)
        QStringList servers = {"a", "b", "c"};
        QString server = servers[(x + y) % servers.size()];
        return QString("https://%1.tile.openstreetmap.org/%2/%3/%4.png")
            .arg(server).arg(z).arg(x).arg(y);
    }
}

QString OfflineTileManager::getTileCachePath(int z, int x, int y)
{
    return QString("%1/%2/%3/%4.png").arg(m_cacheDirectory).arg(z).arg(x).arg(y);
}

bool OfflineTileManager::isTileCached(int z, int x, int y) const
{
    QString path = QString("%1/%2/%3/%4.png").arg(m_cacheDirectory).arg(z).arg(x).arg(y);
    return QFile::exists(path);
}

int OfflineTileManager::cachedTileCount() const
{
    int count = 0;
    QDirIterator it(m_cacheDirectory, QStringList() << "*.png", QDir::Files, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        it.next();
        count++;
    }
    return count;
}

int OfflineTileManager::estimateTileCount(double centerLat, double centerLon,
                                           double radiusKm, int minZoom, int maxZoom)
{
    // Calculate bounding box from center and radius
    double latDelta = radiusKm / 111.0;  // ~111 km per degree latitude
    double lonDelta = radiusKm / (111.0 * cos(centerLat * M_PI / 180.0));

    double minLat = centerLat - latDelta;
    double maxLat = centerLat + latDelta;
    double minLon = centerLon - lonDelta;
    double maxLon = centerLon + lonDelta;

    int count = 0;
    for (int z = minZoom; z <= maxZoom; z++) {
        int minX = lonToTileX(minLon, z);
        int maxX = lonToTileX(maxLon, z);
        int minY = latToTileY(maxLat, z);  // Note: Y is inverted
        int maxY = latToTileY(minLat, z);

        count += (maxX - minX + 1) * (maxY - minY + 1);
    }
    return count;
}

void OfflineTileManager::downloadRegion(double centerLat, double centerLon,
                                         double radiusKm, int minZoom, int maxZoom)
{
    if (m_isDownloading) {
        qWarning() << "Download already in progress";
        return;
    }

    qDebug() << "Starting region download:";
    qDebug() << "  Center:" << centerLat << "," << centerLon;
    qDebug() << "  Radius:" << radiusKm << "km";
    qDebug() << "  Zoom range:" << minZoom << "-" << maxZoom;

    // Calculate bounding box from center and radius
    double latDelta = radiusKm / 111.0;
    double lonDelta = radiusKm / (111.0 * cos(centerLat * M_PI / 180.0));

    double minLat = centerLat - latDelta;
    double maxLat = centerLat + latDelta;
    double minLon = centerLon - lonDelta;
    double maxLon = centerLon + lonDelta;

    downloadArea(minLat, maxLat, minLon, maxLon, minZoom, maxZoom);
}

void OfflineTileManager::downloadArea(double minLat, double maxLat,
                                       double minLon, double maxLon,
                                       int minZoom, int maxZoom)
{
    if (m_isDownloading) {
        qWarning() << "Download already in progress";
        return;
    }

    m_downloadQueue.clear();
    m_downloadedTiles = 0;
    m_totalTiles = 0;

    // Calculate all tiles to download
    calculateTilesToDownload(minLat, maxLat, minLon, maxLon, minZoom, maxZoom);

    if (m_downloadQueue.isEmpty()) {
        qDebug() << "All tiles already cached!";
        emit downloadComplete();
        return;
    }

    m_totalTiles = m_downloadQueue.size();
    m_isDownloading = true;

    qDebug() << "Downloading" << m_totalTiles << "tiles...";

    emit isDownloadingChanged();
    emit totalTilesChanged();
    emit progressChanged();

    // Start downloading (respecting concurrent limit)
    for (int i = 0; i < m_maxConcurrentDownloads && !m_downloadQueue.isEmpty(); i++) {
        processNextTile();
    }
}

void OfflineTileManager::calculateTilesToDownload(double minLat, double maxLat,
                                                   double minLon, double maxLon,
                                                   int minZoom, int maxZoom)
{
    for (int z = minZoom; z <= maxZoom; z++) {
        int minX = lonToTileX(minLon, z);
        int maxX = lonToTileX(maxLon, z);
        int minY = latToTileY(maxLat, z);  // Y is inverted in tile coordinates
        int maxY = latToTileY(minLat, z);

        // Clamp to valid range
        int maxTile = (1 << z) - 1;
        minX = qMax(0, minX);
        maxX = qMin(maxTile, maxX);
        minY = qMax(0, minY);
        maxY = qMin(maxTile, maxY);

        for (int x = minX; x <= maxX; x++) {
            for (int y = minY; y <= maxY; y++) {
                // Only add if not already cached
                if (!isTileCached(z, x, y)) {
                    TileCoord coord = {z, x, y};
                    m_downloadQueue.enqueue(coord);
                }
            }
        }
    }

    qDebug() << "Tiles to download:" << m_downloadQueue.size();
}

void OfflineTileManager::processNextTile()
{
    QMutexLocker locker(&m_mutex);

    if (m_downloadQueue.isEmpty()) {
        if (m_activeDownloads == 0) {
            m_isDownloading = false;
            emit isDownloadingChanged();
            emit downloadComplete();
            emit cacheSizeChanged();
            qDebug() << "Download complete!";
        }
        return;
    }

    TileCoord coord = m_downloadQueue.dequeue();
    locker.unlock();

    downloadTile(coord.z, coord.x, coord.y);
}

void OfflineTileManager::downloadTile(int z, int x, int y)
{
    QString url = getTileUrl(z, x, y);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, m_userAgent);
    request.setRawHeader("Referer", "https://github.com/excavator-app");

    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("z", z);
    reply->setProperty("x", x);
    reply->setProperty("y", y);

    m_activeDownloads++;
    m_activeReplies.append(reply);

    connect(reply, &QNetworkReply::finished, this, &OfflineTileManager::onTileDownloaded);
}

void OfflineTileManager::onTileDownloaded()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    m_activeDownloads--;
    m_activeReplies.removeOne(reply);

    int z = reply->property("z").toInt();
    int x = reply->property("x").toInt();
    int y = reply->property("y").toInt();

    if (reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();

        // Save to cache
        QString cachePath = getTileCachePath(z, x, y);
        QDir().mkpath(QFileInfo(cachePath).absolutePath());

        QFile file(cachePath);
        if (file.open(QIODevice::WriteOnly)) {
            file.write(data);
            file.close();

            m_downloadedTiles++;
            emit downloadedTilesChanged();
            emit progressChanged();
            emit tileDownloaded(z, x, y);
        }
    } else {
        qWarning() << "Failed to download tile" << z << x << y << ":" << reply->errorString();
    }

    reply->deleteLater();

    // Add delay to respect OSM rate limits (max 2 req/sec per policy)
    QThread::msleep(100);

    // Process next tile
    processNextTile();
}

void OfflineTileManager::cancelDownload()
{
    QMutexLocker locker(&m_mutex);

    m_downloadQueue.clear();

    for (QNetworkReply *reply : m_activeReplies) {
        reply->abort();
        reply->deleteLater();
    }
    m_activeReplies.clear();
    m_activeDownloads = 0;

    if (m_isDownloading) {
        m_isDownloading = false;
        emit isDownloadingChanged();
        qDebug() << "Download cancelled";
    }
}

void OfflineTileManager::clearCache()
{
    if (m_isDownloading) {
        qWarning() << "Cannot clear cache while downloading";
        return;
    }

    QDir cacheDir(m_cacheDirectory);
    if (cacheDir.exists()) {
        cacheDir.removeRecursively();
        cacheDir.mkpath(".");
        emit cacheSizeChanged();
        qDebug() << "Cache cleared";
    }
}
