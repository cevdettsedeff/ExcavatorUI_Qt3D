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
    property string projectName: "AŞ-KAZI-042"
    property bool gnssOk: true  // GNSS durumu: true = yeşil, false = gri
    property bool imu1Ok: true  // IMU/1 durumu
    property bool imu2Ok: true  // IMU/2 durumu
    property bool imu3Ok: true  // IMU/3 durumu
    property string excavatorName: "CAT 390F LME"
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

    // Tek satır içerik
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 6

        // SOL: Proje İkonu + Proje Adı (Altlı Üstlü)
        Row {
            spacing: 6
            Layout.alignment: Qt.AlignVCenter

            // Proje ikonu (küp)
            Rectangle {
                width: statusBar.iconSize * 0.7
                height: statusBar.iconSize * 0.7
                radius: 3
                color: "#FF9800"
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "◇"
                    font.pixelSize: statusBar.iconSize * 0.38
                    font.bold: true
                    color: "#ffffff"
                }
            }

            // Proje ve Ekskavatör Adı - Altlı üstlü
            Column {
                spacing: 2
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: statusBar.projectName
                    font.pixelSize: statusBar.smallFontSize
                    font.bold: true
                    color: "#ffffff"
                }

                Text {
                    text: statusBar.excavatorName
                    font.pixelSize: statusBar.tinyFontSize
                    color: "#888888"
                }
            }
        }

        Item { Layout.fillWidth: true }

        // SENSÖRLER GRUBU - Tıklanabilir
        Row {
            spacing: 8
            Layout.alignment: Qt.AlignVCenter

            // GNSS Durumu
            Rectangle {
                id: gnssBox
                width: gnssContent.width + 16
                height: statusBar.badgeHeight
                radius: 4
                color: "#2a2a2a"
                border.color: statusBar.gnssOk ? "#4CAF50" : "#666666"
                border.width: 2

                Row {
                    id: gnssContent
                    anchors.centerIn: parent
                    spacing: 6

                    // Sinyal çubukları
                    Row {
                        spacing: 2
                        anchors.verticalCenter: parent.verticalCenter
                        height: statusBar.badgeHeight * 0.6

                        Repeater {
                            model: 4

                            Rectangle {
                                width: 3
                                height: 4 + index * 4
                                radius: 1
                                anchors.bottom: parent.bottom
                                color: statusBar.gnssOk ? "#4CAF50" : "#666666"
                            }
                        }
                    }

                    Text {
                        text: "GNSS"
                        font.pixelSize: statusBar.smallFontSize
                        font.bold: true
                        color: statusBar.gnssOk ? "#4CAF50" : "#666666"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // IMU Durumları (3 ayrı sensör)
            Row {
                spacing: 4
                Layout.alignment: Qt.AlignVCenter

                // IMU/1
                Rectangle {
                    width: imu1Content.width + 12
                    height: statusBar.badgeHeight
                    radius: 4
                    color: "#2a2a2a"
                    border.color: statusBar.imu1Ok ? "#4CAF50" : "#666666"
                    border.width: 2

                    Row {
                        id: imu1Content
                        anchors.centerIn: parent
                        spacing: 4

                        // Sinyal çubukları
                        Row {
                            spacing: 1
                            anchors.verticalCenter: parent.verticalCenter
                            height: statusBar.badgeHeight * 0.5

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
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // IMU/2
                Rectangle {
                    width: imu2Content.width + 12
                    height: statusBar.badgeHeight
                    radius: 4
                    color: "#2a2a2a"
                    border.color: statusBar.imu2Ok ? "#4CAF50" : "#666666"
                    border.width: 2

                    Row {
                        id: imu2Content
                        anchors.centerIn: parent
                        spacing: 4

                        // Sinyal çubukları
                        Row {
                            spacing: 1
                            anchors.verticalCenter: parent.verticalCenter
                            height: statusBar.badgeHeight * 0.5

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
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // IMU/3
                Rectangle {
                    width: imu3Content.width + 12
                    height: statusBar.badgeHeight
                    radius: 4
                    color: "#2a2a2a"
                    border.color: statusBar.imu3Ok ? "#4CAF50" : "#666666"
                    border.width: 2

                    Row {
                        id: imu3Content
                        anchors.centerIn: parent
                        spacing: 4

                        // Sinyal çubukları
                        Row {
                            spacing: 1
                            anchors.verticalCenter: parent.verticalCenter
                            height: statusBar.badgeHeight * 0.5

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
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

        }

        Item { Layout.fillWidth: true }

        // User Bilgisi - İkon + Kullanıcı Adı + Rol
        Row {
            spacing: 8
            Layout.alignment: Qt.AlignVCenter

            // User İkonu
            Rectangle {
                width: statusBar.iconSize * 1.3
                height: statusBar.iconSize * 1.3
                radius: width / 2
                color: "#2a2a2a"
                border.color: "#4CAF50"
                border.width: 2
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
                    font.pixelSize: statusBar.iconSize * 0.6
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
        }

        // Ayırıcı çizgi
        Rectangle {
            width: 1
            height: statusBar.badgeHeight
            color: "#444444"
            Layout.alignment: Qt.AlignVCenter
        }

        // Tarih ve Saat - Altlı Üstlü
        Column {
            spacing: 1
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: statusBar.currentTime
                font.pixelSize: statusBar.tinyFontSize
                font.bold: true
                color: "#ffffff"
            }

            Text {
                text: statusBar.currentDate
                font.pixelSize: statusBar.tinyFontSize
                color: "#888888"
            }
        }

        // Menü İkonu
        Rectangle {
            width: statusBar.iconSize
            height: statusBar.iconSize
            radius: 4
            color: menuMouseArea.containsMouse ? "#3a3a3a" : "#2a2a2a"
            border.color: "#505050"
            border.width: 1
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: "☰"
                font.pixelSize: statusBar.iconSize * 0.5
                color: "#ffffff"
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

    // Alt çizgi
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#333333"
    }
}
