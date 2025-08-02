/****************************************************************************
 *  LogFileHelper.cpp
 ****************************************************************************/
#include "LogFileHelper.h"

#include <QDir>
#include <QFileInfo>
#include <QDebug>

LogFileHelper::LogFileHelper(QObject* parent)
    : QObject(parent)
{
}

QStringList LogFileHelper::getBinFiles(const QString& path)
{
    QDir dir(path);
    if (!dir.exists()) {
        qWarning().noquote() << "LogFileHelper: directory does not exist:" << path;
        return {};
    }

    // Retrieve only *.bin files, newest first
    QFileInfoList files = dir.entryInfoList(QStringList() << "*.bin",
                                            QDir::Files,
                                            QDir::Time | QDir::Reversed);

    QStringList out;
    out.reserve(files.count());
    for (const QFileInfo& fi : files)
        out << fi.absoluteFilePath();

    return out;
}
