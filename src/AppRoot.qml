import QtQuick
import QtQuick.Controls
import QtQuick.VirtualKeyboard
import "components"

/**
 * AppRoot - Uygulamanın kalıcı root container'ı
 *
 * Bu bileşen uygulama boyunca yaşar ve:
 * 1. Tek bir InputPanel instance'ı tutar (VirtualKeyboard crash'ini önler)
 * 2. Loader ile Login/ConfigDashboard/Dashboard arasında geçiş yapar
 * 3. AuthService sinyallerini merkezi olarak yönetir
 * 4. Inactivity timeout ile screensaver gösterir (login ekranında)
 */
ApplicationWindow {
    id: appRoot
    width: 800
    height: 1280
    visible: true
    title: qsTr("EHK - Harita Ve Görselleştirme Yönetimi")
    color: themeManager ? themeManager.backgroundColor : "#2d3748"

    // Mevcut görünüm durumu
    // "login" -> "config-dashboard" -> "dashboard"
    property string currentView: "login"

    // Screensaver durumu
    property bool screenSaverActive: false

    // Inactivity timeout süresi (2 dakika = 120000 ms)
    readonly property int inactivityTimeout: 120000

    // Window'u ortala (masaüstünde)
    Component.onCompleted: {
        if (Screen.width > 800) {
            appRoot.x = (Screen.width - appRoot.width) / 2
            appRoot.y = (Screen.height - appRoot.height) / 2
        }
    }

    // Inactivity timer - sadece login ekranında çalışır
    Timer {
        id: inactivityTimer
        interval: appRoot.inactivityTimeout
        running: (currentView === "login") && !screenSaverActive
        repeat: false
        onTriggered: {
            console.log("Inactivity timeout - Screensaver aktif")
            screenSaverActive = true
        }
    }

    // Kullanıcı aktivitesini algıla ve timer'ı sıfırla
    function resetInactivityTimer() {
        if (currentView === "login" && !screenSaverActive) {
            inactivityTimer.restart()
        }
    }

    // Screensaver'ı kapat
    function dismissScreenSaver() {
        if (screenSaverActive) {
            console.log("Screensaver kapatıldı")
            screenSaverActive = false
            inactivityTimer.restart()
        }
    }

    // AuthService sinyallerini dinle
    Connections {
        target: authService

        function onLoginSucceeded() {
            console.log("Login başarılı...")
            // Önce klavyeyi kapat
            Qt.inputMethod.hide()
            // Kısa bir gecikme ile geçiş yap (klavye animasyonu için)
            transitionTimer.start()
        }

        function onLoggedOut() {
            console.log("Logout yapıldı, login ekranına dönülüyor...")
            currentView = "login"
        }
    }

    // Dashboard'a geçiş için timer (klavye kapanma animasyonu bekler)
    Timer {
        id: transitionTimer
        interval: 150
        repeat: false
        onTriggered: {
            // Her zaman config-dashboard'a git, kullanıcı oradan ana ekrana geçebilir
            console.log("Login başarılı, config-dashboard'a geçiliyor...")
            currentView = "config-dashboard"
        }
    }

    // Ana içerik alanı - klavye için alan bırak
    Item {
        id: contentArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: inputPanel.top

        // Global aktivite algılama (inactivity timer için)
        // Login ekranında mouse/touch hareketlerini yakalar
        MouseArea {
            id: globalActivityDetector
            anchors.fill: parent
            propagateComposedEvents: true
            hoverEnabled: true
            enabled: currentView === "login" && !screenSaverActive

            // Tüm olayları geçir ama timer'ı sıfırla
            onPressed: function(mouse) {
                resetInactivityTimer()
                mouse.accepted = false
            }
            onReleased: function(mouse) {
                mouse.accepted = false
            }
            onClicked: function(mouse) {
                resetInactivityTimer()
                mouse.accepted = false
            }
            onPositionChanged: function(mouse) {
                resetInactivityTimer()
                mouse.accepted = false
            }
            onWheel: function(wheel) {
                resetInactivityTimer()
                wheel.accepted = false
            }
        }

        // View Loader - Login, ConfigDashboard veya Dashboard yükler
        Loader {
            id: viewLoader
            anchors.fill: parent
            source: getViewSource()

            function getViewSource() {
                switch (currentView) {
                    case "login":
                        return "qrc:/ExcavatorUI_Qt3D/src/auth/LoginContainer.qml"
                    case "config-dashboard":
                        return "qrc:/ExcavatorUI_Qt3D/src/views/ConfigDashboard.qml"
                    case "dashboard":
                        return "qrc:/ExcavatorUI_Qt3D/src/views/Main.qml"
                    default:
                        return "qrc:/ExcavatorUI_Qt3D/src/auth/LoginContainer.qml"
                }
            }

            // ConfigDashboard'dan gelen sinyalleri dinle
            Connections {
                target: viewLoader.item
                ignoreUnknownSignals: true

                function onConfigurationComplete() {
                    console.log("Konfigürasyon tamamlandı, ana dashboard'a geçiliyor...")
                    currentView = "dashboard"
                }
            }

            // Geçiş animasyonu
            onSourceChanged: {
                opacity = 0
                fadeIn.start()
            }

            NumberAnimation {
                id: fadeIn
                target: viewLoader
                property: "opacity"
                from: 0
                to: 1
                duration: 200
            }
        }
    }

    // Virtual Keyboard - TEK INSTANCE, uygulama boyunca yaşar
    InputPanel {
        id: inputPanel
        z: 99
        x: 0
        y: appRoot.height
        width: appRoot.width

        states: State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: appRoot.height - inputPanel.height
            }
        }

        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    // ScreenSaver - login ekranında inaktivite durumunda gösterilir
    ScreenSaver {
        id: screenSaver
        anchors.fill: parent
        z: 1000  // Her şeyin üstünde
        visible: screenSaverActive
        opacity: screenSaverActive ? 1 : 0

        onDismissed: {
            dismissScreenSaver()
        }

        Behavior on opacity {
            NumberAnimation { duration: 500 }
        }
    }
}
