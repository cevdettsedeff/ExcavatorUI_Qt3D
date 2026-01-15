import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: loginView

    // Global responsive değişkenlere erişim
    property var app: ApplicationWindow.window

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

    Rectangle {
        anchors.fill: parent
        color: themeManager ? themeManager.backgroundColor : "#2d3748"

        // Dil seçici butonu (sağ üst köşe) - Tam Responsive
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: app.smallPadding
            width: app.largeIconSize * 2.2
            height: app.buttonHeight * 0.8
            radius: app.smallRadius
            color: langBtnArea.containsMouse ? "#333333" : "#34495e"
            border.color: "#505050"
            border.width: 1
            z: 100

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Row {
                anchors.centerIn: parent
                spacing: app.smallSpacing * 0.5

                Text {
                    text: "🌐"
                    font.pixelSize: app.baseFontSize
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: translationService ? (translationService.currentLanguage === "tr_TR" ? "TR" : "EN") : "TR"
                    font.pixelSize: app.smallFontSize
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
                width: Math.min(loginView.width * 0.92, 700)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: app.largeSpacing
                anchors.topMargin: app.xlSpacing * 3
                anchors.bottomMargin: app.largeSpacing

            // Logo/Başlık bölümü (Responsive)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: app.largeIconSize * 4.5
                color: "transparent"
                Layout.topMargin: app.xlSpacing * 3.5

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 0
                    spacing: app.normalSpacing

                    // Uygulama İkonu (Responsive - Küçültülmüş)
                    Image {
                        Layout.alignment: Qt.AlignHCenter
                        source: "qrc:/ExcavatorUI_Qt3D/resources/icons/app_icon.ico"
                        width: app.largeIconSize * 2
                        height: app.largeIconSize * 2
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        antialiasing: true
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: translationService && translationService.currentLanguage === "tr_TR"
                              ? "EHK - Harita Ve Görselleştirme Yönetimi"
                              : "EHK - Map And Visualization Management"
                        font.pixelSize: app.mediumFontSize
                        font.bold: true
                        color: "#ffffff"
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Form bölümü (Responsive)
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: app.xlSpacing * 2.5
                Layout.leftMargin: app.largeSpacing
                Layout.rightMargin: app.largeSpacing
                spacing: app.normalSpacing + app.smallSpacing

                // Kullanıcı adı (Responsive)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: app.smallSpacing

                    Text {
                        text: qsTranslate("Main", "Username")
                        font.pixelSize: app.smallFontSize
                        color: "#cccccc"
                    }

                    TextField {
                        id: usernameField
                        Layout.fillWidth: true
                        Layout.preferredHeight: app.buttonHeight
                        placeholderText: qsTranslate("Main", "Enter your username")
                        font.pixelSize: app.baseFontSize
                        color: "#ffffff"

                        background: Rectangle {
                            color: "#2a2a2a"
                            border.color: usernameField.activeFocus ? "#3498db" : "#404040"
                            border.width: 2
                            radius: app.smallRadius
                        }

                        Keys.onReturnPressed: passwordField.forceActiveFocus()
                    }
                }

                // Şifre (Responsive)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: app.smallSpacing

                    Text {
                        text: qsTranslate("Main", "Password")
                        font.pixelSize: app.smallFontSize
                        color: "#cccccc"
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: app.buttonHeight

                        property bool showPassword: false

                        TextField {
                            id: passwordField
                            anchors.fill: parent
                            placeholderText: qsTranslate("Main", "Enter your password")
                            echoMode: parent.showPassword ? TextInput.Normal : TextInput.Password
                            font.pixelSize: app.baseFontSize
                            color: "#ffffff"
                            rightPadding: app.buttonHeight

                            background: Rectangle {
                                color: "#2a2a2a"
                                border.color: passwordField.activeFocus ? "#3498db" : "#404040"
                                border.width: 2
                                radius: app.smallRadius
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

                // Giriş butonu (Responsive)
                Button {
                    id: loginButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: app.largeButtonHeight
                    Layout.topMargin: app.normalSpacing
                    text: qsTranslate("Main", "Login")
                    font.pixelSize: app.mediumFontSize
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

                // Üye Ol bölümü (Responsive)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: app.normalSpacing
                    spacing: app.smallSpacing

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#404040"
                    }

                    Text {
                        text: qsTranslate("Main", "or")
                        font.pixelSize: app.smallFontSize
                        color: "#888888"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#404040"
                    }
                }

                // Yeni Kayıt Oluştur butonu (Responsive)
                Button {
                    id: registerButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: app.buttonHeight + app.smallSpacing
                    text: qsTranslate("Main", "Create New Account")
                    font.pixelSize: app.baseFontSize
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

                // Copyright bölümü (Responsive)
                Text {
                    Layout.fillWidth: true
                    Layout.topMargin: app.largeSpacing
                    Layout.bottomMargin: app.smallSpacing
                    text: "© 2025 EHK - Excavator Visualization System"
                    font.pixelSize: app.smallFontSize
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
