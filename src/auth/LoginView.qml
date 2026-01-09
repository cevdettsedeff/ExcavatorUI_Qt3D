import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: loginView

    signal switchToRegister()

    // Dil değişikliği tetikleyici - bu değiştiğinde tüm qsTr() çağrıları yenilenir
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    // Helper fonksiyon - QML binding için
    function tr(text) {
        // languageTrigger kullanarak binding dependency oluştur
        return languageTrigger >= 0 ? qsTranslate("Main", text) : ""
    }

    // TranslationService'i dinle
    Connections {
        target: translationService
        function onLanguageChanged() {
            languageTrigger++
        }
    }

    // Türkçe tarih formatı
    property var turkishDays: ["Pazar", "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi"]
    property var turkishMonths: ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]

    function formatTurkishDate(date) {
        var day = date.getDate()
        var monthName = turkishMonths[date.getMonth()]
        var year = date.getFullYear()
        return day + " " + monthName + " " + year
    }

    // Saat için timer
    Timer {
        id: clockTimer
        interval: 1000
        running: loginView.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            clockText.text = Qt.formatTime(now, "HH:mm:ss")

            // Dil kontrolü
            if (translationService && translationService.currentLanguage === "tr_TR") {
                dateText.text = loginView.formatTurkishDate(now)
            } else {
                dateText.text = Qt.formatDate(now, "d MMMM yyyy")
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: themeManager ? themeManager.backgroundColor : "#2d3748"

        // Saat ve Tarih göstergesi (sol üst köşe) - Geliştirilmiş tasarım
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 12
            width: 180
            height: 60
            radius: 8
            color: "#1e2936"
            border.color: "#3a4556"
            border.width: 1
            z: 100

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 2

                // Saat
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "🕐"
                        font.pixelSize: 16
                        color: "#3498db"
                    }

                    Text {
                        id: clockText
                        text: "00:00:00"
                        font.pixelSize: 16
                        font.bold: true
                        font.family: "Monospace"
                        color: "#ffffff"
                    }
                }

                // Tarih
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "📅"
                        font.pixelSize: 14
                        color: "#2ecc71"
                    }

                    Text {
                        id: dateText
                        text: "1 Ocak 2025"
                        font.pixelSize: 12
                        color: "#aaaaaa"
                    }
                }
            }
        }

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
                width: Math.min(loginView.width * 0.85, 500)  // 10 inç için responsive
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                anchors.topMargin: 20
                anchors.bottomMargin: 20

            // Logo/Başlık bölümü
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                color: "transparent"
                Layout.topMargin: 20

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 0
                    spacing: 12

                    // Uygulama İkonu - Büyütülmüş
                    Image {
                        Layout.alignment: Qt.AlignHCenter
                        source: "qrc:/ExcavatorUI_Qt3D/resources/icons/app_icon.ico"
                        width: 100
                        height: 100
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        antialiasing: true
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: translationService && translationService.currentLanguage === "tr_TR"
                              ? "EHK - Harita Ve Görselleştirme Yönetimi"
                              : "EHK - Map And Visualization Management"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#ffffff"
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTranslate("Main", "Please log in")
                        font.pixelSize: 14
                        color: "#888888"
                        Layout.topMargin: 15
                    }
                }
            }

            // Form bölümü
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 15
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                spacing: 18

                // Kullanıcı adı
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: qsTranslate("Main", "Username")
                        font.pixelSize: 13
                        color: "#cccccc"
                    }

                    TextField {
                        id: usernameField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        placeholderText: qsTranslate("Main", "Enter your username")
                        font.pixelSize: 15
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
                    spacing: 8

                    Text {
                        text: qsTranslate("Main", "Password")
                        font.pixelSize: 13
                        color: "#cccccc"
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50

                        property bool showPassword: false

                        TextField {
                            id: passwordField
                            anchors.fill: parent
                            placeholderText: qsTranslate("Main", "Enter your password")
                            echoMode: parent.showPassword ? TextInput.Normal : TextInput.Password
                            font.pixelSize: 15
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
                                text: parent.parent.showPassword ? qsTranslate("Main", "Hide") : qsTranslate("Main", "Show")
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
                    Layout.preferredHeight: 55
                    Layout.topMargin: 12
                    text: qsTranslate("Main", "Login")
                    font.pixelSize: 17
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
                    Layout.topMargin: 15
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#404040"
                    }

                    Text {
                        text: qsTranslate("Main", "or")
                        font.pixelSize: 12
                        color: "#888888"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#404040"
                    }
                }

                // Yeni Kayıt Oluştur butonu
                Button {
                    id: registerButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    text: qsTranslate("Main", "Create New Account")
                    font.pixelSize: 15
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

                // Copyright bölümü
                Text {
                    Layout.fillWidth: true
                    Layout.topMargin: 20
                    Layout.bottomMargin: 10
                    text: "© 2025 EHK - Excavator Visualization System"
                    font.pixelSize: 11
                    color: "#666666"
                    horizontalAlignment: Text.AlignHCenter
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
