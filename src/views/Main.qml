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

    property bool contentLoaded: false
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
            rtkConnected: true
            imuOk: true
            alarmCount: 3
            z: 100

            onUserIconClicked: {
                userMenu.open()
            }

            onRtkClicked: {
                // Ayarlar sayfasına git (index 4)
                root.currentPageIndex = 4
            }

            onImuClicked: {
                // Ayarlar sayfasına git (index 4)
                root.currentPageIndex = 4
            }

            onGoToDashboard: {
                // Config Dashboard'a dön
                root.goToDashboard()
            }
        }

        // Kullanıcı menüsü - Sadeleştirilmiş
        Menu {
            id: userMenu
            x: root.width - 200
            y: 50
            width: 180

            background: Rectangle {
                color: themeManager ? themeManager.surfaceColor : "#2a2a2a"
                radius: 8
                border.width: 1
                border.color: themeManager ? themeManager.borderColor : "#3a3a3a"
            }

            MenuItem {
                text: "🏠 " + root.tr("Dashboard")
                onTriggered: {
                    statusBar.goToDashboard()
                }

                background: Rectangle {
                    color: parent.highlighted ? Qt.rgba(0.2, 0.6, 0.6, 0.2) : "transparent"
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: themeManager ? themeManager.textColor : "#ffffff"
                    verticalAlignment: Text.AlignVCenter
                }
            }

            MenuSeparator {
                contentItem: Rectangle {
                    implicitHeight: 1
                    color: themeManager ? themeManager.borderColor : "#3a3a3a"
                }
            }

            MenuItem {
                text: "🚪 " + root.tr("Logout")
                onTriggered: {
                    if (authService) {
                        authService.logout()
                    }
                }

                background: Rectangle {
                    color: parent.highlighted ? Qt.rgba(0.8, 0.2, 0.2, 0.2) : "transparent"
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: themeManager ? themeManager.textColor : "#ffffff"
                    verticalAlignment: Text.AlignVCenter
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

    // Loading Screen (inline - module import sorunu için)
    Rectangle {
        id: loadingScreen
        anchors.fill: parent
        z: 1000
        color: themeManager ? themeManager.backgroundColor : "#2d3748"
        visible: !root.contentLoaded
        opacity: root.contentLoaded ? 0 : 1

        property real progress: 0.0
        property real loadProgress: 0.0
        property real targetProgress: 0.0

        Column {
            anchors.centerIn: parent
            spacing: 30

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "ExcavatorUI"
                font.pixelSize: 48
                font.bold: true
                color: "#4CAF50"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Yükleniyor..."
                font.pixelSize: 20
                color: "#888888"
            }

            // Progress bar
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 300
                height: 8
                radius: 4
                color: "#333333"

                Rectangle {
                    width: parent.width * loadingScreen.progress
                    height: parent.height
                    radius: 4
                    color: "#4CAF50"

                    Behavior on width {
                        NumberAnimation { duration: 100 }
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Math.round(loadingScreen.progress * 100) + "%"
                font.pixelSize: 16
                color: "#888888"
            }
        }

        Timer {
            interval: 30
            repeat: true
            running: !root.contentLoaded

            onTriggered: {
                if (root.contentLoaded) {
                    loadingScreen.targetProgress = 1.0
                } else {
                    if (loadingScreen.targetProgress < 0.9) {
                        loadingScreen.targetProgress += 0.02
                    }
                }

                if (loadingScreen.loadProgress < loadingScreen.targetProgress) {
                    var diff = loadingScreen.targetProgress - loadingScreen.loadProgress
                    loadingScreen.loadProgress += diff * 0.15
                }

                loadingScreen.progress = loadingScreen.loadProgress
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 500 }
        }
    }

    Timer {
        id: loadingCompleteTimer
        interval: 1500
        running: true
        onTriggered: {
            root.contentLoaded = true
        }
    }

}
