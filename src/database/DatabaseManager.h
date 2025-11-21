#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QString>
#include <QVariantMap>

class DatabaseManager : public QObject
{
    Q_OBJECT

public:
    static DatabaseManager& instance();

    // Database operations
    bool initialize();
    bool isInitialized() const { return m_initialized; }

    // User operations
    bool createUser(const QString& username, const QString& password);
    bool validateUser(const QString& username, const QString& password);
    bool userExists(const QString& username);
    int getUserCount();

private:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    DatabaseManager(const DatabaseManager&) = delete;
    DatabaseManager& operator=(const DatabaseManager&) = delete;

    bool createTables();
    QString hashPassword(const QString& password);
    bool verifyPassword(const QString& password, const QString& hash);

    QSqlDatabase m_database;
    bool m_initialized;
    static const QString DB_NAME;
};

#endif // DATABASEMANAGER_H
