#include "ConfigManager.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDebug>
#include <QDir>

ConfigManager::ConfigManager(QObject *parent)
    : QObject(parent)
    , m_isLoaded(false)
    , m_tileSize(256)
    , m_cacheSize(100)
    , m_defaultLOD(0)
    , m_verticalExaggeration(2.0)
    , m_gridVisible(true)
    , m_legendVisible(true)
{
    setDefaultValues();

    // Default config path
    m_configPath = QDir::currentPath() + "/config/bathymetry_config.json";
}

ConfigManager::~ConfigManager()
{
}

void ConfigManager::setConfigPath(const QString &path)
{
    if (m_configPath != path) {
        m_configPath = path;
        emit configPathChanged();

        // Auto-load if file exists
        if (QFile::exists(path)) {
            loadConfig();
        }
    }
}

bool ConfigManager::loadConfig()
{
    if (m_configPath.isEmpty()) {
        emit errorOccurred("Config path is empty");
        return false;
    }

    QFile file(m_configPath);
    if (!file.exists()) {
        qWarning() << "Config file does not exist:" << m_configPath;
        qWarning() << "Using default values";
        emit errorOccurred("Config file not found: " + m_configPath);
        return false;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        QString error = "Cannot open config file: " + file.errorString();
        qWarning() << error;
        emit errorOccurred(error);
        return false;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        QString error = "JSON parse error: " + parseError.errorString();
        qWarning() << error;
        emit errorOccurred(error);
        return false;
    }

    if (!doc.isObject()) {
        emit errorOccurred("Config root must be a JSON object");
        return false;
    }

    // Parse configuration
    parseConfig(doc.object());

    m_isLoaded = true;
    emit isLoadedChanged();
    emit configLoaded();

    qDebug() << "✓ Configuration loaded from" << m_configPath;
    qDebug() << "  VRT Path:" << m_vrtPath;
    qDebug() << "  Tile Size:" << m_tileSize;
    qDebug() << "  Cache Size:" << m_cacheSize;
    qDebug() << "  Default LOD:" << m_defaultLOD;
    qDebug() << "  Vertical Exaggeration:" << m_verticalExaggeration;

    return true;
}

void ConfigManager::reloadConfig()
{
    loadConfig();
}

void ConfigManager::parseConfig(const QJsonObject &json)
{
    // Parse bathymetry settings
    if (json.contains("bathymetry") && json["bathymetry"].isObject()) {
        parseBathymetrySettings(json["bathymetry"].toObject());
    }

    // Parse rendering settings
    if (json.contains("rendering") && json["rendering"].isObject()) {
        parseRenderingSettings(json["rendering"].toObject());
    }
}

void ConfigManager::parseBathymetrySettings(const QJsonObject &bathymetry)
{
    if (bathymetry.contains("vrt_path")) {
        QString newPath = bathymetry["vrt_path"].toString();
        if (m_vrtPath != newPath) {
            m_vrtPath = newPath;
            emit vrtPathChanged();
        }
    }

    if (bathymetry.contains("tile_size")) {
        int newSize = bathymetry["tile_size"].toInt(256);
        if (m_tileSize != newSize) {
            m_tileSize = newSize;
            emit tileSizeChanged();
        }
    }

    if (bathymetry.contains("cache_size")) {
        int newCache = bathymetry["cache_size"].toInt(100);
        if (m_cacheSize != newCache) {
            m_cacheSize = newCache;
            emit cacheSizeChanged();
        }
    }

    if (bathymetry.contains("default_lod")) {
        int newLOD = bathymetry["default_lod"].toInt(0);
        if (m_defaultLOD != newLOD) {
            m_defaultLOD = newLOD;
            emit defaultLODChanged();
        }
    }

    // Parse color scheme
    if (bathymetry.contains("color_scheme") && bathymetry["color_scheme"].isObject()) {
        parseColorScheme(bathymetry["color_scheme"].toObject());
    }

    // Parse depth ranges
    if (bathymetry.contains("depth_ranges") && bathymetry["depth_ranges"].isObject()) {
        parseDepthRanges(bathymetry["depth_ranges"].toObject());
    }
}

