import QtQuick 2.15
import QtQuick.Controls 2.15
import QGroundControl    1.0               // For QGC types/objects if used
import QGroundControl.Controls 1.0      // For styling, if required

Rectangle {
    id: startupOverlay
    anchors.fill: parent
    color: "#1a1a1a"
    visible: overlayVisible
    z: 9999
    opacity: 1.0

    property bool overlayVisible: true           // Controls overlay visibility
    property var logHelper                      // Expose your log helper from C++
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    // -- Background gradient
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0f172a" }
            GradientStop { position: 0.5; color: "#1e293b" }
            GradientStop { position: 1.0; color: "#334155" }
        }
    }

    // -- Hero Section
    Rectangle {
        width: parent.width
        height: parent.height * 0.75
        color: "transparent"
        clip: true

        // Hero image overlay
        Rectangle {
            anchors.fill: parent
            color: "#000"
            Image {
                anchors.fill: parent
                source: "qrc:/qmlimages/homepage.jpg"  // <-- YOUR DASHBOARD IMAGE
                fillMode: Image.PreserveAspectCrop
                opacity: 0.7
            }
            Rectangle {
                anchors.fill: parent
                color: "#000"
                opacity: 0.4
            }
        }

        // Hero Content
        Column {
            anchors.centerIn: parent
            spacing: 30

            Text {
                text: "INDRONESCOMMAND CENTER"
                font.pixelSize: 48
                font.weight: Font.Bold
                color: "#ffffff"
                opacity: 0
                NumberAnimation on opacity { from: 0; to: 1; duration: 1000; }
            }
            Text {
                text: "Advanced Aerial Operations & Fleet Management"
                font.pixelSize: 18
                color: "#e2e8f0"
                opacity: 0
                NumberAnimation on opacity { from: 0; to: 1; duration: 1000; delay: 300; }
            }
            Rectangle {
                width: 200
                height: 40
                radius: 20
                color: _activeVehicle ? "#10b981" : "#ef4444"
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0
                NumberAnimation on opacity { from: 0; to: 1; duration: 1000; delay: 600;}
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Rectangle {
                        width: 8; height: 8; radius: 4; color: "#fff"
                        SequentialAnimation on opacity {
                            running: _activeVehicle !== null
                            loops: Animation.Infinite
                            NumberAnimation { from: 1; to: 0.3; duration: 800 }
                            NumberAnimation { from: 0.3; to: 1; duration: 800 }
                        }
                    }
                    Text {
                        text: _activeVehicle ? "AIRCRAFT CONNECTED" : "AIRCRAFT OFFLINE"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: "#fff"
                    }
                }
            }
        }
    }

    // -- Control Panel Section
    Rectangle {
        width: parent.width
        height: parent.height * 0.25
        color: "#0f172a"
        border.color: "#334155"
        border.width: 1
        anchors.bottom: parent.bottom

        Row {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 30

            // LOG UPLOAD CARD
            Rectangle {
                id: logCard
                width: 320
                height: parent.height - 20
                radius: 16
                color: "#1e293b"
                border.color: "#475569"
                border.width: 1
                property bool hovered: false
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on scale { NumberAnimation { duration: 200 } }
                scale: hovered ? 1.05 : 1.0
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#3b82f6" }
                        GradientStop { position: 1.0; color: "#1d4ed8" }
                    }
                    opacity: logCard.hovered ? 0.1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: logCard.hovered = true
                    onExited: logCard.hovered = false
                    onClicked: {
                        logUploadDialog.logFiles = logHelper.getBinFiles("C:/Users/gfhgd/OneDrive/Desktop/binfiles")
                        logUploadDialog.open()
                    }
                }
                Column {
                    anchors.centerIn: parent
                    spacing: 15
                    Rectangle { width: 48; height: 48; radius: 24; color: "#3b82f6";
                        Text { text: "📊"; font.pixelSize: 24; anchors.centerIn: parent }
                    }
                    Text { text: "Log Upload"; font.pixelSize: 18; font.weight: Font.Bold; color: "#f8fafc" }
                    Text { text: "Upload flight data & telemetry"; font.pixelSize: 12; color: "#94a3b8" }
                }
            }

            // DEVICE INFO CARD
            Rectangle {
                id: deviceCard
                width: 320
                height: parent.height - 20
                radius: 16
                color: "#1e293b"
                border.color: "#475569"
                border.width: 1
                property bool hovered: false
                Behavior on scale { NumberAnimation { duration: 200 } }
                scale: hovered ? 1.05 : 1.0
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#10b981" }
                        GradientStop { position: 1.0; color: "#059669" }
                    }
                    opacity: deviceCard.hovered ? 0.1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        deviceCard.hovered = true
                        versionInfoLabel.text =
                            "Firmware: " +
                            (_activeVehicle ?
                              _activeVehicle.firmwareMajorVersion + "." +
                              _activeVehicle.firmwareMinorVersion + "." +
                              _activeVehicle.firmwarePatchVersion : "N/A") +
                            "\nApp: " + QGroundControl.qgcVersion
                    }
                    onExited: {
                        deviceCard.hovered = false
                        versionInfoLabel.text = "System Status: Operational"
                    }
                }
                Column {
                    anchors.centerIn: parent
                    spacing: 15
                    Rectangle { width: 48; height: 48; radius: 24; color: "#10b981";
                        Text { text: "⚙️"; font.pixelSize: 24; anchors.centerIn: parent }
                    }
                    Text { text: "Device Management"; font.pixelSize: 18; font.weight: Font.Bold; color: "#f8fafc" }
                    Text {
                        id: versionInfoLabel
                        text: "System Status: Operational"
                        font.pixelSize: 12; color: "#94a3b8"; horizontalAlignment: Text.AlignHCenter; width: 280
                        anchors.horizontalCenter: parent.horizontalCenter;
                        wrapMode: Text.Wrap
                    }
                }
            }

            // CONNECTION AND LAUNCH CARD
            Rectangle {
                id: connectionCard
                width: parent.width - 680
                height: parent.height - 20
                radius: 16
                color: "#1e293b"
                border.color: "#475569"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 30

                    // Connection Status
                    Column {
                        width: parent.width * 0.6
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10
                        Row {
                            spacing: 15; anchors.horizontalCenter: parent.horizontalCenter
                            Rectangle {
                                width: 12; height: 12; radius: 6
                                color: {
                                    var v = _activeVehicle
                                    var q = v ? v.rcRSSI : -1
                                    if (q >= 200) return "#10b981"
                                    if (q >= 150) return "#f59e0b"
                                    return "#ef4444"
                                }
                                SequentialAnimation on opacity {
                                    running: _activeVehicle !== null
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 1; to: 0.3; duration: 1000 }
                                    NumberAnimation { from: 0.3; to: 1; duration: 1000 }
                                }
                            }
                            Text {
                                font.pixelSize: 16;
                                font.weight: Font.Bold
                                color: {
                                    var v = _activeVehicle
                                    var q = v ? v.rcRSSI : -1
                                    if (q >= 200) return "#10b981"
                                    if (q >= 150) return "#f59e0b"
                                    return "#ef4444"
                                }
                                text: {
                                    var v = _activeVehicle
                                    var q = v ? v.rcRSSI : -1
                                    if (!v) return "Aircraft Offline"
                                    if (q >= 200) return "Aircraft Connected"
                                    if (q >= 150) return "Weak Signal"
                                    return "Connection Lost"
                                }
                            }
                        }
                        Text {
                            text: {
                                var v = _activeVehicle
                                var q = v ? v.rcRSSI : -1
                                return "Signal: " + ((q / 255) * 100).toFixed(1) + "%"
                            }
                            font.pixelSize: 12; color: "#94a3b8"; anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    // ---- LAUNCH / BEGIN BUTTON ----
                    Rectangle {
                        id: beginButton
                        width: 200; height: 60; radius: 12; anchors.verticalCenter: parent.verticalCenter
                        property bool hovered: false
                        property bool pressed: false
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: beginButton.pressed ? "#dc2626" : (beginButton.hovered ? "#f97316" : "#ea580c") }
                            GradientStop { position: 1.0; color: beginButton.pressed ? "#b91c1c" : (beginButton.hovered ? "#ea580c" : "#c2410c") }
                        }
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        scale: pressed ? 0.95 : (hovered ? 1.05 : 1.0)
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: "transparent"
                            border.color: "#f97316"
                            border.width: hovered ? 2 : 0
                            opacity: hovered ? 0.5 : 0
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }
                        Row {
                            anchors.centerIn: parent
                            spacing: 10
                            Text { text: "🚁"; font.pixelSize: 20 }
                            Text { text: "LAUNCH MISSION"; font.pixelSize: 14; font.weight: Font.Bold; color: "#fff" }
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: beginButton.hovered = true
                            onExited: beginButton.hovered = false
                            onPressed: beginButton.pressed = true
                            onReleased: beginButton.pressed = false
                            onClicked: {
                                beginButton.scale = 0.9
                                scaleBackAnimation.start()
                                fadeOutAnim.start()
                            }
                        }
                        NumberAnimation {
                            id: scaleBackAnimation
                            target: beginButton
                            property: "scale"
                            from: 0.9; to: 1.0; duration: 150
                        }
                    }
                }
            }
        }
    }

    // ---- LOG UPLOAD DIALOG ----
    Dialog {
        id: logUploadDialog
        width: parent.width * 0.8
        height: parent.height * 0.8
        modal: true
        property var logFiles: []
        background: Rectangle {
            color: "#1e293b"
            radius: 12
            border.color: "#475569"
            border.width: 1
        }
        header: Rectangle {
            width: parent.width; height: 60; color: "#0f172a"; radius: 12
            Text { text: "📊 Flight Data Management"; font.pixelSize: 20; font.weight: Font.Bold; color: "#f8fafc"; anchors.centerIn: parent }
        }
        function uploadToCloud(filePath) { console.log("Uploading:", filePath); return true }
        contentItem: Column {
            spacing: 20
            anchors.margins: 20
            Text { text: "Select log files to upload to cloud storage"; font.pixelSize: 14; color: "#94a3b8" }
            ScrollView {
                width: parent.width; height: parent.height - 100
                ListView {
                    id: logFileList
                    model: logUploadDialog.logFiles
                    spacing: 15
                    delegate: Rectangle {
                        width: parent.width
                        height: 60
                        radius: 8
                        color: "#334155"
                        border.color: "#475569"
                        border.width: 1
                        Row {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 15
                            Rectangle { width: 30; height: 30; radius: 15; color: "#3b82f6";
                                Text { text: "📄"; font.pixelSize: 16; anchors.centerIn: parent }
                            }
                            Text {
                                text: modelData
                                width: parent.width * 0.5
                                elide: Text.ElideRight
                                color: "#f8fafc"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Row {
                                spacing: 10; anchors.verticalCenter: parent.verticalCenter
                                Rectangle {
                                    width: 80; height: 32; radius: 6; color: "#10b981"
                                    Text { text: "Upload"; color: "white"; font.pixelSize: 12; font.weight: Font.Bold; anchors.centerIn: parent }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (logUploadDialog.uploadToCloud(modelData)) {
                                                logUploadDialog.logFiles.splice(index, 1)
                                                logUploadDialog.logFiles = logUploadDialog.logFiles.slice()
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    width: 80; height: 32; radius: 6; color: "#ef4444"
                                    Text { text: "Remove"; color: "white"; font.pixelSize: 12; font.weight: Font.Bold; anchors.centerIn: parent }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            logUploadDialog.logFiles.splice(index, 1)
                                            logUploadDialog.logFiles = logUploadDialog.logFiles.slice()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        footer: Rectangle {
            width: parent.width; height: 50; color: "#0f172a"
            Rectangle {
                width: 100; height: 35; radius: 6; color: "#475569"; anchors.centerIn: parent
                Text { text: "Close"; color: "#f8fafc"; font.pixelSize: 14; font.weight: Font.Bold; anchors.centerIn: parent }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: logUploadDialog.close() }
            }
        }
    }

    // ---- FADE OUT ANIMATION ----
    SequentialAnimation {
        id: fadeOutAnim
        running: false
        ParallelAnimation {
            PropertyAnimation { target: startupOverlay; property: "opacity"; from: 1; to: 0; duration: 800 }
            PropertyAnimation { target: startupOverlay; property: "scale"; from: 1; to: 0.9; duration: 800 }
        }
        ScriptAction { script: startupOverlay.overlayVisible = false }
    }
}
