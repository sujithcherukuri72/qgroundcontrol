#ifndef CUSTOMPLUGIN_H
#define CUSTOMPLUGIN_H
#pragma once

#include "QGCCorePlugin.h"
#include "QGCOptions.h"
#include "QGCLoggingCategory.h"
#include <QStringList>

// Forward declarations only
class LoginManager;

Q_DECLARE_LOGGING_CATEGORY(CustomLog)

class CustomFlyViewOptions : public QGCFlyViewOptions
{
public:
    CustomFlyViewOptions(QGCOptions* options, QObject* parent = nullptr);
    bool showInstrumentPanel() const override;
    bool showMultiVehicleList() const override;
};

class CustomOptions : public QGCOptions
{
public:
    CustomOptions(QObject* parent = nullptr);
    bool wifiReliableForCalibration() const override;
    bool showFirmwareUpgrade() const override;
    QGCFlyViewOptions* flyViewOptions() override;

private:
    CustomFlyViewOptions* _flyViewOptions = nullptr;
};

class CustomPlugin : public QGCCorePlugin
{
    Q_OBJECT
public:
    CustomPlugin(QGCApplication* app, QGCToolbox* toolbox);
    ~CustomPlugin() override;

    // QGCCorePlugin overrides
    QVariantList& settingsPages() override;
    QGCOptions* options() override;
    QString brandImageIndoor() const override;
    QString brandImageOutdoor() const override;
    bool overrideSettingsGroupVisibility(QString name) override;
    bool adjustSettingMetaData(const QString& settingsGroup, FactMetaData& metaData) override;
    void paletteOverride(QString colorName, QGCPalette::PaletteColorInfo_t& colorInfo) override;
    QQmlApplicationEngine* createQmlApplicationEngine(QObject* parent) override;
    void setToolbox(QGCToolbox* toolbox) override;

private slots:
    void _advancedChanged(bool advanced);

private:
    void _addSettingsEntry(const QString& title, const char* qmlFile, const char* iconFile = nullptr);

    LoginManager* _loginMgr = nullptr;
    QStringList _userRestricted { "MAVLink", "Console", "Vehicle Setup", "Analyze Tools" };
    CustomOptions* _options = nullptr;
    QVariantList _customSettingsList;
};

#endif
