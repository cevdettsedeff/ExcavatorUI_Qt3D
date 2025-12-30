import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * DigAreaConfigPage - Kazı Alanı Ayarları Sayfası
 *
 * Kullanıcı grid sistemini ayarlar:
 * - Satır ve sütun sayısı
 * - Her grid hücresine derinlik değeri girişi
 */
Rectangle {
    id: root
    color: themeManager ? themeManager.backgroundColor : "#f5f5f5"

    signal back()
    signal configSaved()

    // Theme colors with fallbacks
    property color primaryColor: themeManager ? themeManager.primaryColor : "#0891b2"
    property color surfaceColor: themeManager ? themeManager.surfaceColor : "#ffffff"
    property color textColor: themeManager ? themeManager.textColor : "#1f2937"
    property color textSecondaryColor: themeManager ? themeManager.textSecondaryColor : "#6b7280"
    property color borderColor: themeManager ? themeManager.borderColor : "#e5e7eb"

    // Selected cell for editing
    property int selectedRow: -1
    property int selectedCol: -1

    // Header
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: root.primaryColor

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            Button {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                flat: true

                contentItem: Text {
                    text: "←"
                    font.pixelSize: 24
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 20
                    color: parent.pressed ? Qt.rgba(1, 1, 1, 0.2) : "transparent"
                }

                onClicked: root.back()
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("Kazı Alanı Ayarları")
                font.pixelSize: 20
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.preferredWidth: 40 }
        }
    }

    // Content
    ScrollView {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
        contentWidth: parent.width

        ColumnLayout {
            width: parent.width
            spacing: 20

            Item { Layout.preferredHeight: 10 }

            // Grid Size Controls
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.preferredHeight: gridSizeContent.height + 32
                color: root.surfaceColor
                radius: 12

                ColumnLayout {
                    id: gridSizeContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 16
                    spacing: 16

                    Text {
                        text: qsTr("Grid Boyutu")
                        font.pixelSize: 16
                        font.bold: true
                        color: root.textColor
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20

                        // Rows
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: qsTr("Satır Sayısı")
                                font.pixelSize: 13
                                color: root.textSecondaryColor
                            }

                            RowLayout {
                                spacing: 8

                                Button {
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    text: "-"
                                    font.pixelSize: 20
                                    enabled: configManager ? configManager.gridRows > 1 : false

                                    background: Rectangle {
                                        radius: 8
                                        color: parent.pressed ? Qt.darker(root.surfaceColor, 1.2) : root.surfaceColor
                                        border.width: 1
                                        border.color: root.borderColor
                                    }

                                    onClicked: if (configManager) configManager.gridRows = configManager.gridRows - 1
                                }

                                Text {
                                    Layout.preferredWidth: 40
                                    text: configManager ? configManager.gridRows.toString() : "4"
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: root.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Button {
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    text: "+"
                                    font.pixelSize: 20
                                    enabled: configManager ? configManager.gridRows < 10 : false

                                    background: Rectangle {
                                        radius: 8
                                        color: parent.pressed ? Qt.darker(root.surfaceColor, 1.2) : root.surfaceColor
                                        border.width: 1
                                        border.color: root.borderColor
                                    }

                                    onClicked: if (configManager) configManager.gridRows = configManager.gridRows + 1
                                }
                            }
                        }

                        // Columns
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: qsTr("Sütun Sayısı")
                                font.pixelSize: 13
                                color: root.textSecondaryColor
                            }

                            RowLayout {
                                spacing: 8

                                Button {
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    text: "-"
                                    font.pixelSize: 20
                                    enabled: configManager ? configManager.gridCols > 1 : false

                                    background: Rectangle {
                                        radius: 8
                                        color: parent.pressed ? Qt.darker(root.surfaceColor, 1.2) : root.surfaceColor
                                        border.width: 1
                                        border.color: root.borderColor
                                    }

                                    onClicked: if (configManager) configManager.gridCols = configManager.gridCols - 1
                                }

                                Text {
                                    Layout.preferredWidth: 40
                                    text: configManager ? configManager.gridCols.toString() : "4"
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: root.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Button {
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    text: "+"
                                    font.pixelSize: 20
                                    enabled: configManager ? configManager.gridCols < 10 : false

                                    background: Rectangle {
                                        radius: 8
                                        color: parent.pressed ? Qt.darker(root.surfaceColor, 1.2) : root.surfaceColor
                                        border.width: 1
                                        border.color: root.borderColor
                                    }

                                    onClicked: if (configManager) configManager.gridCols = configManager.gridCols + 1
                                }
                            }
                        }
                    }

                    Text {
                        text: qsTr("Toplam: %1 grid hücresi").arg(
                            configManager ? (configManager.gridRows * configManager.gridCols) : 16
                        )
                        font.pixelSize: 12
                        color: root.textSecondaryColor
                    }
                }
            }

            // Grid Visualization
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.preferredHeight: gridArea.height + 80
                color: root.surfaceColor
                radius: 12

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        text: qsTr("Batimetrik Veri Girişi")
                        font.pixelSize: 16
                        font.bold: true
                        color: root.textColor
                    }

                    Text {
                        text: qsTr("Her hücreye tıklayarak derinlik değeri girin")
                        font.pixelSize: 12
                        color: root.textSecondaryColor
                    }

                    // Grid
                    Item {
                        id: gridArea
                        Layout.fillWidth: true
                        Layout.preferredHeight: {
                            var cols = configManager ? configManager.gridCols : 4
                            var rows = configManager ? configManager.gridRows : 4
                            var availableWidth = parent.width - 32
                            var cellSize = Math.min(availableWidth / cols, 80)
                            return cellSize * rows
                        }

                        Grid {
                            anchors.centerIn: parent
                            columns: configManager ? configManager.gridCols : 4
                            spacing: 4

                            Repeater {
                                model: configManager ? (configManager.gridRows * configManager.gridCols) : 16

                                Rectangle {
                                    id: gridCell
                                    property int row: Math.floor(index / (configManager ? configManager.gridCols : 4))
                                    property int col: index % (configManager ? configManager.gridCols : 4)
                                    property real depth: configManager ? configManager.getGridDepth(row, col) : 0

                                    width: {
                                        var cols = configManager ? configManager.gridCols : 4
                                        var availableWidth = gridArea.width - (cols - 1) * 4
                                        return Math.min(availableWidth / cols, 76)
                                    }
                                    height: width
                                    radius: 8
                                    color: getDepthColor(depth)
                                    border.width: (selectedRow === row && selectedCol === col) ? 3 : 1
                                    border.color: (selectedRow === row && selectedCol === col)
                                        ? root.primaryColor
                                        : Qt.darker(color, 1.2)

                                    function getDepthColor(d) {
                                        if (d === 0) return root.surfaceColor
                                        var intensity = Math.min(d / 30, 1)
                                        return Qt.rgba(
                                            0.2 + (1 - intensity) * 0.3,
                                            0.6 - intensity * 0.4,
                                            0.9 - intensity * 0.3,
                                            1
                                        )
                                    }

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 2

                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: depth > 0 ? depth.toFixed(1) : "-"
                                            font.pixelSize: gridCell.width > 50 ? 14 : 10
                                            font.bold: true
                                            color: depth > 15 ? "white" : root.textColor
                                        }

                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: depth > 0 ? "m" : ""
                                            font.pixelSize: 9
                                            color: depth > 15 ? Qt.rgba(1,1,1,0.7) : root.textSecondaryColor
                                            visible: gridCell.width > 40
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            selectedRow = row
                                            selectedCol = col
                                            depthInputDialog.open()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Depth Scale Legend
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.preferredHeight: 80
                color: root.surfaceColor
                radius: 12

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    Text {
                        text: qsTr("Derinlik Skalası:")
                        font.pixelSize: 12
                        color: root.textSecondaryColor
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24
                        radius: 4

                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#4DB8FF" }
                            GradientStop { position: 0.5; color: "#2196F3" }
                            GradientStop { position: 1.0; color: "#0D47A1" }
                        }
                    }

                    Text {
                        text: "0m"
                        font.pixelSize: 11
                        color: root.textSecondaryColor
                    }

                    Text {
                        text: "→"
                        font.pixelSize: 11
                        color: root.textSecondaryColor
                    }

                    Text {
                        text: "30m+"
                        font.pixelSize: 11
                        color: root.textSecondaryColor
                    }
                }
            }

            Item { Layout.preferredHeight: 20 }
        }
    }

    // Footer
    Rectangle {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        color: root.surfaceColor

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: root.borderColor
        }

        Button {
            anchors.centerIn: parent
            width: parent.width - 40
            height: 50
            text: qsTr("Kaydet ve Devam Et")

            background: Rectangle {
                radius: 12
                color: parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 16
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                root.configSaved()
            }
        }
    }

    // Depth Input Dialog
    Dialog {
        id: depthInputDialog
        title: qsTr("Derinlik Değeri Girin")
        modal: true
        anchors.centerIn: parent
        width: 300

        background: Rectangle {
            color: themeManager ? themeManager.backgroundColor : "#f5f5f5"
            radius: 16
            border.width: 1
            border.color: root.borderColor
        }

        header: Rectangle {
            width: parent.width
            height: 50
            color: root.primaryColor
            radius: 16

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.radius
                color: parent.color
            }

            Text {
                anchors.centerIn: parent
                text: qsTr("Grid [%1, %2] Derinliği").arg(selectedRow + 1).arg(selectedCol + 1)
                font.pixelSize: 16
                font.bold: true
                color: "white"
            }
        }

        contentItem: ColumnLayout {
            spacing: 16

            Item { Layout.preferredHeight: 8 }

            TextField {
                id: depthInput
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                placeholderText: qsTr("Derinlik (metre)")
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                validator: DoubleValidator { bottom: 0; decimals: 2 }
                color: root.textColor
                placeholderTextColor: root.textSecondaryColor

                background: Rectangle {
                    color: root.surfaceColor
                    radius: 8
                    border.width: depthInput.activeFocus ? 2 : 1
                    border.color: depthInput.activeFocus ? root.primaryColor : root.borderColor
                }

                Component.onCompleted: {
                    text = ""
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Mevcut değer: %1 m").arg(
                    (selectedRow >= 0 && selectedCol >= 0 && configManager)
                        ? configManager.getGridDepth(selectedRow, selectedCol).toFixed(1)
                        : "0.0"
                )
                font.pixelSize: 12
                color: root.textSecondaryColor
            }
        }

        footer: RowLayout {
            spacing: 12

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("İptal")
                flat: true

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: root.textSecondaryColor
                    horizontalAlignment: Text.AlignHCenter
                }

                onClicked: depthInputDialog.close()
            }

            Button {
                text: qsTr("Kaydet")

                background: Rectangle {
                    radius: 8
                    color: parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                }

                onClicked: {
                    var val = parseFloat(depthInput.text)
                    if (!isNaN(val) && val >= 0 && selectedRow >= 0 && selectedCol >= 0 && configManager) {
                        configManager.setGridDepth(selectedRow, selectedCol, val)
                    }
                    depthInputDialog.close()
                }
            }

            Item { Layout.preferredWidth: 8 }
        }

        onOpened: {
            depthInput.text = ""
            depthInput.forceActiveFocus()
        }
    }
}
