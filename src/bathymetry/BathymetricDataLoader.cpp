#include "BathymetricDataLoader.h"
#include <QDebug>
#include <QFile>
#include <QDateTime>
#include <cmath>

// GDAL includes
#include <gdal.h>
#include <gdal_priv.h>
#include <cpl_conv.h>
#include <ogr_spatialref.h>

using namespace BathymetryConstants;

BathymetricDataLoader::BathymetricDataLoader(QObject *parent)
    : QObject(parent)
    , m_isLoaded(false)
    , m_tileSize(DEFAULT_TILE_SIZE)
    , m_overviewCount(0)
    , m_dataset(nullptr)
    , m_band(nullptr)
    , m_rasterWidth(0)
    , m_rasterHeight(0)
{
    // Initialize GDAL
    GDALAllRegister();

    // Initialize geotransform to identity
    m_geoTransform[0] = 0.0;  // Top left x
    m_geoTransform[1] = 1.0;  // W-E pixel resolution
    m_geoTransform[2] = 0.0;  // Rotation, 0 if image is "north up"
    m_geoTransform[3] = 0.0;  // Top left y
    m_geoTransform[4] = 0.0;  // Rotation, 0 if image is "north up"
    m_geoTransform[5] = -1.0; // N-S pixel resolution (negative value)

    qDebug() << "BathymetricDataLoader: GDAL version" << GDALVersionInfo("RELEASE_NAME");
}

BathymetricDataLoader::~BathymetricDataLoader()
{
    cleanupGDAL();
}

void BathymetricDataLoader::setVrtPath(const QString &path)
{
    if (m_vrtPath != path) {
        m_vrtPath = path;
        emit vrtPathChanged();

        // Auto-load if path is valid
        if (QFile::exists(path)) {
            loadVRT();
        }
    }
}

void BathymetricDataLoader::setTileSize(int size)
{
    if (m_tileSize != size && size > 0) {
        m_tileSize = size;
        clearCache();  // Clear cache as tile size changed
        emit tileSizeChanged();
    }
}

bool BathymetricDataLoader::loadVRT()
{
    if (m_vrtPath.isEmpty()) {
        emit errorOccurred("VRT path is empty");
        return false;
    }

    if (!QFile::exists(m_vrtPath)) {
        emit errorOccurred("VRT file does not exist: " + m_vrtPath);
        return false;
    }

    // Clean up existing dataset
    cleanupGDAL();

    qDebug() << "Loading VRT file:" << m_vrtPath;
    emit loadingProgress(10);

    // Open the VRT file
    m_dataset = static_cast<GDALDataset*>(
        GDALOpen(m_vrtPath.toUtf8().constData(), GA_ReadOnly)
    );

    if (!m_dataset) {
        QString error = QString("Failed to open VRT file: %1").arg(CPLGetLastErrorMsg());
        qWarning() << error;
        emit errorOccurred(error);
        return false;
    }

    emit loadingProgress(30);

    // Get raster information
    m_rasterWidth = m_dataset->GetRasterXSize();
    m_rasterHeight = m_dataset->GetRasterYSize();

    qDebug() << "Raster size:" << m_rasterWidth << "x" << m_rasterHeight;

    if (m_dataset->GetGeoTransform(m_geoTransform) != CE_None) {
        qWarning() << "Failed to get geotransform, using default";
    } else {
        qDebug() << "GeoTransform:"
                 << m_geoTransform[0] << m_geoTransform[1] << m_geoTransform[2]
                 << m_geoTransform[3] << m_geoTransform[4] << m_geoTransform[5];
    }

    emit loadingProgress(50);

    // Get the first raster band (assuming single-band elevation data)
    m_band = m_dataset->GetRasterBand(1);
    if (!m_band) {
        emit errorOccurred("Failed to get raster band");
        cleanupGDAL();
        return false;
    }

    // Get overview count (pyramid levels)
    m_overviewCount = m_band->GetOverviewCount();
    qDebug() << "Overview count:" << m_overviewCount;
    emit overviewCountChanged();

    // Get no-data value
    int hasNoData = 0;
    double noDataValue = m_band->GetNoDataValue(&hasNoData);
    if (hasNoData) {
        qDebug() << "No-data value:" << noDataValue;
    }

    emit loadingProgress(70);

    // Compute geographic bounds
    computeGeoBounds();

    emit loadingProgress(100);

    m_isLoaded = true;
    emit isLoadedChanged();

    qDebug() << "VRT loaded successfully. Bounds:" << m_geoBounds;

    return true;
}

