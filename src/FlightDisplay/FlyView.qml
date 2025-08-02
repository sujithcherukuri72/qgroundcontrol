/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

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

    //-- Altitude slider
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
        rightPanelWidth:        ScreenTools.defaultFontPixelHeight * 9
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
    //instance of an LogFileHelper
    LogFileHelper { id: logHelper }


    // Local Log Files Model - Fixed path for cross-platform compatibility
    Dialog {
            id: logUploadDialog
            width: parent.width * 0.8
            height: parent.height * 0.8
            title: "Log Files"
            standardButtons: Dialog.Close

            property var logFiles: []

            function reloadLogs() {
                const logDir = StandardPaths.homeLocation + "/QGroundControl/Logs"
                logFiles = logHelper.getBinFiles(logDir)
            }

            contentItem: Column {
                spacing: 10; padding: 10

                Button { text: "Refresh"; onClicked: reloadLogs() }

                ListView {
                    id: fileList
                    width: parent.width; height: parent.height - 120
                    model: logUploadDialog.logFiles
                    delegate: Row {
                        width: parent.width; height: 40; spacing: 10
                        Text { text: modelData; elide: Text.ElideRight; width: parent.width * 0.6 }
                        Button {
                            text: "Upload"
                            onClicked: console.log("Uploading", modelData)
                        }
                        Button {
                            text: "Remove"
                            onClicked: {
                                logUploadDialog.logFiles.splice(index,1)
                                fileList.model = logUploadDialog.logFiles  // refresh
                            }
                        }
                    }
                }
            }
        }
    // Log Files Display Popup (log files data)
    Popup {
            id: logFilesDialog
            width: 600; height: 400
            anchors.centerIn: parent
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
            //acceptedButtons: Popup.NoButton

            Rectangle {
                anchors.fill: parent
                color: "#2d2d2d"; border.color: "#FFC107"; border.width: 2; radius: 10

                Column {
                    anchors.fill: parent; anchors.margins: 20; spacing: 10
                    Text { text: "Select Flight Log Files"; font.pixelSize: 18; font.weight: Font.Bold; color: "#FFC107" }

                    Row {
                        spacing: 10
                        Text { text: "Filter:"; color: "white"; anchors.verticalCenter: parent.verticalCenter }
                        ComboBox {
                            id: filterCombo; width: 150
                            model: ["All Files",".bin files",".log files",".ulg files"]
                            onCurrentTextChanged: {
                                switch(currentText) {
                                    case "All Files": logFilesModel.nameFilters = ["*.bin","*.log","*.ulg"]; break
                                    case ".bin files": logFilesModel.nameFilters = ["*.bin"]; break
                                    case ".log files": logFilesModel.nameFilters = ["*.log"]; break
                                    case ".ulg files": logFilesModel.nameFilters = ["*.ulg"]; break
                                }
                            }
                        }
                        Button { text: "Close"; onClicked: logFilesDialog.close() }
                    }

                    ScrollView {
                        width: parent.width; height: parent.height - 120
                        ListView {
                            id: logView; model: logFilesModel; currentIndex: 0
                            delegate: Rectangle {
                                width: logView.width; height: 50; radius: 5
                                color: hoverMouse.containsMouse ? "#FFC107" : "#3d3d3d"
                                border.color: "#555555"; border.width: 1
                                Row {
                                    anchors.left: parent.left; anchors.leftMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter; spacing: 15
                                    Text { text: "📄"; font.pixelSize: 16 }
                                    Column {
                                        Text { text: model.fileName; color: "white"; font.pixelSize: 12; font.weight: Font.Bold }
                                        Text { text: "Size: " + ((model.fileSize||0)/1024).toFixed(1) + " KB"
                                               color: "#cccccc"; font.pixelSize: 9 }
                                    }
                                }
                                MouseArea { id: hoverMouse; anchors.fill: parent; hoverEnabled: true
                                            onClicked: { console.log("Selected log:", model.fileName); logFilesDialog.close() } }
                            }
                        }
                    }
                    Text {
                        id: emptyHint
                        text: "No log files found."
                        color: "#888888"; font.pixelSize: 11
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: logFilesModel.count === 0
                        Connections { target: logFilesModel; onCountChanged: emptyHint.visible = logFilesModel.count === 0 }
                    }
                }
            }
        }
    // Communication Connections Popup (Live connections)
    Popup {
            id: connectionsDialog
            width: 520; height: 480
            anchors.centerIn: parent
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

            property var lm: QGroundControl.linkManager
            property int token: 0
            function refresh() { token++ }

            Connections {
                target: lm
                onLinkAdded:        refresh()
                onLinkDeleted:      refresh()
                onLinkConnected:    refresh()
                onLinkDisconnected: refresh()
            }

            Rectangle {
                anchors.fill: parent; color: "#2d2d2d"
                border.color: "#FFC107"; border.width: 2; radius: 10

                Column {
                    anchors.fill: parent; anchors.margins: 20; spacing: 15
                    Text { text: "Communication Connections"; font.pixelSize: 18; font.weight: Font.Bold; color: "#FFC107" }

                    Rectangle {
                        width: parent.width; height: 310
                        color: "#3d3d3d"; border.color: "#555555"; border.width: 1; radius: 8

                        Column {
                            anchors.fill: parent; anchors.margins: 10; spacing: 8
                            Text { text: "Saved & Detected Links"; font.pixelSize: 14; font.weight: Font.Bold; color: "white" }

                            ListView {
                                id: linkList; width: parent.width; height: 260
                                model: token
                                delegate: Component {
                                    Rectangle {
                                        width: linkList.width; height: 38; radius: 4
                                        color: mouse.containsMouse ? "#FFC10733" : "transparent"

                                        property var linkObj: QGroundControl.linkManager.links.get(index)
                                        property var cfg: linkObj.configuration

                                        Row {
                                            property var linkObj: QGroundControl.linkManager.links.get(index)
                                            property var cfg: linkObj.configuration

                                            anchors.left: parent.left; anchors.leftMargin: 10
                                            anchors.verticalCenter: parent.verticalCenter; spacing: 15
                                            Rectangle { width: 8; height: 8; radius: 4
                                                color: linkObj.connected ? "#4CAF50" : "#666666" }
                                            Text { text: cfg.name; color: "white"; font.weight: Font.Bold; width: 120 }
                                            Text { text: cfg.portName || ""; color: "#cccccc"; width: 120 }
                                            Text { text: cfg.baudRate ? cfg.baudRate + " bps" : "";
                                                   color: "#999999"; font.pixelSize: 10 }
                                        }
                                        MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true
                                            onClicked: {
                                                if (!linkObj.connected)
                                                    QGroundControl.linkManager.connectLink(cfg.name)
                                                else
                                                    QGroundControl.linkManager.disconnectLink(cfg.name)
                                            } }
                                    }
                                }
                            }

                            Text {
                                visible: lm.links.count === 0
                                text: "No links configured or detected."
                                color: "#cccccc"; font.pixelSize: 11
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter; spacing: 10
                        Button { text: "Scan Ports"; onClicked: lm.refreshSerialPorts() }
                        Button { text: "Close"; onClicked: connectionsDialog.close() }
                    }
                }
            }
        }
    // Dashboard overlay code (UI)
    Rectangle {
            id: dashboardOverlay
            anchors.fill: parent; z: 1000
            property bool showDashboard: true
            visible: showDashboard

            gradient: Gradient {
                GradientStop { position: 0; color: "#1a1a1a" }
                GradientStop { position: 0.5; color: "#2d2d2d" }
                GradientStop { position: 1; color: "#1a1a1a" }
            }

            /* Logo bar */
            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 80; color: "#FFC107"
                Row {
                    anchors.centerIn: parent; spacing: 15
                    Rectangle { width: 60; height: 40; radius: 5; color: "#1a1a1a"
                        Text { anchors.centerIn: parent; text: "Indrones"; color: "#FFC107"
                               font.pixelSize: 14; font.weight: Font.Bold } }
                    Column {
                        Text { text: "Indrones"; font.pixelSize: 24; font.weight: Font.Bold; color: "#1a1a1a" }
                        Text { text: "DRONES AT WORK"; font.pixelSize: 10; color: "#333333"; font.weight: Font.Medium }
                    }
                }
            }

            Column {
                anchors.centerIn: parent; anchors.verticalCenterOffset: 40; spacing: 30

                /* Connection pill */
                Rectangle {
                    width: 200; height: 40; radius: 20
                    color: QGroundControl.multiVehicleManager.activeVehicle ? "#4CAF50" : "#f44336"
                    Row {
                        anchors.centerIn: parent; spacing: 8
                        Rectangle { width: 8; height: 8; radius: 4; color: "white"
                            SequentialAnimation on opacity {
                                running: QGroundControl.multiVehicleManager.activeVehicle
                                loops: Animation.Infinite
                                NumberAnimation { from: 1; to: 0.3; duration: 800 }
                                NumberAnimation { from: 0.3; to: 1; duration: 800 }
                            } }
                        Text { text: QGroundControl.multiVehicleManager.activeVehicle
                                      ? "DRONE CONNECTED" : "DRONE OFFLINE"
                               font.pixelSize: 12; font.weight: Font.Bold; color: "white" }
                    }
                }

                /* Three-card row */
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter; spacing: 20

                    /* Log card */
                    Rectangle {
                        width: 180; height: 140; radius: 12; color: "#2d2d2d"
                        border.color: logMouse.containsMouse ? "#FFC107" : "#555555"; border.width: 2
                        Column {
                            anchors.centerIn: parent; spacing: 12
                            Rectangle { width: 40; height: 40; radius: 20; color: "#FFC107"
                                Text { text: "📂"; anchors.centerIn: parent; font.pixelSize: 18 } }
                            Text { text: "LOG UPLOAD"; font.pixelSize: 12; font.weight: Font.Bold; color: "white" }
                            Text { text: "Browse local logs\n(.bin, .log, .ulg)"; font.pixelSize: 9; color: "#cccccc"
                                   horizontalAlignment: Text.AlignHCenter }
                        }
                        MouseArea { id: logMouse; anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor; onClicked: logFilesDialog.open() }
                    }

                    /* Connection card */
                    Rectangle {
                        width: 180; height: 140; radius: 12; color: "#2d2d2d"
                        border.color: connMouse.containsMouse ? "#FFC107" : "#555555"; border.width: 2
                        Column {
                            anchors.centerIn: parent; spacing: 12
                            Rectangle { width: 40; height: 40; radius: 20; color: "#4CAF50"
                                Text { text: "📡"; anchors.centerIn: parent; font.pixelSize: 18 } }
                            Text { text: "CONNECT"; font.pixelSize: 12; font.weight: Font.Bold; color: "white" }
                            Text { text: "COM ports & network\nconnections"; font.pixelSize: 9; color: "#cccccc"
                                   horizontalAlignment: Text.AlignHCenter }
                        }
                        MouseArea { id: connMouse; anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor; onClicked: connectionsDialog.open() }
                    }

                    /* Device-status card */
                    Rectangle {
                        id: devCard; width: 180; height: 180; radius: 12; color: "#2d2d2d"
                        border.color: devMouse.containsMouse ? "#FFC107" : "#555555"; border.width: 2
                        property var veh: QGroundControl.multiVehicleManager.activeVehicle

                        Column {
                            anchors.centerIn: parent; spacing: 10 ;
                            Rectangle { width: 40; height: 40; radius: 20
                                color: QGroundControl.multiVehicleManager.activeVehicle ? "#2196F3" : "#666666"
                                Text { text: "🛩️"; anchors.centerIn: parent; font.pixelSize: 18 } }
                            Text { text: "DEVICE STATUS"; font.pixelSize: 12; font.weight: Font.Bold; color: "white" }

                            Text { id: fwLine; font.pixelSize: 9; color: "#cccccc"
                                   text: QGroundControl.multiVehicleManager.activeVehicle ? "FW: " + QGroundControl.multiVehicleManager.activeVehicle.firmwareTypeString + " " + QGroundControl.multiVehicleManager.activeVehicle.firmwareVersion : "FW: —" }
                            Text { id: battLine; font.pixelSize: 9; color: "#cccccc"
                                   text: QGroundControl.multiVehicleManager.activeVehicle ? "Batt: " + QGroundControl.multiVehicleManager.activeVehicle.battery.percentRemaining.value.toFixed(0) + "% (" +
                                                   QGroundControl.multiVehicleManager.activeVehicle.battery.voltage.value.toFixed(1) + "V)" : "Batt: —" }
                            Text { id: satLine; font.pixelSize: 9; color: "#cccccc"
                                   text: QGroundControl.multiVehicleManager.activeVehicle ? "Sat: " + QGroundControl.multiVehicleManager.activeVehicle.satellitesVisible.value + "  HDOP:" +
                                                   QGroundControl.multiVehicleManager.activeVehicle.satelliteHDOP.value.toFixed(1) : "Sat: —" }
                            Text { id: rssiLine; font.pixelSize: 9; color: "#cccccc"
                                   text: QGroundControl.multiVehicleManager.activeVehicle ? "Signal: " + QGroundControl.multiVehicleManager.activeVehicle.telemetryLRSSI.value + "dBm" : "Signal: —" }
                        }
                        MouseArea { id: devMouse; anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor }

                        /* live fact updates */
                        Connections { target: QGroundControl.multiVehicleManager.activeVehicle ? QGroundControl.multiVehicleManager.activeVehicle.battery.percentRemaining : null
                            onValueChanged: battLine.text =
                                "Batt: " + QGroundControl.multiVehicleManager.activeVehicle.battery.percentRemaining.value.toFixed(0) + "% (" +
                                QGroundControl.multiVehicleManager.activeVehicle.battery.voltage.value.toFixed(1) + "V)" }
                        Connections { target: QGroundControl.multiVehicleManager.activeVehicle ? QGroundControl.multiVehicleManager.activeVehicle.satellitesVisible : null
                            onValueChanged: satLine.text =
                                "Sat: " + QGroundControl.multiVehicleManager.activeVehicle.satellitesVisible.value + "  HDOP:" +
                                QGroundControl.multiVehicleManager.activeVehicle.satelliteHDOP.value.toFixed(1) }
                        Connections { target: QGroundControl.multiVehicleManager.activeVehicle ? QGroundControl.multiVehicleManager.activeVehicle.telemetryLRSSI : null
                            onValueChanged: rssiLine.text =
                                "Signal: " + QGroundControl.multiVehicleManager.activeVehicle.telemetryLRSSI.value + "dBm" }
                        Connections { target: QGroundControl.multiVehicleManager.activeVehicle ? QGroundControl.multiVehicleManager.activeVehicle : null
                            onFirmwareVersionChanged: fwLine.text =
                                "FW: " + QGroundControl.multiVehicleManager.activeVehicle.firmwareTypeString + " " + QGroundControl.multiVehicleManager.activeVehicle.firmwareVersion }
                    }
                }

                /* Launch mission */
                Rectangle {
                    width: 220; height: 50; radius: 25
                    color: launchMouse.pressed ? "#FF9800"
                          : (launchMouse.containsMouse ? "#FFD54F" : "#FFC107")
                    scale: launchMouse.pressed ? 0.95 : (launchMouse.containsMouse ? 1.02 : 1)
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    Row { anchors.centerIn: parent; spacing: 10
                        Text { text: "LAUNCH MISSION"; font.pixelSize: 14; font.weight: Font.Bold; color: "#1a1a1a" } }
                    MouseArea { id: launchMouse; anchors.fill: parent; hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { dashboardOverlay.showDashboard = false } }
                }
            }

            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutQuart } }
            opacity: visible ? 1 : 0
        }
}
