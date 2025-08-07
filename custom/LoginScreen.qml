// LoginScreen.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Rectangle {
    id: loginScreen
    anchors.fill: parent
    //pre requisites like colors and variables
    property bool showLogin: !loginManager.isLoggedIn
    property color primaryColor: "#1B4B8C"
    property color secondaryColor: "#3D7EDB"
    property color accentColor: "#FF6B35"
    property color backgroundColor: "#F8FAFC"
    property color textPrimary: "#1E293B"
    property color textSecondary: "#64748B"
    property color cardBackground: "#FFFFFF"
    property color errorColor: "#EF4444"
    property color successColor: "#10B981"

    // Animated gradient background
    Rectangle {
        anchors.fill: parent

        LinearGradient {
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(parent.width, parent.height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#F1F5F9" }
                GradientStop { position: 0.5; color: "#E2E8F0" }
                GradientStop { position: 1.0; color: "#CBD5E1" }
            }
        }

        // Animated floating elements optional with random int module just mooving the colored circled
        Repeater {
            model: 5
            Rectangle {
                property real initialX: Math.random() * parent.width
                property real initialY: Math.random() * parent.height

                width: 70 + Math.random() * 40
                height: width
                radius: width / 2
                opacity: 0.1
                color: primaryColor

                x: initialX
                y: initialY

                SequentialAnimation on x {
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: initialX
                        to: initialX + 100
                        duration: 3000 + Math.random() * 2000
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        from: initialX + 100
                        to: initialX
                        duration: 3000 + Math.random() * 2000
                        easing.type: Easing.InOutSine
                    }
                }

                SequentialAnimation on y {
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: initialY
                        to: initialY - 50
                        duration: 4000 + Math.random() * 2000
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        from: initialY - 50
                        to: initialY
                        duration: 4000 + Math.random() * 2000
                        easing.type: Easing.InOutSine
                    }
                }
            }
        }
    }

    // Main login container
    Rectangle {
        id: loginContainer
        width: 420
        height: 580
        anchors.centerIn: parent
        color: cardBackground
        radius: 20

        visible: showLogin

        PropertyAnimation {
            id: slideInAnimation
            target: loginContainer
            property: "anchors.verticalCenterOffset"
            from: 100
            to: 0
            duration: 600
            easing.type: Easing.OutCubic
        }


        DropShadow {
            anchors.fill: loginContainer
            horizontalOffset: 0
            verticalOffset: 8
            radius: 24
            samples: 17
            color: "#1E293B"
            opacity: 0.1
            source: loginContainer
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 32
            width: parent.width * 0.85

            Column {
                Layout.alignment: Qt.AlignHCenter
                spacing: baseUnit * 2.5


                Rectangle {
                    width: baseUnit * 12
                    height: baseUnit * 12
                    radius: baseUnit * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "transparent"

                    // Main logo image
                    Image {
                        id: companyLogo
                        anchors.centerIn: parent
                        width: parent.width * 0.9
                        height: parent.height * 0.9
                        source: "indrones-image.png"  // Your provided image file
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        antialiasing: true

                        // Loading animation while image loads
                        Behavior on opacity {
                            NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
                        }

                        // Fallback container if image doesn't load
                        Rectangle {
                            anchors.fill: parent
                            radius: baseUnit * 2
                            visible: companyLogo.status !== Image.Ready

                            LinearGradient {
                                anchors.fill: parent
                                start: Qt.point(0, 0)
                                end: Qt.point(parent.width, parent.height)
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: primaryColor }
                                    GradientStop { position: 1.0; color: secondaryColor }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "IN"
                                font.pixelSize: baseUnit * 4
                                font.bold: true
                                color: "white"
                            }
                        }
                    }

                    // Enhanced glow effect for the logo
                    Glow {
                        anchors.fill: parent
                        radius: baseUnit * 2
                        samples: 25
                        color: companyLogo.status === Image.Ready ? "#667EEA" : primaryColor
                        source: companyLogo.status === Image.Ready ? companyLogo : parent
                        opacity: 0.5

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.3; to: 0.7; duration: 2000; easing.type: Easing.InOutSine }
                            NumberAnimation { from: 0.7; to: 0.3; duration: 2000; easing.type: Easing.InOutSine }
                        }
                    }

                    // Subtle pulsing border effect
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: "transparent"
                        border.color: "#FFFFFF40"
                        border.width: 1
                        opacity: 0.6

                        SequentialAnimation on border.color {
                            loops: Animation.Infinite
                            ColorAnimation { from: "#FFFFFF40"; to: "#667EEA60"; duration: 3000 }
                            ColorAnimation { from: "#667EEA60"; to: "#FFFFFF40"; duration: 3000 }
                        }
                    }
                }

                // Enhanced company name with gradient text effect
                Text {
                    text: "INDRONES"
                    font.pixelSize: baseUnit * 4
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter

                    // Create gradient text effect
                    color: primaryColor

                    // Optional: Add text shadow for depth
                    style: Text.Raised
                    styleColor: "#00000020"
                }

                // Improved tagline with better styling
                Text {
                    text: "Drones At Work"
                    font.pixelSize: baseUnit * 2
                    color: textSecondary
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.weight: Font.Medium
                    font.italic: true
                    opacity: 0.85
                }

                // Additional welcome message for better UX
                Text {
                    text: "Welcome back! Sign in to continue"
                    font.pixelSize: baseUnit * 1.8
                    color: textSecondary
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: 0.7
                    Layout.topMargin: baseUnit
                }
            }

            // Username field with modern styling
            Column {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Username"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: textPrimary
                }

                Rectangle {
                    width: parent.width
                    height: 56
                    color: backgroundColor
                    radius: 12
                    border.color: usernameField.focus ? secondaryColor : "transparent"
                    border.width: 2

                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        spacing: 12

                        // User icon
                        Text {
                            text: "👤"
                            font.pixelSize: 18
                            color: textSecondary
                        }

                        TextInput {
                            id: usernameField
                            width: loginContainer.width * 0.6
                            font.pixelSize: 16
                            color: textPrimary
                            selectByMouse: true
                            clip: true

                            Text {
                                text: "Enter your username"
                                color: textSecondary
                                visible: usernameField.text.length === 0 && !usernameField.focus
                                font.pixelSize: 16
                            }
                        }
                    }
                }
            }

            // Password field with show/hide toggle for privacy
            Column {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Password"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: textPrimary
                }

                Rectangle {
                    width: parent.width
                    height: 56
                    color: backgroundColor
                    radius: 12
                    border.color: passwordField.focus ? secondaryColor : "transparent"
                    border.width: 2

                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        spacing: 12


                        Text {
                            text: "🔒"
                            font.pixelSize: 18
                            color: textSecondary
                        }

                        TextInput {
                            id: passwordField
                            width: loginContainer.width * 0.55
                            font.pixelSize: 16
                            color: textPrimary
                            echoMode: showPasswordButton.checked ? TextInput.Normal : TextInput.Password
                            selectByMouse: true
                            clip: true

                            Text {
                                text: "Enter your password"
                                color: textSecondary
                                visible: passwordField.text.length === 0 && !passwordField.focus
                                font.pixelSize: 16
                            }
                        }
                    }

                    // Show/Hide password toggle
                    Button {
                        id: showPasswordButton
                        width: 40
                        height: 40
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        checkable: true

                        background: Rectangle {
                            color: "transparent"
                            radius: 6
                        }

                        contentItem: Text {
                            text: showPasswordButton.checked ? "🙈" : "👁️"
                            font.pixelSize: 16
                            color: textSecondary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // Error message ;ike not valid password or else implemented soon
            // Rectangle {
            //     Layout.fillWidth: true
            //     height: errorText.visible ? 40 : 0
            //     color: errorColor
            //     radius: 8
            //     opacity: errorText.visible ? 0.1 : 0
            //      visible: false

            //     Behavior on height {
            //         NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            //     }

            //     Text {
            //         id: errorText
            //         anchors.centerIn: parent
            //         text: loginManager.errorMessage
            //         color: errorColor
            //         font.pixelSize: 14
            //         font.weight: Font.Medium

            //     }
            // }

            // Login button with hover effects
            Button {
                id: loginButton
                Layout.fillWidth: true
                height: 56
                text: "LOGIN -->"

                property bool isHovered: false

                background: Rectangle {
                    color: loginButton.pressed ? "#E65100" :
                           (loginButton.isHovered ? "#FF8A65" : accentColor)
                    radius: 12

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }

                    // Subtle gradient overlay
                    LinearGradient {
                        anchors.fill: parent
                        start: Qt.point(0, 0)
                        end: Qt.point(0, parent.height)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: "#00000015" }
                        }
                    }
                }

                contentItem: Text {
                    text: loginButton.text
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: loginButton.isHovered = true
                    onExited: loginButton.isHovered = false
                    onClicked: {
                        loginManager.login(usernameField.text, passwordField.text);
                        clickAnimation.start();
                    }
                }

                // Click animation of login button
                SequentialAnimation {
                    id: clickAnimation
                    ScaleAnimator {
                        target: loginButton
                        from: 1.0
                        to: 0.98
                        duration: 100
                    }
                    ScaleAnimator {
                        target: loginButton
                        from: 0.98
                        to: 1.0
                        duration: 100
                    }
                }
            }

            // Additional options REMEMBER ME and all
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8

                CheckBox {
                    id: rememberMe
                    text: "Remember me"

                    indicator: Rectangle {
                        implicitWidth: 20
                        implicitHeight: 20
                        radius: 4
                        border.color: secondaryColor
                        border.width: 2
                        color: rememberMe.checked ? secondaryColor : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }

                        Text {
                            text: "✓"
                            color: "#FFFFFF"
                            anchors.centerIn: parent
                            font.pixelSize: 12
                            font.bold: true
                            visible: rememberMe.checked
                        }
                    }

                    contentItem: Text {
                        text: rememberMe.text
                        color: textSecondary
                        font.pixelSize: 14
                        leftPadding: rememberMe.indicator.width + 12
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Item { Layout.fillWidth: true }

                Button {
                    text: "Forgot Password?"

                    background: Rectangle {
                        color: "transparent"
                    }

                    contentItem: Text {
                        text: parent.text
                        color: secondaryColor
                        font.pixelSize: 14
                        font.underline: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("Forgot password clicked");
                        //implemented soon if required
                    }
                }
            }
        }
    }


    // Handle keyboard events
    Keys.onReturnPressed: {
        if (showLogin) {
            loginManager.login(usernameField.text, passwordField.text);
        }
    }

    Keys.onEnterPressed: {
        if (showLogin) {
            loginManager.login(usernameField.text, passwordField.text);
        }
    }

    focus: true
}