void BathymetricDataLoader::computeGeoBounds()
{
    // Compute corner coordinates
    double minX, maxX, minY, maxY;

    // Top-left corner
    double x1 = m_geoTransform[0];
    double y1 = m_geoTransform[3];

    // Top-right corner
    double x2 = m_geoTransform[0] + m_geoTransform[1] * m_rasterWidth;
    double y2 = m_geoTransform[3] + m_geoTransform[4] * m_rasterWidth;

    // Bottom-left corner
    double x3 = m_geoTransform[0] + m_geoTransform[2] * m_rasterHeight;
    double y3 = m_geoTransform[3] + m_geoTransform[5] * m_rasterHeight;

    // Bottom-right corner
    double x4 = m_geoTransform[0] + m_geoTransform[1] * m_rasterWidth + m_geoTransform[2] * m_rasterHeight;
    double y4 = m_geoTransform[3] + m_geoTransform[4] * m_rasterWidth + m_geoTransform[5] * m_rasterHeight;

    minX = std::min({x1, x2, x3, x4});
    maxX = std::max({x1, x2, x3, x4});
    minY = std::min({y1, y2, y3, y4});
    maxY = std::max({y1, y2, y3, y4});

    // Note: GEBCO uses longitude (X) and latitude (Y)
    // QRectF uses (left, top, width, height)
    m_geoBounds = QRectF(minX, minY, maxX - minX, maxY - minY);

    emit geoBoundsChanged();
}

float BathymetricDataLoader::getDepthAt(double lat, double lon, int lodLevel)
{
    if (!m_isLoaded) {
        return NO_DATA_VALUE;
    }

    int x, y;
    geoToPixelInternal(lat, lon, x, y, lodLevel);

    return readPixelValue(x, y, lodLevel);
}

float BathymetricDataLoader::readPixelValue(int x, int y, int lodLevel)
{
    if (!m_band) {
        return NO_DATA_VALUE;
    }

    // Get appropriate band (main or overview)
    GDALRasterBand *readBand = m_band;
    if (lodLevel > 0 && lodLevel <= m_overviewCount) {
        readBand = m_band->GetOverview(lodLevel - 1);
        if (!readBand) {
            readBand = m_band;  // Fallback to main band
        }
    }

    int bandWidth = readBand->GetXSize();
    int bandHeight = readBand->GetYSize();

    // Check bounds
    if (x < 0 || x >= bandWidth || y < 0 || y >= bandHeight) {
        return NO_DATA_VALUE;
    }

    // Read single pixel
    float value = NO_DATA_VALUE;
    CPLErr err = readBand->RasterIO(
        GF_Read,
        x, y,           // Pixel offset
        1, 1,           // Size to read (1x1 pixel)
        &value,         // Output buffer
        1, 1,           // Buffer size
        GDT_Float32,    // Data type
        0, 0            // Pixel/line spacing (0 = auto)
    );

    if (err != CE_None) {
        qWarning() << "Failed to read pixel at" << x << y << ":" << CPLGetLastErrorMsg();
        return NO_DATA_VALUE;
    }

    return value;
}

