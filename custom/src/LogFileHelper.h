#pragma once
/****************************************************************************
 *  LogFileHelper.h
 *
 *  Lightweight utility for enumerating “.bin” flight-log files in a folder.
 *  Copyright © 2025 <Indrones>.
 ****************************************************************************/

#include <QObject>
#include <QStringList>

class LogFileHelper : public QObject
{
    Q_OBJECT
public:
    explicit LogFileHelper(QObject* parent = nullptr);

    // QML-callable: returns a list of *.bin files in |path|
    Q_INVOKABLE QStringList getBinFiles(const QString& path);
};
