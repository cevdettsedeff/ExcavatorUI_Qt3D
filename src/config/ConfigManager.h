#ifndef CONFIGMANAGER_H
#define CONFIGMANAGER_H

#include <QObject>
#include <QString>
#include <QJsonObject>
#include <QJsonArray>
#include <QColor>
#include <QVariantList>
#include <QVariantMap>

/**
 * Manages application configuration from JSON file
 * Provides easy access to bathymetry and rendering settings
 */
class ConfigManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString configPath READ configPath WRITE setConfigPath NOTIFY configPathChanged)
    Q_PROPERTY(bool isLoaded READ isLoaded NOTIFY isLoadedChanged)
    Q_PROPERTY(bool isConfigured READ isConfigured NOTIFY isConfiguredChanged)

    // Bathymetry settings
    Q_PROPERTY(QString vrtPath READ vrtPath NOTIFY vrtPathChanged)
    Q_PROPERTY(int tileSize READ tileSize NOTIFY tileSizeChanged)
    Q_PROPERTY(int cacheSize READ cacheSize NOTIFY cacheSizeChanged)
    Q_PROPERTY(int defaultLOD READ defaultLOD NOTIFY defaultLODChanged)

    // Rendering settings
    Q_PROPERTY(double verticalExaggeration READ verticalExaggeration NOTIFY verticalExaggerationChanged)
    Q_PROPERTY(bool gridVisible READ gridVisible NOTIFY gridVisibleChanged)
    Q_PROPERTY(bool legendVisible READ legendVisible NOTIFY legendVisibleChanged)

    // Excavator settings
    Q_PROPERTY(QString excavatorName READ excavatorName WRITE setExcavatorName NOTIFY excavatorNameChanged)
    Q_PROPERTY(double boomLength READ boomLength WRITE setBoomLength NOTIFY boomLengthChanged)
    Q_PROPERTY(double armLength READ armLength WRITE setArmLength NOTIFY armLengthChanged)
    Q_PROPERTY(double bucketWidth READ bucketWidth WRITE setBucketWidth NOTIFY bucketWidthChanged)
    Q_PROPERTY(double scanningDepth READ scanningDepth WRITE setScanningDepth NOTIFY scanningDepthChanged)
    Q_PROPERTY(bool excavatorConfigured READ excavatorConfigured NOTIFY excavatorConfiguredChanged)
    Q_PROPERTY(QVariantList excavatorPresets READ excavatorPresets NOTIFY excavatorPresetsChanged)

    // Dig Area / Grid settings
    Q_PROPERTY(int gridRows READ gridRows WRITE setGridRows NOTIFY gridRowsChanged)
    Q_PROPERTY(int gridCols READ gridCols WRITE setGridCols NOTIFY gridColsChanged)
    Q_PROPERTY(QVariantList gridDepths READ gridDepths WRITE setGridDepths NOTIFY gridDepthsChanged)
    Q_PROPERTY(bool digAreaConfigured READ digAreaConfigured NOTIFY digAreaConfiguredChanged)
    Q_PROPERTY(double targetDepth READ targetDepth WRITE setTargetDepth NOTIFY targetDepthChanged)
    Q_PROPERTY(double calculatedMaxDepth READ calculatedMaxDepth NOTIFY calculatedMaxDepthChanged)
    // Grid coordinate bounds
    Q_PROPERTY(double gridStartLatitude READ gridStartLatitude WRITE setGridStartLatitude NOTIFY gridStartLatitudeChanged)
    Q_PROPERTY(double gridStartLongitude READ gridStartLongitude WRITE setGridStartLongitude NOTIFY gridStartLongitudeChanged)
    Q_PROPERTY(double gridEndLatitude READ gridEndLatitude WRITE setGridEndLatitude NOTIFY gridEndLatitudeChanged)
    Q_PROPERTY(double gridEndLongitude READ gridEndLongitude WRITE setGridEndLongitude NOTIFY gridEndLongitudeChanged)

    // Map settings
    Q_PROPERTY(double mapCenterLatitude READ mapCenterLatitude WRITE setMapCenterLatitude NOTIFY mapCenterLatitudeChanged)
    Q_PROPERTY(double mapCenterLongitude READ mapCenterLongitude WRITE setMapCenterLongitude NOTIFY mapCenterLongitudeChanged)
    Q_PROPERTY(int mapZoomLevel READ mapZoomLevel WRITE setMapZoomLevel NOTIFY mapZoomLevelChanged)
    Q_PROPERTY(double mapAreaWidth READ mapAreaWidth WRITE setMapAreaWidth NOTIFY mapAreaWidthChanged)
    Q_PROPERTY(double mapAreaHeight READ mapAreaHeight WRITE setMapAreaHeight NOTIFY mapAreaHeightChanged)
    Q_PROPERTY(bool mapConfigured READ mapConfigured NOTIFY mapConfiguredChanged)

    // Alarm settings
    Q_PROPERTY(QString alarmColorCritical READ alarmColorCritical WRITE setAlarmColorCritical NOTIFY alarmColorCriticalChanged)
    Q_PROPERTY(QString alarmColorWarning READ alarmColorWarning WRITE setAlarmColorWarning NOTIFY alarmColorWarningChanged)
    Q_PROPERTY(QString alarmColorInfo READ alarmColorInfo WRITE setAlarmColorInfo NOTIFY alarmColorInfoChanged)
    Q_PROPERTY(QString alarmColorSuccess READ alarmColorSuccess WRITE setAlarmColorSuccess NOTIFY alarmColorSuccessChanged)
    Q_PROPERTY(bool alarmConfigured READ alarmConfigured NOTIFY alarmConfiguredChanged)

    // Screen Saver settings
    Q_PROPERTY(bool screenSaverEnabled READ screenSaverEnabled WRITE setScreenSaverEnabled NOTIFY screenSaverEnabledChanged)
    Q_PROPERTY(int screenSaverTimeoutSeconds READ screenSaverTimeoutSeconds WRITE setScreenSaverTimeoutSeconds NOTIFY screenSaverTimeoutSecondsChanged)

