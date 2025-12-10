#ifndef BATHYMETRICDATALOADER_H
#define BATHYMETRICDATALOADER_H

#include <QObject>
#include <QVector>
#include <QPointF>
#include <QRectF>
#include <QHash>
#include <QMutex>
#include <QThreadPool>
#include <memory>

// Forward declaration for GDAL types to avoid exposing GDAL headers in Qt code
class GDALDataset;
class GDALRasterBand;

namespace BathymetryConstants {
    constexpr int DEFAULT_TILE_SIZE = 256;
    constexpr int MAX_CACHE_TILES = 100;
    constexpr double NO_DATA_VALUE = -32768.0;
}

/**
 * Represents a single tile of bathymetric data
 */
struct BathymetricTile {
    int tileX;
    int tileY;
    int lodLevel;
    int width;
    int height;
    QVector<float> depths;  // Elevation/depth values in meters
    QRectF geoBounds;       // Geographic bounds (lat/lon)
    bool isValid;

    BathymetricTile()
        : tileX(0), tileY(0), lodLevel(0)
        , width(0), height(0)
        , isValid(false) {}

    QString key() const {
        return QString("%1_%2_%3").arg(tileX).arg(tileY).arg(lodLevel);
    }
};

/**
 * Main class for loading and managing bathymetric data from GDAL VRT files
 * Supports:
 * - Virtual Raster (VRT) files combining multiple GeoTIFF tiles
 * - Level of Detail (LOD) using overview pyramids
 * - Tile-based lazy loading
 * - Thread-safe operations
 * - LRU cache for performance
 */
class BathymetricDataLoader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString vrtPath READ vrtPath WRITE setVrtPath NOTIFY vrtPathChanged)
    Q_PROPERTY(bool isLoaded READ isLoaded NOTIFY isLoadedChanged)
    Q_PROPERTY(QRectF geoBounds READ geoBounds NOTIFY geoBoundsChanged)
    Q_PROPERTY(int tileSize READ tileSize WRITE setTileSize NOTIFY tileSizeChanged)
    Q_PROPERTY(int overviewCount READ overviewCount NOTIFY overviewCountChanged)

public:
    explicit BathymetricDataLoader(QObject *parent = nullptr);
    ~BathymetricDataLoader();

    // Property getters
    QString vrtPath() const { return m_vrtPath; }
    bool isLoaded() const { return m_isLoaded; }
    QRectF geoBounds() const { return m_geoBounds; }
    int tileSize() const { return m_tileSize; }
    int overviewCount() const { return m_overviewCount; }

    // Property setters
    void setVrtPath(const QString &path);
    void setTileSize(int size);

    /**
     * Load VRT file and initialize GDAL dataset
     * @return true if successful
     */
    Q_INVOKABLE bool loadVRT();

    /**
     * Get depth value at specific geographic coordinate
     * @param lat Latitude in degrees
     * @param lon Longitude in degrees
     * @param lodLevel Level of detail (0 = highest resolution)
     * @return Depth in meters (negative = below sea level)
     */
    Q_INVOKABLE float getDepthAt(double lat, double lon, int lodLevel = 0);

    /**
     * Load a tile of bathymetric data
     * @param tileX Tile X index
     * @param tileY Tile Y index
     * @param lodLevel Level of detail
     * @return Tile data (may be cached)
     */
    Q_INVOKABLE BathymetricTile* loadTile(int tileX, int tileY, int lodLevel = 0);

    /**
     * Get depth data for a rectangular region
     * @param bounds Geographic bounds (lat/lon)
     * @param width Output width in pixels
     * @param height Output height in pixels
     * @param lodLevel Level of detail
     * @return Vector of depth values (row-major order)
     */
    Q_INVOKABLE QVector<float> getDepthRegion(const QRectF &bounds, int width, int height, int lodLevel = 0);

    /**
     * Convert geographic coordinates to pixel coordinates
     */
    Q_INVOKABLE QPointF geoToPixel(double lat, double lon, int lodLevel = 0) const;

    /**
     * Convert pixel coordinates to geographic coordinates
     */
    Q_INVOKABLE QPointF pixelToGeo(int x, int y, int lodLevel = 0) const;

    /**
     * Get recommended LOD level based on camera distance/zoom
     * @param zoomLevel Camera zoom (0 = closest, higher = farther)
     * @return Recommended LOD level
     */
    Q_INVOKABLE int getRecommendedLOD(double zoomLevel) const;

    /**
     * Clear tile cache
     */
    Q_INVOKABLE void clearCache();

    /**
     * Get cache statistics
     */
    Q_INVOKABLE QString getCacheStats() const;

signals:
    void vrtPathChanged();
    void isLoadedChanged();
    void geoBoundsChanged();
    void tileSizeChanged();
    void overviewCountChanged();
    void loadingProgress(int percent);
    void errorOccurred(const QString &error);
    void tileLoaded(int tileX, int tileY, int lodLevel);

private:
    QString m_vrtPath;
    bool m_isLoaded;
    QRectF m_geoBounds;  // Geographic bounds in lat/lon
    int m_tileSize;
    int m_overviewCount;

    // GDAL resources
    GDALDataset *m_dataset;
    GDALRasterBand *m_band;

    // Coordinate transformation parameters
    double m_geoTransform[6];  // GDAL geotransform matrix
    int m_rasterWidth;
    int m_rasterHeight;

    // Tile cache (LRU)
    QHash<QString, std::shared_ptr<BathymetricTile>> m_tileCache;
    QMutex m_cacheMutex;
    QThreadPool m_threadPool;

    // Cache management
    void addToCache(const QString &key, std::shared_ptr<BathymetricTile> tile);
    std::shared_ptr<BathymetricTile> getFromCache(const QString &key);
    void evictOldestCacheTile();

    // GDAL helpers
    bool initializeGDAL();
    void cleanupGDAL();
    float readPixelValue(int x, int y, int lodLevel);
    bool isValidCoordinate(double lat, double lon) const;

    // Coordinate transformations
    void computeGeoBounds();
    void geoToPixelInternal(double lat, double lon, int &x, int &y, int lodLevel) const;
    void pixelToGeoInternal(int x, int y, double &lat, double &lon, int lodLevel) const;
};

#endif // BATHYMETRICDATALOADER_H
