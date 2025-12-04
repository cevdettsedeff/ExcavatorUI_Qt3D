import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#2a2a2a"

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

    // Ana başlık
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: "#1a1a1a"

        Text {
            anchors.centerIn: parent
            text: "Kullanıcı Yönetimi"
            font.pixelSize: 24
            font.bold: true
            color: "#ffffff"
        }
    }

    // İçerik alanı
    ScrollView {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20

        ColumnLayout {
            width: parent.width
            spacing: 20

            // Onay Bekleyen Kullanıcılar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: pendingSection.height + 40
                color: "#1a1a1a"
                radius: 10
                border.color: "#ff9800"
                border.width: 2

                Column {
                    id: pendingSection
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    // Başlık
                    Row {
                        width: parent.width
                        spacing: 10

                        Rectangle {
                            width: 8
                            height: 30
                            color: "#ff9800"
                            radius: 4
                        }

                        Text {
                            text: "Onay Bekleyen Kullanıcılar (" + pendingUsers.length + ")"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#ff9800"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#404040"
                    }

                    // Pending user listesi
                    Repeater {
                        model: pendingUsers

                        Rectangle {
                            width: parent.width
                            height: 70
                            color: "#252525"
                            radius: 8

                            Row {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                // Kullanıcı bilgileri
                                Column {
                                    spacing: 5
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        text: modelData.username
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#ffffff"
                                    }

                                    Text {
                                        text: "Kayıt: " + Qt.formatDateTime(new Date(modelData.createdAt), "dd.MM.yyyy hh:mm")
                                        font.pixelSize: 12
                                        color: "#888888"
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                // Onay butonu
                                Button {
                                    text: "✓ Onayla"
                                    width: 100
                                    height: 40
                                    anchors.verticalCenter: parent.verticalCenter

                                    background: Rectangle {
                                        color: parent.pressed ? "#45a049" : (parent.hovered ? "#5cb85c" : "#4CAF50")
                                        radius: 5

                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
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

                                // Reddet butonu
                                Button {
                                    text: "✗ Reddet"
                                    width: 100
                                    height: 40
                                    anchors.verticalCenter: parent.verticalCenter

                                    background: Rectangle {
                                        color: parent.pressed ? "#c0392b" : (parent.hovered ? "#e74c3c" : "#d32f2f")
                                        radius: 5

                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
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
                                        if (authService.rejectUser(modelData.id)) {
                                            console.log("Kullanıcı reddedildi:", modelData.username)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Boş mesajı
                    Text {
                        visible: pendingUsers.length === 0
                        text: "Onay bekleyen kullanıcı bulunmuyor"
                        font.pixelSize: 14
                        color: "#888888"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // Tüm Kullanıcılar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: allUsersSection.height + 40
                color: "#1a1a1a"
                radius: 10
                border.color: "#00bcd4"
                border.width: 2

                Column {
                    id: allUsersSection
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    // Başlık ve Yeni Kullanıcı butonu
                    Row {
                        width: parent.width
                        spacing: 10

                        Rectangle {
                            width: 8
                            height: 30
                            color: "#00bcd4"
                            radius: 4
                        }

                        Text {
                            text: "Tüm Kullanıcılar (" + allUsers.length + ")"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#00bcd4"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item { width: parent.width - 300 }

                        Button {
                            text: "+ Yeni Kullanıcı Ekle"
                            width: 180
                            height: 35

                            background: Rectangle {
                                color: parent.pressed ? "#0097a7" : (parent.hovered ? "#00acc1" : "#00bcd4")
                                radius: 5
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
                                addUserDialog.open()
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#404040"
                    }

                    // Kullanıcı listesi
                    Repeater {
                        model: allUsers

                        Rectangle {
                            width: parent.width
                            height: 80
                            color: "#252525"
                            radius: 8

                            Row {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                // Kullanıcı bilgileri
                                Column {
                                    spacing: 5
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 200

                                    Row {
                                        spacing: 10

                                        Text {
                                            text: modelData.username
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: "#ffffff"
                                        }

                                        Rectangle {
                                            visible: modelData.isAdmin
                                            width: 60
                                            height: 20
                                            color: "#9c27b0"
                                            radius: 3

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
                                            width: 60
                                            height: 20
                                            color: "#ff9800"
                                            radius: 3

                                            Text {
                                                text: "BEKLEMEDE"
                                                font.pixelSize: 8
                                                font.bold: true
                                                color: "#ffffff"
                                                anchors.centerIn: parent
                                            }
                                        }
                                    }

                                    Text {
                                        text: "Kayıt: " + Qt.formatDateTime(new Date(modelData.createdAt), "dd.MM.yyyy hh:mm")
                                        font.pixelSize: 11
                                        color: "#888888"
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                // Düzenle butonu
                                Button {
                                    text: "✎ Düzenle"
                                    width: 90
                                    height: 35
                                    anchors.verticalCenter: parent.verticalCenter

                                    background: Rectangle {
                                        color: parent.pressed ? "#1976d2" : (parent.hovered ? "#2196F3" : "#1565c0")
                                        radius: 5
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 12
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

                                // Sil butonu
                                Button {
                                    text: "✗ Sil"
                                    width: 70
                                    height: 35
                                    anchors.verticalCenter: parent.verticalCenter
                                    enabled: modelData.username !== authService.currentUser

                                    background: Rectangle {
                                        color: parent.enabled ? (parent.pressed ? "#c0392b" : (parent.hovered ? "#e74c3c" : "#d32f2f")) : "#555555"
                                        radius: 5
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#ffffff"
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

    // Yeni Kullanıcı Ekleme Dialog
    Dialog {
        id: addUserDialog
        title: "Yeni Kullanıcı Ekle"
        modal: true
        anchors.centerIn: parent
        width: 400

        property alias username: usernameInput.text
        property alias password: passwordInput.text
        property alias isAdmin: adminCheckbox.checked

        ColumnLayout {
            spacing: 15
            width: parent.width

            TextField {
                id: usernameInput
                Layout.fillWidth: true
                placeholderText: "Kullanıcı Adı"
                font.pixelSize: 14
            }

            TextField {
                id: passwordInput
                Layout.fillWidth: true
                placeholderText: "Şifre"
                echoMode: TextInput.Password
                font.pixelSize: 14
            }

            CheckBox {
                id: adminCheckbox
                text: "Admin Yetkisi Ver"
                font.pixelSize: 14
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
        width: 400

        property int currentUserId: 0
        property alias currentUsername: editUsernameInput.text
        property alias currentIsAdmin: editAdminCheckbox.checked

        ColumnLayout {
            spacing: 15
            width: parent.width

            TextField {
                id: editUsernameInput
                Layout.fillWidth: true
                placeholderText: "Kullanıcı Adı"
                font.pixelSize: 14
            }

            TextField {
                id: editPasswordInput
                Layout.fillWidth: true
                placeholderText: "Yeni Şifre (boş bırakılabilir)"
                echoMode: TextInput.Password
                font.pixelSize: 14
            }

            CheckBox {
                id: editAdminCheckbox
                text: "Admin Yetkisi"
                font.pixelSize: 14
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
        width: 350

        property int userIdToDelete: 0
        property string usernameToDelete: ""

        Text {
            text: "'" + deleteConfirmDialog.usernameToDelete + "' kullanıcısını silmek istediğinize emin misiniz?"
            font.pixelSize: 14
            color: "#ffffff"
            wrapMode: Text.WordWrap
            width: parent.width
        }

        standardButtons: Dialog.Yes | Dialog.No

        onAccepted: {
            if (authService.deleteUser(userIdToDelete)) {
                console.log("Kullanıcı silindi:", usernameToDelete)
            }
        }
    }
}
