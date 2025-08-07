/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts  1.11
import QtQuick.Dialogs  1.3

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.Palette               1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Controllers           1.0
import "qrc:/Custom/Widgets" as Custom

Rectangle {
    id:     _root
    color:  qgcPal.toolbarBackground

    property int currentToolbar: flyViewToolbar

    readonly property int flyViewToolbar:   0
    readonly property int planViewToolbar:  1
    readonly property int simpleToolbar:    2

    // ═══ DASHBOARD TOGGLE PROPERTY  ═══
    property bool dashboardVisible: false

    // ═══ VARIABLE TO COMMUNICATE WITH FLYVIEW  ═══
    signal toggleDashboard(bool visible)

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _mainStatusBGColor: qgcPal.brandingYellow

    QGCPalette { id: qgcPal }

    /// Bottom single pixel divider
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         1
        color:          "black"
        visible:        qgcPal.globalTheme === QGCPalette.Light
    }

    Rectangle {
        anchors.fill:   viewButtonRow
        visible:        currentToolbar === flyViewToolbar

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0;                                     color: _mainStatusBGColor }
            GradientStop { position: currentButton.x + currentButton.width; color: _mainStatusBGColor }
            GradientStop { position: 1;                                     color: _root.color }
        }
    }

    RowLayout {
        id:                     viewButtonRow
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        spacing:                ScreenTools.defaultFontPixelWidth / 2

        QGCToolBarButton {
            id:                     currentButton
            Layout.preferredHeight: viewButtonRow.height
            icon.source:            "/res/IndronesLogo"
            logo:                   true
            onClicked:              mainWindow.showToolSelectDialog()
        }

        MainStatusIndicator {
            Layout.preferredHeight: viewButtonRow.height
            visible:                currentToolbar === flyViewToolbar
        }

        QGCButton {
            id:                 disconnectButton
            text:               qsTr("Disconnect")
            onClicked:          _activeVehicle.closeVehicle()
            visible:            _activeVehicle && _communicationLost && currentToolbar === flyViewToolbar
        }


    }

    QGCFlickable {
        id:                     toolsFlickable
        anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * ScreenTools.largeFontPointRatio * 1.5
        anchors.left:           viewButtonRow.right
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.right:          parent.right
        contentWidth:           indicatorLoader.x + indicatorLoader.width
        flickableDirection:     Flickable.HorizontalFlick

        Loader {
            id:                 indicatorLoader
            anchors.left:       parent.left
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             currentToolbar === flyViewToolbar ?
                                    "qrc:/toolbar/MainToolBarIndicators.qml" :
                                    (currentToolbar == planViewToolbar ? "qrc:/qml/PlanToolBarIndicators.qml" : "")
        }
    }
    // ═══════ PROFILE BUTTON  ═══════
    QGCToolBarButton {
        id:                     profileButton
        anchors.right:          parent.right
        anchors.top: parent.top
        anchors.rightMargin: 100
        icon.source:            "/qmlimages/Hamburger.svg"
        visible:                loginManager && loginManager.isLoggedIn
        onClicked:              profilePopup.open()
    }

    // PROFILE POPUP
    Popup {
        id:             profilePopup
        modal:          false
        focus:          true
        closePolicy:    Popup.CloseOnEscape | Popup.CloseOnPressOutside
           x: profileButton.x - width + profileButton.width
           y: profileButton.y + profileButton.height + ScreenTools.defaultFontPixelHeight * 0.25

           width:  ScreenTools.defaultFontPixelWidth * 28
           height: profileContent.height + (ScreenTools.defaultFontPixelHeight * 1.5)

        background: Rectangle {
            color:          qgcPal.button
            border.color:   qgcPal.text
            border.width:   1
            radius:         ScreenTools.defaultFontPixelHeight * 0.25
        }

        Column {
            id:         profileContent
            anchors.centerIn: parent
            spacing:    ScreenTools.defaultFontPixelHeight * 0.75
            width:      parent.width - (ScreenTools.defaultFontPixelWidth * 2)

            // Header with user icon
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: ScreenTools.defaultFontPixelWidth

                QGCColoredImage {
                    width: ScreenTools.defaultFontPixelHeight * 1.5
                    height: width
                    source: "/qmlimages/Profile-icon.svg"
                    color: qgcPal.text
                    anchors.verticalCenter: parent.verticalCenter
                }

                QGCLabel {
                    text: qsTr("Profile")
                    font.pointSize: ScreenTools.mediumFontPointSize
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                width:  parent.width
                height: 1
                color:  qgcPal.text
                opacity: 0.3
            }

           // User info
            Column {
                width:      parent.width
                spacing:    ScreenTools.defaultFontPixelHeight * 0.25

                QGCLabel {
                    text: loginManager ? qsTr("User: ") + loginManager.username : qsTr("User: Not logged in")
                    font.pointSize: ScreenTools.defaultFontPointSize
                }

                Rectangle {
                    width: roleLabel.width + (ScreenTools.defaultFontPixelWidth * 1.5)
                    height: roleLabel.height + (ScreenTools.defaultFontPixelHeight * 0.5)
                    radius: height * 0.25
                    color: loginManager && loginManager.isAdmin ? qgcPal.colorGreen : qgcPal.colorBlue
                    opacity: 0.2

                    QGCLabel {
                        id: roleLabel
                        anchors.centerIn: parent
                        text: loginManager ? (loginManager.isAdmin ? qsTr("Administrator") : qsTr("User")) : qsTr("Guest")
                        font.pointSize: ScreenTools.defaultFontPointSize
                        font.bold: true
                        color: loginManager && loginManager.isAdmin ? qgcPal.colorGreen : qgcPal.colorBlue
                    }
                }

                // Status indicator
                Row {
                    spacing: ScreenTools.defaultFontPixelWidth * 0.5

                    Rectangle {
                        width: ScreenTools.defaultFontPixelHeight * 0.75
                        height: width
                        radius: width * 0.5
                        color: loginManager && loginManager.isLoggedIn ? qgcPal.colorGreen : qgcPal.colorRed
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    QGCLabel {
                        text: loginManager && loginManager.isLoggedIn ? qsTr("Online") : qsTr("Offline")
                        font.pointSize: ScreenTools.smallFontPointSize
                        color: loginManager && loginManager.isLoggedIn ? qgcPal.colorGreen : qgcPal.colorRed
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Rectangle {
                width:  parent.width
                height: 1
                color:  qgcPal.text
                opacity: 0.3
            }

            // ═══ ACTION BUTTONS ═══
            Column {
                width:      parent.width
                spacing:    ScreenTools.defaultFontPixelHeight * 0.5

                QGCButton {
                    text:           dashboardVisible ? qsTr("Hide Dashboard") : qsTr("Show Dashboard")
                    width:          parent.width
                    icon.source:    "/qmlimages/Home.svg"
                    onClicked: {
                        // Toggle dashboard visibility
                        dashboardVisible = !dashboardVisible

                        // Emit signal to FlyView
                        _root.toggleDashboard(dashboardVisible)

                        // Ensure we're in FlyView
                        mainWindow.showFlyView()

                        profilePopup.close()
                    }
                }

                QGCButton {
                    text:           qsTr("Settings")
                    width:          parent.width
                    icon.source:    "/qmlimages/Gears.svg"
                    visible:        loginManager && loginManager.isAdmin
                    onClicked: {
                        mainWindow.showSettingsTool()
                        profilePopup.close()
                    }
                }

                QGCButton {
                    text:           qsTr("Log Out")
                    width:          parent.width
                    icon.source:    "/qmlimages/PowerButton.svg"
                    enabled:        loginManager && loginManager.isLoggedIn
                    onClicked: {
                        if (loginManager) {
                            loginManager.logout()
                        }
                        // Hide dashboard on logout
                        dashboardVisible = false
                        _root.toggleDashboard(false)
                        profilePopup.close()
                    }
                }
            }
        }
    }

    // Auto-close popup and reset dashboard on login status change
    Connections {
        target: loginManager
        ignoreUnknownSignals: true
        function onLoginStatusChanged() {
            if (profilePopup) {
                profilePopup.close()
            }
            // Hide dashboard when login status changes
            if (!loginManager || !loginManager.isLoggedIn) {
                dashboardVisible = false
                _root.toggleDashboard(false)
            }
        }
    }

    //-------------------------------------------------------------------------
    //-- Branding Logo
    Image {
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.margins:        ScreenTools.defaultFontPixelHeight * 0.66
        visible:                currentToolbar !== planViewToolbar && _activeVehicle && !_communicationLost && x > (toolsFlickable.x + toolsFlickable.contentWidth + ScreenTools.defaultFontPixelWidth)
        fillMode:               Image.PreserveAspectFit
        source:                 _outdoorPalette ? _brandImageOutdoor : _brandImageIndoor
        mipmap:                 true

        property bool   _outdoorPalette:        qgcPal.globalTheme === QGCPalette.Light
        property bool   _corePluginBranding:    QGroundControl.corePlugin.brandImageIndoor.length != 0
        property string _userBrandImageIndoor:  QGroundControl.settingsManager.brandImageSettings.userBrandImageIndoor.value
        property string _userBrandImageOutdoor: QGroundControl.settingsManager.brandImageSettings.userBrandImageOutdoor.value
        property bool   _userBrandingIndoor:    _userBrandImageIndoor.length != 0
        property bool   _userBrandingOutdoor:   _userBrandImageOutdoor.length != 0
        property string _brandImageIndoor:      brandImageIndoor()
        property string _brandImageOutdoor:     brandImageOutdoor()

        function brandImageIndoor() {
            if (_userBrandingIndoor) {
                return _userBrandImageIndoor
            } else {
                if (_userBrandingOutdoor) {
                    return _userBrandingOutdoor
                } else {
                    if (_corePluginBranding) {
                        return QGroundControl.corePlugin.brandImageIndoor
                    } else {
                        return _activeVehicle ? _activeVehicle.brandImageIndoor : ""
                    }
                }
            }
        }

        function brandImageOutdoor() {
            if (_userBrandingOutdoor) {
                return _userBrandingOutdoor
            } else {
                if (_userBrandingIndoor) {
                    return _userBrandingIndoor
                } else {
                    if (_corePluginBranding) {
                        return QGroundControl.corePlugin.brandImageOutdoor
                    } else {
                        return _activeVehicle ? _activeVehicle.brandImageOutdoor : ""
                    }
                }
            }
        }
    }

    // Small parameter download progress bar
    Rectangle {
        anchors.bottom: parent.bottom
        height:         _root.height * 0.05
        width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
        color:          qgcPal.colorGreen
        visible:        !largeProgressBar.visible
    }

    // Large parameter download progress bar
    Rectangle {
        id:             largeProgressBar
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:         parent.height
        color:          qgcPal.window
        visible:        _showLargeProgress

        property bool _initialDownloadComplete: _activeVehicle ? _activeVehicle.initialConnectComplete : true
        property bool _userHide:                false
        property bool _showLargeProgress:       !_initialDownloadComplete && !_userHide && qgcPal.globalTheme === QGCPalette.Light

        Connections {
            target:                 QGroundControl.multiVehicleManager
            function onActiveVehicleChanged(activeVehicle) { largeProgressBar._userHide = false }
        }

        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
            color:          qgcPal.colorGreen
        }

        QGCLabel {
            anchors.centerIn:   parent
            text:               qsTr("Downloading")
            font.pointSize:     ScreenTools.largeFontPointSize
        }

        QGCLabel {
            anchors.margins:    _margin
            anchors.right:      parent.right
            anchors.bottom:     parent.bottom
            text:               qsTr("Click anywhere to hide")

            property real _margin: ScreenTools.defaultFontPixelWidth / 2
        }

        MouseArea {
            anchors.fill:   parent
            onClicked:      largeProgressBar._userHide = true
        }
    }
}
