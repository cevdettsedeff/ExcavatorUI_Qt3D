import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: registerView

    signal switchToLogin()
    signal registrationSuccessful()

    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"

        ScrollView {
            anchors.fill: parent
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: registerView.width * 0.8
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
                        placeholderText: "Kullanıcı adınızı seçin (min. 3 karakter)"
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
                        placeholderText: "Şifrenizi belirleyin"
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

                // Kayıt Ol butonu
                Button {
                    id: registerButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    text: "Kayıt Ol"
                    font.pixelSize: 16
                    font.bold: true
                    enabled: usernameField.text.length > 0 &&
                             passwordField.text.length > 0 &&
                             confirmPasswordField.text.length > 0

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
                        // Validasyon kontrolleri
                        var validationResult = validateForm()

                        if (!validationResult.valid) {
                            errorDialog.errorText = validationResult.error
                            errorDialog.open()
                            return
                        }

                        // Kayıt işlemi
                        if (authService.registerUser(usernameField.text, passwordField.text)) {
                            successDialog.open()
                        } else {
                            errorDialog.errorText = "Bu kullanıcı adı zaten kullanımda. Lütfen başka bir kullanıcı adı seçin."
                            errorDialog.open()
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
                        switchToLogin()
                    }
                }

                // Bilgi mesajı
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    color: "#2c3e50"
                    radius: 5
                    border.color: "#34495e"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Text {
                            Layout.fillWidth: true
                            text: "ℹ️ Şifre Gereksinimleri"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#ecf0f1"
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "• Kullanıcı adı: En az 3 karakter\n• Şifre: En az 6 karakter\n• En az 1 büyük harf, 1 küçük harf\n• En az 1 rakam içermeli"
                            font.pixelSize: 11
                            color: "#bdc3c7"
                            lineHeight: 1.4
                        }
                    }
                }
            }
            }  // ColumnLayout
        }  // ScrollView
    }  // Rectangle

    // Validasyon fonksiyonu
    function validateForm() {
        var username = usernameField.text
        var password = passwordField.text
        var confirmPassword = confirmPasswordField.text

        // Kullanıcı adı kontrolü
        if (username.length < 3) {
            return {
                valid: false,
                error: "Kullanıcı adı en az 3 karakter olmalıdır."
            }
        }

        if (username.length > 20) {
            return {
                valid: false,
                error: "Kullanıcı adı en fazla 20 karakter olabilir."
            }
        }

        // Özel karakterlerin kontrolü (sadece alfanumerik ve alt çizgi)
        var usernameRegex = /^[a-zA-Z0-9_]+$/
        if (!usernameRegex.test(username)) {
            return {
                valid: false,
                error: "Kullanıcı adı sadece harf, rakam ve alt çizgi (_) içerebilir."
            }
        }

        // Şifre uzunluk kontrolü
        if (password.length < 6) {
            return {
                valid: false,
                error: "Şifre en az 6 karakter olmalıdır."
            }
        }

        // Büyük harf kontrolü
        if (!/[A-Z]/.test(password)) {
            return {
                valid: false,
                error: "Şifre en az 1 büyük harf içermelidir."
            }
        }

        // Küçük harf kontrolü
        if (!/[a-z]/.test(password)) {
            return {
                valid: false,
                error: "Şifre en az 1 küçük harf içermelidir."
            }
        }

        // Rakam kontrolü
        if (!/[0-9]/.test(password)) {
            return {
                valid: false,
                error: "Şifre en az 1 rakam içermelidir."
            }
        }

        // Şifre eşleşme kontrolü
        if (password !== confirmPassword) {
            return {
                valid: false,
                error: "Şifreler eşleşmiyor. Lütfen aynı şifreyi tekrar girin."
            }
        }

        return { valid: true }
    }

    // Başarı Dialog'u
    Dialog {
        id: successDialog
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.8, 350)
        modal: true
        standardButtons: Dialog.Ok

        background: Rectangle {
            color: "#2a2a2a"
            border.color: "#2ecc71"
            border.width: 2
            radius: 10
        }

        header: Rectangle {
            width: parent.width
            height: 60
            color: "#2ecc71"
            radius: 10

            Text {
                anchors.centerIn: parent
                text: "✓ Kayıt Başarılı!"
                font.pixelSize: 18
                font.bold: true
                color: "#ffffff"
            }
        }

        ColumnLayout {
            width: parent.width
            spacing: 10

            Text {
                Layout.fillWidth: true
                Layout.margins: 20
                text: "Hesabınız başarıyla oluşturuldu!\n\nGiriş sayfasına yönlendiriliyorsunuz..."
                font.pixelSize: 14
                color: "#ffffff"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                lineHeight: 1.4
            }
        }

        onAccepted: {
            registrationSuccessful()
            switchToLogin()
        }
    }

    // Hata Dialog'u
    Dialog {
        id: errorDialog
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.8, 350)
        modal: true
        standardButtons: Dialog.Ok

        property string errorText: ""

        background: Rectangle {
            color: "#2a2a2a"
            border.color: "#e74c3c"
            border.width: 2
            radius: 10
        }

        header: Rectangle {
            width: parent.width
            height: 60
            color: "#e74c3c"
            radius: 10

            Text {
                anchors.centerIn: parent
                text: "⚠ Hata"
                font.pixelSize: 18
                font.bold: true
                color: "#ffffff"
            }
        }

        ColumnLayout {
            width: parent.width
            spacing: 10

            Text {
                Layout.fillWidth: true
                Layout.margins: 20
                text: errorDialog.errorText
                font.pixelSize: 14
                color: "#ffffff"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
                lineHeight: 1.4
            }
        }
    }
}
