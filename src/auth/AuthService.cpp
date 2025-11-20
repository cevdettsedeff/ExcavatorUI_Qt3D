#include "AuthService.h"
#include "../database/DatabaseManager.h"
#include <QDebug>

AuthService::AuthService(QObject *parent)
    : QObject(parent)
    , m_isAuthenticated(false)
{
}

bool AuthService::login(const QString& username, const QString& password)
{
    qDebug() << "Login attempt for user:" << username;

    if (username.isEmpty() || password.isEmpty()) {
        qWarning() << "Kullanıcı adı veya şifre boş";
        emit loginFailed("Kullanıcı adı ve şifre boş olamaz");
        return false;
    }

    DatabaseManager& db = DatabaseManager::instance();
    if (!db.isInitialized()) {
        qCritical() << "Veritabanı başlatılmamış";
        emit loginFailed("Veritabanı hatası");
        return false;
    }

    if (db.validateUser(username, password)) {
        m_isAuthenticated = true;
        m_currentUser = username;
        emit authenticationChanged();
        emit loginSucceeded();
        qDebug() << "Login başarılı:" << username;
        return true;
    }

    qWarning() << "Login başarısız:" << username;
    emit loginFailed("Kullanıcı adı veya şifre hatalı");
    return false;
}

void AuthService::logout()
{
    if (m_isAuthenticated) {
        qDebug() << "Logout:" << m_currentUser;
        m_isAuthenticated = false;
        m_currentUser.clear();
        emit authenticationChanged();
        emit loggedOut();
    }
}

bool AuthService::registerUser(const QString& username, const QString& password)
{
    qDebug() << "Kullanıcı kayıt denemesi:" << username;

    if (username.isEmpty() || password.isEmpty()) {
        qWarning() << "Kullanıcı adı veya şifre boş";
        return false;
    }

    if (password.length() < 4) {
        qWarning() << "Şifre çok kısa";
        return false;
    }

    DatabaseManager& db = DatabaseManager::instance();
    if (!db.isInitialized()) {
        qCritical() << "Veritabanı başlatılmamış";
        return false;
    }

    return db.createUser(username, password);
}
