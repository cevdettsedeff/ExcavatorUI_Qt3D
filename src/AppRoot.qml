import QtQuick
import QtQuick.Controls
import QtQuick.VirtualKeyboard
import ExcavatorUI_Qt3D
import "./components"

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
    // Başlangıç pencere boyutu
    width: 520
    height: 835
    visible: true
    title: qsTr("EHK - Harita Ve Görselleştirme Yönetimi")
    color: themeManager ? themeManager.backgroundColor : "#2d3748"

    // ============================================
    // GLOBAL RESPONSIVE DESIGN SYSTEM - 10.1 inç
    // ============================================

    // Temel ölçekler
    property real fontScale: Math.min(width / 520, height / 835)

    // Font boyutları (10.1 inç için optimize - BÜYÜTÜLMÜŞ)
    property real baseFontSize: 22 * fontScale      // Normal metin (14→22)
    property real smallFontSize: 18 * fontScale     // Küçük metin (11→18)
    property real mediumFontSize: 26 * fontScale    // Orta metin (16→26)
    property real largeFontSize: 32 * fontScale     // Büyük başlıklar (20→32)
    property real xlFontSize: 38 * fontScale        // Çok büyük başlıklar (24→38)

    // Buton boyutları (BÜYÜTÜLMÜŞ)
    property real buttonHeight: 60 * fontScale      // Standart buton (45→60)
    property real smallButtonHeight: 50 * fontScale // Küçük buton (35→50)
    property real largeButtonHeight: 70 * fontScale // Büyük buton (55→70)

    // İkon boyutları (BÜYÜTÜLMÜŞ)
    property real iconSize: 40 * fontScale          // Standart ikon (28→40)
    property real smallIconSize: 30 * fontScale     // Küçük ikon (20→30)
    property real largeIconSize: 50 * fontScale     // Büyük ikon (36→50)

    // Spacing/Padding değerleri (BÜYÜTÜLMÜŞ)
    property real smallSpacing: 10 * fontScale      // Küçük boşluk (6→10)
    property real normalSpacing: 16 * fontScale     // Normal boşluk (12→16)
    property real largeSpacing: 26 * fontScale      // Büyük boşluk (20→26)
    property real xlSpacing: 40 * fontScale         // Çok büyük boşluk (30→40)

    property real smallPadding: 12 * fontScale      // Küçük padding (8→12)
    property real normalPadding: 20 * fontScale     // Normal padding (15→20)
    property real largePadding: 32 * fontScale      // Büyük padding (25→32)

    // Border radius (BÜYÜTÜLMÜŞ)
    property real smallRadius: 6 * fontScale        // Küçük köşe (4→6)
    property real normalRadius: 10 * fontScale      // Normal köşe (8→10)
    property real largeRadius: 16 * fontScale       // Büyük köşe (12→16)

    // ============================================

    // Mevcut görünüm durumu
    // "splash" -> "login" -> "config-dashboard" -> "dashboard"
    property string currentView: "splash"

    // Screensaver durumu
    property bool screenSaverActive: false

    // ConfigManager'dan screensaver ayarlarını al
    property bool screenSaverEnabled: configManager ? configManager.screenSaverEnabled : true
    property int screenSaverTimeoutSeconds: configManager ? configManager.screenSaverTimeoutSeconds : 120

    // Inactivity timeout süresi (saniyeden milisaniyeye çevir)
    readonly property int inactivityTimeout: screenSaverTimeoutSeconds * 1000

    // Window'u ortala (masaüstünde)
    Component.onCompleted: {
        if (Screen.width > 800) {
            appRoot.x = (Screen.width - appRoot.width) / 2
            appRoot.y = (Screen.height - appRoot.height) / 2
        }
    }

    // ConfigManager değişikliklerini dinle
    Connections {
        target: configManager
        function onScreenSaverEnabledChanged() {
            console.log("Screensaver enabled changed:", configManager.screenSaverEnabled)
            if (!configManager.screenSaverEnabled && screenSaverActive) {
                dismissScreenSaver()
            }
        }
        function onScreenSaverTimeoutSecondsChanged() {
            console.log("Screensaver timeout changed:", configManager.screenSaverTimeoutSeconds, "seconds")
            inactivityTimer.restart()
        }
    }

    // Inactivity timer - sadece login ekranında ve screensaver etkinse çalışır
    Timer {
        id: inactivityTimer
        interval: appRoot.inactivityTimeout
        running: (currentView === "login") && !screenSaverActive && screenSaverEnabled
        repeat: false
        onTriggered: {
            console.log("Inactivity timeout (" + screenSaverTimeoutSeconds + " sn) - Screensaver aktif")
            screenSaverActive = true
        }
    }

    // Kullanıcı aktivitesini algıla ve timer'ı sıfırla
    function resetInactivityTimer() {
        if (currentView === "login" && !screenSaverActive && screenSaverEnabled) {
            inactivityTimer.restart()
        }
    }

    // Screensaver'ı kapat
    function dismissScreenSaver() {
        if (screenSaverActive) {
            console.log("Screensaver kapatıldı")
            screenSaverActive = false
            if (screenSaverEnabled) {
                inactivityTimer.restart()
            }
        }
    }

    // AuthService sinyallerini dinle
    Connections {
        target: authService

        function onLoginSucceeded() {
            console.log("Login başarılı...")
            // Screensaver'ı kapat (varsa)
            screenSaverActive = false
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
            // Eğer konfigürasyon tamamlanmışsa direkt dashboard'a git
            if (configManager && configManager.isConfigured) {
                console.log("Konfigürasyon tamamlanmış, ana dashboard'a geçiliyor...")
                currentView = "dashboard"
            } else {
                // Konfigürasyon tamamlanmamışsa config-dashboard'a git
                console.log("Konfigürasyon tamamlanmamış, config-dashboard'a geçiliyor...")
                currentView = "config-dashboard"
            }
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
                    case "splash":
                        return "qrc:/ExcavatorUI_Qt3D/src/components/SplashScreen.qml"
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

            // ConfigDashboard ve Main'den gelen sinyalleri dinle
            Connections {
                target: viewLoader.item
                ignoreUnknownSignals: true

                function onSplashFinished() {
                    console.log("Splash screen tamamlandı, login ekranına geçiliyor...")
                    currentView = "login"
                }

                function onConfigurationComplete() {
                    console.log("Konfigürasyon tamamlandı, ana dashboard'a geçiliyor...")
                    currentView = "dashboard"
                }

                function onBackToLogin() {
                    console.log("Login ekranına dönülüyor...")
                    currentView = "login"
                    if (authService) {
                        authService.logout()
                    }
                }

                function onGoToDashboard() {
                    console.log("Config Dashboard'a dönülüyor...")
                    currentView = "config-dashboard"
                }
            }

            // SplashScreen timeout değerini ConfigManager'dan al
            onLoaded: {
                if (currentView === "splash" && viewLoader.item) {
                    if (configManager && configManager.splashScreenTimeoutMilliseconds) {
                        viewLoader.item.displayDuration = configManager.splashScreenTimeoutMilliseconds
                    }
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

    // ScreenSaver - SADECE login ekranında inaktivite durumunda gösterilir
    ScreenSaver {
        id: screenSaver
        anchors.fill: parent
        z: 1000  // Her şeyin üstünde
        // Sadece login ekranında VE screenSaverActive ise görünür
        visible: screenSaverActive && currentView === "login"

        onDismissed: {
            dismissScreenSaver()
        }
    }
}
