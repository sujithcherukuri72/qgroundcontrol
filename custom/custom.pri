message("Adding Custom Plugin")

#-- Version control
#   Major and minor versions are defined here (manually)

CUSTOM_QGC_VER_MAJOR = 0
CUSTOM_QGC_VER_MINOR = 0
CUSTOM_QGC_VER_FIRST_BUILD = 0

# Build number is automatic
# Uses the current branch. This way it works on any branch including build-server's PR branches
CUSTOM_QGC_VER_BUILD = $$system(git --git-dir ../.git rev-list $$GIT_BRANCH --first-parent --count)
win32 {
    CUSTOM_QGC_VER_BUILD = $$system("set /a $$CUSTOM_QGC_VER_BUILD - $$CUSTOM_QGC_VER_FIRST_BUILD")
} else {
    CUSTOM_QGC_VER_BUILD = $$system("echo $(($$CUSTOM_QGC_VER_BUILD - $$CUSTOM_QGC_VER_FIRST_BUILD))")
}
CUSTOM_QGC_VERSION = $${CUSTOM_QGC_VER_MAJOR}.$${CUSTOM_QGC_VER_MINOR}.$${CUSTOM_QGC_VER_BUILD}

DEFINES -= GIT_VERSION=\"\\\"$$GIT_VERSION\\\"\"
DEFINES += GIT_VERSION=\"\\\"$$CUSTOM_QGC_VERSION\\\"\"

message(Custom QGC Version: $${CUSTOM_QGC_VERSION})

# Build a single flight stack by disabling APM(ArduPilotMega) support (i'm enabling because i need arducopter for SITL)
MAVLINK_CONF = ardupilotmega
# CONFIG  += QGC_DISABLE_APM_MAVLINK
# CONFIG  += QGC_DISABLE_APM_PLUGIN QGC_DISABLE_APM_PLUGIN_FACTORY
CONFIG += APMFirmwarePlugin
CONFIG -= QGC_DISABLE_APM_PLUGIN
CONFIG -= QGC_DISABLE_APM_MAVLINK
CONFIG -= QGC_DISABLE_APM_PLUGIN_FACTORY

#CONFIG  += QGC_DISABLE_PX4_PLUGIN_FACTORY

# Branding

DEFINES += CUSTOMHEADER=\"\\\"CustomPlugin.h\\\"\"
DEFINES += CUSTOMCLASS=CustomPlugin

QGC_APP_NAME        = "IndronesGCS"
QGC_BINARY_NAME     = "CustomIndrones"
QGC_ORG_NAME        = "Indrones.com"
QGC_ORG_DOMAIN      = "org.Indrones"
QGC_ANDROID_PACKAGE = "org.custom.Indrones"
QGC_APP_DESCRIPTION = "Indrones-Customized QGCS"
QGC_APP_COPYRIGHT   = "Copyright (C) 2025 Indrones Development Team. All rights reserved."

TARGET   = CustomGroundControl
DEFINES += QGC_APPLICATION_NAME=\"\\\"$$QGC_APP_NAME\\\"\"
DEFINES += QGC_ORG_NAME=\"\\\"$$QGC_ORG_NAME\\\"\"
DEFINES += QGC_ORG_DOMAIN=\"\\\"$$QGC_ORG_DOMAIN\\\"\"
DEFINES += QGC_BINARY_NAME=\"\\\"$$QGC_BINARY_NAME\\\"\"
DEFINES += QGC_ANDROID_PACKAGE=\"\\\"$$QGC_ANDROID_PACKAGE\\\"\"
DEFINES += QGC_APP_DESCRIPTION=\"\\\"$$QGC_APP_DESCRIPTION\\\"\"
DEFINES += QGC_APP_COPYRIGHT=\"\\\"$$QGC_APP_COPYRIGHT\\\"\"



# Our own, custom resources
RESOURCES += \
    $$PWD/custom.qrc

QML_IMPORT_PATH += \
   $$PWD/res

# Our own, custom sources
SOURCES += \
    $$PWD/src/CustomPlugin.cc \
    $$PWD/src/LoginManager.cpp

HEADERS += \
    $$PWD/src/CustomPlugin.h \
    $$PWD/src/LoginManager.h

INCLUDEPATH += \
    $$PWD/src \

#-------------------------------------------------------------------------------------
# Custom Firmware/AutoPilot --Plugin These are the custom Firmwares (commented to enable arducopter and general px4 not customised)

# INCLUDEPATH += \
#     $$PWD/src/FirmwarePlugin \
#     $$PWD/src/AutoPilotPlugin

# HEADERS+= \
#     $$PWD/src/AutoPilotPlugin/CustomAutoPilotPlugin.h \
#     $$PWD/src/FirmwarePlugin/CustomFirmwarePlugin.h \
#     $$PWD/src/FirmwarePlugin/CustomFirmwarePluginFactory.h \

# SOURCES += \
#     $$PWD/src/AutoPilotPlugin/CustomAutoPilotPlugin.cc \
#     $$PWD/src/FirmwarePlugin/CustomFirmwarePlugin.cc \
#     $$PWD/src/FirmwarePlugin/CustomFirmwarePluginFactory.cc \