BathymetricTile* BathymetricDataLoader::loadTile(int tileX, int tileY, int lodLevel)
{
    if (!m_isLoaded) {
        return nullptr;
    }

    QString key = QString("%1_%2_%3").arg(tileX).arg(tileY).arg(lodLevel);

    // Check cache first
    auto cachedTile = getFromCache(key);
    if (cachedTile) {
        return cachedTile.get();
    }

    // Create new tile
    auto tile = std::make_shared<BathymetricTile>();
    tile->tileX = tileX;
    tile->tileY = tileY;
    tile->lodLevel = lodLevel;
    tile->width = m_tileSize;
    tile->height = m_tileSize;

    // Get appropriate band
    GDALRasterBand *readBand = m_band;
    if (lodLevel > 0 && lodLevel <= m_overviewCount) {
        readBand = m_band->GetOverview(lodLevel - 1);
        if (!readBand) {
            readBand = m_band;
        }
    }

    int bandWidth = readBand->GetXSize();
    int bandHeight = readBand->GetYSize();

    // Calculate pixel coordinates
    int pixelX = tileX * m_tileSize;
    int pixelY = tileY * m_tileSize;

    // Clamp to raster bounds
    int readWidth = std::min(m_tileSize, bandWidth - pixelX);
    int readHeight = std::min(m_tileSize, bandHeight - pixelY);

    if (readWidth <= 0 || readHeight <= 0 || pixelX >= bandWidth || pixelY >= bandHeight) {
        tile->isValid = false;
        addToCache(key, tile);
        return tile.get();
    }

    // Allocate buffer
    tile->depths.resize(readWidth * readHeight);

    // Read tile data
    CPLErr err = readBand->RasterIO(
        GF_Read,
        pixelX, pixelY,
        readWidth, readHeight,
        tile->depths.data(),
        readWidth, readHeight,
        GDT_Float32,
        0, 0
    );

    if (err != CE_None) {
        qWarning() << "Failed to read tile" << tileX << tileY << ":" << CPLGetLastErrorMsg();
        tile->isValid = false;
    } else {
        tile->isValid = true;
        tile->width = readWidth;
        tile->height = readHeight;

        // Compute geographic bounds for this tile
        double lat1, lon1, lat2, lon2;
        pixelToGeoInternal(pixelX, pixelY, lat1, lon1, lodLevel);
        pixelToGeoInternal(pixelX + readWidth, pixelY + readHeight, lat2, lon2, lodLevel);

        tile->geoBounds = QRectF(
            QPointF(std::min(lon1, lon2), std::min(lat1, lat2)),
            QPointF(std::max(lon1, lon2), std::max(lat1, lat2))
        );

        emit tileLoaded(tileX, tileY, lodLevel);
    }

    // Add to cache
    addToCache(key, tile);

    return tile.get();
}

QVector<float> BathymetricDataLoader::getDepthRegion(const QRectF &bounds, int width, int height, int lodLevel)
{
    QVector<float> depths(width * height, NO_DATA_VALUE);

    if (!m_isLoaded || width <= 0 || height <= 0) {
        return depths;
    }

    // Get appropriate band
    GDALRasterBand *readBand = m_band;
    if (lodLevel > 0 && lodLevel <= m_overviewCount) {
        readBand = m_band->GetOverview(lodLevel - 1);
        if (!readBand) {
            readBand = m_band;
        }
    }

    // Convert geographic bounds to pixel coordinates
    int x1, y1, x2, y2;
    geoToPixelInternal(bounds.top(), bounds.left(), x1, y1, lodLevel);
    geoToPixelInternal(bounds.bottom(), bounds.right(), x2, y2, lodLevel);

    int pixelX = std::min(x1, x2);
    int pixelY = std::min(y1, y2);
    int pixelWidth = std::abs(x2 - x1);
    int pixelHeight = std::abs(y2 - y1);

    // Clamp to raster bounds
    int bandWidth = readBand->GetXSize();
    int bandHeight = readBand->GetYSize();

    pixelX = std::max(0, std::min(pixelX, bandWidth - 1));
    pixelY = std::max(0, std::min(pixelY, bandHeight - 1));
    pixelWidth = std::min(pixelWidth, bandWidth - pixelX);
    pixelHeight = std::min(pixelHeight, bandHeight - pixelY);

    if (pixelWidth <= 0 || pixelHeight <= 0) {
        return depths;
    }

    // Read region with resampling
    CPLErr err = readBand->RasterIO(
        GF_Read,
        pixelX, pixelY,
        pixelWidth, pixelHeight,
        depths.data(),
        width, height,
        GDT_Float32,
        0, 0
    );

    if (err != CE_None) {
        qWarning() << "Failed to read region:" << CPLGetLastErrorMsg();
        depths.fill(NO_DATA_VALUE);
    }

    return depths;
}

