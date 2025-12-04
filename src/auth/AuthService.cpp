#include "AuthService.h"
#include "../database/DatabaseManager.h"
#include <QDebug>

AuthService::AuthService(QObject *parent)
    : QObject(parent)
    , m_isAuthenticated(false)
    , m_isAdmin(false)
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
        m_isAdmin = db.isUserAdmin(username);
        emit authenticationChanged();
        emit loginSucceeded();
        qDebug() << "Login başarılı:" << username << "(Admin:" << m_isAdmin << ")";
        return true;
    }

    // Onay bekliyor mu kontrol et
    if (db.userExists(username) && !db.isUserApproved(username)) {
        qWarning() << "Login başarısız - onay bekliyor:" << username;
        emit loginFailed("Hesabınız henüz onaylanmadı. Lütfen admin onayını bekleyin.");
        return false;
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
        m_isAdmin = false;
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

    // Kullanıcı adı kontrolü
    if (username.length() < 3) {
        qWarning() << "Kullanıcı adı çok kısa";
        return false;
    }

    // Şifre uzunluk kontrolü (minimum 6 karakter)
    if (password.length() < 6) {
        qWarning() << "Şifre çok kısa (minimum 6 karakter)";
        return false;
    }

    DatabaseManager& db = DatabaseManager::instance();
    if (!db.isInitialized()) {
        qCritical() << "Veritabanı başlatılmamış";
        return false;
    }

    // Normal kayıt - onay bekleyecek (approved = false)
    return db.createUser(username, password, false, false);
}

// Admin metodları
QVariantList AuthService::getAllUsers()
{
    if (!m_isAdmin) {
        qWarning() << "Yetkisiz erişim denemesi: getAllUsers";
        return QVariantList();
    }

    DatabaseManager& db = DatabaseManager::instance();
    return db.getAllUsers();
}

QVariantList AuthService::getPendingUsers()
{
    if (!m_isAdmin) {
        qWarning() << "Yetkisiz erişim denemesi: getPendingUsers";
        return QVariantList();
    }

    DatabaseManager& db = DatabaseManager::instance();
    return db.getPendingUsers();
}

bool AuthService::approveUser(int userId)
{
    if (!m_isAdmin) {
        qWarning() << "Yetkisiz erişim denemesi: approveUser";
        return false;
    }

    DatabaseManager& db = DatabaseManager::instance();
    bool result = db.approveUser(userId);
    if (result) {
        emit userListChanged();
    }
    return result;
}

bool AuthService::rejectUser(int userId)
{
    if (!m_isAdmin) {
        qWarning() << "Yetkisiz erişim denemesi: rejectUser";
        return false;
    }

    DatabaseManager& db = DatabaseManager::instance();
    bool result = db.rejectUser(userId);
    if (result) {
        emit userListChanged();
    }
    return result;
}

bool AuthService::deleteUser(int userId)
{
    if (!m_isAdmin) {
        qWarning() << "Yetkisiz erişim denemesi: deleteUser";
        return false;
    }

    DatabaseManager& db = DatabaseManager::instance();
    bool result = db.deleteUser(userId);
    if (result) {
        emit userListChanged();
    }
    return result;
}

bool AuthService::updateUser(int userId, const QString& username, const QString& password, bool isAdmin)
{
    if (!m_isAdmin) {
        qWarning() << "Yetkisiz erişim denemesi: updateUser";
        return false;
    }

    DatabaseManager& db = DatabaseManager::instance();
    bool result = db.updateUser(userId, username, password, isAdmin);
    if (result) {
        emit userListChanged();
    }
    return result;
}

bool AuthService::createUserByAdmin(const QString& username, const QString& password, bool isAdmin)
{
    if (!m_isAdmin) {
        qWarning() << "Yetkisiz erişim denemesi: createUserByAdmin";
        return false;
    }

    DatabaseManager& db = DatabaseManager::instance();
    bool result = db.createUser(username, password, isAdmin, true); // Admin tarafından oluşturulduğu için direkt onaylı
    if (result) {
        emit userListChanged();
    }
    return result;
}
