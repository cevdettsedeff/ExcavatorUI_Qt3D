#ifndef AUTHSERVICE_H
#define AUTHSERVICE_H

#include <QObject>
#include <QString>

class AuthService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isAuthenticated READ isAuthenticated NOTIFY authenticationChanged)
    Q_PROPERTY(QString currentUser READ currentUser NOTIFY authenticationChanged)

public:
    explicit AuthService(QObject *parent = nullptr);

    bool isAuthenticated() const { return m_isAuthenticated; }
    QString currentUser() const { return m_currentUser; }

    // QML'den çağrılabilir metodlar
    Q_INVOKABLE bool login(const QString& username, const QString& password);
    Q_INVOKABLE void logout();
    Q_INVOKABLE bool registerUser(const QString& username, const QString& password);

signals:
    void authenticationChanged();
    void loginSucceeded();
    void loginFailed(const QString& error);

private:
    bool m_isAuthenticated;
    QString m_currentUser;
};

#endif // AUTHSERVICE_H
