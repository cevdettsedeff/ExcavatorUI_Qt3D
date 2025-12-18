#include "TranslationService.h"
#include <QDebug>
#include <QDir>

TranslationService::TranslationService(QGuiApplication *app, QQmlEngine *engine, QObject *parent)
    : QObject(parent)
    , m_app(app)
    , m_engine(engine)
    , m_translator(new QTranslator(this))
    , m_currentLanguage("tr_TR")  // Default: Turkish
    , m_settings("ExcavatorUI", "Settings")
{
    qDebug() << "TranslationService initialized (Qt Linguist based)";

    // Load Turkish by default first
    loadTranslation("tr_TR");

    // Then load saved preference if exists
    loadLanguagePreference();
}

TranslationService::~TranslationService()
{
    if (m_translator) {
        m_app->removeTranslator(m_translator);
    }
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

    // Remove old translator
    if (m_translator) {
        m_app->removeTranslator(m_translator);
    }

    // Load new translation
    if (loadTranslation(language)) {
        m_currentLanguage = language;
        emit currentLanguageChanged();
        emit languageChanged();

        // Save preference
        saveLanguagePreference();

        // Retranslate QML UI
        if (m_engine) {
            m_engine->retranslate();
        }

        qDebug() << "Language switched successfully to:" << language;
    } else {
        qWarning() << "Failed to load translation for:" << language;
    }
}

bool TranslationService::loadTranslation(const QString &language)
{
    QString translationFile = QString("excavator_%1").arg(language);

    // Try multiple paths
    QStringList searchPaths = {
        ":/i18n",                           // Qt resource system
        "translations",                     // Relative to working dir
        "../translations",                  // Parent directory
        QDir::currentPath() + "/translations",
        QDir::currentPath() + "/../translations"
    };

    for (const QString &path : searchPaths) {
        qDebug() << "Trying to load translation from:" << path << "/" << translationFile;

        if (m_translator->load(translationFile, path)) {
            m_app->installTranslator(m_translator);
            qDebug() << "✓ Translation loaded successfully from:" << path;
            return true;
        }
    }

    qWarning() << "✗ Translation file not found:" << translationFile;
    qDebug() << "  Make sure .qm files are compiled and in one of the search paths";
    return false;
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
