#ifndef AUTHSERVICE_H
#define AUTHSERVICE_H

#include <QObject>
#include <QString>
#include <QVariantList>

class AuthService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isAuthenticated READ isAuthenticated NOTIFY authenticationChanged)
    Q_PROPERTY(QString currentUser READ currentUser NOTIFY authenticationChanged)
    Q_PROPERTY(bool isAdmin READ isAdmin NOTIFY authenticationChanged)

public:
    explicit AuthService(QObject *parent = nullptr);

    bool isAuthenticated() const { return m_isAuthenticated; }
    QString currentUser() const { return m_currentUser; }
    bool isAdmin() const { return m_isAdmin; }

    // QML'den çağrılabilir metodlar
    Q_INVOKABLE bool login(const QString& username, const QString& password);
    Q_INVOKABLE void logout();
    Q_INVOKABLE bool registerUser(const QString& username, const QString& password);
    Q_INVOKABLE bool updateProfile(const QString& newUsername, const QString& newPassword);

    // Admin metodları
    Q_INVOKABLE QVariantList getAllUsers();
    Q_INVOKABLE QVariantList getPendingUsers();
    Q_INVOKABLE bool approveUser(int userId);
    Q_INVOKABLE bool rejectUser(int userId);
    Q_INVOKABLE bool deleteUser(int userId);
    Q_INVOKABLE bool updateUser(int userId, const QString& username, const QString& password, bool isAdmin);
    Q_INVOKABLE bool createUserByAdmin(const QString& username, const QString& password, bool isAdmin);

signals:
    void authenticationChanged();
    void loginSucceeded();
    void loginFailed(const QString& error);
    void loggedOut();
    void userListChanged();

private:
    bool m_isAuthenticated;
    QString m_currentUser;
    bool m_isAdmin;
};

#endif // AUTHSERVICE_H