void BathymetricDataLoader::geoToPixelInternal(double lat, double lon, int &x, int &y, int lodLevel) const
{
    // Apply inverse geotransform
    // [lon, lat] = [GT0 + x*GT1 + y*GT2, GT3 + x*GT4 + y*GT5]
    // Solving for x, y:

    double denominator = m_geoTransform[1] * m_geoTransform[5] - m_geoTransform[2] * m_geoTransform[4];

    if (std::abs(denominator) < 1e-10) {
        x = y = 0;
        return;
    }

    double dx = lon - m_geoTransform[0];
    double dy = lat - m_geoTransform[3];

    x = static_cast<int>((dx * m_geoTransform[5] - dy * m_geoTransform[2]) / denominator);
    y = static_cast<int>((dy * m_geoTransform[1] - dx * m_geoTransform[4]) / denominator);

    // Scale for LOD level
    if (lodLevel > 0 && lodLevel <= m_overviewCount) {
        GDALRasterBand *overviewBand = m_band->GetOverview(lodLevel - 1);
        if (overviewBand) {
            double scaleFactor = static_cast<double>(overviewBand->GetXSize()) / m_rasterWidth;
            x = static_cast<int>(x * scaleFactor);
            y = static_cast<int>(y * scaleFactor);
        }
    }
}

QPointF BathymetricDataLoader::geoToPixel(double lat, double lon, int lodLevel) const
{
    int x, y;
    geoToPixelInternal(lat, lon, x, y, lodLevel);
    return QPointF(x, y);
}

void BathymetricDataLoader::pixelToGeoInternal(int x, int y, double &lat, double &lon, int lodLevel) const
{
    // Scale for LOD level
    double scaledX = x;
    double scaledY = y;

    if (lodLevel > 0 && lodLevel <= m_overviewCount) {
        GDALRasterBand *overviewBand = m_band->GetOverview(lodLevel - 1);
        if (overviewBand) {
            double scaleFactor = static_cast<double>(m_rasterWidth) / overviewBand->GetXSize();
            scaledX = x * scaleFactor;
            scaledY = y * scaleFactor;
        }
    }

    // Apply geotransform
    lon = m_geoTransform[0] + scaledX * m_geoTransform[1] + scaledY * m_geoTransform[2];
    lat = m_geoTransform[3] + scaledX * m_geoTransform[4] + scaledY * m_geoTransform[5];
}

QPointF BathymetricDataLoader::pixelToGeo(int x, int y, int lodLevel) const
{
    double lat, lon;
    pixelToGeoInternal(x, y, lat, lon, lodLevel);
    return QPointF(lon, lat);  // Note: returns (lon, lat)
}

int BathymetricDataLoader::getRecommendedLOD(double zoomLevel) const
{
    if (!m_isLoaded || m_overviewCount == 0) {
        return 0;
    }

    // Simple heuristic: higher zoom = lower detail
    // zoomLevel 0-2: LOD 0 (full resolution)
    // zoomLevel 2-4: LOD 1
    // zoomLevel 4-6: LOD 2, etc.

    int lod = static_cast<int>(zoomLevel / 2.0);
    return std::min(lod, m_overviewCount);
}

void BathymetricDataLoader::clearCache()
{
    QMutexLocker locker(&m_cacheMutex);
    m_tileCache.clear();
    qDebug() << "Tile cache cleared";
}

QString BathymetricDataLoader::getCacheStats() const
{
    QMutexLocker locker(&m_cacheMutex);
    return QString("Cache: %1 tiles").arg(m_tileCache.size());
}

void BathymetricDataLoader::addToCache(const QString &key, std::shared_ptr<BathymetricTile> tile)
{
    QMutexLocker locker(&m_cacheMutex);

    // Evict if cache is full
    if (m_tileCache.size() >= MAX_CACHE_TILES) {
        evictOldestCacheTile();
    }

    m_tileCache[key] = tile;
}

std::shared_ptr<BathymetricTile> BathymetricDataLoader::getFromCache(const QString &key)
{
    QMutexLocker locker(&m_cacheMutex);

    auto it = m_tileCache.find(key);
    if (it != m_tileCache.end()) {
        return it.value();
    }

    return nullptr;
}

void BathymetricDataLoader::evictOldestCacheTile()
{
    // Simple eviction: remove first item (could be improved with LRU)
    if (!m_tileCache.isEmpty()) {
        auto it = m_tileCache.begin();
        m_tileCache.erase(it);
    }
}

bool BathymetricDataLoader::isValidCoordinate(double lat, double lon) const
{
    return lat >= -90.0 && lat <= 90.0 && lon >= -180.0 && lon <= 180.0;
}

void BathymetricDataLoader::cleanupGDAL()
{
    if (m_dataset) {
        GDALClose(m_dataset);
        m_dataset = nullptr;
        m_band = nullptr;
    }

    m_isLoaded = false;
    clearCache();
}
