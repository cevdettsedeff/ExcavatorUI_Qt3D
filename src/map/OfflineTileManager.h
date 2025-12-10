#ifndef OFFLINETILEMANAGER_H
#define OFFLINETILEMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QString>
#include <QList>
#include <QQueue>
#include <QMutex>
#include <QDir>

/**
 * OfflineTileManager - Downloads OSM tiles for offline use
 *
 * Downloads tiles for a specified region and zoom range,
 * saving them to the local cache directory.
 *
 * Usage from QML:
 *   offlineTileManager.downloadRegion(lat, lon, radiusKm, minZoom, maxZoom)
 */
class OfflineTileManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool isDownloading READ isDownloading NOTIFY isDownloadingChanged)
    Q_PROPERTY(int totalTiles READ totalTiles NOTIFY totalTilesChanged)
    Q_PROPERTY(int downloadedTiles READ downloadedTiles NOTIFY downloadedTilesChanged)
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QString cacheDirectory READ cacheDirectory WRITE setCacheDirectory NOTIFY cacheDirectoryChanged)
    Q_PROPERTY(qint64 cacheSize READ cacheSize NOTIFY cacheSizeChanged)

public:
    explicit OfflineTileManager(QObject *parent = nullptr);
    ~OfflineTileManager();

    // Properties
    bool isDownloading() const { return m_isDownloading; }
    int totalTiles() const { return m_totalTiles; }
    int downloadedTiles() const { return m_downloadedTiles; }
    double progress() const { return m_totalTiles > 0 ? (double)m_downloadedTiles / m_totalTiles : 0; }
    QString cacheDirectory() const { return m_cacheDirectory; }
    void setCacheDirectory(const QString &path);
    qint64 cacheSize() const;

    // Q_INVOKABLE methods for QML
    Q_INVOKABLE void downloadRegion(double centerLat, double centerLon,
                                     double radiusKm, int minZoom, int maxZoom);
    Q_INVOKABLE void downloadArea(double minLat, double maxLat,
                                   double minLon, double maxLon,
                                   int minZoom, int maxZoom);
    Q_INVOKABLE void cancelDownload();
    Q_INVOKABLE void clearCache();
    Q_INVOKABLE int estimateTileCount(double centerLat, double centerLon,
                                       double radiusKm, int minZoom, int maxZoom);
    Q_INVOKABLE QString formatCacheSize() const;

signals:
    void isDownloadingChanged();
    void totalTilesChanged();
    void downloadedTilesChanged();
    void progressChanged();
    void cacheDirectoryChanged();
    void cacheSizeChanged();
    void downloadComplete();
    void downloadError(const QString &error);
    void tileDownloaded(int z, int x, int y);

private slots:
    void onTileDownloaded();
    void processNextTile();

private:
    struct TileCoord {
        int z, x, y;
    };

    // Coordinate conversion
    int lonToTileX(double lon, int zoom);
    int latToTileY(double lat, int zoom);
    double tileXToLon(int x, int zoom);
    double tileYToLat(int y, int zoom);

    // Tile management
    QString getTileUrl(int z, int x, int y);
    QString getTileCachePath(int z, int x, int y);
    bool isTileCached(int z, int x, int y);
    void downloadTile(int z, int x, int y);
    void calculateTilesToDownload(double minLat, double maxLat,
                                   double minLon, double maxLon,
                                   int minZoom, int maxZoom);

    // State
    bool m_isDownloading;
    int m_totalTiles;
    int m_downloadedTiles;
    QString m_cacheDirectory;
    QString m_userAgent;

    // Download queue
    QQueue<TileCoord> m_downloadQueue;
    QNetworkAccessManager *m_networkManager;
    QNetworkReply *m_currentReply;
    TileCoord m_currentTile;

    // Concurrent downloads
    int m_maxConcurrentDownloads;
    int m_activeDownloads;
    QList<QNetworkReply*> m_activeReplies;

    QMutex m_mutex;
};

#endif // OFFLINETILEMANAGER_H
