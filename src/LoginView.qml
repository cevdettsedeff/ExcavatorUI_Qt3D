import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: loginView

    signal switchToRegister()

    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"

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
                Layout.preferredHeight: 120
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 10

                    // İkon
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 60
                        height: 60
                        radius: 30
                        color: "#3498db"

                        Text {
                            anchors.centerIn: parent
                            text: "🚜"
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
                        text: "Lütfen giriş yapın"
                        font.pixelSize: 14
                        color: "#888888"
                    }
                }
            }

            // Form bölümü
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15

                // Kullanıcı adı
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Text {
                        text: "Kullanıcı Adı"
                        font.pixelSize: 12
                        color: "#cccccc"
                    }

                    TextField {
                        id: usernameField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        placeholderText: "Kullanıcı adınızı girin"
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
                        text: "Şifre"
                        font.pixelSize: 12
                        color: "#cccccc"
                    }

                    TextField {
                        id: passwordField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        placeholderText: "Şifrenizi girin"
                        echoMode: TextInput.Password
                        font.pixelSize: 14
                        color: "#ffffff"

                        background: Rectangle {
                            color: "#2a2a2a"
                            border.color: passwordField.activeFocus ? "#3498db" : "#404040"
                            border.width: 2
                            radius: 5
                        }

                        Keys.onReturnPressed: loginButton.clicked()
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
                    text: "Giriş Yap"
                    font.pixelSize: 16
                    font.bold: true
                    enabled: usernameField.text.length > 0 && passwordField.text.length > 0
                    hoverEnabled: true

                    background: Rectangle {
                        color: {
                            if (!loginButton.enabled) return "#555555"
                            if (loginButton.pressed) return "#2980b9"
                            if (loginButton.hovered) return "#2c90c9"
                            return "#3498db"
                        }
                        radius: 5

                        Behavior on color {
                            ColorAnimation { duration: 150 }
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

                        if (authService.login(usernameField.text, passwordField.text)) {
                            // Login başarılı - main.cpp'de handle edilecek
                        } else {
                            errorMessage.text = "Kullanıcı adı veya şifre hatalı"
                        }
                    }
                }

                // Bilgi mesajı
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    color: "#2c3e50"
                    radius: 5
                    border.color: "#34495e"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        Text {
                            Layout.fillWidth: true
                            text: "ℹ️ Varsayılan Kullanıcı"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#ecf0f1"
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Kullanıcı Adı: admin\nŞifre: admin"
                            font.pixelSize: 12
                            color: "#bdc3c7"
                            lineHeight: 1.5
                        }
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
                        text: "veya"
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
                    text: "Üye Ol"
                    font.pixelSize: 14
                    hoverEnabled: true

                    background: Rectangle {
                        color: {
                            if (registerButton.pressed) return "#1e1e1e"
                            if (registerButton.hovered) return "#2a2a2a"
                            return "transparent"
                        }
                        border.color: registerButton.hovered ? "#5dade2" : "#3498db"
                        border.width: 2
                        radius: 5

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                        Behavior on border.color {
                            ColorAnimation { duration: 150 }
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
