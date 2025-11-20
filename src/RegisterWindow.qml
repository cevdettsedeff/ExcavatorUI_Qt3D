import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: registerWindow
    width: 400
    height: 650
    visible: true
    title: qsTr("Excavator Dashboard - Üye Ol")
    color: "#1a1a1a"
    modality: Qt.ApplicationModal

    // Window'u ortala
    Component.onCompleted: {
        registerWindow.x = (Screen.width - registerWindow.width) / 2
        registerWindow.y = (Screen.height - registerWindow.height) / 2
    }

    // Ana container
    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width * 0.8
            spacing: 20

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
                        color: "#2ecc71"

                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            font.pixelSize: 32
                            font.bold: true
                            color: "#ffffff"
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Yeni Hesap Oluştur"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#ffffff"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Lütfen bilgilerinizi girin"
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
                        placeholderText: "Kullanıcı adınızı seçin"
                        font.pixelSize: 14
                        color: "#ffffff"

                        background: Rectangle {
                            color: "#2a2a2a"
                            border.color: usernameField.activeFocus ? "#2ecc71" : "#404040"
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
                        placeholderText: "Şifrenizi belirleyin (min. 4 karakter)"
                        echoMode: TextInput.Password
                        font.pixelSize: 14
                        color: "#ffffff"

                        background: Rectangle {
                            color: "#2a2a2a"
                            border.color: passwordField.activeFocus ? "#2ecc71" : "#404040"
                            border.width: 2
                            radius: 5
                        }

                        Keys.onReturnPressed: confirmPasswordField.forceActiveFocus()
                    }
                }

                // Şifre tekrar
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Text {
                        text: "Şifre Tekrar"
                        font.pixelSize: 12
                        color: "#cccccc"
                    }

                    TextField {
                        id: confirmPasswordField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        placeholderText: "Şifrenizi tekrar girin"
                        echoMode: TextInput.Password
                        font.pixelSize: 14
                        color: "#ffffff"

                        background: Rectangle {
                            color: "#2a2a2a"
                            border.color: confirmPasswordField.activeFocus ? "#2ecc71" : "#404040"
                            border.width: 2
                            radius: 5
                        }

                        Keys.onReturnPressed: registerButton.clicked()
                    }
                }

                // Hata/Başarı mesajı
                Text {
                    id: messageText
                    Layout.fillWidth: true
                    Layout.preferredHeight: visible ? implicitHeight : 0
                    text: ""
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    visible: text !== ""

                    // Dinamik renk (hata için kırmızı, başarı için yeşil)
                    property bool isError: true
                    color: isError ? "#e74c3c" : "#2ecc71"
                }

                // Kayıt Ol butonu
                Button {
                    id: registerButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    text: "Kayıt Ol"
                    font.pixelSize: 16
                    font.bold: true
                    enabled: usernameField.text.length > 0 &&
                             passwordField.text.length >= 4 &&
                             confirmPasswordField.text.length >= 4

                    background: Rectangle {
                        color: registerButton.enabled ? (registerButton.pressed ? "#27ae60" : "#2ecc71") : "#555555"
                        radius: 5

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    contentItem: Text {
                        text: registerButton.text
                        font: registerButton.font
                        color: registerButton.enabled ? "#ffffff" : "#888888"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        messageText.text = ""

                        // Validasyon
                        if (usernameField.text.length < 3) {
                            messageText.isError = true
                            messageText.text = "Kullanıcı adı en az 3 karakter olmalıdır"
                            return
                        }

                        if (passwordField.text.length < 4) {
                            messageText.isError = true
                            messageText.text = "Şifre en az 4 karakter olmalıdır"
                            return
                        }

                        if (passwordField.text !== confirmPasswordField.text) {
                            messageText.isError = true
                            messageText.text = "Şifreler eşleşmiyor"
                            return
                        }

                        // Kayıt işlemi
                        if (authService.registerUser(usernameField.text, passwordField.text)) {
                            messageText.isError = false
                            messageText.text = "Kayıt başarılı! Giriş sayfasına yönlendiriliyorsunuz..."

                            // 1.5 saniye sonra window'u kapat
                            closeTimer.start()
                        } else {
                            messageText.isError = true
                            messageText.text = "Bu kullanıcı adı zaten kullanımda"
                        }
                    }
                }

                // Geri Dön butonu
                Button {
                    id: backButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    text: "Geri Dön"
                    font.pixelSize: 14

                    background: Rectangle {
                        color: backButton.pressed ? "#1e1e1e" : "transparent"
                        border.color: "#95a5a6"
                        border.width: 2
                        radius: 5

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    contentItem: Text {
                        text: backButton.text
                        font: backButton.font
                        color: "#95a5a6"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        registerWindow.close()
                    }
                }

                // Bilgi mesajı
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: "#2c3e50"
                    radius: 5
                    border.color: "#34495e"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5

                        Text {
                            Layout.fillWidth: true
                            text: "ℹ️ Bilgi"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#ecf0f1"
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Kullanıcı adı en az 3 karakter\nŞifre en az 4 karakter olmalıdır"
                            font.pixelSize: 10
                            color: "#bdc3c7"
                            lineHeight: 1.3
                        }
                    }
                }
            }
        }
    }

    // Başarılı kayıt sonrası window'u kapatmak için timer
    Timer {
        id: closeTimer
        interval: 1500
        running: false
        repeat: false
        onTriggered: {
            registerWindow.close()
        }
    }
}
