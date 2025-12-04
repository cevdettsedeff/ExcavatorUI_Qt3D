import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#1a1a1a"

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
                text: "👥"
                font.pixelSize: 32
            }

            Text {
                text: "Kullanıcı Yönetimi"
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
                GradientStop { position: 0.5; color: "#9c27b0" }
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
        anchors.rightMargin: 10
        clip: true

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
            width: 12
            anchors.right: parent.right
            anchors.rightMargin: 5

            background: Rectangle {
                color: "#1a1a1a"
                radius: 6
                border.color: "#404040"
                border.width: 1
            }

            contentItem: Rectangle {
                implicitWidth: 12
                radius: 6
                color: parent.pressed ? "#ba68c8" : (parent.hovered ? "#9c27b0" : "#7b1fa2")

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }

                // Glow effect simulation with gradient
                gradient: Gradient {
                    GradientStop { position: 0.0; color: parent.pressed ? "#ba68c8" : (parent.hovered ? "#ab47bc" : "#8e24aa") }
                    GradientStop { position: 0.5; color: parent.pressed ? "#9c27b0" : (parent.hovered ? "#9c27b0" : "#7b1fa2") }
                    GradientStop { position: 1.0; color: parent.pressed ? "#7b1fa2" : (parent.hovered ? "#8e24aa" : "#6a1b9a") }
                }
            }
        }

        ColumnLayout {
            width: parent.width - 20
            spacing: 30

            // Onay Bekleyen Kullanıcılar
            Rectangle {
                Layout.fillWidth: true
                Layout.minimumHeight: pendingContent.implicitHeight + 50
                color: "#252525"
                radius: 15
                border.color: "#ff9800"
                border.width: 3

                Column {
                    id: pendingContent
                    anchors.fill: parent
                    anchors.margins: 25
                    spacing: 20

                    // Başlık
                    RowLayout {
                        width: parent.width
                        spacing: 15

                        Rectangle {
                            width: 5
                            height: 35
                            radius: 2.5
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#ffb74d" }
                                GradientStop { position: 1.0; color: "#ff9800" }
                            }
                        }

                        Column {
                            spacing: 3
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: "Onay Bekleyen Kullanıcılar"
                                font.pixelSize: 22
                                font.bold: true
                                color: "#ffffff"
                            }

                            Text {
                                text: pendingUsers.length + " kullanıcı onay bekliyor"
                                font.pixelSize: 14
                                color: "#ff9800"
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

                    // Pending user listesi
                    Column {
                        width: parent.width
                        spacing: 12

                        Repeater {
                            model: pendingUsers

                            Rectangle {
                                width: parent.width
                                height: 85
                                color: "#2a2a2a"
                                radius: 10
                                border.color: "#404040"
                                border.width: 1

                                Rectangle {
                                    anchors.left: parent.left
                                    width: 4
                                    height: parent.height
                                    radius: 10
                                    color: "#ff9800"
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 20
                                    anchors.rightMargin: 15
                                    spacing: 15

                                    // User icon
                                    Rectangle {
                                        width: 50
                                        height: 50
                                        radius: 25
                                        Layout.alignment: Qt.AlignVCenter
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: "#ffb74d" }
                                            GradientStop { position: 1.0; color: "#ff9800" }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "👤"
                                            font.pixelSize: 24
                                        }
                                    }

                                    // Kullanıcı bilgileri
                                    Column {
                                        spacing: 5
                                        Layout.alignment: Qt.AlignVCenter

                                        Text {
                                            text: modelData.username
                                            font.pixelSize: 17
                                            font.bold: true
                                            color: "#ffffff"
                                        }

                                        Row {
                                            spacing: 8

                                            Text {
                                                text: "🕐"
                                                font.pixelSize: 12
                                            }

                                            Text {
                                                text: Qt.formatDateTime(new Date(modelData.createdAt), "dd.MM.yyyy hh:mm")
                                                font.pixelSize: 13
                                                color: "#999999"
                                            }
                                        }
                                    }

                                    Item { Layout.fillWidth: true }

                                    // Action buttons
                                    Row {
                                        spacing: 10
                                        Layout.alignment: Qt.AlignVCenter

                                        Button {
                                            text: "✓ Onayla"
                                            width: 110
                                            height: 42

                                            background: Rectangle {
                                                radius: 8
                                                gradient: Gradient {
                                                    GradientStop { position: 0.0; color: parent.parent.pressed ? "#45a049" : (parent.parent.hovered ? "#5cb85c" : "#4CAF50") }
                                                    GradientStop { position: 1.0; color: parent.parent.pressed ? "#388e3c" : (parent.parent.hovered ? "#4CAF50" : "#43a047") }
                                                }
                                                border.color: parent.parent.hovered ? "#66BB6A" : "transparent"
                                                border.width: 2

                                                Behavior on opacity {
                                                    NumberAnimation { duration: 150 }
                                                }
                                            }

                                            contentItem: Text {
                                                text: parent.text
                                                font.pixelSize: 13
                                                font.bold: true
                                                color: "#ffffff"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            onClicked: {
                                                if (authService.approveUser(modelData.id)) {
                                                    console.log("Kullanıcı onaylandı:", modelData.username)
                                                }
                                            }
                                        }

                                        Button {
                                            text: "✗ Reddet"
                                            width: 110
                                            height: 42

                                            background: Rectangle {
                                                radius: 8
                                                gradient: Gradient {
                                                    GradientStop { position: 0.0; color: parent.parent.pressed ? "#c0392b" : (parent.parent.hovered ? "#e74c3c" : "#d32f2f") }
                                                    GradientStop { position: 1.0; color: parent.parent.pressed ? "#a93226" : (parent.parent.hovered ? "#d32f2f" : "#c62828") }
                                                }
                                                border.color: parent.parent.hovered ? "#e74c3c" : "transparent"
                                                border.width: 2
                                            }

                                            contentItem: Text {
                                                text: parent.text
                                                font.pixelSize: 13
                                                font.bold: true
                                                color: "#ffffff"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            onClicked: {
                                                if (authService.rejectUser(modelData.id)) {
                                                    console.log("Kullanıcı reddedildi:", modelData.username)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Boş mesajı
                        Rectangle {
                            visible: pendingUsers.length === 0
                            width: parent.width
                            height: 80
                            color: "#2a2a2a"
                            radius: 10
                            border.color: "#404040"
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: "✓"
                                    font.pixelSize: 32
                                    color: "#4CAF50"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: "Tüm kayıt istekleri işlendi"
                                    font.pixelSize: 14
                                    color: "#888888"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                }
            }

            // Tüm Kullanıcılar
            Rectangle {
                Layout.fillWidth: true
                Layout.minimumHeight: allUsersContent.implicitHeight + 50
                color: "#252525"
                radius: 15
                border.color: "#00bcd4"
                border.width: 3

                Column {
                    id: allUsersContent
                    anchors.fill: parent
                    anchors.margins: 25
                    spacing: 20

                    // Başlık ve Yeni Kullanıcı butonu
                    RowLayout {
                        width: parent.width
                        spacing: 15

                        Rectangle {
                            width: 5
                            height: 35
                            radius: 2.5
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#4dd0e1" }
                                GradientStop { position: 1.0; color: "#00bcd4" }
                            }
                        }

                        Column {
                            spacing: 3
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: "Tüm Kullanıcılar"
                                font.pixelSize: 22
                                font.bold: true
                                color: "#ffffff"
                            }

                            Text {
                                text: allUsers.length + " kayıtlı kullanıcı"
                                font.pixelSize: 14
                                color: "#00bcd4"
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            text: "+ Yeni Kullanıcı Ekle"
                            width: 200
                            height: 42
                            Layout.alignment: Qt.AlignVCenter

                            background: Rectangle {
                                radius: 8
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: parent.parent.pressed ? "#0097a7" : (parent.parent.hovered ? "#00acc1" : "#00bcd4") }
                                    GradientStop { position: 1.0; color: parent.parent.pressed ? "#00838f" : (parent.parent.hovered ? "#0097a7" : "#00acc1") }
                                }
                                border.color: parent.parent.hovered ? "#4dd0e1" : "transparent"
                                border.width: 2
                            }

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                font.bold: true
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                addUserDialog.open()
                            }
                        }
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

                    // Kullanıcı listesi
                    Column {
                        width: parent.width
                        spacing: 12

                        Repeater {
                            model: allUsers

                            Rectangle {
                                width: parent.width
                                height: 90
                                color: "#2a2a2a"
                                radius: 10
                                border.color: "#404040"
                                border.width: 1

                                Rectangle {
                                    anchors.left: parent.left
                                    width: 4
                                    height: parent.height
                                    radius: 10
                                    color: modelData.isAdmin ? "#9c27b0" : "#00bcd4"
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 20
                                    anchors.rightMargin: 15
                                    spacing: 15

                                    // User icon
                                    Rectangle {
                                        width: 55
                                        height: 55
                                        radius: 27.5
                                        Layout.alignment: Qt.AlignVCenter
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: modelData.isAdmin ? "#ba68c8" : "#4dd0e1" }
                                            GradientStop { position: 1.0; color: modelData.isAdmin ? "#9c27b0" : "#00bcd4" }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.isAdmin ? "👑" : "👤"
                                            font.pixelSize: 28
                                        }
                                    }

                                    // Kullanıcı bilgileri
                                    Column {
                                        spacing: 6
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.preferredWidth: 250

                                        Row {
                                            spacing: 10

                                            Text {
                                                text: modelData.username
                                                font.pixelSize: 17
                                                font.bold: true
                                                color: "#ffffff"
                                            }

                                            Rectangle {
                                                visible: modelData.isAdmin
                                                width: 65
                                                height: 22
                                                radius: 11
                                                gradient: Gradient {
                                                    GradientStop { position: 0.0; color: "#ba68c8" }
                                                    GradientStop { position: 1.0; color: "#9c27b0" }
                                                }

                                                Text {
                                                    text: "ADMIN"
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                    color: "#ffffff"
                                                    anchors.centerIn: parent
                                                }
                                            }

                                            Rectangle {
                                                visible: !modelData.approved
                                                width: 80
                                                height: 22
                                                radius: 11
                                                color: "#ff9800"

                                                Text {
                                                    text: "BEKLEMEDE"
                                                    font.pixelSize: 9
                                                    font.bold: true
                                                    color: "#ffffff"
                                                    anchors.centerIn: parent
                                                }
                                            }
                                        }

                                        Row {
                                            spacing: 8

                                            Text {
                                                text: "📅"
                                                font.pixelSize: 12
                                            }

                                            Text {
                                                text: Qt.formatDateTime(new Date(modelData.createdAt), "dd.MM.yyyy hh:mm")
                                                font.pixelSize: 12
                                                color: "#888888"
                                            }
                                        }
                                    }

                                    Item { Layout.fillWidth: true }

                                    // Action buttons
                                    Row {
                                        spacing: 10
                                        Layout.alignment: Qt.AlignVCenter

                                        Button {
                                            text: "✎ Düzenle"
                                            width: 100
                                            height: 38

                                            background: Rectangle {
                                                radius: 8
                                                gradient: Gradient {
                                                    GradientStop { position: 0.0; color: parent.parent.pressed ? "#1976d2" : (parent.parent.hovered ? "#2196F3" : "#1565c0") }
                                                    GradientStop { position: 1.0; color: parent.parent.pressed ? "#1565c0" : (parent.parent.hovered ? "#1976d2" : "#0d47a1") }
                                                }
                                                border.color: parent.parent.hovered ? "#42a5f5" : "transparent"
                                                border.width: 2
                                            }

                                            contentItem: Text {
                                                text: parent.text
                                                font.pixelSize: 13
                                                font.bold: true
                                                color: "#ffffff"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            onClicked: {
                                                editUserDialog.currentUserId = modelData.id
                                                editUserDialog.currentUsername = modelData.username
                                                editUserDialog.currentIsAdmin = modelData.isAdmin
                                                editUserDialog.open()
                                            }
                                        }

                                        Button {
                                            text: "✗ Sil"
                                            width: 80
                                            height: 38
                                            enabled: modelData.username !== authService.currentUser

                                            background: Rectangle {
                                                radius: 8
                                                gradient: Gradient {
                                                    GradientStop {
                                                        position: 0.0
                                                        color: parent.parent.enabled ? (parent.parent.pressed ? "#c0392b" : (parent.parent.hovered ? "#e74c3c" : "#d32f2f")) : "#404040"
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: parent.parent.enabled ? (parent.parent.pressed ? "#a93226" : (parent.parent.hovered ? "#d32f2f" : "#c62828")) : "#303030"
                                                    }
                                                }
                                                border.color: parent.parent.enabled && parent.parent.hovered ? "#e74c3c" : "transparent"
                                                border.width: 2
                                            }

                                            contentItem: Text {
                                                text: parent.text
                                                font.pixelSize: 13
                                                font.bold: true
                                                color: parent.enabled ? "#ffffff" : "#666666"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            onClicked: {
                                                deleteConfirmDialog.userIdToDelete = modelData.id
                                                deleteConfirmDialog.usernameToDelete = modelData.username
                                                deleteConfirmDialog.open()
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
    }

    // Yeni Kullanıcı Ekleme Dialog
    Dialog {
        id: addUserDialog
        title: "Yeni Kullanıcı Ekle"
        modal: true
        anchors.centerIn: parent
        width: 450

        property alias username: usernameInput.text
        property alias password: passwordInput.text
        property alias isAdmin: adminCheckbox.checked

        background: Rectangle {
            color: "#2a2a2a"
            radius: 12
            border.color: "#00bcd4"
            border.width: 3
        }

        header: Rectangle {
            height: 60
            color: "transparent"
            radius: 12

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#00bcd4" }
                    GradientStop { position: 1.0; color: "#0097a7" }
                }
                radius: 12
            }

            Text {
                anchors.centerIn: parent
                text: "➕ Yeni Kullanıcı Ekle"
                font.pixelSize: 18
                font.bold: true
                color: "#ffffff"
            }
        }

        ColumnLayout {
            spacing: 20
            width: parent.width
            anchors.margins: 20

            TextField {
                id: usernameInput
                Layout.fillWidth: true
                placeholderText: "Kullanıcı Adı"
                font.pixelSize: 14
                height: 45

                background: Rectangle {
                    color: "#1a1a1a"
                    radius: 8
                    border.color: usernameInput.activeFocus ? "#00bcd4" : "#404040"
                    border.width: 2

                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                }

                color: "#ffffff"
            }

            TextField {
                id: passwordInput
                Layout.fillWidth: true
                placeholderText: "Şifre (minimum 6 karakter)"
                echoMode: TextInput.Password
                font.pixelSize: 14
                height: 45

                background: Rectangle {
                    color: "#1a1a1a"
                    radius: 8
                    border.color: passwordInput.activeFocus ? "#00bcd4" : "#404040"
                    border.width: 2

                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                }

                color: "#ffffff"
            }

            CheckBox {
                id: adminCheckbox
                text: "Admin Yetkisi Ver"
                font.pixelSize: 14

                indicator: Rectangle {
                    width: 22
                    height: 22
                    radius: 4
                    border.color: adminCheckbox.checked ? "#9c27b0" : "#505050"
                    border.width: 2
                    color: adminCheckbox.checked ? "#9c27b0" : "transparent"

                    Text {
                        visible: adminCheckbox.checked
                        text: "✓"
                        anchors.centerIn: parent
                        font.pixelSize: 14
                        font.bold: true
                        color: "#ffffff"
                    }

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                contentItem: Text {
                    text: adminCheckbox.text
                    font: adminCheckbox.font
                    color: "#ffffff"
                    leftPadding: adminCheckbox.indicator.width + 8
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted: {
            if (username.length >= 3 && password.length >= 6) {
                if (authService.createUserByAdmin(username, password, isAdmin)) {
                    console.log("Yeni kullanıcı eklendi:", username)
                    usernameInput.text = ""
                    passwordInput.text = ""
                    adminCheckbox.checked = false
                }
            } else {
                console.log("Geçersiz kullanıcı bilgileri")
            }
        }
    }

    // Kullanıcı Düzenleme Dialog
    Dialog {
        id: editUserDialog
        title: "Kullanıcı Düzenle"
        modal: true
        anchors.centerIn: parent
        width: 450

        property int currentUserId: 0
        property alias currentUsername: editUsernameInput.text
        property alias currentIsAdmin: editAdminCheckbox.checked

        background: Rectangle {
            color: "#2a2a2a"
            radius: 12
            border.color: "#2196F3"
            border.width: 3
        }

        header: Rectangle {
            height: 60
            color: "transparent"
            radius: 12

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#2196F3" }
                    GradientStop { position: 1.0; color: "#1976d2" }
                }
                radius: 12
            }

            Text {
                anchors.centerIn: parent
                text: "✎ Kullanıcı Düzenle"
                font.pixelSize: 18
                font.bold: true
                color: "#ffffff"
            }
        }

        ColumnLayout {
            spacing: 20
            width: parent.width
            anchors.margins: 20

            TextField {
                id: editUsernameInput
                Layout.fillWidth: true
                placeholderText: "Kullanıcı Adı"
                font.pixelSize: 14
                height: 45

                background: Rectangle {
                    color: "#1a1a1a"
                    radius: 8
                    border.color: editUsernameInput.activeFocus ? "#2196F3" : "#404040"
                    border.width: 2

                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                }

                color: "#ffffff"
            }

            TextField {
                id: editPasswordInput
                Layout.fillWidth: true
                placeholderText: "Yeni Şifre (boş bırakılabilir)"
                echoMode: TextInput.Password
                font.pixelSize: 14
                height: 45

                background: Rectangle {
                    color: "#1a1a1a"
                    radius: 8
                    border.color: editPasswordInput.activeFocus ? "#2196F3" : "#404040"
                    border.width: 2

                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                }

                color: "#ffffff"
            }

            CheckBox {
                id: editAdminCheckbox
                text: "Admin Yetkisi"
                font.pixelSize: 14

                indicator: Rectangle {
                    width: 22
                    height: 22
                    radius: 4
                    border.color: editAdminCheckbox.checked ? "#9c27b0" : "#505050"
                    border.width: 2
                    color: editAdminCheckbox.checked ? "#9c27b0" : "transparent"

                    Text {
                        visible: editAdminCheckbox.checked
                        text: "✓"
                        anchors.centerIn: parent
                        font.pixelSize: 14
                        font.bold: true
                        color: "#ffffff"
                    }

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                contentItem: Text {
                    text: editAdminCheckbox.text
                    font: editAdminCheckbox.font
                    color: "#ffffff"
                    leftPadding: editAdminCheckbox.indicator.width + 8
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted: {
            if (editUsernameInput.text.length >= 3) {
                if (authService.updateUser(currentUserId, editUsernameInput.text, editPasswordInput.text, editAdminCheckbox.checked)) {
                    console.log("Kullanıcı güncellendi")
                    editPasswordInput.text = ""
                }
            }
        }
    }

    // Silme Onay Dialog
    Dialog {
        id: deleteConfirmDialog
        title: "Kullanıcı Sil"
        modal: true
        anchors.centerIn: parent
        width: 400

        property int userIdToDelete: 0
        property string usernameToDelete: ""

        background: Rectangle {
            color: "#2a2a2a"
            radius: 12
            border.color: "#d32f2f"
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
                    GradientStop { position: 1.0; color: "#d32f2f" }
                }
                radius: 12
            }

            Text {
                anchors.centerIn: parent
                text: "⚠️ Kullanıcı Sil"
                font.pixelSize: 18
                font.bold: true
                color: "#ffffff"
            }
        }

        Column {
            spacing: 15
            width: parent.width

            Text {
                text: "Aşağıdaki kullanıcıyı silmek istediğinize emin misiniz?"
                font.pixelSize: 14
                color: "#cccccc"
                wrapMode: Text.WordWrap
                width: parent.width
            }

            Rectangle {
                width: parent.width
                height: 50
                color: "#1a1a1a"
                radius: 8
                border.color: "#d32f2f"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "👤 " + deleteConfirmDialog.usernameToDelete
                    font.pixelSize: 16
                    font.bold: true
                    color: "#ffffff"
                }
            }

            Text {
                text: "Bu işlem geri alınamaz!"
                font.pixelSize: 12
                color: "#ff9800"
                font.italic: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        standardButtons: Dialog.Yes | Dialog.No

        onAccepted: {
            if (authService.deleteUser(userIdToDelete)) {
                console.log("Kullanıcı silindi:", usernameToDelete)
            }
        }
    }
}