public:
    explicit ConfigManager(QObject *parent = nullptr);
    ~ConfigManager();

    // Property getters
    QString configPath() const { return m_configPath; }
    bool isLoaded() const { return m_isLoaded; }
    bool isConfigured() const;

    QString vrtPath() const { return m_vrtPath; }
    int tileSize() const { return m_tileSize; }
    int cacheSize() const { return m_cacheSize; }
    int defaultLOD() const { return m_defaultLOD; }

    double verticalExaggeration() const { return m_verticalExaggeration; }
    bool gridVisible() const { return m_gridVisible; }
    bool legendVisible() const { return m_legendVisible; }

    // Excavator getters
    QString excavatorName() const { return m_excavatorName; }
    double boomLength() const { return m_boomLength; }
    double armLength() const { return m_armLength; }
    double bucketWidth() const { return m_bucketWidth; }
    double scanningDepth() const { return m_scanningDepth; }
    bool excavatorConfigured() const { return m_excavatorConfigured; }
    QVariantList excavatorPresets() const { return m_excavatorPresets; }

    // Dig Area getters
    int gridRows() const { return m_gridRows; }
    int gridCols() const { return m_gridCols; }
    QVariantList gridDepths() const { return m_gridDepths; }
    bool digAreaConfigured() const { return m_digAreaConfigured; }
    double targetDepth() const { return m_targetDepth; }
    double calculatedMaxDepth() const;
    double gridStartLatitude() const { return m_gridStartLatitude; }
    double gridStartLongitude() const { return m_gridStartLongitude; }
    double gridEndLatitude() const { return m_gridEndLatitude; }
    double gridEndLongitude() const { return m_gridEndLongitude; }

    // Map getters
    double mapCenterLatitude() const { return m_mapCenterLatitude; }
    double mapCenterLongitude() const { return m_mapCenterLongitude; }
    int mapZoomLevel() const { return m_mapZoomLevel; }
    double mapAreaWidth() const { return m_mapAreaWidth; }
    double mapAreaHeight() const { return m_mapAreaHeight; }
    bool mapConfigured() const { return m_mapConfigured; }

    // Alarm getters
    QString alarmColorCritical() const { return m_alarmColorCritical; }
    QString alarmColorWarning() const { return m_alarmColorWarning; }
    QString alarmColorInfo() const { return m_alarmColorInfo; }
    QString alarmColorSuccess() const { return m_alarmColorSuccess; }
    bool alarmConfigured() const { return m_alarmConfigured; }

    // Screen Saver getters
    bool screenSaverEnabled() const { return m_screenSaverEnabled; }
    int screenSaverTimeoutSeconds() const { return m_screenSaverTimeoutSeconds; }

    // Property setters
    void setConfigPath(const QString &path);

    // Excavator setters
    void setExcavatorName(const QString &name);
    void setBoomLength(double length);
    void setArmLength(double length);
    void setBucketWidth(double width);
    void setScanningDepth(double depth);

    // Dig Area setters
    void setGridRows(int rows);
    void setGridCols(int cols);
    void setGridDepths(const QVariantList &depths);
    void setTargetDepth(double depth);
    void setGridStartLatitude(double lat);
    void setGridStartLongitude(double lon);
    void setGridEndLatitude(double lat);
    void setGridEndLongitude(double lon);

    // Map setters
    void setMapCenterLatitude(double lat);
    void setMapCenterLongitude(double lon);
    void setMapZoomLevel(int zoom);
    void setMapAreaWidth(double width);
    void setMapAreaHeight(double height);

    // Alarm setters
    void setAlarmColorCritical(const QString &color);
    void setAlarmColorWarning(const QString &color);
    void setAlarmColorInfo(const QString &color);
    void setAlarmColorSuccess(const QString &color);

    // Screen Saver setters
    void setScreenSaverEnabled(bool enabled);
    void setScreenSaverTimeoutSeconds(int seconds);

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

    /**
     * Get depth for specific grid cell
     * @param row Grid row index
     * @param col Grid column index
     * @return Depth value or 0 if invalid
     */
    Q_INVOKABLE double getGridDepth(int row, int col) const;

    /**
     * Set depth for specific grid cell
     * @param row Grid row index
     * @param col Grid column index
     * @param depth Depth value
     */
    Q_INVOKABLE void setGridDepth(int row, int col, double depth);

    /**
     * Save current configuration to file
     * @return true if successful
     */
    Q_INVOKABLE bool saveConfig();

    /**
     * Mark excavator configuration as complete
     */
    Q_INVOKABLE void markExcavatorConfigured();

    /**
     * Load excavator preset by index
     * @param index Preset index (0-9 for predefined excavators)
     */
    Q_INVOKABLE void loadExcavatorPreset(int index);

    /**
     * Mark dig area configuration as complete
     */
    Q_INVOKABLE void markDigAreaConfigured();

    /**
     * Mark map configuration as complete
     */
    Q_INVOKABLE void markMapConfigured();

    /**
     * Mark alarm configuration as complete
     */
    Q_INVOKABLE void markAlarmConfigured();

    /**
     * Reset all configurations
     */
    Q_INVOKABLE void resetConfiguration();

