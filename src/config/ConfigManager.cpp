#include "ConfigManager.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDebug>
#include <QDir>
#include <QStandardPaths>

ConfigManager::ConfigManager(QObject *parent)
    : QObject(parent)
    , m_isLoaded(false)
    , m_tileSize(256)
    , m_cacheSize(100)
    , m_defaultLOD(0)
    , m_verticalExaggeration(2.0)
    , m_gridVisible(true)
    , m_legendVisible(true)
    , m_boomLength(12.0)
    , m_armLength(10.0)
    , m_bucketWidth(2.0)
    , m_scanningDepth(15.0)
    , m_excavatorConfigured(false)
    , m_gridRows(4)
    , m_gridCols(4)
    , m_digAreaConfigured(false)
    , m_targetDepth(15.0)
    , m_gridStartLatitude(40.7100)
    , m_gridStartLongitude(29.0000)
    , m_gridEndLatitude(40.7200)
    , m_gridEndLongitude(29.0100)
    , m_mapCenterLatitude(40.7128)
    , m_mapCenterLongitude(29.0060)
    , m_mapZoomLevel(15)
    , m_mapAreaWidth(500.0)
    , m_mapAreaHeight(500.0)
    , m_mapConfigured(false)
    , m_alarmColorCritical("#FF4444")
    , m_alarmColorWarning("#FFA500")
    , m_alarmColorInfo("#2196F3")
    , m_alarmColorSuccess("#4CAF50")
    , m_alarmConfigured(false)
    , m_screenSaverEnabled(true)
    , m_screenSaverTimeoutSeconds(120)  // Varsayılan 2 dakika = 120 saniye
{
    setDefaultValues();
    initializeGridDepths();
    initializeExcavatorPresets();

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

    // Parse excavator settings
    if (json.contains("excavator") && json["excavator"].isObject()) {
        parseExcavatorSettings(json["excavator"].toObject());
    }

    // Parse dig area settings
    if (json.contains("dig_area") && json["dig_area"].isObject()) {
        parseDigAreaSettings(json["dig_area"].toObject());
    }

    // Parse map settings
    if (json.contains("map") && json["map"].isObject()) {
        parseMapSettings(json["map"].toObject());
    }

    // Parse alarm settings
    if (json.contains("alarm") && json["alarm"].isObject()) {
        parseAlarmSettings(json["alarm"].toObject());
    }

    // Parse screen saver settings
    if (json.contains("screen_saver") && json["screen_saver"].isObject()) {
        parseScreenSaverSettings(json["screen_saver"].toObject());
    }

    // Parse excavator presets
    if (json.contains("excavator_presets") && json["excavator_presets"].isArray()) {
        parseExcavatorPresets(json["excavator_presets"].toArray());
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

bool ConfigManager::isConfigured() const
{
    return m_excavatorConfigured && m_digAreaConfigured && m_mapConfigured && m_alarmConfigured;
}

// Excavator setters
void ConfigManager::setExcavatorName(const QString &name)
{
    if (m_excavatorName != name) {
        m_excavatorName = name;
        emit excavatorNameChanged();
    }
}

void ConfigManager::setBoomLength(double length)
{
    if (m_boomLength != length) {
        m_boomLength = length;
        emit boomLengthChanged();
    }
}

void ConfigManager::setArmLength(double length)
{
    if (m_armLength != length) {
        m_armLength = length;
        emit armLengthChanged();
    }
}

void ConfigManager::setBucketWidth(double width)
{
    if (m_bucketWidth != width) {
        m_bucketWidth = width;
        emit bucketWidthChanged();
    }
}

void ConfigManager::setScanningDepth(double depth)
{
    if (m_scanningDepth != depth) {
        m_scanningDepth = depth;
        emit scanningDepthChanged();
    }
}

// Dig Area setters
void ConfigManager::setGridRows(int rows)
{
    if (m_gridRows != rows && rows > 0) {
        m_gridRows = rows;
        initializeGridDepths();
        emit gridRowsChanged();
    }
}

void ConfigManager::setGridCols(int cols)
{
    if (m_gridCols != cols && cols > 0) {
        m_gridCols = cols;
        initializeGridDepths();
        emit gridColsChanged();
    }
}

void ConfigManager::setGridDepths(const QVariantList &depths)
{
    m_gridDepths = depths;
    emit gridDepthsChanged();
    emit calculatedMaxDepthChanged();
}

void ConfigManager::setTargetDepth(double depth)
{
    if (m_targetDepth != depth) {
        m_targetDepth = depth;
        emit targetDepthChanged();
    }
}

double ConfigManager::calculatedMaxDepth() const
{
    double maxVal = 0.0;
    for (const auto &depth : m_gridDepths) {
        double d = depth.toDouble();
        if (d > maxVal) {
            maxVal = d;
        }
    }
    return maxVal > 0 ? maxVal : 15.0; // Default 15m if no depths set
}

void ConfigManager::setGridStartLatitude(double lat)
{
    if (m_gridStartLatitude != lat) {
        m_gridStartLatitude = lat;
        emit gridStartLatitudeChanged();
    }
}

void ConfigManager::setGridStartLongitude(double lon)
{
    if (m_gridStartLongitude != lon) {
        m_gridStartLongitude = lon;
        emit gridStartLongitudeChanged();
    }
}

void ConfigManager::setGridEndLatitude(double lat)
{
    if (m_gridEndLatitude != lat) {
        m_gridEndLatitude = lat;
        emit gridEndLatitudeChanged();
    }
}

void ConfigManager::setGridEndLongitude(double lon)
{
    if (m_gridEndLongitude != lon) {
        m_gridEndLongitude = lon;
        emit gridEndLongitudeChanged();
    }
}

void ConfigManager::initializeGridDepths()
{
    m_gridDepths.clear();
    for (int i = 0; i < m_gridRows * m_gridCols; ++i) {
        m_gridDepths.append(0.0);
    }
    emit gridDepthsChanged();
}

void ConfigManager::initializeExcavatorPresets()
{
    // Only initialize with default presets if JSON doesn't have any
    // This will be overridden by parseExcavatorPresets() if JSON has presets
    if (m_excavatorPresets.isEmpty()) {
        m_excavatorPresets.clear();

        // Default preset 0: UDHB Burak
        QVariantMap preset0;
        preset0["name"] = "UDHB Burak";
        preset0["scanningDepth"] = 15.0;
        preset0["boomLength"] = 13.5;
        preset0["armLength"] = 9.0;
        preset0["bucketWidth"] = 3.1;
        m_excavatorPresets.append(preset0);

        // Default preset 1: Mimar Sinan
        QVariantMap preset1;
        preset1["name"] = "Mimar Sinan";
        preset1["scanningDepth"] = 14.0;
        preset1["boomLength"] = 12.0;
        preset1["armLength"] = 8.5;
        preset1["bucketWidth"] = 3.1;
        m_excavatorPresets.append(preset1);

        // Default preset 2: Kazar II
        QVariantMap preset2;
        preset2["name"] = "Kazar II";
        preset2["scanningDepth"] = 9.5;
        preset2["boomLength"] = 10.5;
        preset2["armLength"] = 4.7;
        preset2["bucketWidth"] = 3.1;
        m_excavatorPresets.append(preset2);

        // Default preset 3: Kazar III
        QVariantMap preset3;
        preset3["name"] = "Kazar III";
        preset3["scanningDepth"] = 9.5;
        preset3["boomLength"] = 10.5;
        preset3["armLength"] = 4.7;
        preset3["bucketWidth"] = 3.1;
        m_excavatorPresets.append(preset3);

        // Default preset 4: Kazar IV
        QVariantMap preset4;
        preset4["name"] = "Kazar IV";
        preset4["scanningDepth"] = 8.0;
        preset4["boomLength"] = 6.0;
        preset4["armLength"] = 4.0;
        preset4["bucketWidth"] = 3.0;
        m_excavatorPresets.append(preset4);

        // Default preset 5: Kazar V
        QVariantMap preset5;
        preset5["name"] = "Kazar V";
        preset5["scanningDepth"] = 9.0;
        preset5["boomLength"] = 6.0;
        preset5["armLength"] = 4.0;
        preset5["bucketWidth"] = 3.0;
        m_excavatorPresets.append(preset5);

        // Default preset 6: Kazar VI
        QVariantMap preset6;
        preset6["name"] = "Kazar VI";
        preset6["scanningDepth"] = 14.0;
        preset6["boomLength"] = 8.5;
        preset6["armLength"] = 6.0;
        preset6["bucketWidth"] = 3.0;
        m_excavatorPresets.append(preset6);

        // Default preset 7: Kazar VII
        QVariantMap preset7;
        preset7["name"] = "Kazar VII";
        preset7["scanningDepth"] = 13.5;
        preset7["boomLength"] = 8.0;
        preset7["armLength"] = 5.0;
        preset7["bucketWidth"] = 3.0;
        m_excavatorPresets.append(preset7);

        // Default preset 8: Kazar VIII
        QVariantMap preset8;
        preset8["name"] = "Kazar VIII";
        preset8["scanningDepth"] = 14.0;
        preset8["boomLength"] = 8.5;
        preset8["armLength"] = 6.0;
        preset8["bucketWidth"] = 3.0;
        m_excavatorPresets.append(preset8);

        // Default preset 9: Kazar X
        QVariantMap preset9;
        preset9["name"] = "Kazar X";
        preset9["scanningDepth"] = 6.0;
        preset9["boomLength"] = 7.9;
        preset9["armLength"] = 5.1;
        preset9["bucketWidth"] = 3.0;
        m_excavatorPresets.append(preset9);

        qDebug() << "Initialized" << m_excavatorPresets.size() << "default excavator presets";
        emit excavatorPresetsChanged();
    }
}

void ConfigManager::loadExcavatorPreset(int index)
{
    if (index < 0 || index >= m_excavatorPresets.size()) {
        qWarning() << "Invalid excavator preset index:" << index;
        return;
    }

    QVariantMap preset = m_excavatorPresets[index].toMap();

    setExcavatorName(preset["name"].toString());
    setScanningDepth(preset["scanningDepth"].toDouble());
    setBoomLength(preset["boomLength"].toDouble());
    setArmLength(preset["armLength"].toDouble());
    setBucketWidth(preset["bucketWidth"].toDouble());

    qDebug() << "Loaded excavator preset:" << preset["name"].toString();
}

void ConfigManager::addExcavatorPreset(const QString &name, double scanningDepth,
                                       double boomLength, double armLength, double bucketWidth)
{
    QVariantMap preset;
    preset["name"] = name;
    preset["scanningDepth"] = scanningDepth;
    preset["boomLength"] = boomLength;
    preset["armLength"] = armLength;
    preset["bucketWidth"] = bucketWidth;

    m_excavatorPresets.append(preset);
    emit excavatorPresetsChanged();

    // Auto-save to JSON
    saveConfig();

    qDebug() << "Added new excavator preset:" << name;
}

void ConfigManager::removeExcavatorPreset(int index)
{
    if (index < 0 || index >= m_excavatorPresets.size()) {
        qWarning() << "Invalid excavator preset index:" << index;
        return;
    }

    QVariantMap preset = m_excavatorPresets[index].toMap();
    QString name = preset["name"].toString();

    m_excavatorPresets.removeAt(index);
    emit excavatorPresetsChanged();

    // Auto-save to JSON
    saveConfig();

    qDebug() << "Removed excavator preset:" << name;
}

void ConfigManager::saveCurrentAsPreset()
{
    // Check if current configuration is valid
    if (m_excavatorName.isEmpty() || m_boomLength <= 0 || m_armLength <= 0 || m_bucketWidth <= 0 || m_scanningDepth <= 0) {
        qWarning() << "Cannot save preset: Invalid excavator configuration";
        emit errorOccurred("Geçersiz ekskavatör ayarları. Tüm alanları doldurun.");
        return;
    }

    // Check if preset with same name already exists
    for (const auto &preset : m_excavatorPresets) {
        QVariantMap presetMap = preset.toMap();
        if (presetMap["name"].toString() == m_excavatorName) {
            qWarning() << "Preset with name already exists:" << m_excavatorName;
            emit errorOccurred("Bu isimde bir ekskavatör zaten kayıtlı.");
            return;
        }
    }

    addExcavatorPreset(m_excavatorName, m_scanningDepth, m_boomLength, m_armLength, m_bucketWidth);
    qDebug() << "Saved current excavator as preset:" << m_excavatorName;
}

double ConfigManager::getGridDepth(int row, int col) const
{
    int index = row * m_gridCols + col;
    if (index >= 0 && index < m_gridDepths.size()) {
        return m_gridDepths[index].toDouble();
    }
    return 0.0;
}

void ConfigManager::setGridDepth(int row, int col, double depth)
{
    int index = row * m_gridCols + col;
    if (index >= 0 && index < m_gridDepths.size()) {
        m_gridDepths[index] = depth;
        emit gridDepthsChanged();
    }
}

// Map setters
void ConfigManager::setMapCenterLatitude(double lat)
{
    if (m_mapCenterLatitude != lat) {
        m_mapCenterLatitude = lat;
        emit mapCenterLatitudeChanged();
    }
}

void ConfigManager::setMapCenterLongitude(double lon)
{
    if (m_mapCenterLongitude != lon) {
        m_mapCenterLongitude = lon;
        emit mapCenterLongitudeChanged();
    }
}

void ConfigManager::setMapZoomLevel(int zoom)
{
    if (m_mapZoomLevel != zoom) {
        m_mapZoomLevel = zoom;
        emit mapZoomLevelChanged();
    }
}

void ConfigManager::setMapAreaWidth(double width)
{
    if (m_mapAreaWidth != width) {
        m_mapAreaWidth = width;
        emit mapAreaWidthChanged();
    }
}

void ConfigManager::setMapAreaHeight(double height)
{
    if (m_mapAreaHeight != height) {
        m_mapAreaHeight = height;
        emit mapAreaHeightChanged();
    }
}

// Alarm setters
void ConfigManager::setAlarmColorCritical(const QString &color)
{
    if (m_alarmColorCritical != color) {
        m_alarmColorCritical = color;
        emit alarmColorCriticalChanged();
    }
}

void ConfigManager::setAlarmColorWarning(const QString &color)
{
    if (m_alarmColorWarning != color) {
        m_alarmColorWarning = color;
        emit alarmColorWarningChanged();
    }
}

void ConfigManager::setAlarmColorInfo(const QString &color)
{
    if (m_alarmColorInfo != color) {
        m_alarmColorInfo = color;
        emit alarmColorInfoChanged();
    }
}

void ConfigManager::setAlarmColorSuccess(const QString &color)
{
    if (m_alarmColorSuccess != color) {
        m_alarmColorSuccess = color;
        emit alarmColorSuccessChanged();
    }
}

// Mark configuration sections as complete
void ConfigManager::markExcavatorConfigured()
{
    if (!m_excavatorConfigured) {
        m_excavatorConfigured = true;
        emit excavatorConfiguredChanged();
        emit isConfiguredChanged();
    }
}

void ConfigManager::markDigAreaConfigured()
{
    if (!m_digAreaConfigured) {
        m_digAreaConfigured = true;
        emit digAreaConfiguredChanged();
        emit isConfiguredChanged();
    }
}

void ConfigManager::markMapConfigured()
{
    if (!m_mapConfigured) {
        m_mapConfigured = true;
        emit mapConfiguredChanged();
        emit isConfiguredChanged();
    }
}

void ConfigManager::markAlarmConfigured()
{
    if (!m_alarmConfigured) {
        m_alarmConfigured = true;
        emit alarmConfiguredChanged();
        emit isConfiguredChanged();
    }
}

void ConfigManager::resetConfiguration()
{
    m_excavatorConfigured = false;
    m_digAreaConfigured = false;
    m_mapConfigured = false;
    m_alarmConfigured = false;

    emit excavatorConfiguredChanged();
    emit digAreaConfiguredChanged();
    emit mapConfiguredChanged();
    emit alarmConfiguredChanged();
    emit isConfiguredChanged();
}

// Parse new settings sections
void ConfigManager::parseExcavatorSettings(const QJsonObject &excavator)
{
    if (excavator.contains("name")) {
        setExcavatorName(excavator["name"].toString());
    }
    if (excavator.contains("boom_length")) {
        setBoomLength(excavator["boom_length"].toDouble(12.0));
    }
    if (excavator.contains("arm_length")) {
        setArmLength(excavator["arm_length"].toDouble(10.0));
    }
    if (excavator.contains("bucket_width")) {
        setBucketWidth(excavator["bucket_width"].toDouble(2.0));
    }
    if (excavator.contains("scanning_depth")) {
        setScanningDepth(excavator["scanning_depth"].toDouble(15.0));
    }
    if (excavator.contains("configured")) {
        m_excavatorConfigured = excavator["configured"].toBool(false);
        emit excavatorConfiguredChanged();
    }
}

void ConfigManager::parseDigAreaSettings(const QJsonObject &digArea)
{
    if (digArea.contains("grid_rows")) {
        m_gridRows = digArea["grid_rows"].toInt(4);
        emit gridRowsChanged();
    }
    if (digArea.contains("grid_cols")) {
        m_gridCols = digArea["grid_cols"].toInt(4);
        emit gridColsChanged();
    }
    if (digArea.contains("grid_depths") && digArea["grid_depths"].isArray()) {
        m_gridDepths.clear();
        QJsonArray arr = digArea["grid_depths"].toArray();
        for (const auto &val : arr) {
            m_gridDepths.append(val.toDouble(0.0));
        }
        emit gridDepthsChanged();
        emit calculatedMaxDepthChanged();
    } else {
        initializeGridDepths();
    }
    if (digArea.contains("target_depth")) {
        setTargetDepth(digArea["target_depth"].toDouble(15.0));
    }
    // Grid coordinate bounds
    if (digArea.contains("start_latitude")) {
        setGridStartLatitude(digArea["start_latitude"].toDouble(40.7100));
    }
    if (digArea.contains("start_longitude")) {
        setGridStartLongitude(digArea["start_longitude"].toDouble(29.0000));
    }
    if (digArea.contains("end_latitude")) {
        setGridEndLatitude(digArea["end_latitude"].toDouble(40.7200));
    }
    if (digArea.contains("end_longitude")) {
        setGridEndLongitude(digArea["end_longitude"].toDouble(29.0100));
    }
    if (digArea.contains("configured")) {
        m_digAreaConfigured = digArea["configured"].toBool(false);
        emit digAreaConfiguredChanged();
    }
}

void ConfigManager::parseMapSettings(const QJsonObject &mapSettings)
{
    if (mapSettings.contains("center_latitude")) {
        setMapCenterLatitude(mapSettings["center_latitude"].toDouble(40.7128));
    }
    if (mapSettings.contains("center_longitude")) {
        setMapCenterLongitude(mapSettings["center_longitude"].toDouble(29.0060));
    }
    if (mapSettings.contains("zoom_level")) {
        setMapZoomLevel(mapSettings["zoom_level"].toInt(15));
    }
    if (mapSettings.contains("area_width")) {
        setMapAreaWidth(mapSettings["area_width"].toDouble(500.0));
    }
    if (mapSettings.contains("area_height")) {
        setMapAreaHeight(mapSettings["area_height"].toDouble(500.0));
    }
    if (mapSettings.contains("configured")) {
        m_mapConfigured = mapSettings["configured"].toBool(false);
        emit mapConfiguredChanged();
    }
}

void ConfigManager::parseAlarmSettings(const QJsonObject &alarmSettings)
{
    if (alarmSettings.contains("color_critical")) {
        setAlarmColorCritical(alarmSettings["color_critical"].toString("#FF4444"));
    }
    if (alarmSettings.contains("color_warning")) {
        setAlarmColorWarning(alarmSettings["color_warning"].toString("#FFA500"));
    }
    if (alarmSettings.contains("color_info")) {
        setAlarmColorInfo(alarmSettings["color_info"].toString("#2196F3"));
    }
    if (alarmSettings.contains("color_success")) {
        setAlarmColorSuccess(alarmSettings["color_success"].toString("#4CAF50"));
    }
    if (alarmSettings.contains("configured")) {
        m_alarmConfigured = alarmSettings["configured"].toBool(false);
        emit alarmConfiguredChanged();
    }
}

void ConfigManager::parseScreenSaverSettings(const QJsonObject &screenSaverSettings)
{
    if (screenSaverSettings.contains("enabled")) {
        setScreenSaverEnabled(screenSaverSettings["enabled"].toBool(true));
    }
    if (screenSaverSettings.contains("timeout_seconds")) {
        setScreenSaverTimeoutSeconds(screenSaverSettings["timeout_seconds"].toInt(120));
    }
}

void ConfigManager::parseExcavatorPresets(const QJsonArray &presets)
{
    m_excavatorPresets.clear();

    for (const auto &presetValue : presets) {
        if (!presetValue.isObject()) continue;

        QJsonObject presetObj = presetValue.toObject();
        QVariantMap preset;

        preset["name"] = presetObj["name"].toString("");
        preset["scanningDepth"] = presetObj["scanning_depth"].toDouble(15.0);
        preset["boomLength"] = presetObj["boom_length"].toDouble(12.0);
        preset["armLength"] = presetObj["arm_length"].toDouble(10.0);
        preset["bucketWidth"] = presetObj["bucket_width"].toDouble(3.0);

        // Only add if name is not empty
        if (!preset["name"].toString().isEmpty()) {
            m_excavatorPresets.append(preset);
        }
    }

    qDebug() << "Loaded" << m_excavatorPresets.size() << "excavator presets from JSON";
    emit excavatorPresetsChanged();
}

// Screen Saver setters
void ConfigManager::setScreenSaverEnabled(bool enabled)
{
    if (m_screenSaverEnabled != enabled) {
        m_screenSaverEnabled = enabled;
        emit screenSaverEnabledChanged();
        saveConfig();  // Ayar değiştiğinde kaydet
    }
}

void ConfigManager::setScreenSaverTimeoutSeconds(int seconds)
{
    // Min: 10 saniye, Max: 1800 saniye (30 dakika)
    int clampedSeconds = qBound(10, seconds, 1800);
    if (m_screenSaverTimeoutSeconds != clampedSeconds) {
        m_screenSaverTimeoutSeconds = clampedSeconds;
        emit screenSaverTimeoutSecondsChanged();
        saveConfig();  // Ayar değiştiğinde kaydet
    }
}

bool ConfigManager::saveConfig()
{
    QJsonObject root;

    // Bathymetry settings
    QJsonObject bathymetry;
    bathymetry["vrt_path"] = m_vrtPath;
    bathymetry["tile_size"] = m_tileSize;
    bathymetry["cache_size"] = m_cacheSize;
    bathymetry["default_lod"] = m_defaultLOD;

    // Color scheme
    QJsonObject colorScheme;
    colorScheme["shallow"] = m_colorShallow.name();
    colorScheme["shallow_mid"] = m_colorShallowMid.name();
    colorScheme["mid"] = m_colorMid.name();
    colorScheme["mid_deep"] = m_colorMidDeep.name();
    colorScheme["deep"] = m_colorDeep.name();
    bathymetry["color_scheme"] = colorScheme;

    // Depth ranges
    QJsonObject depthRanges;
    depthRanges["shallow"] = QJsonArray{m_rangeShallow[0], m_rangeShallow[1]};
    depthRanges["shallow_mid"] = QJsonArray{m_rangeShallowMid[0], m_rangeShallowMid[1]};
    depthRanges["mid"] = QJsonArray{m_rangeMid[0], m_rangeMid[1]};
    depthRanges["mid_deep"] = QJsonArray{m_rangeMidDeep[0], m_rangeMidDeep[1]};
    depthRanges["deep"] = QJsonArray{m_rangeDeep[0], m_rangeDeep[1]};
    bathymetry["depth_ranges"] = depthRanges;

    root["bathymetry"] = bathymetry;

    // Rendering settings
    QJsonObject rendering;
    rendering["vertical_exaggeration"] = m_verticalExaggeration;
    rendering["grid_visible"] = m_gridVisible;
    rendering["legend_visible"] = m_legendVisible;
    root["rendering"] = rendering;

    // Excavator settings
    QJsonObject excavator;
    excavator["name"] = m_excavatorName;
    excavator["boom_length"] = m_boomLength;
    excavator["arm_length"] = m_armLength;
    excavator["bucket_width"] = m_bucketWidth;
    excavator["scanning_depth"] = m_scanningDepth;
    excavator["configured"] = m_excavatorConfigured;
    root["excavator"] = excavator;

    // Dig area settings
    QJsonObject digArea;
    digArea["grid_rows"] = m_gridRows;
    digArea["grid_cols"] = m_gridCols;
    QJsonArray depthsArray;
    for (const auto &depth : m_gridDepths) {
        depthsArray.append(depth.toDouble());
    }
    digArea["grid_depths"] = depthsArray;
    digArea["target_depth"] = m_targetDepth;
    digArea["start_latitude"] = m_gridStartLatitude;
    digArea["start_longitude"] = m_gridStartLongitude;
    digArea["end_latitude"] = m_gridEndLatitude;
    digArea["end_longitude"] = m_gridEndLongitude;
    digArea["configured"] = m_digAreaConfigured;
    root["dig_area"] = digArea;

    // Map settings
    QJsonObject mapObj;
    mapObj["center_latitude"] = m_mapCenterLatitude;
    mapObj["center_longitude"] = m_mapCenterLongitude;
    mapObj["zoom_level"] = m_mapZoomLevel;
    mapObj["area_width"] = m_mapAreaWidth;
    mapObj["area_height"] = m_mapAreaHeight;
    mapObj["configured"] = m_mapConfigured;
    root["map"] = mapObj;

    // Alarm settings
    QJsonObject alarm;
    alarm["color_critical"] = m_alarmColorCritical;
    alarm["color_warning"] = m_alarmColorWarning;
    alarm["color_info"] = m_alarmColorInfo;
    alarm["color_success"] = m_alarmColorSuccess;
    alarm["configured"] = m_alarmConfigured;
    root["alarm"] = alarm;

    // Screen Saver settings
    QJsonObject screenSaver;
    screenSaver["enabled"] = m_screenSaverEnabled;
    screenSaver["timeout_seconds"] = m_screenSaverTimeoutSeconds;
    root["screen_saver"] = screenSaver;

    // Excavator presets
    QJsonArray presetsArray;
    for (const auto &preset : m_excavatorPresets) {
        QVariantMap presetMap = preset.toMap();
        QJsonObject presetObj;
        presetObj["name"] = presetMap["name"].toString();
        presetObj["scanning_depth"] = presetMap["scanningDepth"].toDouble();
        presetObj["boom_length"] = presetMap["boomLength"].toDouble();
        presetObj["arm_length"] = presetMap["armLength"].toDouble();
        presetObj["bucket_width"] = presetMap["bucketWidth"].toDouble();
        presetsArray.append(presetObj);
    }
    root["excavator_presets"] = presetsArray;

    // Write to file
    QJsonDocument doc(root);
    QFile file(m_configPath);

    // Ensure directory exists
    QDir dir = QFileInfo(m_configPath).absoluteDir();
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    if (!file.open(QIODevice::WriteOnly)) {
        QString error = "Cannot write config file: " + file.errorString();
        qWarning() << error;
        emit errorOccurred(error);
        return false;
    }

    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();

    qDebug() << "Configuration saved to" << m_configPath;
    return true;
}
