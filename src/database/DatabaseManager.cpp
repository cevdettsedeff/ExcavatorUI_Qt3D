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

    // İlk kullanıcı yoksa default kullanıcı oluştur
    if (getUserCount() == 0) {
        qDebug() << "İlk kullanıcı oluşturuluyor: admin/admin";
        createUser("admin", "admin");
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
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    )";

    if (!query.exec(createTableQuery)) {
        qCritical() << "Users tablosu oluşturulamadı:" << query.lastError().text();
        return false;
    }

    qDebug() << "Users tablosu hazır";
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

bool DatabaseManager::createUser(const QString& username, const QString& password)
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
    query.prepare("INSERT INTO users (username, password_hash) VALUES (:username, :password_hash)");
    query.bindValue(":username", username);
    query.bindValue(":password_hash", hashPassword(password));

    if (!query.exec()) {
        qCritical() << "Kullanıcı oluşturulamadı:" << query.lastError().text();
        return false;
    }

    qDebug() << "Kullanıcı başarıyla oluşturuldu:" << username;
    return true;
}

bool DatabaseManager::validateUser(const QString& username, const QString& password)
{
    if (!m_initialized) {
        qWarning() << "Veritabanı başlatılmamış";
        return false;
    }

    QSqlQuery query;
    query.prepare("SELECT password_hash FROM users WHERE username = :username");
    query.bindValue(":username", username);

    if (!query.exec()) {
        qCritical() << "Sorgu hatası:" << query.lastError().text();
        return false;
    }

    if (query.next()) {
        QString storedHash = query.value(0).toString();
        bool isValid = verifyPassword(password, storedHash);
        qDebug() << "Kullanıcı doğrulama:" << username << "->" << (isValid ? "Başarılı" : "Başarısız");
        return isValid;
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
