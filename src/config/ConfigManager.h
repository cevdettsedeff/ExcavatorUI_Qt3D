#ifndef CONFIGMANAGER_H
#define CONFIGMANAGER_H

#include <QObject>
#include <QString>
#include <QJsonObject>
#include <QColor>

/**
 * Manages application configuration from JSON file
 * Provides easy access to bathymetry and rendering settings
 */
class ConfigManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString configPath READ configPath WRITE setConfigPath NOTIFY configPathChanged)
    Q_PROPERTY(bool isLoaded READ isLoaded NOTIFY isLoadedChanged)

    // Bathymetry settings
    Q_PROPERTY(QString vrtPath READ vrtPath NOTIFY vrtPathChanged)
    Q_PROPERTY(int tileSize READ tileSize NOTIFY tileSizeChanged)
    Q_PROPERTY(int cacheSize READ cacheSize NOTIFY cacheSizeChanged)
    Q_PROPERTY(int defaultLOD READ defaultLOD NOTIFY defaultLODChanged)

    // Rendering settings
    Q_PROPERTY(double verticalExaggeration READ verticalExaggeration NOTIFY verticalExaggerationChanged)
    Q_PROPERTY(bool gridVisible READ gridVisible NOTIFY gridVisibleChanged)
    Q_PROPERTY(bool legendVisible READ legendVisible NOTIFY legendVisibleChanged)

public:
    explicit ConfigManager(QObject *parent = nullptr);
    ~ConfigManager();

    // Property getters
    QString configPath() const { return m_configPath; }
    bool isLoaded() const { return m_isLoaded; }

    QString vrtPath() const { return m_vrtPath; }
    int tileSize() const { return m_tileSize; }
    int cacheSize() const { return m_cacheSize; }
    int defaultLOD() const { return m_defaultLOD; }

    double verticalExaggeration() const { return m_verticalExaggeration; }
    bool gridVisible() const { return m_gridVisible; }
    bool legendVisible() const { return m_legendVisible; }

    // Property setters
    void setConfigPath(const QString &path);

    /**
     * Load configuration from JSON file
     * @return true if successful
     */
    Q_INVOKABLE bool loadConfig();

    /**
     * Reload configuration from disk
     */
    Q_INVOKABLE void reloadConfig();

    /**
     * Get color for depth value based on config color scheme
     * @param depth Depth in meters (negative = below sea level)
     * @return QColor for the depth
     */
    Q_INVOKABLE QColor getDepthColor(double depth) const;

    /**
     * Get depth range name for a given depth
     * @param depth Depth in meters
     * @return Range name (e.g., "shallow", "mid", "deep")
     */
    Q_INVOKABLE QString getDepthRangeName(double depth) const;

signals:
    void configPathChanged();
    void isLoadedChanged();
    void vrtPathChanged();
    void tileSizeChanged();
    void cacheSizeChanged();
    void defaultLODChanged();
    void verticalExaggerationChanged();
    void gridVisibleChanged();
    void legendVisibleChanged();
    void configLoaded();
    void errorOccurred(const QString &error);

private:
    QString m_configPath;
    bool m_isLoaded;

    // Bathymetry settings
    QString m_vrtPath;
    int m_tileSize;
    int m_cacheSize;
    int m_defaultLOD;

    // Color scheme
    QColor m_colorShallow;
    QColor m_colorShallowMid;
    QColor m_colorMid;
    QColor m_colorMidDeep;
    QColor m_colorDeep;

    // Depth ranges
    double m_rangeShallow[2];      // [min, max]
    double m_rangeShallowMid[2];
    double m_rangeMid[2];
    double m_rangeMidDeep[2];
    double m_rangeDeep[2];

    // Rendering settings
    double m_verticalExaggeration;
    bool m_gridVisible;
    bool m_legendVisible;

    // JSON parsing helpers
    void parseConfig(const QJsonObject &json);
    void parseBathymetrySettings(const QJsonObject &bathymetry);
    void parseColorScheme(const QJsonObject &colorScheme);
    void parseDepthRanges(const QJsonObject &depthRanges);
    void parseRenderingSettings(const QJsonObject &rendering);
    QColor parseColor(const QString &colorString) const;
    void setDefaultValues();
};

#endif // CONFIGMANAGER_H
