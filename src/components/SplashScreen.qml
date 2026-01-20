import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: splashScreen
    anchors.fill: parent
    color: "#1e293b"  // Dark blue-gray background

    property real progress: 0.0
    property int displayDuration: 3000  // Default 3 seconds

    signal splashFinished()

    // Auto-progress animation
    NumberAnimation {
        id: progressAnimation
        target: splashScreen
        property: "progress"
        from: 0.0
        to: 1.0
        duration: displayDuration
        running: true
        easing.type: Easing.Linear  // Linear for smooth consistent progress

        onFinished: {
            splashFinishedTimer.start()
        }
    }

    Timer {
        id: splashFinishedTimer
        interval: 200
        running: false
        repeat: false
        onTriggered: splashScreen.splashFinished()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // TOP SECTION: Ministry Logo and Title
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.18

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10

                // Ministry Logo Image (will be added by user)
                Image {
                    id: ministryLogo
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80
                    source: "qrc:/ExcavatorUI_Qt3D/resources/logos/uab_logo.png"
                    fillMode: Image.PreserveAspectFit
                    visible: status === Image.Ready

                    // Placeholder if image not found
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: "#60a5fa"
                        border.width: 2
                        radius: 40
                        visible: ministryLogo.status !== Image.Ready

                        Text {
                            anchors.centerIn: parent
                            text: "🇹🇷"
                            font.pixelSize: 40
                            color: "#60a5fa"
                        }
                    }
                }

                // Ministry Title
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "T.C. ULAŞTIRMA VE ALTYAPI BAKANLIĞI"
                    font.pixelSize: 22
                    font.bold: true
                    font.family: "Arial"
                    color: "#e2e8f0"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // TKYŞM SECTION: Department Logo and Title
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.15

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 8

                // TKYŞM Logo Image
                Image {
                    id: tkysmLogo
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 60
                    source: "qrc:/ExcavatorUI_Qt3D/resources/logos/tkysm_logo.jpg"
                    fillMode: Image.PreserveAspectFit
                    visible: status === Image.Ready

                    // Placeholder if image not found
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        visible: tkysmLogo.status !== Image.Ready

                        Text {
                            anchors.centerIn: parent
                            text: "TKYŞM"
                            font.pixelSize: 28
                            font.bold: true
                            color: "#60a5fa"
                        }
                    }
                }

                // TKYŞM Full Name
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "TERSANELER VE KIYI YAPILARI\nGENEL MÜDÜRLÜĞÜ"
                    font.pixelSize: 14
                    font.family: "Arial"
                    color: "#cbd5e1"
                    horizontalAlignment: Text.AlignHCenter
                    lineHeight: 1.2
                }
            }
        }

        // MIDDLE SECTION: Excavator Image
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: parent.height * 0.40

            Image {
                id: excavatorImage
                anchors.centerIn: parent
                width: Math.min(parent.width * 0.7, 500)
                height: Math.min(parent.height * 0.9, 350)
                source: "qrc:/ExcavatorUI_Qt3D/resources/images/excavator_wireframe.png"
                fillMode: Image.PreserveAspectFit
                visible: status === Image.Ready

                // Placeholder if image not found
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    visible: excavatorImage.status !== Image.Ready

                    // Simple excavator wireframe placeholder
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.strokeStyle = "#475569";
                            ctx.lineWidth = 2;
                            ctx.clearRect(0, 0, width, height);

                            var centerX = width / 2;
                            var centerY = height / 2;

                            // Draw simple excavator outline
                            ctx.beginPath();
                            // Tracks (bottom)
                            ctx.rect(centerX - 80, centerY + 40, 160, 30);
                            // Body
                            ctx.rect(centerX - 60, centerY - 10, 120, 50);
                            // Boom
                            ctx.moveTo(centerX, centerY);
                            ctx.lineTo(centerX - 80, centerY - 60);
                            // Arm
                            ctx.lineTo(centerX - 120, centerY - 20);
                            // Bucket
                            ctx.lineTo(centerX - 140, centerY);
                            ctx.stroke();
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 80
                        text: "🚜"
                        font.pixelSize: 120
                        color: "#475569"
                        opacity: 0.3
                    }
                }
            }
        }

        // LOADING SECTION: Progress Bar and Text
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.15

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 15
                width: parent.width * 0.8

                // Loading Text
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Yükleniyor..."
                    font.pixelSize: 18
                    font.family: "Arial"
                    color: "#94a3b8"
                }

                // Progress Bar Container
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: Math.min(parent.width, 600)
                    Layout.preferredHeight: 12
                    radius: 6
                    color: "#334155"
                    border.color: "#475569"
                    border.width: 1

                    // Progress Bar Fill (Turquoise)
                    Rectangle {
                        id: progressBar
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 2
                        width: Math.max(0, (parent.width - 4) * splashScreen.progress)
                        radius: 4

                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#06b6d4" }  // Turquoise
                            GradientStop { position: 1.0; color: "#0891b2" }  // Darker turquoise
                        }

                        // No Behavior - let it follow progress property smoothly
                    }
                }
            }
        }

        // FOOTER SECTION: Company Logos
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.12

            RowLayout {
                anchors.centerIn: parent
                spacing: 60

                // Netaş Logo
                Image {
                    id: netasLogo
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 50
                    source: "qrc:/ExcavatorUI_Qt3D/resources/logos/netas_logo.png"
                    fillMode: Image.PreserveAspectFit
                    visible: status === Image.Ready

                    // Placeholder
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        visible: netasLogo.status !== Image.Ready

                        Text {
                            anchors.centerIn: parent
                            text: "NETAŞ"
                            font.pixelSize: 24
                            font.bold: true
                            color: "#60a5fa"
                        }
                    }
                }

                // TCDD Teknik Logo
                Image {
                    id: tcddLogo
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 50
                    source: "qrc:/ExcavatorUI_Qt3D/resources/logos/tcdd_teknik_logo.png"
                    fillMode: Image.PreserveAspectFit
                    visible: status === Image.Ready

                    // Placeholder
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        visible: tcddLogo.status !== Image.Ready

                        Text {
                            anchors.centerIn: parent
                            text: "TCDD TEKNİK"
                            font.pixelSize: 20
                            font.bold: true
                            color: "#60a5fa"
                        }
                    }
                }
            }
        }
    }
}
