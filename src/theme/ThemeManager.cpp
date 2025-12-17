#include "ThemeManager.h"
#include <QDebug>

ThemeManager::ThemeManager(QObject *parent)
    : QObject(parent)
    , m_isDarkTheme(true)  // Default: Dark theme
    , m_settings("ExcavatorUI", "Settings")
{
    qDebug() << "ThemeManager initialized";

    // Load saved theme preference
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
        // Light theme colors
        m_backgroundColor = QColor("#f5f5f5");
        m_backgroundColorLight = QColor("#ffffff");
        m_backgroundColorDark = QColor("#e0e0e0");

        m_textColor = QColor("#212121");
        m_textColorSecondary = QColor("#757575");
        m_textColorDisabled = QColor("#bdbdbd");

        m_primaryColor = QColor("#0097a7");
        m_secondaryColor = QColor("#546e7a");
        m_accentColor = QColor("#ff5722");
        m_borderColor = QColor("#e0e0e0");
        m_hoverColor = QColor("#f0f0f0");
        m_selectedColor = QColor("#0097a7");
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
