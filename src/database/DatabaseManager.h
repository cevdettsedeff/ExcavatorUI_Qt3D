#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QString>
#include <QVariantMap>
#include <QVariantList>

class DatabaseManager : public QObject
{
    Q_OBJECT

public:
    static DatabaseManager& instance();

    // Database operations
    bool initialize();
    bool isInitialized() const { return m_initialized; }

    // User operations
    bool createUser(const QString& username, const QString& password, bool isAdmin = false, bool approved = true);
    bool validateUser(const QString& username, const QString& password);
    bool userExists(const QString& username);
    int getUserCount();

    // Admin operations
    bool isUserAdmin(const QString& username);
    bool isUserApproved(const QString& username);
    QVariantList getAllUsers();
    QVariantList getPendingUsers();
    bool approveUser(int userId);
    bool rejectUser(int userId);
    bool deleteUser(int userId);
    bool updateUser(int userId, const QString& username, const QString& password, bool isAdmin);

private:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    DatabaseManager(const DatabaseManager&) = delete;
    DatabaseManager& operator=(const DatabaseManager&) = delete;

    bool createTables();
    bool updateTables();
    QString hashPassword(const QString& password);
    bool verifyPassword(const QString& password, const QString& hash);

    QSqlDatabase m_database;
    bool m_initialized;
    static const QString DB_NAME;
};

#endif // DATABASEMANAGER_H
