import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * StepProgressIndicator - Reusable step progress bar component
 *
 * Usage:
 * StepProgressIndicator {
 *     currentStep: 2
 *     stepTitles: ["Step 1", "Step 2", "Step 3"]
 *     primaryColor: "#319795"
 * }
 */
Rectangle {
    id: root

    property int currentStep: 0
    property var stepTitles: []
    property int totalSteps: stepTitles.length

    property color primaryColor: "#319795"
    property color completedColor: "#38A169"
    property color pendingColor: Qt.rgba(1, 1, 1, 0.2)
    property color textColor: "white"
    property color textSecondaryColor: Qt.rgba(1, 1, 1, 0.7)

    property var app: ApplicationWindow.window

    height: 70
    color: Qt.rgba(0, 0, 0, 0.2)

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        Repeater {
            model: root.totalSteps

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 28
                        height: 28
                        radius: 14
                        color: index < root.currentStep ? root.completedColor :
                               index === root.currentStep ? root.primaryColor :
                               root.pendingColor
                        border.width: index === root.currentStep ? 2 : 0
                        border.color: "white"

                        Text {
                            anchors.centerIn: parent
                            text: index < root.currentStep ? "✓" : (index + 1).toString()
                            font.pixelSize: 12
                            font.bold: true
                            color: "white"
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.stepTitles[index] || ""
                        font.pixelSize: root.app ? root.app.smallFontSize * 0.7 : 10
                        color: index === root.currentStep ? root.textColor : root.textSecondaryColor
                        font.bold: index === root.currentStep
                    }
                }

                // Connector line
                Rectangle {
                    visible: index < root.totalSteps - 1
                    anchors.right: parent.right
                    anchors.rightMargin: -2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -10
                    width: 4
                    height: 2
                    color: index < root.currentStep ? root.completedColor : root.pendingColor
                }
            }
        }
    }
}
