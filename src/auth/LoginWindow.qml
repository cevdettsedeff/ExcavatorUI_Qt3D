import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ExcavatorUI_Qt3D

ApplicationWindow {
    id: loginWindow
    width: 400
    height: 680
    visible: true
    title: qsTr("Excavator Dashboard")
    color: "#1a1a1a"

    // Dil değişikliği için trigger
    property int retranslationTrigger: 0

    // Window'u ortala
    Component.onCompleted: {
        loginWindow.x = (Screen.width - loginWindow.width) / 2
        loginWindow.y = (Screen.height - loginWindow.height) / 2
    }

    // Dil değişikliklerini dinle ve view'ı yenile
    Connections {
        target: translationService
        function onLanguageChanged() {
            retranslationTrigger++
            // Current view'ı kaydet
            var isLoginView = stackView.depth === 1

            // View'ı yenile
            if (isLoginView) {
                stackView.replace(null, loginViewComponent)
            } else {
                stackView.replace(null, registerViewComponent)
            }
        }
    }

    // StackView ile view'lar arası geçiş
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: loginViewComponent

        // Animasyonlar
        pushEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 200
            }
        }
        pushExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 200
            }
        }
        popEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 200
            }
        }
        popExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 200
            }
        }
    }

    // Login View Component
    Component {
        id: loginViewComponent

        LoginView {
            onSwitchToRegister: {
                stackView.push(registerViewComponent)
            }
        }
    }

    // Register View Component
    Component {
        id: registerViewComponent

        RegisterView {
            onSwitchToLogin: {
                stackView.pop()
            }

            onRegistrationSuccessful: {
                // Kayıt başarılı olduğunda yapılacaklar
                console.log("Kayıt başarılı!")
            }
        }
    }

    // AuthService'ten gelen sinyalleri dinle
    Connections {
        target: authService

        function onLoginSucceeded() {
            // Login başarılı, window'u kapat
            loginWindow.close()
        }
    }
}