void ConfigManager::parseColorScheme(const QJsonObject &colorScheme)
{
    m_colorShallow = parseColor(colorScheme["shallow"].toString("#90EE90"));
    m_colorShallowMid = parseColor(colorScheme["shallow_mid"].toString("#4DB8A8"));
    m_colorMid = parseColor(colorScheme["mid"].toString("#3EADC4"));
    m_colorMidDeep = parseColor(colorScheme["mid_deep"].toString("#2E8BC0"));
    m_colorDeep = parseColor(colorScheme["deep"].toString("#1F5F8B"));
}

void ConfigManager::parseDepthRanges(const QJsonObject &depthRanges)
{
    auto parseRange = [](const QJsonValue &value, double defaultMin, double defaultMax, double *outRange) {
        if (value.isArray()) {
            QJsonArray arr = value.toArray();
            if (arr.size() >= 2) {
                outRange[0] = arr[0].toDouble(defaultMin);
                outRange[1] = arr[1].toDouble(defaultMax);
            }
        }
    };

    parseRange(depthRanges["shallow"], 0, 5, m_rangeShallow);
    parseRange(depthRanges["shallow_mid"], 5, 15, m_rangeShallowMid);
    parseRange(depthRanges["mid"], 15, 30, m_rangeMid);
    parseRange(depthRanges["mid_deep"], 30, 45, m_rangeMidDeep);
    parseRange(depthRanges["deep"], 45, 60, m_rangeDeep);
}

void ConfigManager::parseRenderingSettings(const QJsonObject &rendering)
{
    if (rendering.contains("vertical_exaggeration")) {
        double newValue = rendering["vertical_exaggeration"].toDouble(2.0);
        if (m_verticalExaggeration != newValue) {
            m_verticalExaggeration = newValue;
            emit verticalExaggerationChanged();
        }
    }

    if (rendering.contains("grid_visible")) {
        bool newValue = rendering["grid_visible"].toBool(true);
        if (m_gridVisible != newValue) {
            m_gridVisible = newValue;
            emit gridVisibleChanged();
        }
    }

    if (rendering.contains("legend_visible")) {
        bool newValue = rendering["legend_visible"].toBool(true);
        if (m_legendVisible != newValue) {
            m_legendVisible = newValue;
            emit legendVisibleChanged();
        }
    }
}

QColor ConfigManager::parseColor(const QString &colorString) const
{
    if (colorString.startsWith("#")) {
        return QColor(colorString);
    }
    return QColor(colorString);
}

void ConfigManager::setDefaultValues()
{
    // Default color scheme
    m_colorShallow = QColor("#90EE90");
    m_colorShallowMid = QColor("#4DB8A8");
    m_colorMid = QColor("#3EADC4");
    m_colorMidDeep = QColor("#2E8BC0");
    m_colorDeep = QColor("#1F5F8B");

    // Default depth ranges
    m_rangeShallow[0] = 0; m_rangeShallow[1] = 5;
    m_rangeShallowMid[0] = 5; m_rangeShallowMid[1] = 15;
    m_rangeMid[0] = 15; m_rangeMid[1] = 30;
    m_rangeMidDeep[0] = 30; m_rangeMidDeep[1] = 45;
    m_rangeDeep[0] = 45; m_rangeDeep[1] = 10000;
}

QColor ConfigManager::getDepthColor(double depth) const
{
    double absDepth = std::abs(depth);

    if (absDepth < m_rangeShallow[1]) {
        return m_colorShallow;
    } else if (absDepth < m_rangeShallowMid[1]) {
        return m_colorShallowMid;
    } else if (absDepth < m_rangeMid[1]) {
        return m_colorMid;
    } else if (absDepth < m_rangeMidDeep[1]) {
        return m_colorMidDeep;
    } else {
        return m_colorDeep;
    }
}

QString ConfigManager::getDepthRangeName(double depth) const
{
    double absDepth = std::abs(depth);

    if (absDepth < m_rangeShallow[1]) {
        return "shallow";
    } else if (absDepth < m_rangeShallowMid[1]) {
        return "shallow_mid";
    } else if (absDepth < m_rangeMid[1]) {
        return "mid";
    } else if (absDepth < m_rangeMidDeep[1]) {
        return "mid_deep";
    } else {
        return "deep";
    }
}
