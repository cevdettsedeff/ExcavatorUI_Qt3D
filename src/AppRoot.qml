import QtQuick
import QtQuick.Controls
import QtQuick.VirtualKeyboard

/**
 * AppRoot - Uygulamanın kalıcı root container'ı
 *
 * Bu bileşen uygulama boyunca yaşar ve:
 * 1. Tek bir InputPanel instance'ı tutar (VirtualKeyboard crash'ini önler)
 * 2. Loader ile Login/Dashboard arasında geçiş yapar
 * 3. AuthService sinyallerini merkezi olarak yönetir
 */
ApplicationWindow {
    id: appRoot
    width: 800
    height: 1280
    visible: true
    title: qsTr("EHK - Harita Ve Görselleştirme Yönetimi")
    color: "#1a1a1a"

    // Mevcut görünüm durumu
    property string currentView: "login" // "login" veya "dashboard"

    // Window'u ortala (masaüstünde)
    Component.onCompleted: {
        if (Screen.width > 800) {
            appRoot.x = (Screen.width - appRoot.width) / 2
            appRoot.y = (Screen.height - appRoot.height) / 2
        }
    }

    // AuthService sinyallerini dinle
    Connections {
        target: authService

        function onLoginSucceeded() {
            console.log("Login başarılı, dashboard'a geçiliyor...")
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
            currentView = "dashboard"
        }
    }

    // Ana içerik alanı - klavye için alan bırak
    Item {
        id: contentArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: inputPanel.top

        // View Loader - Login veya Dashboard yükler
        Loader {
            id: viewLoader
            anchors.fill: parent
            source: currentView === "login"
                ? "qrc:/ExcavatorUI_Qt3D/src/auth/LoginContainer.qml"
                : "qrc:/ExcavatorUI_Qt3D/src/views/Main.qml"

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
}
