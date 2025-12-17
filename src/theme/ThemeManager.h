#ifndef THEMEMANAGER_H
#define THEMEMANAGER_H

#include <QObject>
#include <QColor>
#include <QSettings>

/**
 * ThemeManager - Application theme management
 *
 * Provides dark and light theme support with runtime switching.
 * All color values are exposed as Q_PROPERTY for QML access.
 *
 * Usage from QML:
 *   Rectangle { color: themeManager.backgroundColor }
 *   themeManager.toggleTheme()
 */
class ThemeManager : public QObject
{
    Q_OBJECT

    // Theme mode
    Q_PROPERTY(bool isDarkTheme READ isDarkTheme NOTIFY themeChanged)
    Q_PROPERTY(QString themeName READ themeName NOTIFY themeChanged)

    // Background colors
    Q_PROPERTY(QColor backgroundColor READ backgroundColor NOTIFY themeChanged)
    Q_PROPERTY(QColor backgroundColorLight READ backgroundColorLight NOTIFY themeChanged)
    Q_PROPERTY(QColor backgroundColorDark READ backgroundColorDark NOTIFY themeChanged)

    // Text colors
    Q_PROPERTY(QColor textColor READ textColor NOTIFY themeChanged)
    Q_PROPERTY(QColor textColorSecondary READ textColorSecondary NOTIFY themeChanged)
    Q_PROPERTY(QColor textColorDisabled READ textColorDisabled NOTIFY themeChanged)

    // UI element colors
    Q_PROPERTY(QColor primaryColor READ primaryColor NOTIFY themeChanged)
    Q_PROPERTY(QColor secondaryColor READ secondaryColor NOTIFY themeChanged)
    Q_PROPERTY(QColor accentColor READ accentColor NOTIFY themeChanged)
    Q_PROPERTY(QColor borderColor READ borderColor NOTIFY themeChanged)
    Q_PROPERTY(QColor hoverColor READ hoverColor NOTIFY themeChanged)
    Q_PROPERTY(QColor selectedColor READ selectedColor NOTIFY themeChanged)

    // Status colors (same for both themes)
    Q_PROPERTY(QColor successColor READ successColor CONSTANT)
    Q_PROPERTY(QColor warningColor READ warningColor CONSTANT)
    Q_PROPERTY(QColor errorColor READ errorColor CONSTANT)
    Q_PROPERTY(QColor infoColor READ infoColor CONSTANT)

public:
    explicit ThemeManager(QObject *parent = nullptr);
    ~ThemeManager();

    // Theme mode
    bool isDarkTheme() const { return m_isDarkTheme; }
    QString themeName() const { return m_isDarkTheme ? "dark" : "light"; }

    // Background colors
    QColor backgroundColor() const { return m_backgroundColor; }
    QColor backgroundColorLight() const { return m_backgroundColorLight; }
    QColor backgroundColorDark() const { return m_backgroundColorDark; }

    // Text colors
    QColor textColor() const { return m_textColor; }
    QColor textColorSecondary() const { return m_textColorSecondary; }
    QColor textColorDisabled() const { return m_textColorDisabled; }

    // UI element colors
    QColor primaryColor() const { return m_primaryColor; }
    QColor secondaryColor() const { return m_secondaryColor; }
    QColor accentColor() const { return m_accentColor; }
    QColor borderColor() const { return m_borderColor; }
    QColor hoverColor() const { return m_hoverColor; }
    QColor selectedColor() const { return m_selectedColor; }

    // Status colors
    QColor successColor() const { return QColor("#4CAF50"); }
    QColor warningColor() const { return QColor("#ff9800"); }
    QColor errorColor() const { return QColor("#f44336"); }
    QColor infoColor() const { return QColor("#00bcd4"); }

    // Methods
    Q_INVOKABLE void toggleTheme();
    Q_INVOKABLE void setDarkTheme(bool dark);
    Q_INVOKABLE void saveThemePreference();
    Q_INVOKABLE void loadThemePreference();

signals:
    void themeChanged();

private:
    void updateColors();

    bool m_isDarkTheme;
    QSettings m_settings;

    // Color properties
    QColor m_backgroundColor;
    QColor m_backgroundColorLight;
    QColor m_backgroundColorDark;
    QColor m_textColor;
    QColor m_textColorSecondary;
    QColor m_textColorDisabled;
    QColor m_primaryColor;
    QColor m_secondaryColor;
    QColor m_accentColor;
    QColor m_borderColor;
    QColor m_hoverColor;
    QColor m_selectedColor;
};

#endif // THEMEMANAGER_H
