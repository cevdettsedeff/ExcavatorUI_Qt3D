import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: root
    color: themeManager ? themeManager.backgroundColor : "#1a1a1a"

    // Theme colors
    property color primaryColor: themeManager ? themeManager.primaryColor : "#00bcd4"
    property color surfaceColor: themeManager ? themeManager.surfaceColor : "#2a2a2a"
    property color textColor: themeManager ? themeManager.textColor : "#ffffff"
    property color textSecondaryColor: themeManager ? themeManager.textColorSecondary : "#888888"
    property color borderColor: themeManager ? themeManager.borderColor : "#404040"

    // Dil desteği
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    function tr(text) {
        return languageTrigger >= 0 ? qsTr(text) : ""
    }

    Connections {
        target: translationService
        function onLanguageChanged() {
            languageTrigger++
        }
    }

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

            // Onay Bekleyen Kullanıcılar
            Rectangle {
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
                                font.pixelSize: 18
                                font.bold: true
                                color: root.textColor
                            }

                            Text {
                                text: pendingUsers.length + " " + tr("users waiting")
                                font.pixelSize: 12
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
                                height: 70
                                color: Qt.darker(root.surfaceColor, 1.1)
                                radius: 8
                                border.color: root.borderColor
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Rectangle {
                                        width: 44
                                        height: 44
                                        radius: 22
                                        color: "#ff9800"

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.username.charAt(0).toUpperCase()
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: "white"
                                        }
                                    }

                                    Column {
                                        spacing: 4
                                        Layout.fillWidth: true

                                        Text {
                                            text: modelData.username
                                            font.pixelSize: 15
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        Text {
                                            text: Qt.formatDateTime(new Date(modelData.createdAt), "dd.MM.yyyy hh:mm")
                                            font.pixelSize: 11
                                            color: root.textSecondaryColor
                                        }
                                    }

                                    Row {
                                        spacing: 8

                                        Rectangle {
                                            width: 36
                                            height: 36
                                            radius: 18
                                            color: approveArea.containsMouse ? "#4CAF50" : "#388e3c"

                                            Text {
                                                anchors.centerIn: parent
                                                text: "✓"
                                                font.pixelSize: 18
                                                font.bold: true
                                                color: "white"
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

                                        Rectangle {
                                            width: 36
                                            height: 36
                                            radius: 18
                                            color: rejectArea.containsMouse ? "#f44336" : "#d32f2f"

                                            Text {
                                                anchors.centerIn: parent
                                                text: "✗"
                                                font.pixelSize: 18
                                                font.bold: true
                                                color: "white"
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
                                    font.pixelSize: 24
                                    color: "#4CAF50"
                                }

                                Text {
                                    text: tr("No pending requests")
                                    font.pixelSize: 14
                                    color: root.textSecondaryColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }

            // Tüm Kullanıcılar
            Rectangle {
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
                                font.pixelSize: 18
                                font.bold: true
                                color: root.textColor
                            }

                            Text {
                                text: allUsers.length + " " + tr("registered")
                                font.pixelSize: 12
                                color: root.primaryColor
                            }
                        }

                        Rectangle {
                            width: addUserRow.width + 24
                            height: 38
                            radius: 19
                            color: addUserArea.containsMouse ? Qt.lighter(root.primaryColor, 1.1) : root.primaryColor

                            Row {
                                id: addUserRow
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "+"
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "white"
                                }

                                Text {
                                    text: tr("Add User")
                                    font.pixelSize: 13
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
                                onClicked: addUserPopup.open()
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
                                height: 70
                                color: Qt.darker(root.surfaceColor, 1.1)
                                radius: 8
                                border.color: root.borderColor
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Rectangle {
                                        width: 44
                                        height: 44
                                        radius: 22
                                        color: modelData.isAdmin ? "#9c27b0" : root.primaryColor

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.isAdmin ? "👑" : modelData.username.charAt(0).toUpperCase()
                                            font.pixelSize: modelData.isAdmin ? 20 : 18
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
                                                font.pixelSize: 15
                                                font.bold: true
                                                color: root.textColor
                                            }

                                            Rectangle {
                                                visible: modelData.isAdmin
                                                width: adminLabel.width + 10
                                                height: 18
                                                radius: 9
                                                color: "#9c27b0"

                                                Text {
                                                    id: adminLabel
                                                    anchors.centerIn: parent
                                                    text: "ADMIN"
                                                    font.pixelSize: 9
                                                    font.bold: true
                                                    color: "white"
                                                }
                                            }
                                        }

                                        Text {
                                            text: Qt.formatDateTime(new Date(modelData.createdAt), "dd.MM.yyyy hh:mm")
                                            font.pixelSize: 11
                                            color: root.textSecondaryColor
                                        }
                                    }

                                    Row {
                                        spacing: 8

                                        // Edit button
                                        Rectangle {
                                            width: 36
                                            height: 36
                                            radius: 8
                                            color: editArea.containsMouse ? "#2196F3" : "#1976d2"

                                            Text {
                                                anchors.centerIn: parent
                                                text: "✎"
                                                font.pixelSize: 16
                                                color: "white"
                                            }

                                            MouseArea {
                                                id: editArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    editUserPopup.userId = modelData.id
                                                    editUserPopup.username = modelData.username
                                                    editUserPopup.isAdmin = modelData.isAdmin
                                                    editUserPopup.open()
                                                }
                                            }

                                            Behavior on color { ColorAnimation { duration: 150 } }
                                        }

                                        // Delete button
                                        Rectangle {
                                            width: 36
                                            height: 36
                                            radius: 8
                                            color: deleteArea.enabled ? (deleteArea.containsMouse ? "#f44336" : "#d32f2f") : "#555555"
                                            opacity: deleteArea.enabled ? 1.0 : 0.5

                                            Text {
                                                anchors.centerIn: parent
                                                text: "🗑"
                                                font.pixelSize: 16
                                            }

                                            MouseArea {
                                                id: deleteArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                enabled: modelData.username !== authService.currentUser
                                                onClicked: {
                                                    deleteConfirmPopup.userId = modelData.id
                                                    deleteConfirmPopup.username = modelData.username
                                                    deleteConfirmPopup.open()
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
    }

    // ==================== POPUP'LAR ====================

    // Yeni Kullanıcı Ekleme Popup
    Popup {
        id: addUserPopup
        anchors.centerIn: parent
        width: 400
        height: addUserContent.height + 40
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: root.surfaceColor
            radius: 16
            border.color: root.primaryColor
            border.width: 2

            // Shadow effect
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#80000000"
                shadowBlur: 1.0
                shadowVerticalOffset: 8
            }
        }

        contentItem: Column {
            id: addUserContent
            spacing: 20
            padding: 24

            // Header
            Row {
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 48
                    height: 48
                    radius: 24
                    color: root.primaryColor

                    Text {
                        anchors.centerIn: parent
                        text: "👤"
                        font.pixelSize: 24
                    }
                }

                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: tr("Add New User")
                        font.pixelSize: 20
                        font.bold: true
                        color: root.textColor
                    }

                    Text {
                        text: tr("Create a new user account")
                        font.pixelSize: 12
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
                spacing: 16

                // Username
                Column {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: tr("Username")
                        font.pixelSize: 13
                        font.bold: true
                        color: root.textColor
                    }

                    TextField {
                        id: addUsernameField
                        width: parent.width
                        height: 44
                        placeholderText: tr("Enter username...")
                        font.pixelSize: 14
                        color: root.textColor
                        placeholderTextColor: root.textSecondaryColor

                        background: Rectangle {
                            color: Qt.darker(root.surfaceColor, 1.2)
                            radius: 8
                            border.color: addUsernameField.activeFocus ? root.primaryColor : root.borderColor
                            border.width: addUsernameField.activeFocus ? 2 : 1

                            Behavior on border.color { ColorAnimation { duration: 150 } }
                        }
                    }
                }

                // Password
                Column {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: tr("Password")
                        font.pixelSize: 13
                        font.bold: true
                        color: root.textColor
                    }

                    TextField {
                        id: addPasswordField
                        width: parent.width
                        height: 44
                        placeholderText: tr("Minimum 6 characters")
                        echoMode: TextInput.Password
                        font.pixelSize: 14
                        color: root.textColor
                        placeholderTextColor: root.textSecondaryColor

                        background: Rectangle {
                            color: Qt.darker(root.surfaceColor, 1.2)
                            radius: 8
                            border.color: addPasswordField.activeFocus ? root.primaryColor : root.borderColor
                            border.width: addPasswordField.activeFocus ? 2 : 1

                            Behavior on border.color { ColorAnimation { duration: 150 } }
                        }
                    }
                }

                // Admin checkbox
                Rectangle {
                    width: parent.width
                    height: 44
                    radius: 8
                    color: addAdminCheck.checked ? Qt.rgba(156/255, 39/255, 176/255, 0.2) : Qt.darker(root.surfaceColor, 1.2)
                    border.color: addAdminCheck.checked ? "#9c27b0" : root.borderColor
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        Rectangle {
                            width: 22
                            height: 22
                            radius: 4
                            color: addAdminCheck.checked ? "#9c27b0" : "transparent"
                            border.color: addAdminCheck.checked ? "#9c27b0" : root.textSecondaryColor
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "✓"
                                font.pixelSize: 14
                                font.bold: true
                                color: "white"
                                visible: addAdminCheck.checked
                            }

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        Text {
                            text: tr("Grant admin permission")
                            font.pixelSize: 14
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
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 120
                    height: 44
                    radius: 22
                    color: cancelAddArea.containsMouse ? Qt.lighter(root.borderColor, 1.2) : root.borderColor

                    Text {
                        anchors.centerIn: parent
                        text: tr("Cancel")
                        font.pixelSize: 14
                        font.bold: true
                        color: root.textColor
                    }

                    MouseArea {
                        id: cancelAddArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: addUserPopup.close()
                    }

                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Rectangle {
                    width: 120
                    height: 44
                    radius: 22
                    color: saveAddArea.containsMouse ? Qt.lighter(root.primaryColor, 1.1) : root.primaryColor

                    Text {
                        anchors.centerIn: parent
                        text: tr("Create")
                        font.pixelSize: 14
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
                                    addUserPopup.close()
                                }
                            }
                        }
                    }

                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
        }
    }

    // Kullanıcı Düzenleme Popup
    Popup {
        id: editUserPopup
        anchors.centerIn: parent
        width: 400
        height: editUserContent.height + 40
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property int userId: 0
        property string username: ""
        property bool isAdmin: false

        onOpened: {
            editUsernameField.text = username
            editAdminCheck.checked = isAdmin
            editPasswordField.text = ""
        }

        background: Rectangle {
            color: root.surfaceColor
            radius: 16
            border.color: "#2196F3"
            border.width: 2

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#80000000"
                shadowBlur: 1.0
                shadowVerticalOffset: 8
            }
        }

        contentItem: Column {
            id: editUserContent
            spacing: 20
            padding: 24

            // Header
            Row {
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 48
                    height: 48
                    radius: 24
                    color: "#2196F3"

                    Text {
                        anchors.centerIn: parent
                        text: "✎"
                        font.pixelSize: 22
                        color: "white"
                    }
                }

                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: tr("Edit User")
                        font.pixelSize: 20
                        font.bold: true
                        color: root.textColor
                    }

                    Text {
                        text: tr("Update user information")
                        font.pixelSize: 12
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
                spacing: 16

                // Username
                Column {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: tr("Username")
                        font.pixelSize: 13
                        font.bold: true
                        color: root.textColor
                    }

                    TextField {
                        id: editUsernameField
                        width: parent.width
                        height: 44
                        font.pixelSize: 14
                        color: root.textColor

                        background: Rectangle {
                            color: Qt.darker(root.surfaceColor, 1.2)
                            radius: 8
                            border.color: editUsernameField.activeFocus ? "#2196F3" : root.borderColor
                            border.width: editUsernameField.activeFocus ? 2 : 1
                        }
                    }
                }

                // New Password
                Column {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: tr("New Password")
                        font.pixelSize: 13
                        font.bold: true
                        color: root.textColor
                    }

                    TextField {
                        id: editPasswordField
                        width: parent.width
                        height: 44
                        placeholderText: tr("Leave blank to keep current")
                        echoMode: TextInput.Password
                        font.pixelSize: 14
                        color: root.textColor
                        placeholderTextColor: root.textSecondaryColor

                        background: Rectangle {
                            color: Qt.darker(root.surfaceColor, 1.2)
                            radius: 8
                            border.color: editPasswordField.activeFocus ? "#2196F3" : root.borderColor
                            border.width: editPasswordField.activeFocus ? 2 : 1
                        }
                    }
                }

                // Admin checkbox
                Rectangle {
                    width: parent.width
                    height: 44
                    radius: 8
                    color: editAdminCheck.checked ? Qt.rgba(156/255, 39/255, 176/255, 0.2) : Qt.darker(root.surfaceColor, 1.2)
                    border.color: editAdminCheck.checked ? "#9c27b0" : root.borderColor
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        Rectangle {
                            width: 22
                            height: 22
                            radius: 4
                            color: editAdminCheck.checked ? "#9c27b0" : "transparent"
                            border.color: editAdminCheck.checked ? "#9c27b0" : root.textSecondaryColor
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "✓"
                                font.pixelSize: 14
                                font.bold: true
                                color: "white"
                                visible: editAdminCheck.checked
                            }
                        }

                        Text {
                            text: tr("Admin permission")
                            font.pixelSize: 14
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
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 120
                    height: 44
                    radius: 22
                    color: cancelEditArea.containsMouse ? Qt.lighter(root.borderColor, 1.2) : root.borderColor

                    Text {
                        anchors.centerIn: parent
                        text: tr("Cancel")
                        font.pixelSize: 14
                        font.bold: true
                        color: root.textColor
                    }

                    MouseArea {
                        id: cancelEditArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: editUserPopup.close()
                    }

                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Rectangle {
                    width: 120
                    height: 44
                    radius: 22
                    color: saveEditArea.containsMouse ? Qt.lighter("#2196F3", 1.1) : "#2196F3"

                    Text {
                        anchors.centerIn: parent
                        text: tr("Save")
                        font.pixelSize: 14
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
                                if (authService.updateUser(editUserPopup.userId, editUsernameField.text, editPasswordField.text, editAdminCheck.checked)) {
                                    editUserPopup.close()
                                }
                            }
                        }
                    }

                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
        }
    }

    // Silme Onay Popup
    Popup {
        id: deleteConfirmPopup
        anchors.centerIn: parent
        width: 360
        height: deleteContent.height + 40
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property int userId: 0
        property string username: ""

        background: Rectangle {
            color: root.surfaceColor
            radius: 16
            border.color: "#f44336"
            border.width: 2

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#80000000"
                shadowBlur: 1.0
                shadowVerticalOffset: 8
            }
        }

        contentItem: Column {
            id: deleteContent
            spacing: 20
            padding: 24

            // Warning icon
            Rectangle {
                width: 64
                height: 64
                radius: 32
                color: "#f44336"
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    anchors.centerIn: parent
                    text: "!"
                    font.pixelSize: 36
                    font.bold: true
                    color: "white"
                }
            }

            Column {
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: tr("Delete User?")
                    font.pixelSize: 20
                    font.bold: true
                    color: root.textColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: tr("This action cannot be undone")
                    font.pixelSize: 13
                    color: root.textSecondaryColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // Username display
            Rectangle {
                width: parent.width - 48
                height: 50
                radius: 8
                color: Qt.rgba(244/255, 67/255, 54/255, 0.1)
                border.color: "#f44336"
                border.width: 1
                anchors.horizontalCenter: parent.horizontalCenter

                Row {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        text: "👤"
                        font.pixelSize: 20
                    }

                    Text {
                        text: deleteConfirmPopup.username
                        font.pixelSize: 16
                        font.bold: true
                        color: root.textColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Buttons
            Row {
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 120
                    height: 44
                    radius: 22
                    color: cancelDeleteArea.containsMouse ? Qt.lighter(root.borderColor, 1.2) : root.borderColor

                    Text {
                        anchors.centerIn: parent
                        text: tr("Cancel")
                        font.pixelSize: 14
                        font.bold: true
                        color: root.textColor
                    }

                    MouseArea {
                        id: cancelDeleteArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: deleteConfirmPopup.close()
                    }

                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Rectangle {
                    width: 120
                    height: 44
                    radius: 22
                    color: confirmDeleteArea.containsMouse ? Qt.lighter("#f44336", 1.1) : "#f44336"

                    Text {
                        anchors.centerIn: parent
                        text: tr("Delete")
                        font.pixelSize: 14
                        font.bold: true
                        color: "white"
                    }

                    MouseArea {
                        id: confirmDeleteArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (authService.deleteUser(deleteConfirmPopup.userId)) {
                                deleteConfirmPopup.close()
                            }
                        }
                    }

                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
        }
    }
}
