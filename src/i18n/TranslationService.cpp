#include "TranslationService.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>
#include <QDir>

TranslationService::TranslationService(QObject *parent)
    : QObject(parent)
    , m_currentLanguage("tr_TR")  // Default: Turkish
    , m_settings("ExcavatorUI", "Settings")
{
    qDebug() << "TranslationService initialized (JSON-based - no Qt Linguist needed!)";

    // Load saved language preference
    loadLanguagePreference();
}

TranslationService::~TranslationService()
{
}

QStringList TranslationService::availableLanguages() const
{
    return QStringList() << "tr_TR" << "en_US";
}

void TranslationService::setCurrentLanguage(const QString &language)
{
    if (m_currentLanguage != language && availableLanguages().contains(language)) {
        switchLanguage(language);
    }
}

void TranslationService::switchLanguage(const QString &language)
{
    if (!availableLanguages().contains(language)) {
        qWarning() << "Unsupported language:" << language;
        return;
    }

    if (m_currentLanguage == language) {
        qDebug() << "Language already set to:" << language;
        return;
    }

    qDebug() << "Switching language from" << m_currentLanguage << "to" << language;

    // Load new translations
    if (loadTranslations(language)) {
        m_currentLanguage = language;
        emit currentLanguageChanged();
        emit languageChanged();

        // Save preference
        saveLanguagePreference();

        qDebug() << "Language switched successfully to:" << language;
    } else {
        qWarning() << "Failed to load translations for:" << language;
    }
}

bool TranslationService::loadTranslations(const QString &language)
{
    QString filename = language + ".json";

    // Try multiple paths
    QStringList searchPaths = {
        ":/translations/" + filename,           // Qt resource system
        "translations/" + filename,             // Relative to working dir
        "../translations/" + filename,          // Parent directory
        "../../translations/" + filename,       // Two levels up
        QDir::currentPath() + "/translations/" + filename,
        QDir::currentPath() + "/../translations/" + filename
    };

    for (const QString &path : searchPaths) {
        QFile file(path);

        qDebug() << "Trying to load translation from:" << path;

        if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QByteArray data = file.readAll();
            file.close();

            QJsonParseError error;
            QJsonDocument doc = QJsonDocument::fromJson(data, &error);

            if (error.error != QJsonParseError::NoError) {
                qWarning() << "JSON parse error:" << error.errorString();
                continue;
            }

            if (!doc.isObject()) {
                qWarning() << "Invalid JSON format - expected object";
                continue;
            }

            m_translations = doc.object().toVariantMap();
            qDebug() << "✓ Translations loaded from:" << path;
            qDebug() << "  Translation keys:" << m_translations.keys();
            return true;
        }
    }

    qWarning() << "✗ Translation file not found:" << filename;
    return false;
}

QString TranslationService::tr(const QString &key, const QString &defaultValue) const
{
    if (m_translations.isEmpty()) {
        qDebug() << "No translations loaded, returning key:" << key;
        return defaultValue.isEmpty() ? key : defaultValue;
    }

    QVariant value = getNestedValue(m_translations, key);

    if (value.isValid() && value.canConvert<QString>()) {
        return value.toString();
    }

    qDebug() << "Translation not found for key:" << key;
    return defaultValue.isEmpty() ? key : defaultValue;
}

QVariant TranslationService::getNestedValue(const QVariantMap &map, const QString &key) const
{
    QStringList parts = key.split('.');

    if (parts.isEmpty()) {
        return QVariant();
    }

    QVariant current = map;

    for (const QString &part : parts) {
        if (!current.canConvert<QVariantMap>()) {
            return QVariant();
        }

        QVariantMap currentMap = current.toMap();
        if (!currentMap.contains(part)) {
            return QVariant();
        }

        current = currentMap.value(part);
    }

    return current;
}

QString TranslationService::getLanguageName(const QString &languageCode) const
{
    if (languageCode == "tr_TR") {
        return "Türkçe";
    } else if (languageCode == "en_US") {
        return "English";
    }
    return languageCode;
}

void TranslationService::saveLanguagePreference()
{
    m_settings.setValue("language", m_currentLanguage);
    m_settings.sync();
    qDebug() << "Language preference saved:" << m_currentLanguage;
}

void TranslationService::loadLanguagePreference()
{
    QString savedLanguage = m_settings.value("language", "tr_TR").toString();

    if (availableLanguages().contains(savedLanguage)) {
        qDebug() << "Loading saved language preference:" << savedLanguage;
        switchLanguage(savedLanguage);
    } else {
        qDebug() << "No valid language preference found, using default: tr_TR";
        switchLanguage("tr_TR");
    }
}
