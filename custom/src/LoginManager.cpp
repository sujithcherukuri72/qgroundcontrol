#include "LoginManager.h"

LoginManager::LoginManager(QObject *parent) : QObject(parent) {}
//Dummy variables

bool LoginManager::validateCreds(const QString &u, const QString &p, Role &outRole)
{
    if (u == "admin" && p == "admin123") { outRole = Admin; return true; }
    if (u == "user"  && p == "user123")  { outRole = User;  return true; }
    return false;
}

bool LoginManager::login(const QString &u, const QString &p)
{
    Role newRole = None;
    if (validateCreds(u, p, newRole)) {
        _role     = newRole;
        _errorMsg.clear();
        emit loginStatusChanged();
        emit errorMsgChanged();
        emit loginSuccessful();
        return true;
    }
    _errorMsg = "Invalid username or password";
    emit errorMsgChanged();
    return false;
}

void LoginManager::logout()
{
    if (_role != None) {
        _role = None;
        emit loginStatusChanged();
    }
}
