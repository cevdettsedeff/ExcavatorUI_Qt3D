import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D
import ExcavatorUI_Qt3D

/**
 * Main Dashboard View
 * AppRoot tarafından Loader ile yüklenir
 */
Rectangle {
    id: root
    color: themeManager ? themeManager.backgroundColor : "#2d3748"

    property bool contentLoaded: true
    property int currentPageIndex: 0

    // Dashboard'a dönüş sinyali
    signal goToDashboard()

    // Dil değişikliği tetikleyici
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

    // Ana container
    ColumnLayout {
        id: mainContainer
        anchors.fill: parent
        spacing: 0

        // Üst Durum Çubuğu - Responsive (height kendi içinde hesaplanıyor)
        StatusBar {
            id: statusBar
            Layout.fillWidth: true
            projectName: "AŞ-KAZI-042"
            excavatorName: "CAT 390F LME"
            gnssOk: true  // GNSS durumu (true = yeşil, false = gri)
            imu1Ok: true  // IMU/1 durumu (default: hepsi OK = yeşil)
            imu2Ok: true  // IMU/2 durumu
            imu3Ok: true  // IMU/3 durumu
            z: 100

            onUserIconClicked: {
                userMenu.open()
            }

            onSensorClicked: {
                // Sensör ayarları sayfasına git (index 4 = Ayarlar)
                root.currentPageIndex = 4
            }

            onGoToDashboard: {
                // Config Dashboard'a dön
                root.goToDashboard()
            }
        }

        // Kullanıcı menüsü - BT, AU, Dashboard, Logout
        Menu {
            id: userMenu
            x: root.width - 220
            y: statusBar.height
            width: 200

            background: Rectangle {
                color: themeManager ? themeManager.surfaceColor : "#2a2a2a"
                radius: 8
                border.width: 1
                border.color: themeManager ? themeManager.borderColor : "#3a3a3a"
            }

            // BT (Bluetooth) Toggle
            MenuItem {
                id: bluetoothMenuItem
                height: 48
                onTriggered: {
                    statusBar.bluetoothEnabled = !statusBar.bluetoothEnabled
                    console.log("Bluetooth:", statusBar.bluetoothEnabled ? "Açık" : "Kapalı")
                }

                background: Rectangle {
                    color: bluetoothMenuItem.highlighted ? Qt.rgba(0.2, 0.4, 0.8, 0.2) : "transparent"
                    radius: 4
                }

                contentItem: Row {
                    spacing: 12
                    anchors.verticalCenter: parent.verticalCenter

                    // BT ikonu
                    Image {
                        id: bluetoothIconImage
                        source: statusBar.bluetoothEnabled ?
                            "qrc:/ExcavatorUI_Qt3D/resources/icons/bluetooth.png" :
                            "qrc:/ExcavatorUI_Qt3D/resources/icons/bluetooth_disabled.png"
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                        visible: status === Image.Ready
                        opacity: statusBar.bluetoothEnabled ? 1.0 : 0.5
                    }

                    // Fallback ikon
                    Rectangle {
                        visible: bluetoothIconImage.status !== Image.Ready
                        width: 24
                        height: 24
                        radius: 4
                        color: statusBar.bluetoothEnabled ? "#2196F3" : "#666666"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "⚡"
                            font.pixelSize: 14
                            color: "white"
                        }
                    }

                    Text {
                        text: "BT"
                        font.pixelSize: 16
                        font.bold: true
                        color: statusBar.bluetoothEnabled ? "#2196F3" : "#666666"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item { Layout.fillWidth: true }

                    // Toggle göstergesi
                    Rectangle {
                        width: 40
                        height: 20
                        radius: 10
                        color: statusBar.bluetoothEnabled ? "#2196F3" : "#666666"
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            x: statusBar.bluetoothEnabled ? parent.width - width - 2 : 2
                            y: 2
                            width: 16
                            height: 16
                            radius: 8
                            color: "white"

                            Behavior on x {
                                NumberAnimation { duration: 200 }
                            }
                        }
                    }
                }
            }

            // AU (Audio) Toggle
            MenuItem {
                id: audioMenuItem
                height: 48
                onTriggered: {
                    statusBar.audioEnabled = !statusBar.audioEnabled
                    console.log("Ses:", statusBar.audioEnabled ? "Açık" : "Kapalı")
                }

                background: Rectangle {
                    color: audioMenuItem.highlighted ? Qt.rgba(0.8, 0.4, 0.2, 0.2) : "transparent"
                    radius: 4
                }

                contentItem: Row {
                    spacing: 12
                    anchors.verticalCenter: parent.verticalCenter

                    // AU ikonu
                    Image {
                        id: audioIconImage
                        source: statusBar.audioEnabled ?
                            "qrc:/ExcavatorUI_Qt3D/resources/icons/audio.png" :
                            "qrc:/ExcavatorUI_Qt3D/resources/icons/audio_muted.png"
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                        visible: status === Image.Ready
                    }

                    // Fallback ikon
                    Rectangle {
                        visible: audioIconImage.status !== Image.Ready
                        width: 24
                        height: 24
                        radius: 4
                        color: statusBar.audioEnabled ? "#FF9800" : "#666666"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: statusBar.audioEnabled ? "🔊" : "🔇"
                            font.pixelSize: 14
                            color: "white"
                        }
                    }

                    Text {
                        text: "AU"
                        font.pixelSize: 16
                        font.bold: true
                        color: statusBar.audioEnabled ? "#FF9800" : "#666666"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item { Layout.fillWidth: true }

                    // Toggle göstergesi
                    Rectangle {
                        width: 40
                        height: 20
                        radius: 10
                        color: statusBar.audioEnabled ? "#FF9800" : "#666666"
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            x: statusBar.audioEnabled ? parent.width - width - 2 : 2
                            y: 2
                            width: 16
                            height: 16
                            radius: 8
                            color: "white"

                            Behavior on x {
                                NumberAnimation { duration: 200 }
                            }
                        }
                    }
                }
            }

            MenuSeparator {
                contentItem: Rectangle {
                    implicitHeight: 1
                    color: themeManager ? themeManager.borderColor : "#3a3a3a"
                }
            }

            MenuItem {
                id: dashboardMenuItem
                height: 48
                onTriggered: {
                    statusBar.goToDashboard()
                }

                background: Rectangle {
                    color: dashboardMenuItem.highlighted ? Qt.rgba(0.2, 0.6, 0.6, 0.2) : "transparent"
                    radius: 4
                }

                contentItem: Row {
                    spacing: 12
                    anchors.verticalCenter: parent.verticalCenter

                    // Dashboard ikonu - Image component (özel ikon için)
                    Image {
                        id: dashboardIconImage
                        source: "qrc:/ExcavatorUI_Qt3D/resources/icons/dashboard.png"
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                        visible: status === Image.Ready
                    }

                    // Fallback ikon (Image yüklenmezse)
                    Rectangle {
                        visible: dashboardIconImage.status !== Image.Ready
                        width: 24
                        height: 24
                        radius: 4
                        color: "#4CAF50"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "⌂"
                            font.pixelSize: 14
                            color: "white"
                        }
                    }

                    Text {
                        text: root.tr("Dashboard")
                        font.pixelSize: 16
                        font.bold: true
                        color: themeManager ? themeManager.textColor : "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            MenuSeparator {
                contentItem: Rectangle {
                    implicitHeight: 1
                    color: themeManager ? themeManager.borderColor : "#3a3a3a"
                }
            }

            MenuItem {
                id: logoutMenuItem
                height: 48
                onTriggered: {
                    if (authService) {
                        authService.logout()
                    }
                }

                background: Rectangle {
                    color: logoutMenuItem.highlighted ? Qt.rgba(0.8, 0.2, 0.2, 0.2) : "transparent"
                    radius: 4
                }

                contentItem: Row {
                    spacing: 12
                    anchors.verticalCenter: parent.verticalCenter

                    // Çıkış ikonu - Image component (özel ikon için)
                    Image {
                        id: logoutIconImage
                        source: "qrc:/ExcavatorUI_Qt3D/resources/icons/logout.png"
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                        visible: status === Image.Ready
                    }

                    // Fallback ikon (Image yüklenmezse)
                    Rectangle {
                        visible: logoutIconImage.status !== Image.Ready
                        width: 24
                        height: 24
                        radius: 4
                        color: "#f44336"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "⏻"
                            font.pixelSize: 14
                            color: "white"
                        }
                    }

                    Text {
                        text: root.tr("Logout")
                        font.pixelSize: 16
                        font.bold: true
                        color: themeManager ? themeManager.textColor : "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // Ana İçerik Alanı
        StackLayout {
            id: contentStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.currentPageIndex

            // Sayfa 0: Ana Sayfa (Excavator View)
            HomePage {
                id: homePage
            }

            // Sayfa 1: Harita
            MapPage {
                id: mapPage
            }

            // Sayfa 2: Alan
            AreaPage {
                id: areaPage
            }

            // Sayfa 3: Alarm
            AlarmPage {
                id: alarmPage
            }

            // Sayfa 4: Ayarlar
            SettingsPage {
                id: settingsPage
            }
        }

        // Alt Navigasyon
        BottomNavigation {
            id: bottomNav
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            currentIndex: root.currentPageIndex

            onTabChanged: function(index) {
                root.currentPageIndex = index
            }
        }
    }


}
