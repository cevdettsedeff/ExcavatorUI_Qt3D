#ifndef TRANSLATIONSERVICE_H
#define TRANSLATIONSERVICE_H

#include <QObject>
#include <QTranslator>
#include <QGuiApplication>
#include <QQmlEngine>
#include <QSettings>

/**
 * TranslationService - Multi-language support service
 *
 * Provides runtime language switching for the application.
 * Supports Turkish (tr_TR) and English (en_US).
 *
 * Usage from QML:
 *   translationService.currentLanguage = "tr_TR"
 *   translationService.switchLanguage("en_US")
 */
class TranslationService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentLanguage READ currentLanguage WRITE setCurrentLanguage NOTIFY currentLanguageChanged)
    Q_PROPERTY(QStringList availableLanguages READ availableLanguages CONSTANT)

public:
    explicit TranslationService(QGuiApplication *app, QQmlEngine *engine, QObject *parent = nullptr);
    ~TranslationService();

    QString currentLanguage() const { return m_currentLanguage; }
    void setCurrentLanguage(const QString &language);

    QStringList availableLanguages() const;

    Q_INVOKABLE void switchLanguage(const QString &language);
    Q_INVOKABLE QString getLanguageName(const QString &languageCode) const;
    Q_INVOKABLE void saveLanguagePreference();
    Q_INVOKABLE void loadLanguagePreference();

signals:
    void currentLanguageChanged();
    void languageChanged();

private:
    bool loadTranslation(const QString &language);

    QGuiApplication *m_app;
    QQmlEngine *m_engine;
    QTranslator *m_translator;
    QString m_currentLanguage;
    QSettings m_settings;
};

#endif // TRANSLATIONSERVICE_H
