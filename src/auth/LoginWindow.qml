import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ExcavatorUI_Qt3D

ApplicationWindow {
    id: loginWindow
    width: 800
    height: 1280
    visible: true
    title: qsTr("Excavator Dashboard")
    color: "#1a1a1a"

    // Dil değişikliği için trigger
    property int retranslationTrigger: 0
    property bool showLanguageLoadingOverlay: false
    property string loadingMessage: ""

    // Window'u ortala (masaüstünde)
    Component.onCompleted: {
        if (Screen.width > 800) {
            loginWindow.x = (Screen.width - loginWindow.width) / 2
            loginWindow.y = (Screen.height - loginWindow.height) / 2
        }
    }

    // Dil değişikliklerini dinle ve loading göster
    Connections {
        target: translationService
        function onLanguageChanged() {
            retranslationTrigger++
            loadingMessage = (translationService.currentLanguage === "tr_TR") ? "Changing language..." : "Dil değiştiriliyor..."
            showLanguageLoadingOverlay = true
            languageLoadingTimer.start()

            var isLoginView = stackView.depth === 1

            if (isLoginView) {
                stackView.replace(null, loginViewComponent)
            } else {
                stackView.replace(null, registerViewComponent)
            }
        }
    }

    Timer {
        id: languageLoadingTimer
        interval: 800
        repeat: false
        onTriggered: {
            showLanguageLoadingOverlay = false
        }
    }

    // Dil değişikliği loading overlay
    Rectangle {
        id: languageLoadingOverlay
        anchors.fill: parent
        color: "#80000000"
        visible: showLanguageLoadingOverlay
        z: 1000

        Rectangle {
            anchors.centerIn: parent
            width: 200
            height: 90
            color: "#2a2a2a"
            radius: 10
            border.color: "#00bcd4"
            border.width: 2

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 12

                BusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                    running: showLanguageLoadingOverlay
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: loadingMessage
                    font.pixelSize: 13
                    color: "#ffffff"
                }
            }
        }
    }

    // Ana içerik alanı
    Item {
        id: contentArea
        anchors.fill: parent

        // StackView ile view'lar arası geçiş
        StackView {
            id: stackView
            anchors.fill: parent
            initialItem: loginViewComponent

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
                console.log("Kayıt başarılı!")
            }
        }
    }

    // AuthService'ten gelen sinyalleri dinle
    Connections {
        target: authService

        function onLoginSucceeded() {
            loginWindow.close()
        }
    }
}
