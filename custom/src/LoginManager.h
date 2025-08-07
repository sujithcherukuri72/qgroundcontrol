#ifndef LOGINMANAGER_H
#define LOGINMANAGER_H

#include <QObject>
#include <QString>

class LoginManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool   isLoggedIn READ isLoggedIn NOTIFY loginStatusChanged)
    Q_PROPERTY(bool   isAdmin    READ isAdmin    NOTIFY loginStatusChanged)
    Q_PROPERTY(bool   isUser     READ isUser     NOTIFY loginStatusChanged)
    Q_PROPERTY(QString role      READ role       NOTIFY loginStatusChanged)
    Q_PROPERTY(QString errorMsg  READ errorMsg   NOTIFY errorMsgChanged)

public:
    enum Role { None, Admin, User };
    Q_ENUM(Role)

    explicit LoginManager(QObject *parent = nullptr);

    // state accessors
    bool     isLoggedIn() const { return _role != None; }
    bool     isAdmin()    const { return _role == Admin; }
    bool     isUser()     const { return _role == User;  }
    QString  role() const        { return _role == Admin ? "admin" :
                                      _role == User  ? "user"  : ""; }
    QString  errorMsg() const    { return _errorMsg; }

    // API exposed to QML
    Q_INVOKABLE bool login (const QString &u, const QString &p);
    Q_INVOKABLE void logout();

signals:
    void loginStatusChanged();
    void errorMsgChanged();
    void loginSuccessful();

private:
    bool validateCreds(const QString &u, const QString &p, Role &outRole);

    Role    _role      = None;
    QString _errorMsg;
};

#endif
