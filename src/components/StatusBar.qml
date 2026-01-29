import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Üst Durum Çubuğu - Tek satır, tüm sensörler dahil - 10.1 inç responsive
Rectangle {
    id: statusBar
    height: Math.max(parent.height * 0.055, 50)  // Tek satır, kompakt
    color: themeManager ? themeManager.backgroundColorDark : "#1a1a2e"

    // Responsive boyutlar - 10.1 inç için optimize
    property real baseFontSize: height * 0.24  // Ana font: küçültüldü
    property real smallFontSize: height * 0.20  // Küçük font
    property real tinyFontSize: height * 0.18  // Çok küçük font (altlı üstlü için)
    property real iconSize: height * 0.50  // İkon boyutu
    property real badgeHeight: height * 0.60  // Badge yüksekliği

    // Properties
    property bool gnssOk: true  // GNSS durumu: true = yeşil, false = gri
    property bool imu1Ok: true  // IMU/1 durumu
    property bool imu2Ok: true  // IMU/2 durumu
    property bool imu3Ok: true  // IMU/3 durumu
    property string currentDate: Qt.formatDateTime(new Date(), "dd.MM.yyyy")
    property string currentTime: Qt.formatDateTime(new Date(), "HH:mm")
    property bool bluetoothEnabled: true
    property bool audioEnabled: true

    // Signals
    signal userIconClicked()
    signal sensorClicked()  // Tüm sensörler için tek signal
    signal goToDashboard()

    // IMU genel durumu hesaplama fonksiyonu
    // Hepsi OK = yeşil, biri arızalı = turuncu, hepsi arızalı = gri
    function getImuStatusColor() {
        var okCount = (imu1Ok ? 1 : 0) + (imu2Ok ? 1 : 0) + (imu3Ok ? 1 : 0)
        if (okCount === 3) return "#4CAF50"  // Yeşil
        if (okCount === 0) return "#666666"  // Gri
        return "#FF9800"  // Turuncu
    }

    // Dil desteği
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    function tr(text) {
        return languageTrigger >= 0 ? qsTranslate("Main", text) : ""
    }

    // Saat güncelleyici
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            statusBar.currentDate = Qt.formatDateTime(new Date(), "dd.MM.yyyy")
            statusBar.currentTime = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }

    // Sensör border yanıp sönme animasyonu
    property bool sensorBorderVisible: true
    Timer {
        id: blinkTimer
        interval: 800
        running: true
        repeat: true
        onTriggered: {
            statusBar.sensorBorderVisible = !statusBar.sensorBorderVisible
        }
    }

    // Tek satır içerik - Kartlara bölünmüş
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 4

        // KART 1: Proje ve Ekskavatör Kartı (Altlı Üstlü)
        Rectangle {
            id: projectCard
            width: projectContent.width + 16
            height: statusBar.badgeHeight
            radius: 6
            color: "#1e2738"
            border.color: "#666666"
            border.width: 1

            Row {
                id: projectContent
                anchors.centerIn: parent
                spacing: 6

                // İkonlar - Sol tarafta altlı üstlü
                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter

                    // Klasör ikonu
                    Rectangle {
                        width: statusBar.iconSize * 0.5
                        height: statusBar.iconSize * 0.5
                        color: "transparent"
                        anchors.horizontalCenter: parent.horizontalCenter

                        Image {
                            id: folderIcon
                            source: "qrc:/ExcavatorUI_Qt3D/resources/icons/folder.png"
                            width: parent.width
                            height: parent.height
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                            visible: status === Image.Ready
                        }

                        // Fallback ikon
                        Text {
                            visible: folderIcon.status !== Image.Ready
                            anchors.centerIn: parent
                            text: "📁"
                            font.pixelSize: statusBar.iconSize * 0.35
                            color: "#FF9800"
                        }
                    }

                    // Ekskavatör ikonu
                    Rectangle {
                        width: statusBar.iconSize * 0.5
                        height: statusBar.iconSize * 0.5
                        color: "transparent"
                        anchors.horizontalCenter: parent.horizontalCenter

                        Image {
                            id: truckIcon
                            source: "qrc:/ExcavatorUI_Qt3D/resources/icons/config_excavator.png"
                            width: parent.width
                            height: parent.height
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                            visible: status === Image.Ready
                        }

                        // Fallback ikon
                        Text {
                            visible: truckIcon.status !== Image.Ready
                            anchors.centerIn: parent
                            text: "🚜"
                            font.pixelSize: statusBar.iconSize * 0.35
                            color: "#FF9800"
                        }
                    }
                }

                // Proje ve Ekskavatör Adları - Sağ tarafta altlı üstlü
                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter

                    // ConfigManager'a direct binding - reaktif güncelleme
                    property string _projectName: configManager ? configManager.projectName : ""
                    property string _excavatorName: configManager ? configManager.excavatorName : ""

                    Text {
                        text: parent._projectName.length > 0 ? parent._projectName : "—"
                        font.pixelSize: statusBar.tinyFontSize
                        font.bold: true
                        color: parent._projectName.length > 0 ? "#ffffff" : "#666666"
                    }

                    // Ayırıcı çizgi
                    Rectangle {
                        width: 60
                        height: 1
                        color: "#444444"
                    }

                    Text {
                        text: parent._excavatorName.length > 0 ? parent._excavatorName : "—"
                        font.pixelSize: statusBar.tinyFontSize
                        color: parent._excavatorName.length > 0 ? "#888888" : "#666666"
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }

        // KART 3: GNSS Kartı (Altlı üstlü)
        Rectangle {
            id: gnssCard
            width: gnssContent.width + 16
            height: statusBar.badgeHeight
            radius: 6
            color: "#1e2738"
            border.color: statusBar.gnssOk ? "#4CAF50" : "#666666"
            border.width: 1

            Column {
                id: gnssContent
                anchors.centerIn: parent
                spacing: 2
                width: 35

                // Sinyal çubukları
                Row {
                    spacing: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: statusBar.badgeHeight * 0.35

                    Repeater {
                        model: 4

                        Rectangle {
                            width: 2
                            height: 3 + index * 3
                            radius: 1
                            anchors.bottom: parent.bottom
                            color: statusBar.gnssOk ? "#4CAF50" : "#666666"
                        }
                    }
                }

                Text {
                    text: "GNSS"
                    font.pixelSize: statusBar.tinyFontSize
                    font.bold: true
                    color: statusBar.gnssOk ? "#4CAF50" : "#666666"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // KART 4: IMU Kartı (3 IMU yan yana, ikonlar altlı üstlü)
        Rectangle {
            id: imuCard
            width: imuCardContent.width + 16
            height: statusBar.badgeHeight
            radius: 6
            color: "#1e2738"
            border.color: statusBar.getImuStatusColor()
            border.width: 1

            Row {
                id: imuCardContent
                anchors.centerIn: parent
                spacing: 8

                // IMU/1
                Column {
                    spacing: 2
                    width: 30
                    anchors.verticalCenter: parent.verticalCenter

                    // Sinyal çubukları
                    Row {
                        spacing: 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: statusBar.badgeHeight * 0.4

                        Repeater {
                            model: 3

                            Rectangle {
                                width: 2
                                height: 3 + index * 3
                                radius: 1
                                anchors.bottom: parent.bottom
                                color: statusBar.imu1Ok ? "#4CAF50" : "#666666"
                            }
                        }
                    }

                    Text {
                        text: "IMU/1"
                        font.pixelSize: statusBar.tinyFontSize
                        font.bold: true
                        color: statusBar.imu1Ok ? "#4CAF50" : "#666666"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                // Ayırıcı
                Rectangle {
                    width: 1
                    height: statusBar.badgeHeight * 0.6
                    color: "#444444"
                    anchors.verticalCenter: parent.verticalCenter
                }

                // IMU/2
                Column {
                    spacing: 2
                    width: 30
                    anchors.verticalCenter: parent.verticalCenter

                    // Sinyal çubukları
                    Row {
                        spacing: 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: statusBar.badgeHeight * 0.4

                        Repeater {
                            model: 3

                            Rectangle {
                                width: 2
                                height: 3 + index * 3
                                radius: 1
                                anchors.bottom: parent.bottom
                                color: statusBar.imu2Ok ? "#4CAF50" : "#666666"
                            }
                        }
                    }

                    Text {
                        text: "IMU/2"
                        font.pixelSize: statusBar.tinyFontSize
                        font.bold: true
                        color: statusBar.imu2Ok ? "#4CAF50" : "#666666"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                // Ayırıcı
                Rectangle {
                    width: 1
                    height: statusBar.badgeHeight * 0.6
                    color: "#444444"
                    anchors.verticalCenter: parent.verticalCenter
                }

                // IMU/3
                Column {
                    spacing: 2
                    width: 30
                    anchors.verticalCenter: parent.verticalCenter

                    // Sinyal çubukları
                    Row {
                        spacing: 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: statusBar.badgeHeight * 0.4

                        Repeater {
                            model: 3

                            Rectangle {
                                width: 2
                                height: 3 + index * 3
                                radius: 1
                                anchors.bottom: parent.bottom
                                color: statusBar.imu3Ok ? "#4CAF50" : "#666666"
                            }
                        }
                    }

                    Text {
                        text: "IMU/3"
                        font.pixelSize: statusBar.tinyFontSize
                        font.bold: true
                        color: statusBar.imu3Ok ? "#4CAF50" : "#666666"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }

        // KART 5: Kullanıcı ve Saat Kartı
        Rectangle {
            id: userCard
            width: userCardContent.width + 16
            height: statusBar.badgeHeight
            radius: 6
            color: "#1e2738"
            border.color: "#505050"
            border.width: 1

            Row {
                id: userCardContent
                anchors.centerIn: parent
                spacing: 10

                // User İkonu
                Rectangle {
                    width: statusBar.iconSize * 0.8
                    height: statusBar.iconSize * 0.8
                    radius: width / 2
                    color: "#2a2a2a"
                    border.color: "#4CAF50"
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: userIconImage
                        anchors.centerIn: parent
                        width: parent.width * 0.6
                        height: parent.height * 0.6
                        source: "qrc:/ExcavatorUI_Qt3D/resources/icons/user.png"
                        fillMode: Image.PreserveAspectFit
                        visible: status === Image.Ready
                    }

                    // Fallback ikon (Image yüklenmezse)
                    Text {
                        visible: userIconImage.status !== Image.Ready
                        anchors.centerIn: parent
                        text: "👤"
                        font.pixelSize: statusBar.iconSize * 0.5
                        color: "#ffffff"
                    }
                }

                // Kullanıcı Adı ve Rol
                Column {
                    spacing: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: authService && authService.currentUser ? authService.currentUser : "LOREMIPSUMDOLOR"
                        font.pixelSize: statusBar.tinyFontSize
                        font.bold: true
                        color: "#ffffff"
                    }

                    Text {
                        text: authService && authService.currentRole ? authService.currentRole : "Operator"
                        font.pixelSize: statusBar.tinyFontSize
                        color: "#888888"
                    }
                }

                // Ayırıcı çizgi
                Rectangle {
                    width: 1
                    height: statusBar.badgeHeight * 0.6
                    color: "#444444"
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Tarih ve Saat
                Column {
                    spacing: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: statusBar.currentTime
                        font.pixelSize: statusBar.smallFontSize
                        font.bold: true
                        color: "#ffffff"
                    }

                    Text {
                        text: statusBar.currentDate
                        font.pixelSize: statusBar.tinyFontSize
                        color: "#888888"
                    }
                }
            }
        }

        // KART 6: Hamburger Menü Kartı
        Rectangle {
            id: menuCard
            width: menuCardContent.width + 16
            height: statusBar.badgeHeight
            radius: 6
            color: "#1e2738"
            border.color: "#505050"
            border.width: 1

            Row {
                id: menuCardContent
                anchors.centerIn: parent

                // Hamburger Menü İkonu
                Rectangle {
                    width: statusBar.iconSize * 0.9
                    height: statusBar.iconSize * 0.9
                    radius: 4
                    color: menuMouseArea.containsMouse ? "#3a3a3a" : "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Column {
                        anchors.centerIn: parent
                        spacing: 3

                        Repeater {
                            model: 3
                            Rectangle {
                                width: statusBar.iconSize * 0.6
                                height: 3
                                radius: 1.5
                                color: "#ffffff"
                            }
                        }
                    }

                    MouseArea {
                        id: menuMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: statusBar.userIconClicked()
                    }
                }
            }
        }
    }

    // Alt çizgi
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#333333"
    }
}