signals:
    void configPathChanged();
    void isLoadedChanged();
    void isConfiguredChanged();
    void vrtPathChanged();
    void tileSizeChanged();
    void cacheSizeChanged();
    void defaultLODChanged();
    void verticalExaggerationChanged();
    void gridVisibleChanged();
    void legendVisibleChanged();
    void configLoaded();
    void errorOccurred(const QString &error);

    // Excavator signals
    void excavatorNameChanged();
    void boomLengthChanged();
    void armLengthChanged();
    void bucketWidthChanged();
    void scanningDepthChanged();
    void excavatorConfiguredChanged();
    void excavatorPresetsChanged();

    // Dig Area signals
    void gridRowsChanged();
    void gridColsChanged();
    void gridDepthsChanged();
    void digAreaConfiguredChanged();
    void targetDepthChanged();
    void calculatedMaxDepthChanged();
    void gridStartLatitudeChanged();
    void gridStartLongitudeChanged();
    void gridEndLatitudeChanged();
    void gridEndLongitudeChanged();

    // Map signals
    void mapCenterLatitudeChanged();
    void mapCenterLongitudeChanged();
    void mapZoomLevelChanged();
    void mapAreaWidthChanged();
    void mapAreaHeightChanged();
    void mapConfiguredChanged();

    // Alarm signals
    void alarmColorCriticalChanged();
    void alarmColorWarningChanged();
    void alarmColorInfoChanged();
    void alarmColorSuccessChanged();
    void alarmConfiguredChanged();

    // Screen Saver signals
    void screenSaverEnabledChanged();
    void screenSaverTimeoutSecondsChanged();

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

    // Excavator settings
    QString m_excavatorName;
    double m_boomLength;
    double m_armLength;
    double m_bucketWidth;
    double m_scanningDepth;
    bool m_excavatorConfigured;
    QVariantList m_excavatorPresets;

    // Dig Area / Grid settings
    int m_gridRows;
    int m_gridCols;
    QVariantList m_gridDepths;
    bool m_digAreaConfigured;
    double m_targetDepth;
    double m_gridStartLatitude;
    double m_gridStartLongitude;
    double m_gridEndLatitude;
    double m_gridEndLongitude;

    // Map settings
    double m_mapCenterLatitude;
    double m_mapCenterLongitude;
    int m_mapZoomLevel;
    double m_mapAreaWidth;
    double m_mapAreaHeight;
    bool m_mapConfigured;

    // Alarm settings
    QString m_alarmColorCritical;
    QString m_alarmColorWarning;
    QString m_alarmColorInfo;
    QString m_alarmColorSuccess;
    bool m_alarmConfigured;

    // Screen Saver settings
    bool m_screenSaverEnabled;
    int m_screenSaverTimeoutSeconds;  // saniye cinsinden (min: 10, max: 1800)

    // JSON parsing helpers
    void parseConfig(const QJsonObject &json);
    void parseBathymetrySettings(const QJsonObject &bathymetry);
    void parseColorScheme(const QJsonObject &colorScheme);
    void parseDepthRanges(const QJsonObject &depthRanges);
    void parseRenderingSettings(const QJsonObject &rendering);
    void parseExcavatorSettings(const QJsonObject &excavator);
    void parseDigAreaSettings(const QJsonObject &digArea);
    void parseMapSettings(const QJsonObject &mapSettings);
    void parseAlarmSettings(const QJsonObject &alarmSettings);
    void parseScreenSaverSettings(const QJsonObject &screenSaverSettings);
    QColor parseColor(const QString &colorString) const;
    void setDefaultValues();
    void initializeGridDepths();
    void initializeExcavatorPresets();
};

#endif // CONFIGMANAGER_H
