#include "DatabaseManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QCryptographicHash>
#include <QStandardPaths>
#include <QDir>

const QString DatabaseManager::DB_NAME = "excavator_db.sqlite";

DatabaseManager::DatabaseManager(QObject *parent)
    : QObject(parent)
    , m_initialized(false)
{
}

DatabaseManager::~DatabaseManager()
{
    if (m_database.isOpen()) {
        m_database.close();
    }
}

DatabaseManager& DatabaseManager::instance()
{
    static DatabaseManager instance;
    return instance;
}

bool DatabaseManager::initialize()
{
    if (m_initialized) {
        return true;
    }

    // Veritabanı dosyasının yolunu belirle
    QString dataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(dataPath);
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    QString dbPath = dataPath + "/" + DB_NAME;
    qDebug() << "Database path:" << dbPath;

    // SQLite veritabanını aç
    m_database = QSqlDatabase::addDatabase("QSQLITE");
    m_database.setDatabaseName(dbPath);

    if (!m_database.open()) {
        qCritical() << "Veritabanı açılamadı:" << m_database.lastError().text();
        return false;
    }

    qDebug() << "Veritabanı başarıyla açıldı";

    // Tabloları oluştur
    if (!createTables()) {
        qCritical() << "Tablolar oluşturulamadı";
        return false;
    }

    m_initialized = true;

    // İlk kullanıcı yoksa default admin kullanıcı oluştur
    if (getUserCount() == 0) {
        qDebug() << "İlk admin kullanıcı oluşturuluyor: admin/admin";
        createUser("admin", "admin", true, true);
    } else {
        // Mevcut admin kullanıcının admin yetkisini güncelle (eski veritabanları için)
        QSqlQuery query;
        query.prepare("UPDATE users SET is_admin = 1 WHERE username = 'admin' AND is_admin = 0");
        if (query.exec() && query.numRowsAffected() > 0) {
            qDebug() << "Admin kullanıcı yetkisi güncellendi";
        }
    }

    return true;
}

bool DatabaseManager::createTables()
{
    QSqlQuery query;

    // Users tablosu
    QString createTableQuery = R"(
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            is_admin INTEGER DEFAULT 0,
            approved INTEGER DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    )";

    if (!query.exec(createTableQuery)) {
        qCritical() << "Users tablosu oluşturulamadı:" << query.lastError().text();
        return false;
    }

    qDebug() << "Users tablosu hazır";

    // Mevcut tabloları güncelle (eski veritabanları için)
    return updateTables();
}

bool DatabaseManager::updateTables()
{
    QSqlQuery query;

    // is_admin kolonunu ekle (eğer yoksa)
    query.exec("ALTER TABLE users ADD COLUMN is_admin INTEGER DEFAULT 0");

    // approved kolonunu ekle (eğer yoksa)
    query.exec("ALTER TABLE users ADD COLUMN approved INTEGER DEFAULT 1");

    return true;
}

QString DatabaseManager::hashPassword(const QString& password)
{
    // SHA-256 ile şifreyi hashle
    QByteArray hash = QCryptographicHash::hash(
        password.toUtf8(),
        QCryptographicHash::Sha256
    );
    return QString(hash.toHex());
}

bool DatabaseManager::verifyPassword(const QString& password, const QString& hash)
{
    return hashPassword(password) == hash;
}

bool DatabaseManager::createUser(const QString& username, const QString& password, bool isAdmin, bool approved)
{
    if (!m_initialized) {
        qWarning() << "Veritabanı başlatılmamış";
        return false;
    }

    if (username.isEmpty() || password.isEmpty()) {
        qWarning() << "Kullanıcı adı veya şifre boş olamaz";
        return false;
    }

    if (userExists(username)) {
        qWarning() << "Kullanıcı zaten mevcut:" << username;
        return false;
    }

    QSqlQuery query;
    query.prepare("INSERT INTO users (username, password_hash, is_admin, approved) VALUES (:username, :password_hash, :is_admin, :approved)");
    query.bindValue(":username", username);
    query.bindValue(":password_hash", hashPassword(password));
    query.bindValue(":is_admin", isAdmin ? 1 : 0);
    query.bindValue(":approved", approved ? 1 : 0);

    if (!query.exec()) {
        qCritical() << "Kullanıcı oluşturulamadı:" << query.lastError().text();
        return false;
    }

    qDebug() << "Kullanıcı başarıyla oluşturuldu:" << username << "(Admin:" << isAdmin << ", Onaylı:" << approved << ")";
    return true;
}

bool DatabaseManager::validateUser(const QString& username, const QString& password)
{
    if (!m_initialized) {
        qWarning() << "Veritabanı başlatılmamış";
        return false;
    }

    QSqlQuery query;
    query.prepare("SELECT password_hash, approved FROM users WHERE username = :username");
    query.bindValue(":username", username);

    if (!query.exec()) {
        qCritical() << "Sorgu hatası:" << query.lastError().text();
        return false;
    }

    if (query.next()) {
        QString storedHash = query.value(0).toString();
        bool isApproved = query.value(1).toBool();

        // Önce şifreyi kontrol et
        bool isValid = verifyPassword(password, storedHash);

        if (!isValid) {
            qDebug() << "Kullanıcı doğrulama başarısız (hatalı şifre):" << username;
            return false;
        }

        // Şifre doğruysa onay durumunu kontrol et
        if (!isApproved) {
            qDebug() << "Kullanıcı doğrulama başarısız (onay bekliyor):" << username;
            return false;
        }

        qDebug() << "Kullanıcı doğrulama başarılı:" << username;
        return true;
    }

    qDebug() << "Kullanıcı bulunamadı:" << username;
    return false;
}

