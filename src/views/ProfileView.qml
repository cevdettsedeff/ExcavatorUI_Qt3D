import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#1a1a1a"

    // Gradient background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1a1a1a" }
            GradientStop { position: 1.0; color: "#0d0d0d" }
        }
    }

    // Ana başlık
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#2d2d2d" }
                GradientStop { position: 1.0; color: "#1a1a1a" }
            }
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 15

            Text {
                text: "👤"
                font.pixelSize: 32
            }

            Text {
                text: "Profilim"
                font.pixelSize: 28
                font.bold: true
                color: "#ffffff"
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: "#3498db" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    // İçerik alanı
    ScrollView {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 30
        clip: true

        ColumnLayout {
            width: parent.width - 40
            spacing: 30
            anchors.horizontalCenter: parent.horizontalCenter

            // Profil Bilgileri Kartı
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: profileContent.implicitHeight + 50
                color: "#252525"
                radius: 15
                border.color: "#3498db"
                border.width: 3

                Column {
                    id: profileContent
                    anchors.fill: parent
                    anchors.margins: 30
                    spacing: 25

                    // Başlık
                    RowLayout {
                        width: parent.width
                        spacing: 15

                        Rectangle {
                            width: 5
                            height: 35
                            radius: 2.5
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#5dade2" }
                                GradientStop { position: 1.0; color: "#3498db" }
                            }
                        }

                        Column {
                            spacing: 3
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: "Profil Bilgileri"
                                font.pixelSize: 22
                                font.bold: true
                                color: "#ffffff"
                            }

                            Text {
                                text: "Kullanıcı adı ve şifrenizi değiştirin"
                                font.pixelSize: 14
                                color: "#3498db"
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.5; color: "#404040" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    // Mevcut Kullanıcı Adı
                    Column {
                        width: parent.width
                        spacing: 10

                        Text {
                            text: "Mevcut Kullanıcı Adı"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#cccccc"
                        }

                        Rectangle {
                            width: parent.width
                            height: 50
                            color: "#1a1a1a"
                            radius: 8
                            border.color: "#404040"
                            border.width: 2

                            Row {
                                anchors.centerIn: parent
                                spacing: 10

                                Text {
                                    text: "👤"
                                    font.pixelSize: 18
                                }

                                Text {
                                    text: authService ? authService.currentUser : ""
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#3498db"
                                }
                            }
                        }
                    }

                    // Yeni Kullanıcı Adı
                    Column {
                        width: parent.width
                        spacing: 10

                        Text {
                            text: "Yeni Kullanıcı Adı"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#cccccc"
                        }

                        TextField {
                            id: newUsernameField
                            width: parent.width
                            height: 50
                            placeholderText: "Yeni kullanıcı adınızı girin"
                            font.pixelSize: 14

                            background: Rectangle {
                                color: "#1a1a1a"
                                radius: 8
                                border.color: newUsernameField.activeFocus ? "#3498db" : "#404040"
                                border.width: 2

                                Behavior on border.color {
                                    ColorAnimation { duration: 200 }
                                }
                            }

                            color: "#ffffff"
                        }
                    }

                    // Yeni Şifre
                    Column {
                        width: parent.width
                        spacing: 10

                        Text {
                            text: "Yeni Şifre"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#cccccc"
                        }

                        Item {
                            width: parent.width
                            height: 50

                            property bool showPassword: false

                            TextField {
                                id: newPasswordField
                                anchors.fill: parent
                                placeholderText: "Yeni şifrenizi girin (en az 6 karakter)"
                                echoMode: parent.showPassword ? TextInput.Normal : TextInput.Password
                                font.pixelSize: 14
                                color: "#ffffff"
                                rightPadding: 45

                                background: Rectangle {
                                    color: "#1a1a1a"
                                    radius: 8
                                    border.color: newPasswordField.activeFocus ? "#3498db" : "#404040"
                                    border.width: 2

                                    Behavior on border.color {
                                        ColorAnimation { duration: 200 }
                                    }
                                }
                            }

                            Button {
                                anchors.right: parent.right
                                anchors.rightMargin: 5
                                anchors.verticalCenter: parent.verticalCenter
                                width: 35
                                height: 35

                                background: Rectangle {
                                    color: "transparent"
                                    radius: 5
                                }

                                contentItem: Text {
                                    text: parent.parent.showPassword ? "👀" : "👁"
                                    font.pixelSize: 20
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    parent.showPassword = !parent.showPassword
                                }
                            }
                        }
                    }

                    // Şifre Tekrar
                    Column {
                        width: parent.width
                        spacing: 10

                        Text {
                            text: "Yeni Şifre (Tekrar)"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#cccccc"
                        }

                        Item {
                            width: parent.width
                            height: 50

                            property bool showConfirmPassword: false

                            TextField {
                                id: confirmPasswordField
                                anchors.fill: parent
                                placeholderText: "Şifrenizi tekrar girin"
                                echoMode: parent.showConfirmPassword ? TextInput.Normal : TextInput.Password
                                font.pixelSize: 14
                                color: "#ffffff"
                                rightPadding: 45

                                background: Rectangle {
                                    color: "#1a1a1a"
                                    radius: 8
                                    border.color: confirmPasswordField.activeFocus ? "#3498db" : "#404040"
                                    border.width: 2

                                    Behavior on border.color {
                                        ColorAnimation { duration: 200 }
                                    }
                                }
                            }

                            Button {
                                anchors.right: parent.right
                                anchors.rightMargin: 5
                                anchors.verticalCenter: parent.verticalCenter
                                width: 35
                                height: 35

                                background: Rectangle {
                                    color: "transparent"
                                    radius: 5
                                }

                                contentItem: Text {
                                    text: parent.parent.showConfirmPassword ? "👀" : "👁"
                                    font.pixelSize: 20
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    parent.showConfirmPassword = !parent.showConfirmPassword
                                }
                            }
                        }
                    }

                    // Uyarı Mesajı
                    Rectangle {
                        width: parent.width
                        height: 60
                        color: "#ff9800"
                        radius: 8
                        opacity: 0.2

                        Row {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10

                            Text {
                                text: "⚠️"
                                font.pixelSize: 24
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "Profil bilgileriniz güncellendiğinde otomatik olarak çıkış yapılacak ve giriş ekranına yönlendirileceksiniz."
                                font.pixelSize: 12
                                color: "#ffffff"
                                wrapMode: Text.WordWrap
                                width: parent.width - 50
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // Kaydet Butonu
                    Button {
                        width: parent.width
                        height: 55
                        enabled: newUsernameField.text.length >= 3 ||
                                (newPasswordField.text.length >= 6 && confirmPasswordField.text.length >= 6)

                        background: Rectangle {
                            radius: 8
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: parent.parent.enabled ? (parent.parent.pressed ? "#1976d2" : (parent.parent.hovered ? "#2196F3" : "#3498db")) : "#404040"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: parent.parent.enabled ? (parent.parent.pressed ? "#1565c0" : (parent.parent.hovered ? "#1976d2" : "#2980b9")) : "#303030"
                                }
                            }
                            border.color: parent.parent.enabled && parent.parent.hovered ? "#5dade2" : "transparent"
                            border.width: 2
                        }

                        contentItem: Row {
                            anchors.centerIn: parent
                            spacing: 10

                            Text {
                                text: "💾"
                                font.pixelSize: 20
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "Değişiklikleri Kaydet"
                                font.pixelSize: 16
                                font.bold: true
                                color: parent.parent.enabled ? "#ffffff" : "#666666"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        onClicked: {
                            // Validasyon
                            if (newUsernameField.text.length === 0 && newPasswordField.text.length === 0) {
                                errorDialog.errorText = "En az bir alan doldurulmalıdır."
                                errorDialog.open()
                                return
                            }

                            if (newUsernameField.text.length > 0 && newUsernameField.text.length < 3) {
                                errorDialog.errorText = "Kullanıcı adı en az 3 karakter olmalıdır."
                                errorDialog.open()
                                return
                            }

                            if (newPasswordField.text.length > 0) {
                                if (newPasswordField.text.length < 6) {
                                    errorDialog.errorText = "Şifre en az 6 karakter olmalıdır."
                                    errorDialog.open()
                                    return
                                }

                                if (newPasswordField.text !== confirmPasswordField.text) {
                                    errorDialog.errorText = "Şifreler eşleşmiyor."
                                    errorDialog.open()
                                    return
                                }
                            }

                            // Profil güncelleme
                            var username = newUsernameField.text.length > 0 ? newUsernameField.text : ""
                            var password = newPasswordField.text.length > 0 ? newPasswordField.text : ""

                            if (authService.updateProfile(username, password)) {
                                successDialog.open()
                            } else {
                                errorDialog.errorText = "Profil güncellenirken bir hata oluştu. Bu kullanıcı adı zaten kullanılıyor olabilir."
                                errorDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }

    // Başarı Dialog'u
    Dialog {
        id: successDialog
        title: "Başarılı"
        modal: true
        anchors.centerIn: parent
        width: 400

        background: Rectangle {
            color: "#2a2a2a"
            radius: 12
            border.color: "#2ecc71"
            border.width: 3
        }

        header: Rectangle {
            height: 60
            color: "transparent"
            radius: 12

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#2ecc71" }
                    GradientStop { position: 1.0; color: "#27ae60" }
                }
                radius: 12
            }

            Text {
                anchors.centerIn: parent
                text: "✓ Profil Güncellendi"
                font.pixelSize: 18
                font.bold: true
                color: "#ffffff"
            }
        }

        Column {
            spacing: 15
            width: parent.width

            Text {
                text: "Profil bilgileriniz başarıyla güncellendi.\n\nGiriş ekranına yönlendiriliyorsunuz..."
                font.pixelSize: 14
                color: "#cccccc"
                wrapMode: Text.WordWrap
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }
        }

        standardButtons: Dialog.Ok

        onAccepted: {
            // Logout ve giriş ekranına yönlendir
            authService.logout()
        }
    }

    // Hata Dialog'u
    Dialog {
        id: errorDialog
        title: "Hata"
        modal: true
        anchors.centerIn: parent
        width: 400

        property string errorText: ""

        background: Rectangle {
            color: "#2a2a2a"
            radius: 12
            border.color: "#e74c3c"
            border.width: 3
        }

        header: Rectangle {
            height: 60
            color: "transparent"
            radius: 12

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#e74c3c" }
                    GradientStop { position: 1.0; color: "#c0392b" }
                }
                radius: 12
            }

            Text {
                anchors.centerIn: parent
                text: "⚠️ Hata"
                font.pixelSize: 18
                font.bold: true
                color: "#ffffff"
            }
        }

        Column {
            spacing: 15
            width: parent.width

            Text {
                text: errorDialog.errorText
                font.pixelSize: 14
                color: "#cccccc"
                wrapMode: Text.WordWrap
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }
        }

        standardButtons: Dialog.Ok
    }
}
