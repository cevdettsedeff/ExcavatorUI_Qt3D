import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: loginView

    signal switchToRegister()

    // Dil değişikliği tetikleyici - bu değiştiğinde tüm qsTr() çağrıları yenilenir
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    // TranslationService'i dinle
    Connections {
        target: translationService
        function onLanguageChanged() {
            languageTrigger++
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"

        // Dil seçici butonu (sağ üst köşe)
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 15
            width: 80
            height: 35
            radius: 5
            color: langBtnArea.containsMouse ? "#333333" : "#34495e"
            border.color: "#505050"
            border.width: 1
            z: 100

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Row {
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: "🌐"
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: translationService ? (translationService.currentLanguage === "tr_TR" ? "TR" : "EN") : "TR"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: langBtnArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    langMenu.open()
                }
            }

            // Language menu
            Menu {
                id: langMenu
                y: parent.height

                MenuItem {
                    text: "🇹🇷 Türkçe"
                    onTriggered: {
                        if (translationService) {
                            translationService.switchLanguage("tr_TR")
                        }
                    }
                }

                MenuItem {
                    text: "🇬🇧 English"
                    onTriggered: {
                        if (translationService) {
                            translationService.switchLanguage("en_US")
                        }
                    }
                }
            }
        }

        ScrollView {
            anchors.fill: parent
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: loginView.width * 0.8
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                anchors.topMargin: 20
                anchors.bottomMargin: 20

            // Logo/Başlık bölümü
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                color: "transparent"
                Layout.topMargin: 10

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 10
                    spacing: 8

                    // İkon
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 60
                        height: 60
                        radius: 30
                        color: "#3498db"

                        Text {
                            anchors.centerIn: parent
                            text: "👷🏻"
                            font.pixelSize: 32
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Excavator Dashboard"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#ffffff"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Please log in")
                        font.pixelSize: 14
                        color: "#888888"
                        Layout.bottomMargin: 15
                    }
                }
            }

            // Form bölümü
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 30
                spacing: 15

                // Kullanıcı adı
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Text {
                        text: qsTr("Username")
                        font.pixelSize: 12
                        color: "#cccccc"
                    }

                    TextField {
                        id: usernameField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        placeholderText: qsTr("Enter your username")
                        font.pixelSize: 14
                        color: "#ffffff"

                        background: Rectangle {
                            color: "#2a2a2a"
                            border.color: usernameField.activeFocus ? "#3498db" : "#404040"
                            border.width: 2
                            radius: 5
                        }

                        Keys.onReturnPressed: passwordField.forceActiveFocus()
                    }
                }

                // Şifre
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Text {
                        text: qsTr("Password")
                        font.pixelSize: 12
                        color: "#cccccc"
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45

                        property bool showPassword: false

                        TextField {
                            id: passwordField
                            anchors.fill: parent
                            placeholderText: qsTr("Enter your password")
                            echoMode: parent.showPassword ? TextInput.Normal : TextInput.Password
                            font.pixelSize: 14
                            color: "#ffffff"
                            rightPadding: 45

                            background: Rectangle {
                                color: "#2a2a2a"
                                border.color: passwordField.activeFocus ? "#3498db" : "#404040"
                                border.width: 2
                                radius: 5
                            }

                            Keys.onReturnPressed: loginButton.clicked()
                        }

                        Button {
                            anchors.right: parent.right
                            anchors.rightMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            width: 50
                            height: 30

                            background: Rectangle {
                                color: "transparent"
                            }

                            contentItem: Text {
                                text: parent.parent.showPassword ? qsTr("Hide") : qsTr("Show")
                                font.pixelSize: 11
                                color: "#3498db"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                parent.showPassword = !parent.showPassword
                            }
                        }
                    }
                }

                // Hata mesajı
                Text {
                    id: errorMessage
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? implicitHeight : 0
                    text: ""
                    color: "#e74c3c"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    visible: text !== ""
                }

                // Giriş butonu
                Button {
                    id: loginButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    text: qsTr("Login")
                    font.pixelSize: 16
                    font.bold: true
                    enabled: usernameField.text.length > 0 && passwordField.text.length > 0
                    hoverEnabled: true
                    scale: loginButton.pressed ? 0.97 : (loginButton.hovered ? 1.02 : 1.0)

                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }

                    background: Rectangle {
                        color: {
                            if (!loginButton.enabled) return "#555555"
                            if (loginButton.pressed) return "#2980b9"
                            if (loginButton.hovered) return "#2c90c9"
                            return "#3498db"
                        }
                        radius: 8
                        opacity: loginButton.enabled ? 1.0 : 0.6

                        // Glow effect with border
                        border.width: loginButton.hovered ? 2 : 0
                        border.color: "#5dade2"

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                        Behavior on border.width {
                            NumberAnimation { duration: 150 }
                        }

                        // Inner glow effect
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 1
                            radius: parent.radius - 1
                            color: "transparent"
                            border.width: loginButton.hovered ? 1 : 0
                            border.color: "#ffffff40"

                            Behavior on border.width {
                                NumberAnimation { duration: 150 }
                            }
                        }
                    }

                    contentItem: Text {
                        text: loginButton.text
                        font: loginButton.font
                        color: loginButton.enabled ? "#ffffff" : "#888888"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        errorMessage.text = ""
                        authService.login(usernameField.text, passwordField.text)
                        // Hata mesajları AuthService'ten loginFailed sinyali ile gelecek
                    }
                }

                // Üye Ol bölümü
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    spacing: 5

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#404040"
                    }

                    Text {
                        text: qsTr("or")
                        font.pixelSize: 11
                        color: "#888888"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#404040"
                    }
                }

                // Üye Ol butonu
                Button {
                    id: registerButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    text: qsTr("Sign Up")
                    font.pixelSize: 14
                    hoverEnabled: true
                    scale: registerButton.pressed ? 0.97 : (registerButton.hovered ? 1.02 : 1.0)

                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }

                    background: Rectangle {
                        color: {
                            if (registerButton.pressed) return "#1e1e1e"
                            if (registerButton.hovered) return "#2a2a2a"
                            return "transparent"
                        }
                        border.color: registerButton.hovered ? "#5dade2" : "#3498db"
                        border.width: 2
                        radius: 8

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                        Behavior on border.color {
                            ColorAnimation { duration: 150 }
                        }

                        // Inner glow effect
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 2
                            radius: parent.radius - 2
                            color: "transparent"
                            border.width: registerButton.hovered ? 1 : 0
                            border.color: "#3498db40"

                            Behavior on border.width {
                                NumberAnimation { duration: 150 }
                            }
                        }
                    }

                    contentItem: Text {
                        text: registerButton.text
                        font: registerButton.font
                        color: registerButton.hovered ? "#5dade2" : "#3498db"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    onClicked: {
                        switchToRegister()
                    }
                }
            }
            }  // ColumnLayout
        }  // ScrollView
    }  // Rectangle

    // AuthService'ten gelen sinyalleri dinle
    Connections {
        target: authService

        function onLoginFailed(error) {
            errorMessage.text = error
        }
    }
}
