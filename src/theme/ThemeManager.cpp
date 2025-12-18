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
        // Dark theme colors
        m_backgroundColor = QColor("#1a1a1a");
        m_backgroundColorLight = QColor("#2a2a2a");
        m_backgroundColorDark = QColor("#0d0d0d");

        m_textColor = QColor("#ffffff");
        m_textColorSecondary = QColor("#888888");
        m_textColorDisabled = QColor("#555555");

        m_primaryColor = QColor("#00bcd4");
        m_secondaryColor = QColor("#34495e");
        m_accentColor = QColor("#FF6B35");
        m_borderColor = QColor("#404040");
        m_hoverColor = QColor("#333333");
        m_selectedColor = QColor("#00bcd4");

    } else {
        // Light theme colors - optimized for better contrast
        m_backgroundColor = QColor("#e8eaf6");        // Soft blue-grey background
        m_backgroundColorLight = QColor("#f5f7fa");   // Very light blue-grey
        m_backgroundColorDark = QColor("#c5cae9");    // Medium blue-grey

        m_textColor = QColor("#1a237e");              // Deep indigo for text
        m_textColorSecondary = QColor("#5c6bc0");     // Medium indigo
        m_textColorDisabled = QColor("#9fa8da");      // Light indigo

        m_primaryColor = QColor("#0097a7");           // Cyan
        m_secondaryColor = QColor("#7986cb");         // Indigo accent
        m_accentColor = QColor("#ff6f00");            // Orange accent
        m_borderColor = QColor("#c5cae9");            // Light border
        m_hoverColor = QColor("#d1d9ff");             // Hover effect
        m_selectedColor = QColor("#0097a7");          // Same as primary
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
