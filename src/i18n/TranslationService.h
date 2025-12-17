#ifndef TRANSLATIONSERVICE_H
#define TRANSLATIONSERVICE_H

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QSettings>

/**
 * TranslationService - Simple JSON-based translation service
 *
 * NO Qt Linguist Tools required! Uses simple JSON files.
 * Supports Turkish (tr_TR) and English (en_US).
 *
 * JSON files location: translations/tr_TR.json, translations/en_US.json
 *
 * Usage from QML:
 *   Text { text: translationService.tr("menu.excavator") }
 *   Text { text: translationService.tr("app.title") }
 */
class TranslationService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentLanguage READ currentLanguage WRITE setCurrentLanguage NOTIFY currentLanguageChanged)
    Q_PROPERTY(QStringList availableLanguages READ availableLanguages CONSTANT)

public:
    explicit TranslationService(QObject *parent = nullptr);
    ~TranslationService();

    QString currentLanguage() const { return m_currentLanguage; }
    void setCurrentLanguage(const QString &language);

    QStringList availableLanguages() const;

    // Main translation method - use this in QML
    Q_INVOKABLE QString tr(const QString &key, const QString &defaultValue = QString()) const;

    Q_INVOKABLE void switchLanguage(const QString &language);
    Q_INVOKABLE QString getLanguageName(const QString &languageCode) const;
    Q_INVOKABLE void saveLanguagePreference();
    Q_INVOKABLE void loadLanguagePreference();

signals:
    void currentLanguageChanged();
    void languageChanged();

private:
    bool loadTranslations(const QString &language);
    QVariant getNestedValue(const QVariantMap &map, const QString &key) const;

    QString m_currentLanguage;
    QVariantMap m_translations;
    QSettings m_settings;
};

#endif // TRANSLATIONSERVICE_H
