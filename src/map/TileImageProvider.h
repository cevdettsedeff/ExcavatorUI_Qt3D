#ifndef TILEIMAGEPROVIDER_H
#define TILEIMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QPixmap>
#include <QCache>
#include <QMutex>
#include <QWaitCondition>
#include <QHash>

/**
 * TileImageProvider - Map tile loader with proper HTTP headers
 *
 * Supports multiple tile providers: OSM, CartoDB Positron
 * Loads tiles with correct User-Agent and Referer headers
 * to comply with tile usage policies.
 *
 * Features:
 * - Multiple tile providers (OSM, CartoDB)
 * - Proper HTTP headers (User-Agent, Referer)
 * - Local disk cache (separate per provider)
 * - Memory cache for recently used tiles
 * - Thread-safe tile loading
 *
 * Usage in QML:
 *   Image { source: "image://osmtiles/13/4561/2987" }
 */
class TileImageProvider : public QQuickImageProvider
{
public:
    TileImageProvider();
    ~TileImageProvider();

    // QQuickImageProvider interface
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override;

    // Configuration
    void setUserAgent(const QString &userAgent);
    void setCacheDirectory(const QString &path);
    void setStaticTileDirectory(const QString &path);
    void setMaxCacheSize(int megabytes);
    void setTileProvider(const QString &provider);

private:
    QPixmap loadTile(int z, int x, int y);
    QPixmap downloadTile(const QString &url);
    QString getTileUrl(int z, int x, int y);
    QString getCachePath(int z, int x, int y);

    QString m_userAgent;
    QString m_cacheDirectory;
    QString m_staticTileDirectory;  // Pre-downloaded tiles directory
    QString m_tileProvider;  // "osm" or "cartodb"
    QCache<QString, QPixmap> m_memoryCache;
    QMutex m_cacheMutex;
};

#endif // TILEIMAGEPROVIDER_H
