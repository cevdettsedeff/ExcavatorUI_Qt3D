import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * LoginContainer - Login/Register view'larını içeren container
 *
 * Bu bileşen InputPanel içermez, AppRoot'taki InputPanel kullanılır.
 * StackView ile Login ve Register arasında geçiş sağlar.
 */
Item {
    id: loginContainer

    // Dil değişikliği için trigger
    property int retranslationTrigger: 0
    property bool showLanguageLoadingOverlay: false
    property string loadingMessage: ""

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
}