bool DatabaseManager::userExists(const QString& username)
{
    if (!m_initialized) {
        return false;
    }

    QSqlQuery query;
    query.prepare("SELECT COUNT(*) FROM users WHERE username = :username");
    query.bindValue(":username", username);

    if (query.exec() && query.next()) {
        return query.value(0).toInt() > 0;
    }

    return false;
}

int DatabaseManager::getUserCount()
{
    if (!m_initialized) {
        return 0;
    }

    QSqlQuery query;
    if (query.exec("SELECT COUNT(*) FROM users") && query.next()) {
        return query.value(0).toInt();
    }

    return 0;
}

// Admin operations
bool DatabaseManager::isUserAdmin(const QString& username)
{
    if (!m_initialized) {
        return false;
    }

    QSqlQuery query;
    query.prepare("SELECT is_admin FROM users WHERE username = :username");
    query.bindValue(":username", username);

    if (query.exec() && query.next()) {
        return query.value(0).toBool();
    }

    return false;
}

bool DatabaseManager::isUserApproved(const QString& username)
{
    if (!m_initialized) {
        return false;
    }

    QSqlQuery query;
    query.prepare("SELECT approved FROM users WHERE username = :username");
    query.bindValue(":username", username);

    if (query.exec() && query.next()) {
        return query.value(0).toBool();
    }

    return false;
}

QVariantList DatabaseManager::getAllUsers()
{
    QVariantList users;

    if (!m_initialized) {
        return users;
    }

    QSqlQuery query;
    query.prepare("SELECT id, username, is_admin, approved, created_at FROM users ORDER BY created_at DESC");

    if (!query.exec()) {
        qCritical() << "Kullanıcılar getirilemedi:" << query.lastError().text();
        return users;
    }

    while (query.next()) {
        QVariantMap user;
        user["id"] = query.value(0).toInt();
        user["username"] = query.value(1).toString();
        user["isAdmin"] = query.value(2).toBool();
        user["approved"] = query.value(3).toBool();
        user["createdAt"] = query.value(4).toString();
        users.append(user);
    }

    return users;
}

QVariantList DatabaseManager::getPendingUsers()
{
    QVariantList users;

    if (!m_initialized) {
        return users;
    }

    QSqlQuery query;
    query.prepare("SELECT id, username, created_at FROM users WHERE approved = 0 ORDER BY created_at DESC");

    if (!query.exec()) {
        qCritical() << "Onay bekleyen kullanıcılar getirilemedi:" << query.lastError().text();
        return users;
    }

    while (query.next()) {
        QVariantMap user;
        user["id"] = query.value(0).toInt();
        user["username"] = query.value(1).toString();
        user["createdAt"] = query.value(2).toString();
        users.append(user);
    }

    return users;
}

bool DatabaseManager::approveUser(int userId)
{
    if (!m_initialized) {
        return false;
    }

    QSqlQuery query;
    query.prepare("UPDATE users SET approved = 1 WHERE id = :id");
    query.bindValue(":id", userId);

    if (!query.exec()) {
        qCritical() << "Kullanıcı onaylanamadı:" << query.lastError().text();
        return false;
    }

    qDebug() << "Kullanıcı onaylandı. ID:" << userId;
    return true;
}

bool DatabaseManager::rejectUser(int userId)
{
    if (!m_initialized) {
        return false;
    }

    // Onaylanmayan kullanıcıyı sil
    return deleteUser(userId);
}

bool DatabaseManager::deleteUser(int userId)
{
    if (!m_initialized) {
        return false;
    }

    QSqlQuery query;
    query.prepare("DELETE FROM users WHERE id = :id");
    query.bindValue(":id", userId);

    if (!query.exec()) {
        qCritical() << "Kullanıcı silinemedi:" << query.lastError().text();
        return false;
    }

    qDebug() << "Kullanıcı silindi. ID:" << userId;
    return true;
}

bool DatabaseManager::updateUser(int userId, const QString& username, const QString& password, bool isAdmin)
{
    if (!m_initialized) {
        return false;
    }

    QSqlQuery query;

    // Şifre verilmişse güncelle
    if (!password.isEmpty()) {
        query.prepare("UPDATE users SET username = :username, password_hash = :password_hash, is_admin = :is_admin WHERE id = :id");
        query.bindValue(":password_hash", hashPassword(password));
    } else {
        query.prepare("UPDATE users SET username = :username, is_admin = :is_admin WHERE id = :id");
    }

    query.bindValue(":id", userId);
    query.bindValue(":username", username);
    query.bindValue(":is_admin", isAdmin ? 1 : 0);

    if (!query.exec()) {
        qCritical() << "Kullanıcı güncellenemedi:" << query.lastError().text();
        return false;
    }

    qDebug() << "Kullanıcı güncellendi. ID:" << userId;
    return true;
}
