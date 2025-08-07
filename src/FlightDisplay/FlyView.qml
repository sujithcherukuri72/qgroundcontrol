import QtQuick                  2.12
import QtQuick.Controls         2.4
import QtQuick.Dialogs          1.3
import QtQuick.Layouts          1.12
import Qt.labs.folderlistmodel  2.12

import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Window           2.2
import QtQml.Models             2.1

import QGroundControl               1.0
import QGroundControl.Airspace      1.0
import QGroundControl.Airmap        1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import LogTools 1.0

Item {
    id: _root

    // ═══ SINGLE DASHBOARD VARIABLE ═══
    property bool dashboardVisible: false

    // ═══ MAINTOOLBAR TOGGLE SIGNAL ═══
    Connections {
        target: mainWindow.header
        ignoreUnknownSignals: true
        function onToggleDashboard(visible) {
            console.log("FlyView received dashboard toggle:", visible)
            _root.dashboardVisible = visible
        }
    }

    // These should only be used by MainRootWindow
    property var planController:    _planController
    property var guidedController:  _guidedController

    PlanMasterController {
        id:                     _planController
        flyView:                true
        Component.onCompleted:  start()
    }

    property bool   _mainWindowIsMap:       mapControl.pipState.state === mapControl.pipState.fullState
    property bool   _isFullWindowItemDark:  _mainWindowIsMap ? mapControl.isSatelliteMap : true
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property var    _missionController:     _planController.missionController
    property var    _geoFenceController:    _planController.geoFenceController
    property var    _rallyPointController:  _planController.rallyPointController
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property var    _guidedController:      guidedActionsController
    property var    _guidedActionList:      guidedActionList
    property var    _guidedAltSlider:       guidedAltSlider
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75
    property rect   _centerViewport:        Qt.rect(0, 0, width, height)
    property real   _rightPanelWidth:       ScreenTools.defaultFontPixelWidth * 30
    property var    _mapControl:            mapControl

    property real   _fullItemZorder:    0
    property real   _pipItemZorder:     QGroundControl.zOrderWidgets

    function _calcCenterViewPort() {
        var newToolInset = Qt.rect(0, 0, width, height)
        toolstrip.adjustToolInset(newToolInset)
        if (QGroundControl.corePlugin.options.instrumentWidget) {
            flightDisplayViewWidgets.adjustToolInset(newToolInset)
        }
    }

    QGCToolInsets {
        id:                     _toolInsets
        leftEdgeBottomInset:    _pipOverlay.visible ? _pipOverlay.x + _pipOverlay.width : 0
        bottomEdgeLeftInset:    _pipOverlay.visible ? parent.height - _pipOverlay.y : 0
    }

    // ═══ MAIN FLYVIEW COMPONENTS ═══
    Item {
        id: flyViewComponents
        anchors.fill: parent
        visible: !_root.dashboardVisible

        FlyViewWidgetLayer {
            id:                     widgetLayer
            anchors.top:            parent.top
            anchors.bottom:         parent.bottom
            anchors.left:           parent.left
            anchors.right:          guidedAltSlider.visible ? guidedAltSlider.left : parent.right
            z:                      _fullItemZorder + 1
            parentToolInsets:       _toolInsets
            mapControl:             _mapControl
            visible:                !QGroundControl.videoManager.fullScreen
        }

        FlyViewCustomLayer {
            id:                 customOverlay
            anchors.fill:       widgetLayer
            z:                  _fullItemZorder + 2
            parentToolInsets:   widgetLayer.totalToolInsets
            mapControl:         _mapControl
            visible:            !QGroundControl.videoManager.fullScreen
        }

        GuidedActionsController {
            id:                 guidedActionsController
            missionController:  _missionController
            actionList:         _guidedActionList
            altitudeSlider:     _guidedAltSlider
        }

        GuidedActionList {
            id:                         guidedActionList
            anchors.margins:            _margins
            anchors.bottom:             parent.bottom
            anchors.horizontalCenter:   parent.horizontalCenter
            z:                          QGroundControl.zOrderTopMost
            guidedController:           _guidedController
        }

        GuidedAltitudeSlider {
            id:                 guidedAltSlider
            anchors.margins:    _toolsMargin
            anchors.right:      parent.right
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            z:                  QGroundControl.zOrderTopMost
            radius:             ScreenTools.defaultFontPixelWidth / 2
            width:              ScreenTools.defaultFontPixelWidth * 10
            color:              qgcPal.window
            visible:            false
        }

        FlyViewMap {
            id:                     mapControl
            planMasterController:   _planController
            rightPanelWidth:        ScreenTools.defaultFrontPixelHeight * 9
            pipMode:                !_mainWindowIsMap
            toolInsets:             customOverlay.totalToolInsets
            mapName:                "FlightDisplayView"
        }

        FlyViewVideo {
            id: videoControl
        }

        QGCPipOverlay {
            id:                     _pipOverlay
            anchors.left:           parent.left
            anchors.bottom:         parent.bottom
            anchors.margins:        _toolsMargin
            item1IsFullSettingsKey: "MainFlyWindowIsMap"
            item1:                  mapControl
            item2:                  QGroundControl.videoManager.hasVideo ? videoControl : null
            fullZOrder:             _fullItemZorder
            pipZOrder:              _pipItemZorder
            show:                   !QGroundControl.videoManager.fullScreen &&
                                        (videoControl.pipState.state === videoControl.pipState.pipState || mapControl.pipState.state === mapControl.pipState.pipState)
        }
    }

    //Dashboard overlay
    Rectangle {
        id: dashboardOverlay
        anchors.fill: parent
        z: 1000
        visible: _root.dashboardVisible

        // Background
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#2e2e2e" }
                GradientStop { position: 0.5; color: "#3a3a3a" }
                GradientStop { position: 1.0; color: "#2e2e2e" }
            }
        }

        ScrollView {
            anchors.fill: parent
            anchors.margins: 20
            contentWidth: availableWidth

            Column {
                width: parent.width
                spacing: 20

                // Title Section
                Rectangle {
                    width: parent.width
                    height: 50
                    radius: 10
                    color: "#4a90e2"
                    opacity: 0.9

                    Text {
                        anchors.centerIn: parent
                        text: "INDRONES - DRONE STATUS MONITOR"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                }

                // Connection Status
                Rectangle {
                    width: parent.width
                    height: 45
                    radius: 8
                    color: QGroundControl.multiVehicleManager.activeVehicle ? "#5cb85c" : "#d9534f"
                    opacity: 0.9

                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: "#ffffff"
                            opacity: 0.9
                        }

                        Text {
                            text: QGroundControl.multiVehicleManager.activeVehicle ? "DRONE CONNECTED" : "DRONE DISCONNECTED"
                            font.bold: true
                            color: "#ffffff"
                            font.pixelSize: 14
                        }
                    }
                }


                Rectangle {
                    width: parent.width
                    height: 350
                    radius: 12
                    color: "#4a4a4a"
                    opacity: 0.95

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15

                        // Grid Layout
                        Grid {
                            anchors.horizontalCenter: parent.horizontalCenter
                            columns: 3
                            columnSpacing: 15
                            rowSpacing: 10
                            width: parent.width - 20

                            // Position Data Cards
                            Rectangle {
                                width: 180; height: 30; radius: 6
                                color: "#3c3c3c"; opacity: 0.9
                                Row {
                                    anchors.fill: parent; anchors.margins: 6; spacing: 8
                                    Text { text: "Latitude:"; color: "#4a90e2"; font.bold: true; width: 70; font.pixelSize: 14 }
                                    Text {
                                        text: QGroundControl.multiVehicleManager.activeVehicle ?
                                              QGroundControl.multiVehicleManager.activeVehicle.coordinate.latitude.toFixed(6) : "N/A"
                                        color: "#d0d0d0"; font.pixelSize: 13
                                    }
                                }
                            }

                            Rectangle {
                                width: 180; height: 35; radius: 6
                                color: "#3c3c3c"; opacity: 0.9
                                Row {
                                    anchors.fill: parent; anchors.margins: 6; spacing: 8
                                    Text { text: "Longitude:"; color: "#4a90e2"; font.bold: true; width: 70; font.pixelSize: 11 }
                                    Text {
                                        text: QGroundControl.multiVehicleManager.activeVehicle ?
                                              QGroundControl.multiVehicleManager.activeVehicle.coordinate.longitude.toFixed(6) : "N/A"
                                        color: "#d0d0d0"; font.pixelSize: 11
                                    }
                                }
                            }

                            Rectangle {
                                width: 180; height: 35; radius: 6
                                color: "#3c3c3c"; opacity: 0.9
                                Row {
                                    anchors.fill: parent; anchors.margins: 6; spacing: 8
                                    Text { text: "Altitude:"; color: "#4a90e2"; font.bold: true; width: 70; font.pixelSize: 11 }
                                    Text {
                                        text: QGroundControl.multiVehicleManager.activeVehicle ?
                                              QGroundControl.multiVehicleManager.activeVehicle.altitudeRelative.value.toFixed(1) + "m" : "N/A"
                                        color: "#d0d0d0"; font.pixelSize: 11
                                    }
                                }
                            }

                            Rectangle {
                                width: 180; height: 35; radius: 6
                                color: "#3c3c3c"; opacity: 0.9
                                Row {
                                    anchors.fill: parent; anchors.margins: 6; spacing: 8
                                    Text { text: "Ground Spd:"; color: "#4a90e2"; font.bold: true; width: 70; font.pixelSize: 11 }
                                    Text {
                                        text: QGroundControl.multiVehicleManager.activeVehicle ?
                                              QGroundControl.multiVehicleManager.activeVehicle.groundSpeed.value.toFixed(1) + "m/s" : "N/A"
                                        color: "#d0d0d0"; font.pixelSize: 11
                                    }
                                }
                            }

                            Rectangle {
                                width: 180; height: 35; radius: 6
                                color: "#3c3c3c"; opacity: 0.9
                                Row {
                                    anchors.fill: parent; anchors.margins: 6; spacing: 8
                                    Text { text: "Air Speed:"; color: "#4a90e2"; font.bold: true; width: 70; font.pixelSize: 11 }
                                    Text {
                                        text: QGroundControl.multiVehicleManager.activeVehicle ?
                                              QGroundControl.multiVehicleManager.activeVehicle.airSpeed.value.toFixed(1) + "m/s" : "N/A"
                                        color: "#d0d0d0"; font.pixelSize: 11
                                    }
                                }
                            }

                            Rectangle {
                                width: 180; height: 35; radius: 6
                                color: "#3c3c3c"; opacity: 0.9
                                Row {
                                    anchors.fill: parent; anchors.margins: 6; spacing: 8
                                    Text { text: "Heading:"; color: "#4a90e2"; font.bold: true; width: 70; font.pixelSize: 11 }
                                    Text {
                                        text: QGroundControl.multiVehicleManager.activeVehicle ?
                                              QGroundControl.multiVehicleManager.activeVehicle.compass.heading.value+ "°" : "N/A"
                                        color: "#d0d0d0"; font.pixelSize: 11
                                    }
                                }
                            }

                            // System Status Cards
                            Rectangle {
                                width: 180; height: 35; radius: 6
                                color: "#3c3c3c"; opacity: 0.9
                                Row {
                                    anchors.fill: parent; anchors.margins: 6; spacing: 8
                                    Text { text: "Armed:"; color: "#4a90e2"; font.bold: true; width: 70; font.pixelSize: 11 }
                                    Text {
                                        text: QGroundControl.multiVehicleManager.activeVehicle &&
                                              QGroundControl.multiVehicleManager.activeVehicle.armed ? "YES" : "NO"
                                        color: QGroundControl.multiVehicleManager.activeVehicle &&
                                               QGroundControl.multiVehicleManager.activeVehicle.armed ? "#d9534f" : "#5cb85c"
                                        font.bold: true; font.pixelSize: 11
                                    }
                                }
                            }

                            Rectangle {
                                width: 180; height: 34; radius: 6
                                color: "#3c3c3c"; opacity: 0.9
                                Row {
                                    anchors.fill: parent; anchors.margins: 6; spacing: 8
                                    Text { text: "Flight Mode:"; color: "#4a90e2"; font.bold: true; width: 70; font.pixelSize: 11 }
                                    Text {
                                        text: QGroundControl.multiVehicleManager.activeVehicle ?
                                              QGroundControl.multiVehicleManager.activeVehicle.flightMode : "N/A"
                                        color: "#d0d0d0"; font.bold: true; font.pixelSize: 11
                                    }
                                }
                            }

                            Rectangle {
                                width: 180; height: 35; radius: 6
                                color: "#3c3c3c"; opacity: 0.9
                                Row {
                                    anchors.fill: parent; anchors.margins: 6; spacing: 8
                                    Text { text: "Battery:"; color: "#4a90e2"; font.bold: true; width: 70; font.pixelSize: 11 }
                                    Text {
                                        text: QGroundControl.multiVehicleManager.activeVehicle ?
                                              Math.round(QGroundControl.multiVehicleManager.activeVehicle.battery.percentRemaining.value) + "%" : "N/A"
                                        color: {
                                            var batteryPercent = QGroundControl.multiVehicleManager.activeVehicle ?
                                                                QGroundControl.multiVehicleManager.activeVehicle.battery.percentRemaining.value : 0
                                            if (batteryPercent > 50) return "#5cb85c"
                                            else if (batteryPercent > 20) return "#f0ad4e"
                                            else return "#d9534f"
                                        }
                                        font.bold: true; font.pixelSize: 11
                                    }
                                }
                            }

                            Rectangle {
                                width: 180; height: 35; radius: 6
                                color: "#3c3c3c"; opacity: 0.9
                                Row {
                                    anchors.fill: parent; anchors.margins: 6; spacing: 8
                                    Text { text: "GPS Sats:"; color: "#4a90e2"; font.bold: true; width: 70; font.pixelSize: 11 }
                                    Text {
                                        text: QGroundControl.multiVehicleManager.activeVehicle ?
                                              QGroundControl.multiVehicleManager.activeVehicle.gps.count.value.toString() : "N/A"
                                        color: "#d0d0d0"; font.pixelSize: 11
                                    }
                                }
                            }

                            Rectangle {
                                width: 180; height: 35; radius: 6
                                color: "#3c3c3c"; opacity: 0.9
                                Row {
                                    anchors.fill: parent; anchors.margins: 6; spacing: 8
                                    Text { text: "GPS HDOP:"; color: "#4a90e2"; font.bold: true; width: 70; font.pixelSize: 11 }
                                    Text {
                                        text: QGroundControl.multiVehicleManager.activeVehicle ?
                                              QGroundControl.multiVehicleManager.activeVehicle.gps.hdop.value.toFixed(1) : "N/A"
                                        color: "#d0d0d0"; font.pixelSize: 11
                                    }
                                }
                            }

                            Rectangle {
                                width: 180; height: 35; radius: 6
                                color: "#3c3c3c"; opacity: 0.9
                                Row {
                                    anchors.fill: parent; anchors.margins: 6; spacing: 8
                                    Text { text: "Vibration:"; color: "#4a90e2"; font.bold: true; width: 70; font.pixelSize: 11 }
                                    Text {
                                        text: QGroundControl.multiVehicleManager.activeVehicle ?
                                              QGroundControl.multiVehicleManager.activeVehicle.vibration.xAxis.value.toFixed(2) : "N/A"
                                        color: "#d0d0d0"; font.pixelSize: 11
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutQuart
            }
        }
        opacity: visible ? 1 : 0
    }
}
