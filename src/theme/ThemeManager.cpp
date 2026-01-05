#include "ThemeManager.h"
#include <QDebug>

ThemeManager::ThemeManager(QObject *parent)
    : QObject(parent)
    , m_isDarkTheme(true)  // Default: Dark theme
    , m_settings("ExcavatorUI", "Settings")
{
    qDebug() << "ThemeManager initialized";

    // Initialize with dark theme colors first
    updateColors();

    // Then load saved preference if exists
    loadThemePreference();
}

ThemeManager::~ThemeManager()
{
}

void ThemeManager::toggleTheme()
{
    setDarkTheme(!m_isDarkTheme);
}

void ThemeManager::setDarkTheme(bool dark)
{
    if (m_isDarkTheme != dark) {
        m_isDarkTheme = dark;
        updateColors();
        saveThemePreference();
        emit themeChanged();

        qDebug() << "Theme changed to:" << (dark ? "Dark" : "Light");
    }
}

void ThemeManager::updateColors()
{
    if (m_isDarkTheme) {
        // Dark theme colors - soft grayish tones (not pure black)
        m_backgroundColor = QColor("#2d3748");        // Slate gray background
        m_backgroundColorLight = QColor("#4a5568");   // Medium slate gray
        m_backgroundColorDark = QColor("#1a202c");    // Dark slate gray
        m_surfaceColor = QColor("#3d4a5c");           // Card/tile background (lighter than bg)

        m_textColor = QColor("#e2e8f0");              // Light gray (not pure white)
        m_textColorSecondary = QColor("#a0aec0");     // Medium gray
        m_textColorDisabled = QColor("#718096");      // Muted gray

        m_primaryColor = QColor("#38b2ac");           // Teal
        m_secondaryColor = QColor("#4a5568");         // Slate accent
        m_accentColor = QColor("#ed8936");            // Soft orange
        m_borderColor = QColor("#4a5568");            // Medium slate border
        m_hoverColor = QColor("#3d4a5c");             // Subtle hover
        m_selectedColor = QColor("#38b2ac");          // Same as primary

    } else {
        // Light theme colors - clean white tones
        m_backgroundColor = QColor("#f7fafc");        // Almost white
        m_backgroundColorLight = QColor("#ffffff");   // Pure white
        m_backgroundColorDark = QColor("#edf2f7");    // Very light gray
        m_surfaceColor = QColor("#ffffff");           // Card/tile background (pure white)

        m_textColor = QColor("#2d3748");              // Dark gray (not pure black)
        m_textColorSecondary = QColor("#718096");     // Medium gray
        m_textColorDisabled = QColor("#a0aec0");      // Light gray

        m_primaryColor = QColor("#319795");           // Teal
        m_secondaryColor = QColor("#4a5568");         // Slate accent
        m_accentColor = QColor("#dd6b20");            // Orange accent
        m_borderColor = QColor("#e2e8f0");            // Light gray border
        m_hoverColor = QColor("#edf2f7");             // Subtle hover
        m_selectedColor = QColor("#319795");          // Same as primary
    }
}

void ThemeManager::saveThemePreference()
{
    m_settings.setValue("theme", m_isDarkTheme ? "dark" : "light");
    m_settings.sync();
    qDebug() << "Theme preference saved:" << (m_isDarkTheme ? "dark" : "light");
}

void ThemeManager::loadThemePreference()
{
    QString savedTheme = m_settings.value("theme", "dark").toString();
    bool isDark = (savedTheme == "dark");

    qDebug() << "Loading saved theme preference:" << savedTheme;

    m_isDarkTheme = isDark;
    updateColors();
    emit themeChanged();
}
