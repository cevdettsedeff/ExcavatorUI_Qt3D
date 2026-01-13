import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: registerView

    signal switchToLogin()
    signal registrationSuccessful()

    // Global responsive değişkenlere erişim
    property var app: ApplicationWindow.window

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
        running: registerView.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            clockText.text = Qt.formatTime(now, "HH:mm:ss")

            // Dil kontrolü
            if (translationService && translationService.currentLanguage === "tr_TR") {
                dateText.text = registerView.formatTurkishDate(now)
            } else {
                dateText.text = Qt.formatDate(now, "d MMMM yyyy")
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: themeManager ? themeManager.backgroundColor : "#2d3748"

        // Saat ve Tarih göstergesi (sol üst köşe) - Tam Responsive
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: app.smallPadding
            width: app.largeIconSize * 5
            height: app.buttonHeight * 1.2
            radius: app.smallRadius
            color: "#1e2936"
            border.color: "#3a4556"
            border.width: 1
            z: 100

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: app.smallPadding
                spacing: app.smallSpacing * 0.3

                // Saat
                RowLayout {
                    Layout.fillWidth: true
                    spacing: app.smallSpacing * 0.5

                    Text {
                        text: "Saat:"
                        font.pixelSize: app.smallFontSize
                        color: "#3498db"
                        font.bold: true
                    }

                    Text {
                        id: clockText
                        text: "00:00:00"
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        font.family: "Monospace"
                        color: "#ffffff"
                    }
                }

                // Tarih
                RowLayout {
                    Layout.fillWidth: true
                    spacing: app.smallSpacing * 0.5

                    Text {
                        text: "Tarih:"
                        font.pixelSize: app.smallFontSize
                        color: "#2ecc71"
                        font.bold: true
                    }

                    Text {
                        id: dateText
                        text: "1 Ocak 2025"
                        font.pixelSize: app.smallFontSize
                        color: "#aaaaaa"
                    }
                }
            }
        }

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
                width: Math.min(registerView.width * 0.92, 700)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: app.largeSpacing
                anchors.topMargin: app.xlSpacing * 3
                anchors.bottomMargin: app.largeSpacing

            // Logo/Başlık bölümü
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: app.largeIconSize * 3
                color: "transparent"
                Layout.topMargin: app.xlSpacing * 3.5

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: app.normalSpacing
                    spacing: app.normalSpacing

                    // İkon
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: app.largeIconSize * 1.7
                        height: app.largeIconSize * 1.7
                        radius: app.largeIconSize * 0.85
                        color: "#2ecc71"

                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            font.pixelSize: app.xlFontSize * 1.2
                            font.bold: true
                            color: "#ffffff"
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: tr("Create New Account")
                        font.pixelSize: app.xlFontSize
                        font.bold: true
                        color: "#ffffff"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: tr("Please enter your information")
                        font.pixelSize: app.baseFontSize
                        color: "#888888"
                        Layout.topMargin: app.largeSpacing
                    }
                }
            }

            // Form bölümü
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: app.xlSpacing * 2.5
                spacing: app.normalSpacing

                // Kullanıcı adı
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: app.smallSpacing * 0.8

                    Text {
                        text: tr("Username")
                        font.pixelSize: app.smallFontSize
                        color: "#cccccc"
                    }

                    TextField {
                        id: usernameField
                        Layout.fillWidth: true
                        Layout.preferredHeight: app.buttonHeight
                        placeholderText: tr("Choose your username (min. 3 characters)")
                        font.pixelSize: app.baseFontSize
                        color: "#ffffff"

                        background: Rectangle {
                            color: "#2a2a2a"
                            border.color: usernameField.activeFocus ? "#2ecc71" : "#404040"
                            border.width: 2
                            radius: app.smallRadius
                        }

                        Keys.onReturnPressed: passwordField.forceActiveFocus()
                    }
                }

                // Şifre
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: app.smallSpacing * 0.8

                    Text {
                        text: tr("Password")
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
                            placeholderText: tr("Choose your password")
                            echoMode: parent.showPassword ? TextInput.Normal : TextInput.Password
                            font.pixelSize: app.baseFontSize
                            color: "#ffffff"
                            rightPadding: app.buttonHeight

                            background: Rectangle {
                                color: "#2a2a2a"
                                border.color: passwordField.activeFocus ? "#2ecc71" : "#404040"
                                border.width: 2
                                radius: app.smallRadius
                            }

                            Keys.onReturnPressed: confirmPasswordField.forceActiveFocus()
                        }

                        Button {
                            anchors.right: parent.right
                            anchors.rightMargin: app.smallSpacing * 0.5
                            anchors.verticalCenter: parent.verticalCenter
                            width: app.buttonHeight * 1.1
                            height: app.smallButtonHeight * 0.9

                            background: Rectangle {
                                color: "transparent"
                            }

                            contentItem: Text {
                                text: parent.parent.showPassword ? registerView.tr("Hide") : registerView.tr("Show")
                                font.pixelSize: app.smallFontSize * 0.9
                                color: "#2ecc71"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                parent.showPassword = !parent.showPassword
                            }
                        }
                    }
                }

                // Şifre tekrar
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: app.smallSpacing * 0.8

                    Text {
                        text: tr("Confirm Password")
                        font.pixelSize: app.smallFontSize
                        color: "#cccccc"
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: app.buttonHeight

                        property bool showConfirmPassword: false

                        TextField {
                            id: confirmPasswordField
                            anchors.fill: parent
                            placeholderText: tr("Re-enter your password")
                            echoMode: parent.showConfirmPassword ? TextInput.Normal : TextInput.Password
                            font.pixelSize: app.baseFontSize
                            color: "#ffffff"
                            rightPadding: app.buttonHeight

                            background: Rectangle {
                                color: "#2a2a2a"
                                border.color: confirmPasswordField.activeFocus ? "#2ecc71" : "#404040"
                                border.width: 2
                                radius: app.smallRadius
                            }

                            Keys.onReturnPressed: registerButton.clicked()
                        }

                        Button {
                            anchors.right: parent.right
                            anchors.rightMargin: app.smallSpacing * 0.5
                            anchors.verticalCenter: parent.verticalCenter
                            width: app.buttonHeight * 1.1
                            height: app.smallButtonHeight * 0.9

                            background: Rectangle {
                                color: "transparent"
                            }

                            contentItem: Text {
                                text: parent.parent.showConfirmPassword ? registerView.tr("Hide") : registerView.tr("Show")
                                font.pixelSize: app.smallFontSize * 0.9
                                color: "#2ecc71"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                parent.showConfirmPassword = !parent.showConfirmPassword
                            }
                        }
                    }
                }

                // Yeni Kayıt Oluştur butonu
                Button {
                    id: registerButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: app.largeButtonHeight
                    text: tr("Create New Account")
                    font.pixelSize: app.mediumFontSize
                    font.bold: true
                    enabled: usernameField.text.length > 0 &&
                             passwordField.text.length > 0 &&
                             confirmPasswordField.text.length > 0
                    hoverEnabled: true
                    scale: registerButton.pressed ? 0.97 : (registerButton.hovered ? 1.02 : 1.0)

                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }

                    background: Rectangle {
                        color: {
                            if (!registerButton.enabled) return "#555555"
                            if (registerButton.pressed) return "#27ae60"
                            if (registerButton.hovered) return "#29d170"
                            return "#2ecc71"
                        }
                        radius: app.normalRadius
                        opacity: registerButton.enabled ? 1.0 : 0.6

                        // Glow effect with border
                        border.width: registerButton.hovered ? 2 : 0
                        border.color: "#5ddd87"

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
                            border.width: registerButton.hovered ? 1 : 0
                            border.color: "#ffffff40"

                            Behavior on border.width {
                                NumberAnimation { duration: 150 }
                            }
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
                            errorDialog.errorText = qsTr("This username is already taken. Please choose another username.")
                            errorDialog.open()
                        }
                    }
                }

                // Geri Dön butonu
                Button {
                    id: backButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: app.buttonHeight
                    text: tr("Go Back")
                    font.pixelSize: app.baseFontSize
                    hoverEnabled: true
                    scale: backButton.pressed ? 0.97 : (backButton.hovered ? 1.02 : 1.0)

                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }

                    background: Rectangle {
                        color: {
                            if (backButton.pressed) return "#1e1e1e"
                            if (backButton.hovered) return "#2a2a2a"
                            return "transparent"
                        }
                        border.color: backButton.hovered ? "#b4bec4" : "#95a5a6"
                        border.width: 2
                        radius: app.normalRadius

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
                            border.width: backButton.hovered ? 1 : 0
                            border.color: "#95a5a640"

                            Behavior on border.width {
                                NumberAnimation { duration: 150 }
                            }
                        }
                    }

                    contentItem: Text {
                        text: backButton.text
                        font: backButton.font
                        color: backButton.hovered ? "#b4bec4" : "#95a5a6"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    onClicked: {
                        switchToLogin()
                    }
                }

                // Bilgi mesajı
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: app.largeIconSize * 4
                    color: "#2c3e50"
                    radius: app.normalRadius
                    border.color: "#34495e"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: app.normalPadding
                        spacing: app.normalSpacing

                        Text {
                            Layout.fillWidth: true
                            text: "ℹ️ " + registerView.tr("Password Requirements")
                            font.pixelSize: app.smallFontSize
                            font.bold: true
                            color: "#ecf0f1"
                        }

                        Text {
                            Layout.fillWidth: true
                            text: tr("• Username: At least 3 characters\n• Password: At least 6 characters\n• At least 1 uppercase, 1 lowercase letter\n• Must contain at least 1 digit")
                            font.pixelSize: app.smallFontSize * 0.9
                            color: "#bdc3c7"
                            lineHeight: 1.6
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
                error: qsTr("Username must be at least 3 characters.")
            }
        }

        if (username.length > 20) {
            return {
                valid: false,
                error: qsTr("Username can be at most 20 characters.")
            }
        }

        // Özel karakterlerin kontrolü (sadece alfanumerik ve alt çizgi)
        var usernameRegex = /^[a-zA-Z0-9_]+$/
        if (!usernameRegex.test(username)) {
            return {
                valid: false,
                error: qsTr("Username can only contain letters, numbers and underscore (_).")
            }
        }

        // Şifre uzunluk kontrolü
        if (password.length < 6) {
            return {
                valid: false,
                error: qsTr("Password must be at least 6 characters.")
            }
        }

        // Büyük harf kontrolü
        if (!/[A-Z]/.test(password)) {
            return {
                valid: false,
                error: qsTr("Password must contain at least 1 uppercase letter.")
            }
        }

        // Küçük harf kontrolü
        if (!/[a-z]/.test(password)) {
            return {
                valid: false,
                error: qsTr("Password must contain at least 1 lowercase letter.")
            }
        }

        // Rakam kontrolü
        if (!/[0-9]/.test(password)) {
            return {
                valid: false,
                error: qsTr("Password must contain at least 1 digit.")
            }
        }

        // Şifre eşleşme kontrolü
        if (password !== confirmPassword) {
            return {
                valid: false,
                error: qsTr("Passwords do not match. Please re-enter the same password.")
            }
        }

        return { valid: true }
    }

    // Başarı Dialog'u
    Dialog {
        id: successDialog
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.8, app.largeIconSize * 10)
        height: Math.min(parent.height * 0.5, app.largeIconSize * 8)
        modal: true
        standardButtons: Dialog.Ok

        background: Rectangle {
            color: "#2a2a2a"
            border.color: "#2ecc71"
            border.width: 2
            radius: app.normalRadius
        }

        header: Rectangle {
            width: parent.width
            height: app.largeButtonHeight * 1.1
            color: "#ff9800"
            radius: app.normalRadius

            Text {
                anchors.centerIn: parent
                text: "✓ " + registerView.tr("Registration Request Received!")
                font.pixelSize: app.mediumFontSize
                font.bold: true
                color: "#ffffff"
            }
        }

        ColumnLayout {
            width: parent.width
            spacing: app.normalSpacing

            Text {
                Layout.fillWidth: true
                Layout.margins: app.largeSpacing
                Layout.preferredHeight: implicitHeight
                text: tr("Your registration request has been sent to the administrator.\n\nRedirecting to login page while waiting for approval...")
                font.pixelSize: app.baseFontSize
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
        width: Math.min(parent.width * 0.8, app.largeIconSize * 10)
        height: Math.min(parent.height * 0.5, app.largeIconSize * 8)
        modal: true
        standardButtons: Dialog.Ok

        property string errorText: ""

        background: Rectangle {
            color: "#2a2a2a"
            border.color: "#e74c3c"
            border.width: 2
            radius: app.normalRadius
        }

        header: Rectangle {
            width: parent.width
            height: app.largeButtonHeight * 1.1
            color: "#e74c3c"
            radius: app.normalRadius

            Text {
                anchors.centerIn: parent
                text: "⚠ " + registerView.tr("Error")
                font.pixelSize: app.mediumFontSize
                font.bold: true
                color: "#ffffff"
            }
        }

        ColumnLayout {
            width: parent.width
            spacing: app.normalSpacing

            Text {
                Layout.fillWidth: true
                Layout.margins: app.largeSpacing
                Layout.preferredHeight: implicitHeight
                text: errorDialog.errorText
                font.pixelSize: app.baseFontSize
                color: "#ffffff"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
                lineHeight: 1.4
            }
        }
    }
}
