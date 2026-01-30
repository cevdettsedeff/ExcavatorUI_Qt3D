import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: root
    color: themeManager ? themeManager.backgroundColor : "#2d3748"

    // Theme colors
    property color primaryColor: themeManager ? themeManager.primaryColor : "#00bcd4"
    property color surfaceColor: themeManager ? themeManager.surfaceColor : "#2a2a2a"
    property color textColor: themeManager ? themeManager.textColor : "#ffffff"
    property color textSecondaryColor: themeManager ? themeManager.textColorSecondary : "#888888"
    property color borderColor: themeManager ? themeManager.borderColor : "#404040"

    // Dil desteği
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    function tr(text) {
        return languageTrigger >= 0 ? qsTranslate("Main", text) : ""
    }

    Connections {
        target: translationService
        function onLanguageChanged() {
            languageTrigger++
        }
    }

    // Kullanıcı bilgileri
    property bool isAdmin: authService ? authService.isAdmin : false
    property string currentUsername: authService ? authService.currentUser : ""
    property var pendingUsers: []
    property var allUsers: []

    Component.onCompleted: {
        refreshUserLists()
    }

    Connections {
        target: authService
        function onUserListChanged() {
            refreshUserLists()
        }
    }

    function refreshUserLists() {
        if (authService && authService.isAdmin) {
            pendingUsers = authService.getPendingUsers()
            allUsers = authService.getAllUsers()
        }
    }

    // İçerik alanı
    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        clip: true

        ColumnLayout {
            width: parent.width - 20
            spacing: 25

            // ==================== PROFİL AYARLARIM (TÜM KULLANICILAR) ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.minimumHeight: profileContent.implicitHeight + 40
                color: root.surfaceColor
                radius: 12
                border.color: root.primaryColor
                border.width: 2

                Column {
                    id: profileContent
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20

                    // Başlık
                    RowLayout {
                        width: parent.width
                        spacing: 12

                        Rectangle {
                            width: 4
                            height: 30
                            radius: 2
                            color: root.primaryColor
                        }

                        Text {
                            text: tr("My Profile")
                            font.pixelSize: app.mediumFontSize
                            font.bold: true
                            color: root.textColor
                            Layout.fillWidth: true
                        }
                    }

                    // Profil kartı
                    Rectangle {
                        width: parent.width
                        height: 120
                        color: Qt.darker(root.surfaceColor, 1.1)
                        radius: 12
                        border.color: root.borderColor
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 20

                            // Avatar
                            Rectangle {
                                width: 80
                                height: 80
                                radius: 40
                                color: isAdmin ? "#9c27b0" : root.primaryColor

                                Text {
                                    anchors.centerIn: parent
                                    text: isAdmin ? "👑" : currentUsername.charAt(0).toUpperCase()
                                    font.pixelSize: isAdmin ? 36 : 32
                                    font.bold: true
                                    color: "white"
                                }
                            }

                            // Kullanıcı bilgileri
                            Column {
                                spacing: 8
                                Layout.fillWidth: true

                                Row {
                                    spacing: 12

                                    Text {
                                        text: currentUsername
                                        font.pixelSize: app.largeFontSize
                                        font.bold: true
                                        color: root.textColor
                                    }

                                    Rectangle {
                                        visible: isAdmin
                                        width: adminBadge.width + 16
                                        height: 24
                                        radius: 12
                                        color: "#9c27b0"
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            id: adminBadge
                                            anchors.centerIn: parent
                                            text: "ADMIN"
                                            font.pixelSize: app.smallFontSize * 0.9
                                            font.bold: true
                                            color: "white"
                                        }
                                    }

                                    Rectangle {
                                        visible: !isAdmin
                                        width: operatorBadge.width + 16
                                        height: 24
                                        radius: 12
                                        color: root.primaryColor
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            id: operatorBadge
                                            anchors.centerIn: parent
                                            text: tr("OPERATOR")
                                            font.pixelSize: app.smallFontSize * 0.9
                                            font.bold: true
                                            color: "white"
                                        }
                                    }
                                }

                                Text {
                                    text: isAdmin ? tr("Full system access") : tr("Standard user access")
                                    font.pixelSize: app.smallFontSize
                                    color: root.textSecondaryColor
                                }
                            }
                        }
                    }

                    // Profil işlemleri
                    Row {
                        width: parent.width
                        spacing: 15

                        // İsim Değiştir
                        Rectangle {
                            width: (parent.width - 15) / 2
                            height: 60
                            radius: 10
                            color: changeNameArea.containsMouse ? Qt.lighter("#2196F3", 1.1) : "#2196F3"

                            Row {
                                anchors.centerIn: parent
                                spacing: 10

                                Text {
                                    text: "✎"
                                    font.pixelSize: app.largeFontSize
                                    color: "white"
                                }

                                Text {
                                    text: tr("Change Name")
                                    font.pixelSize: app.baseFontSize
                                    font.bold: true
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: changeNameArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: changeNameDialog.open()
                            }

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        // Şifre Değiştir
                        Rectangle {
                            width: (parent.width - 15) / 2
                            height: 60
                            radius: 10
                            color: changePasswordArea.containsMouse ? Qt.lighter("#ff9800", 1.1) : "#ff9800"

                            Row {
                                anchors.centerIn: parent
                                spacing: 10

                                Text {
                                    text: "🔒"
                                    font.pixelSize: app.largeFontSize
                                }

                                Text {
                                    text: tr("Change Password")
                                    font.pixelSize: app.baseFontSize
                                    font.bold: true
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: changePasswordArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: changePasswordDialog.open()
                            }

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }
                }
            }

            // ==================== KULLANICI YÖNETİMİ (SADECE ADMİN) ====================

            // Onay Bekleyen Kullanıcılar (Sadece Admin)
            Rectangle {
                visible: isAdmin
                Layout.fillWidth: true
                Layout.minimumHeight: pendingContent.implicitHeight + 40
                color: root.surfaceColor
                radius: 12
                border.color: "#ff9800"
                border.width: 2

                Column {
                    id: pendingContent
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    // Başlık
                    RowLayout {
                        width: parent.width
                        spacing: 12

                        Rectangle {
                            width: 4
                            height: 30
                            radius: 2
                            color: "#ff9800"
                        }

                        Column {
                            spacing: 2
                            Layout.fillWidth: true

                            Text {
                                text: tr("Pending Approval")
                                font.pixelSize: app.mediumFontSize
                                font.bold: true
                                color: root.textColor
                            }

                            Text {
                                text: pendingUsers.length + " " + tr("users waiting")
                                font.pixelSize: app.smallFontSize
                                color: "#ff9800"
                            }
                        }
                    }

                    // Pending user listesi
                    Column {
                        width: parent.width
                        spacing: 10

                        Repeater {
                            model: pendingUsers

                            Rectangle {
                                width: parent.width
                                height: 80
                                color: Qt.darker(root.surfaceColor, 1.1)
                                radius: 8
                                border.color: root.borderColor
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Rectangle {
                                        width: 50
                                        height: 50
                                        radius: 25
                                        color: "#ff9800"

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.username.charAt(0).toUpperCase()
                                            font.pixelSize: app.largeFontSize
                                            font.bold: true
                                            color: "white"
                                        }
                                    }

                                    Column {
                                        spacing: 4
                                        Layout.fillWidth: true

                                        Text {
                                            text: modelData.username
                                            font.pixelSize: app.mediumFontSize
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        Text {
                                            text: Qt.formatDateTime(new Date(modelData.createdAt), "dd.MM.yyyy hh:mm")
                                            font.pixelSize: app.smallFontSize
                                            color: root.textSecondaryColor
                                        }
                                    }

                                    // Onayla butonu
                                    Rectangle {
                                        width: approveText.width + 30
                                        height: 44
                                        radius: 8
                                        color: approveArea.containsMouse ? "#4CAF50" : "#388e3c"

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 6

                                            Text {
                                                text: "✓"
                                                font.pixelSize: app.mediumFontSize
                                                font.bold: true
                                                color: "white"
                                            }

                                            Text {
                                                id: approveText
                                                text: tr("Approve")
                                                font.pixelSize: app.baseFontSize
                                                font.bold: true
                                                color: "white"
                                            }
                                        }

                                        MouseArea {
                                            id: approveArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (authService.approveUser(modelData.id)) {
                                                    console.log("Kullanıcı onaylandı:", modelData.username)
                                                }
                                            }
                                        }

                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }

                                    // Reddet butonu
                                    Rectangle {
                                        width: rejectText.width + 30
                                        height: 44
                                        radius: 8
                                        color: rejectArea.containsMouse ? "#f44336" : "#d32f2f"

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 6

                                            Text {
                                                text: "✗"
                                                font.pixelSize: app.mediumFontSize
                                                font.bold: true
                                                color: "white"
                                            }

                                            Text {
                                                id: rejectText
                                                text: tr("Reject")
                                                font.pixelSize: app.baseFontSize
                                                font.bold: true
                                                color: "white"
                                            }
                                        }

                                        MouseArea {
                                            id: rejectArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (authService.rejectUser(modelData.id)) {
                                                    console.log("Kullanıcı reddedildi:", modelData.username)
                                                }
                                            }
                                        }

                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }
                                }
                            }
                        }

                        // Boş mesajı
                        Rectangle {
                            visible: pendingUsers.length === 0
                            width: parent.width
                            height: 60
                            color: Qt.darker(root.surfaceColor, 1.1)
                            radius: 8

                            Row {
                                anchors.centerIn: parent
                                spacing: 10

                                Text {
                                    text: "✓"
                                    font.pixelSize: app.xlFontSize
                                    color: "#4CAF50"
                                }

                                Text {
                                    text: tr("No pending requests")
                                    font.pixelSize: app.baseFontSize
                                    color: root.textSecondaryColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }

            // Tüm Kullanıcılar (Sadece Admin)
            Rectangle {
                visible: isAdmin
                Layout.fillWidth: true
                Layout.minimumHeight: allUsersContent.implicitHeight + 40
                color: root.surfaceColor
                radius: 12
                border.color: root.primaryColor
                border.width: 2

                Column {
                    id: allUsersContent
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    // Başlık ve Yeni Kullanıcı butonu
                    RowLayout {
                        width: parent.width
                        spacing: 12

                        Rectangle {
                            width: 4
                            height: 30
                            radius: 2
                            color: root.primaryColor
                        }

                        Column {
                            spacing: 2
                            Layout.fillWidth: true

                            Text {
                                text: tr("All Users")
                                font.pixelSize: app.mediumFontSize
                                font.bold: true
                                color: root.textColor
                            }

                            Text {
                                text: allUsers.length + " " + tr("registered")
                                font.pixelSize: app.smallFontSize
                                color: root.primaryColor
                            }
                        }

                        Rectangle {
                            width: addUserRow.width + 30
                            height: 44
                            radius: 8
                            color: addUserArea.containsMouse ? Qt.lighter(root.primaryColor, 1.1) : root.primaryColor

                            Row {
                                id: addUserRow
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: "+"
                                    font.pixelSize: app.largeFontSize
                                    font.bold: true
                                    color: "white"
                                }

                                Text {
                                    text: tr("Add User")
                                    font.pixelSize: app.baseFontSize
                                    font.bold: true
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: addUserArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: addUserDialog.open()
                            }

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    // Kullanıcı listesi
                    Column {
                        width: parent.width
                        spacing: 10

                        Repeater {
                            model: allUsers

                            Rectangle {
                                width: parent.width
                                height: 80
                                color: Qt.darker(root.surfaceColor, 1.1)
                                radius: 8
                                border.color: root.borderColor
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Rectangle {
                                        width: 50
                                        height: 50
                                        radius: 25
                                        color: modelData.isAdmin ? "#9c27b0" : root.primaryColor

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.isAdmin ? "👑" : modelData.username.charAt(0).toUpperCase()
                                            font.pixelSize: modelData.isAdmin ? 22 : 20
                                            font.bold: true
                                            color: "white"
                                        }
                                    }

                                    Column {
                                        spacing: 4
                                        Layout.fillWidth: true

                                        Row {
                                            spacing: 8

                                            Text {
                                                text: modelData.username
                                                font.pixelSize: app.mediumFontSize
                                                font.bold: true
                                                color: root.textColor
                                            }

                                            Rectangle {
                                                visible: modelData.isAdmin
                                                width: adminLabel.width + 12
                                                height: 20
                                                radius: 10
                                                color: "#9c27b0"

                                                Text {
                                                    id: adminLabel
                                                    anchors.centerIn: parent
                                                    text: "ADMIN"
                                                    font.pixelSize: app.smallFontSize * 0.8
                                                    font.bold: true
                                                    color: "white"
                                                }
                                            }

                                            // Mevcut kullanıcı etiketi
                                            Rectangle {
                                                visible: modelData.username === currentUsername
                                                width: youLabel.width + 12
                                                height: 20
                                                radius: 10
                                                color: "#4CAF50"

                                                Text {
                                                    id: youLabel
                                                    anchors.centerIn: parent
                                                    text: tr("YOU")
                                                    font.pixelSize: app.smallFontSize * 0.8
                                                    font.bold: true
                                                    color: "white"
                                                }
                                            }
                                        }

                                        Text {
                                            text: Qt.formatDateTime(new Date(modelData.createdAt), "dd.MM.yyyy hh:mm")
                                            font.pixelSize: app.smallFontSize
                                            color: root.textSecondaryColor
                                        }
                                    }

                                    // Düzenle butonu
                                    Rectangle {
                                        width: editBtnText.width + 30
                                        height: 44
                                        radius: 8
                                        color: editArea.containsMouse ? "#2196F3" : "#1976d2"

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 6

                                            Text {
                                                text: "✎"
                                                font.pixelSize: app.mediumFontSize
                                                color: "white"
                                            }

                                            Text {
                                                id: editBtnText
                                                text: tr("Edit")
                                                font.pixelSize: app.baseFontSize
                                                font.bold: true
                                                color: "white"
                                            }
                                        }

                                        MouseArea {
                                            id: editArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                editUserDialog.userId = modelData.id
                                                editUserDialog.username = modelData.username
                                                editUserDialog.isAdmin = modelData.isAdmin
                                                editUserDialog.open()
                                            }
                                        }

                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }

                                    // Sil butonu
                                    Rectangle {
                                        width: deleteBtnText.width + 30
                                        height: 44
                                        radius: 8
                                        color: deleteArea.enabled ? (deleteArea.containsMouse ? "#f44336" : "#d32f2f") : "#555555"
                                        opacity: deleteArea.enabled ? 1.0 : 0.5

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 6

                                            Text {
                                                text: "🗑"
                                                font.pixelSize: app.baseFontSize
                                            }

                                            Text {
                                                id: deleteBtnText
                                                text: tr("Delete")
                                                font.pixelSize: app.baseFontSize
                                                font.bold: true
                                                color: "white"
                                            }
                                        }

                                        MouseArea {
                                            id: deleteArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                            enabled: modelData.username !== currentUsername
                                            onClicked: {
                                                deleteConfirmDialog.userId = modelData.id
                                                deleteConfirmDialog.username = modelData.username
                                                deleteConfirmDialog.open()
                                            }
                                        }

                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ==================== DIALOG'LAR ====================

    // İsim Değiştirme Dialog (Profil için)
    Dialog {
        id: changeNameDialog
        title: ""
        anchors.centerIn: parent
        width: 420
        modal: true
        dim: true

        onOpened: {
            newNameField.text = currentUsername
        }

        Overlay.modal: Rectangle {
            color: Qt.rgba(0, 0, 0, 0.7)
        }

        background: Rectangle {
            color: root.surfaceColor
            radius: 16
            border.color: "#2196F3"
            border.width: 2
        }

        contentItem: Column {
            spacing: 24
            padding: 24

            // Header
            Row {
                spacing: 16
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 56
                    height: 56
                    radius: 28
                    color: "#2196F3"

                    Text {
                        anchors.centerIn: parent
                        text: "✎"
                        font.pixelSize: 26
                        color: "white"
                    }
                }

                Column {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: tr("Change Name")
                        font.pixelSize: 22
                        font.bold: true
                        color: root.textColor
                    }

                    Text {
                        text: tr("Update your username")
                        font.pixelSize: 13
                        color: root.textSecondaryColor
                    }
                }
            }

            Rectangle {
                width: parent.width - 48
                height: 1
                color: root.borderColor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Form
            Column {
                width: parent.width - 48
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 18

                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: tr("New Username")
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: root.textColor
                    }

                    TextField {
                        id: newNameField
                        width: parent.width
                        height: 48
                        placeholderText: tr("Enter new username...")
                        font.pixelSize: 15
                        color: root.textColor
                        placeholderTextColor: root.textSecondaryColor
                        leftPadding: 15

                        background: Rectangle {
                            color: Qt.darker(root.surfaceColor, 1.3)
                            radius: 10
                            border.color: newNameField.activeFocus ? "#2196F3" : root.borderColor
                            border.width: newNameField.activeFocus ? 2 : 1
                        }
                    }
                }
            }

            // Buttons
            Row {
                spacing: 16
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 140
                    height: 50
                    radius: 10
                    color: cancelNameArea.containsMouse ? Qt.lighter(root.borderColor, 1.2) : root.borderColor

                    Text {
                        anchors.centerIn: parent
                        text: tr("Cancel")
                        font.pixelSize: 15
                        font.bold: true
                        color: root.textColor
                    }

                    MouseArea {
                        id: cancelNameArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: changeNameDialog.close()
                    }
                }

                Rectangle {
                    width: 140
                    height: 50
                    radius: 10
                    color: saveNameArea.containsMouse ? Qt.lighter("#2196F3", 1.1) : "#2196F3"

                    Text {
                        anchors.centerIn: parent
                        text: tr("Save")
                        font.pixelSize: 15
                        font.bold: true
                        color: "white"
                    }

                    MouseArea {
                        id: saveNameArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (newNameField.text.length >= 3 && newNameField.text !== currentUsername) {
                                if (authService.updateCurrentUserName(newNameField.text)) {
                                    changeNameDialog.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Şifre Değiştirme Dialog (Profil için)
    Dialog {
        id: changePasswordDialog
        title: ""
        anchors.centerIn: parent
        width: 420
        modal: true
        dim: true

        onOpened: {
            currentPasswordField.text = ""
            newPasswordField.text = ""
            confirmPasswordField.text = ""
        }

        Overlay.modal: Rectangle {
            color: Qt.rgba(0, 0, 0, 0.7)
        }

        background: Rectangle {
            color: root.surfaceColor
            radius: 16
            border.color: "#ff9800"
            border.width: 2
        }

        contentItem: Column {
            spacing: 24
            padding: 24

            // Header
            Row {
                spacing: 16
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 56
                    height: 56
                    radius: 28
                    color: "#ff9800"

                    Text {
                        anchors.centerIn: parent
                        text: "🔒"
                        font.pixelSize: 26
                    }
                }

                Column {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: tr("Change Password")
                        font.pixelSize: 22
                        font.bold: true
                        color: root.textColor
                    }

                    Text {
                        text: tr("Update your password")
                        font.pixelSize: 13
                        color: root.textSecondaryColor
                    }
                }
            }

            Rectangle {
                width: parent.width - 48
                height: 1
                color: root.borderColor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Form
            Column {
                width: parent.width - 48
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 18

                // Mevcut şifre
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: tr("Current Password")
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: root.textColor
                    }

                    TextField {
                        id: currentPasswordField
                        width: parent.width
                        height: 48
                        placeholderText: tr("Enter current password...")
                        echoMode: TextInput.Password
                        font.pixelSize: 15
                        color: root.textColor
                        placeholderTextColor: root.textSecondaryColor
                        leftPadding: 15

                        background: Rectangle {
                            color: Qt.darker(root.surfaceColor, 1.3)
                            radius: 10
                            border.color: currentPasswordField.activeFocus ? "#ff9800" : root.borderColor
                            border.width: currentPasswordField.activeFocus ? 2 : 1
                        }
                    }
                }

                // Yeni şifre
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: tr("New Password")
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: root.textColor
                    }

                    TextField {
                        id: newPasswordField
                        width: parent.width
                        height: 48
                        placeholderText: tr("Minimum 6 characters")
                        echoMode: TextInput.Password
                        font.pixelSize: 15
                        color: root.textColor
                        placeholderTextColor: root.textSecondaryColor
                        leftPadding: 15

                        background: Rectangle {
                            color: Qt.darker(root.surfaceColor, 1.3)
                            radius: 10
                            border.color: newPasswordField.activeFocus ? "#ff9800" : root.borderColor
                            border.width: newPasswordField.activeFocus ? 2 : 1
                        }
                    }
                }

                // Şifre tekrar
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: tr("Confirm Password")
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: root.textColor
                    }

                    TextField {
                        id: confirmPasswordField
                        width: parent.width
                        height: 48
                        placeholderText: tr("Re-enter new password...")
                        echoMode: TextInput.Password
                        font.pixelSize: 15
                        color: root.textColor
                        placeholderTextColor: root.textSecondaryColor
                        leftPadding: 15

                        background: Rectangle {
                            color: Qt.darker(root.surfaceColor, 1.3)
                            radius: 10
                            border.color: confirmPasswordField.activeFocus ? "#ff9800" : root.borderColor
                            border.width: confirmPasswordField.activeFocus ? 2 : 1
                        }
                    }
                }

                // Uyarı mesajı
                Text {
                    visible: newPasswordField.text.length > 0 && confirmPasswordField.text.length > 0 && newPasswordField.text !== confirmPasswordField.text
                    text: tr("Passwords do not match")
                    font.pixelSize: app.smallFontSize
                    color: "#f44336"
                }
            }

            // Buttons
            Row {
                spacing: 16
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 140
                    height: 50
                    radius: 10
                    color: cancelPassArea.containsMouse ? Qt.lighter(root.borderColor, 1.2) : root.borderColor

                    Text {
                        anchors.centerIn: parent
                        text: tr("Cancel")
                        font.pixelSize: 15
                        font.bold: true
                        color: root.textColor
                    }

                    MouseArea {
                        id: cancelPassArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: changePasswordDialog.close()
                    }
                }

                Rectangle {
                    width: 140
                    height: 50
                    radius: 10
                    color: savePassArea.containsMouse ? Qt.lighter("#ff9800", 1.1) : "#ff9800"

                    Text {
                        anchors.centerIn: parent
                        text: tr("Save")
                        font.pixelSize: 15
                        font.bold: true
                        color: "white"
                    }

                    MouseArea {
                        id: savePassArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (currentPasswordField.text.length >= 6 &&
                                newPasswordField.text.length >= 6 &&
                                newPasswordField.text === confirmPasswordField.text) {
                                if (authService.changeCurrentUserPassword(currentPasswordField.text, newPasswordField.text)) {
                                    changePasswordDialog.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Yeni Kullanıcı Ekleme Dialog (Admin)
    Dialog {
        id: addUserDialog
        title: ""
        anchors.centerIn: parent
        width: 420
        modal: true
        dim: true

        Overlay.modal: Rectangle {
            color: Qt.rgba(0, 0, 0, 0.7)
        }

        background: Rectangle {
            color: root.surfaceColor
            radius: 16
            border.color: root.primaryColor
            border.width: 2
        }

        contentItem: Column {
            spacing: 24
            padding: 24

            // Header
            Row {
                spacing: 16
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 56
                    height: 56
                    radius: 28
                    color: root.primaryColor

                    Text {
                        anchors.centerIn: parent
                        text: "👤"
                        font.pixelSize: 28
                    }
                }

                Column {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: tr("Add New User")
                        font.pixelSize: 22
                        font.bold: true
                        color: root.textColor
                    }

                    Text {
                        text: tr("Create a new user account")
                        font.pixelSize: 13
                        color: root.textSecondaryColor
                    }
                }
            }

            Rectangle {
                width: parent.width - 48
                height: 1
                color: root.borderColor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Form
            Column {
                width: parent.width - 48
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 18

                // Username
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: tr("Username")
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: root.textColor
                    }

                    TextField {
                        id: addUsernameField
                        width: parent.width
                        height: 48
                        placeholderText: tr("Enter username...")
                        font.pixelSize: 15
                        color: root.textColor
                        placeholderTextColor: root.textSecondaryColor
                        leftPadding: 15

                        background: Rectangle {
                            color: Qt.darker(root.surfaceColor, 1.3)
                            radius: 10
                            border.color: addUsernameField.activeFocus ? root.primaryColor : root.borderColor
                            border.width: addUsernameField.activeFocus ? 2 : 1
                        }
                    }
                }

                // Password
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: tr("Password")
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: root.textColor
                    }

                    TextField {
                        id: addPasswordField
                        width: parent.width
                        height: 48
                        placeholderText: tr("Minimum 6 characters")
                        echoMode: TextInput.Password
                        font.pixelSize: 15
                        color: root.textColor
                        placeholderTextColor: root.textSecondaryColor
                        leftPadding: 15

                        background: Rectangle {
                            color: Qt.darker(root.surfaceColor, 1.3)
                            radius: 10
                            border.color: addPasswordField.activeFocus ? root.primaryColor : root.borderColor
                            border.width: addPasswordField.activeFocus ? 2 : 1
                        }
                    }
                }

                // Admin checkbox
                Rectangle {
                    width: parent.width
                    height: 52
                    radius: 10
                    color: addAdminCheck.checked ? Qt.rgba(156/255, 39/255, 176/255, 0.2) : Qt.darker(root.surfaceColor, 1.3)
                    border.color: addAdminCheck.checked ? "#9c27b0" : root.borderColor
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 12

                        Rectangle {
                            width: 26
                            height: 26
                            radius: 6
                            color: addAdminCheck.checked ? "#9c27b0" : "transparent"
                            border.color: addAdminCheck.checked ? "#9c27b0" : root.textSecondaryColor
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "✓"
                                font.pixelSize: app.mediumFontSize
                                font.bold: true
                                color: "white"
                                visible: addAdminCheck.checked
                            }
                        }

                        Text {
                            text: tr("Grant admin permission")
                            font.pixelSize: 15
                            color: root.textColor
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: addAdminCheck.checked = !addAdminCheck.checked
                    }

                    CheckBox {
                        id: addAdminCheck
                        visible: false
                    }
                }
            }

            // Buttons
            Row {
                spacing: 16
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 140
                    height: 50
                    radius: 10
                    color: cancelAddArea.containsMouse ? Qt.lighter(root.borderColor, 1.2) : root.borderColor

                    Text {
                        anchors.centerIn: parent
                        text: tr("Cancel")
                        font.pixelSize: 15
                        font.bold: true
                        color: root.textColor
                    }

                    MouseArea {
                        id: cancelAddArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: addUserDialog.close()
                    }
                }

                Rectangle {
                    width: 140
                    height: 50
                    radius: 10
                    color: saveAddArea.containsMouse ? Qt.lighter(root.primaryColor, 1.1) : root.primaryColor

                    Text {
                        anchors.centerIn: parent
                        text: tr("Create")
                        font.pixelSize: 15
                        font.bold: true
                        color: "white"
                    }

                    MouseArea {
                        id: saveAddArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (addUsernameField.text.length >= 3 && addPasswordField.text.length >= 6) {
                                if (authService.createUserByAdmin(addUsernameField.text, addPasswordField.text, addAdminCheck.checked)) {
                                    addUsernameField.text = ""
                                    addPasswordField.text = ""
                                    addAdminCheck.checked = false
                                    addUserDialog.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Kullanıcı Düzenleme Dialog (Admin)
    Dialog {
        id: editUserDialog
        title: ""
        anchors.centerIn: parent
        width: 420
        modal: true
        dim: true

        property int userId: 0
        property string username: ""
        property bool isAdmin: false

        onOpened: {
            editUsernameField.text = username
            editAdminCheck.checked = isAdmin
            editPasswordField.text = ""
        }

        Overlay.modal: Rectangle {
            color: Qt.rgba(0, 0, 0, 0.7)
        }

        background: Rectangle {
            color: root.surfaceColor
            radius: 16
            border.color: "#2196F3"
            border.width: 2
        }

        contentItem: Column {
            spacing: 24
            padding: 24

            // Header
            Row {
                spacing: 16
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 56
                    height: 56
                    radius: 28
                    color: "#2196F3"

                    Text {
                        anchors.centerIn: parent
                        text: "✎"
                        font.pixelSize: 26
                        color: "white"
                    }
                }

                Column {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: tr("Edit User")
                        font.pixelSize: 22
                        font.bold: true
                        color: root.textColor
                    }

                    Text {
                        text: tr("Update user information")
                        font.pixelSize: 13
                        color: root.textSecondaryColor
                    }
                }
            }

            Rectangle {
                width: parent.width - 48
                height: 1
                color: root.borderColor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Form
            Column {
                width: parent.width - 48
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 18

                // Username
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: tr("Username")
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: root.textColor
                    }

                    TextField {
                        id: editUsernameField
                        width: parent.width
                        height: 48
                        font.pixelSize: 15
                        color: root.textColor
                        leftPadding: 15

                        background: Rectangle {
                            color: Qt.darker(root.surfaceColor, 1.3)
                            radius: 10
                            border.color: editUsernameField.activeFocus ? "#2196F3" : root.borderColor
                            border.width: editUsernameField.activeFocus ? 2 : 1
                        }
                    }
                }

                // New Password
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: tr("New Password")
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: root.textColor
                    }

                    TextField {
                        id: editPasswordField
                        width: parent.width
                        height: 48
                        placeholderText: tr("Leave blank to keep current")
                        echoMode: TextInput.Password
                        font.pixelSize: 15
                        color: root.textColor
                        placeholderTextColor: root.textSecondaryColor
                        leftPadding: 15

                        background: Rectangle {
                            color: Qt.darker(root.surfaceColor, 1.3)
                            radius: 10
                            border.color: editPasswordField.activeFocus ? "#2196F3" : root.borderColor
                            border.width: editPasswordField.activeFocus ? 2 : 1
                        }
                    }
                }

                // Admin checkbox
                Rectangle {
                    width: parent.width
                    height: 52
                    radius: 10
                    color: editAdminCheck.checked ? Qt.rgba(156/255, 39/255, 176/255, 0.2) : Qt.darker(root.surfaceColor, 1.3)
                    border.color: editAdminCheck.checked ? "#9c27b0" : root.borderColor
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 12

                        Rectangle {
                            width: 26
                            height: 26
                            radius: 6
                            color: editAdminCheck.checked ? "#9c27b0" : "transparent"
                            border.color: editAdminCheck.checked ? "#9c27b0" : root.textSecondaryColor
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "✓"
                                font.pixelSize: app.mediumFontSize
                                font.bold: true
                                color: "white"
                                visible: editAdminCheck.checked
                            }
                        }

                        Text {
                            text: tr("Admin permission")
                            font.pixelSize: 15
                            color: root.textColor
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: editAdminCheck.checked = !editAdminCheck.checked
                    }

                    CheckBox {
                        id: editAdminCheck
                        visible: false
                    }
                }
            }

            // Buttons
            Row {
                spacing: 16
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 140
                    height: 50
                    radius: 10
                    color: cancelEditArea.containsMouse ? Qt.lighter(root.borderColor, 1.2) : root.borderColor

                    Text {
                        anchors.centerIn: parent
                        text: tr("Cancel")
                        font.pixelSize: 15
                        font.bold: true
                        color: root.textColor
                    }

                    MouseArea {
                        id: cancelEditArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: editUserDialog.close()
                    }
                }

                Rectangle {
                    width: 140
                    height: 50
                    radius: 10
                    color: saveEditArea.containsMouse ? Qt.lighter("#2196F3", 1.1) : "#2196F3"

                    Text {
                        anchors.centerIn: parent
                        text: tr("Save")
                        font.pixelSize: 15
                        font.bold: true
                        color: "white"
                    }

                    MouseArea {
                        id: saveEditArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (editUsernameField.text.length >= 3) {
                                if (authService.updateUser(editUserDialog.userId, editUsernameField.text, editPasswordField.text, editAdminCheck.checked)) {
                                    editUserDialog.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Silme Onay Dialog (Admin)
    Dialog {
        id: deleteConfirmDialog
        title: ""
        anchors.centerIn: parent
        width: 400
        modal: true
        dim: true

        property int userId: 0
        property string username: ""

        Overlay.modal: Rectangle {
            color: Qt.rgba(0, 0, 0, 0.7)
        }

        background: Rectangle {
            color: root.surfaceColor
            radius: 16
            border.color: "#f44336"
            border.width: 2
        }

        contentItem: Column {
            spacing: 24
            padding: 24

            // Warning icon
            Rectangle {
                width: 72
                height: 72
                radius: 36
                color: "#f44336"
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    anchors.centerIn: parent
                    text: "!"
                    font.pixelSize: 42
                    font.bold: true
                    color: "white"
                }
            }

            Column {
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: tr("Delete User?")
                    font.pixelSize: 22
                    font.bold: true
                    color: root.textColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: tr("This action cannot be undone")
                    font.pixelSize: app.baseFontSize
                    color: root.textSecondaryColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // Username display
            Rectangle {
                width: parent.width - 48
                height: 56
                radius: 10
                color: Qt.rgba(244/255, 67/255, 54/255, 0.15)
                border.color: "#f44336"
                border.width: 1
                anchors.horizontalCenter: parent.horizontalCenter

                Row {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        text: "👤"
                        font.pixelSize: app.xlFontSize
                    }

                    Text {
                        text: deleteConfirmDialog.username
                        font.pixelSize: app.mediumFontSize
                        font.bold: true
                        color: root.textColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Buttons
            Row {
                spacing: 16
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 140
                    height: 50
                    radius: 10
                    color: cancelDeleteArea.containsMouse ? Qt.lighter(root.borderColor, 1.2) : root.borderColor

                    Text {
                        anchors.centerIn: parent
                        text: tr("Cancel")
                        font.pixelSize: 15
                        font.bold: true
                        color: root.textColor
                    }

                    MouseArea {
                        id: cancelDeleteArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: deleteConfirmDialog.close()
                    }
                }

                Rectangle {
                    width: 140
                    height: 50
                    radius: 10
                    color: confirmDeleteArea.containsMouse ? Qt.lighter("#f44336", 1.1) : "#f44336"

                    Text {
                        anchors.centerIn: parent
                        text: tr("Delete")
                        font.pixelSize: 15
                        font.bold: true
                        color: "white"
                    }

                    MouseArea {
                        id: confirmDeleteArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (authService.deleteUser(deleteConfirmDialog.userId)) {
                                deleteConfirmDialog.close()
                            }
                        }
                    }
                }
            }
        }
    }
}
