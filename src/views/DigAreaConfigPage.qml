import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

/**
 * DigAreaConfigPage - Kazı Alanı Ayarları Sayfası
 *
 * Batimetrik veri girişi ve önizleme
 * - Grid boyutu ayarı
 * - Her hücreye derinlik girişi
 * - Canlı batimetrik harita önizlemesi
 */
Rectangle {
    id: root
    color: themeManager ? themeManager.backgroundColor : "#f7fafc"

    signal back()
    signal configSaved()

    // Translation support
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

    // Theme colors with fallbacks
    property color primaryColor: themeManager ? themeManager.primaryColor : "#319795"
    property color surfaceColor: themeManager ? themeManager.surfaceColor : "#ffffff"
    property color textColor: themeManager ? themeManager.textColor : "#2d3748"
    property color textSecondaryColor: themeManager ? themeManager.textSecondaryColor : "#718096"
    property color borderColor: themeManager ? themeManager.borderColor : "#e2e8f0"

    // Selected cell for editing
    property int selectedRow: -1
    property int selectedCol: -1

    // Grid verileri
    property int gridRows: configManager ? configManager.gridRows : 5
    property int gridCols: configManager ? configManager.gridCols : 5
    property var gridDepths: configManager ? configManager.gridDepths : []

    // Hesaplanan değerler
    property real maxDepth: {
        if (!gridDepths || gridDepths.length === 0) return 30
        var max = 0
        for (var i = 0; i < gridDepths.length; i++) {
            if (gridDepths[i] > max) max = gridDepths[i]
        }
        return max > 0 ? max : 30
    }

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
                    text: "<"
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
                text: tr("Dig Area Settings")
                font.pixelSize: 20
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.preferredWidth: 40 }
        }
    }

    // Content - Split view
    RowLayout {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
        anchors.margins: 16
        spacing: 16

        // Sol panel - Ayarlar ve veri girişi
        Rectangle {
            Layout.preferredWidth: parent.width * 0.45
            Layout.fillHeight: true
            color: root.surfaceColor
            radius: 12

            ScrollView {
                anchors.fill: parent
                contentWidth: parent.width

                ColumnLayout {
                    width: parent.width
                    spacing: 16

                    Item { Layout.preferredHeight: 8 }

                    // Grid Boyutu Kontrolleri
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.margins: 16
                        Layout.preferredHeight: gridSizeContent.height + 32
                        color: Qt.lighter(root.surfaceColor, 0.97)
                        radius: 8
                        border.width: 1
                        border.color: root.borderColor

                        ColumnLayout {
                            id: gridSizeContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: tr("Grid Size")
                                font.pixelSize: 14
                                font.bold: true
                                color: root.textColor
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 20

                                // Rows
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Text {
                                        text: tr("Rows")
                                        font.pixelSize: 12
                                        color: root.textSecondaryColor
                                    }

                                    RowLayout {
                                        spacing: 8

                                        Button {
                                            Layout.preferredWidth: 36
                                            Layout.preferredHeight: 36
                                            text: "-"
                                            font.pixelSize: 18
                                            enabled: configManager ? configManager.gridRows > 1 : false

                                            background: Rectangle {
                                                radius: 6
                                                color: parent.pressed ? Qt.darker(root.surfaceColor, 1.1) : root.surfaceColor
                                                border.width: 1
                                                border.color: root.borderColor
                                            }

                                            onClicked: if (configManager) configManager.gridRows = configManager.gridRows - 1
                                        }

                                        Text {
                                            Layout.preferredWidth: 32
                                            text: configManager ? configManager.gridRows.toString() : "5"
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: root.textColor
                                            horizontalAlignment: Text.AlignHCenter
                                        }

                                        Button {
                                            Layout.preferredWidth: 36
                                            Layout.preferredHeight: 36
                                            text: "+"
                                            font.pixelSize: 18
                                            enabled: configManager ? configManager.gridRows < 15 : false

                                            background: Rectangle {
                                                radius: 6
                                                color: parent.pressed ? Qt.darker(root.surfaceColor, 1.1) : root.surfaceColor
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
                                    spacing: 6

                                    Text {
                                        text: tr("Columns")
                                        font.pixelSize: 12
                                        color: root.textSecondaryColor
                                    }

                                    RowLayout {
                                        spacing: 8

                                        Button {
                                            Layout.preferredWidth: 36
                                            Layout.preferredHeight: 36
                                            text: "-"
                                            font.pixelSize: 18
                                            enabled: configManager ? configManager.gridCols > 1 : false

                                            background: Rectangle {
                                                radius: 6
                                                color: parent.pressed ? Qt.darker(root.surfaceColor, 1.1) : root.surfaceColor
                                                border.width: 1
                                                border.color: root.borderColor
                                            }

                                            onClicked: if (configManager) configManager.gridCols = configManager.gridCols - 1
                                        }

                                        Text {
                                            Layout.preferredWidth: 32
                                            text: configManager ? configManager.gridCols.toString() : "5"
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: root.textColor
                                            horizontalAlignment: Text.AlignHCenter
                                        }

                                        Button {
                                            Layout.preferredWidth: 36
                                            Layout.preferredHeight: 36
                                            text: "+"
                                            font.pixelSize: 18
                                            enabled: configManager ? configManager.gridCols < 15 : false

                                            background: Rectangle {
                                                radius: 6
                                                color: parent.pressed ? Qt.darker(root.surfaceColor, 1.1) : root.surfaceColor
                                                border.width: 1
                                                border.color: root.borderColor
                                            }

                                            onClicked: if (configManager) configManager.gridCols = configManager.gridCols + 1
                                        }
                                    }
                                }
                            }

                            Text {
                                text: tr("Total") + ": " + (configManager ? (configManager.gridRows * configManager.gridCols) : 25) + " " + tr("cells")
                                font.pixelSize: 11
                                color: root.textSecondaryColor
                            }
                        }
                    }

                    // Derinlik Veri Girişi Grid'i
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.margins: 16
                        Layout.preferredHeight: depthInputContent.height + 32
                        color: Qt.lighter(root.surfaceColor, 0.97)
                        radius: 8
                        border.width: 1
                        border.color: root.borderColor

                        ColumnLayout {
                            id: depthInputContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 16
                            spacing: 12

                            Row {
                                spacing: 8

                                Text {
                                    text: tr("Bathymetric Data Input")
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: root.textColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Rectangle {
                                    width: infoIcon.width + 8
                                    height: infoIcon.height + 8
                                    radius: height / 2
                                    color: "#1A75A8"

                                    Text {
                                        id: infoIcon
                                        anchors.centerIn: parent
                                        text: "?"
                                        font.pixelSize: 10
                                        font.bold: true
                                        color: "white"
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        ToolTip.visible: containsMouse
                                        ToolTip.text: tr("Click on cells to enter depth values. The bathymetric map will update in real-time.")
                                    }
                                }
                            }

                            Text {
                                text: tr("Click cells to enter depth (m)")
                                font.pixelSize: 11
                                color: root.textSecondaryColor
                            }

                            // Veri giriş grid'i
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: {
                                    var cellSize = Math.min((parent.width - 40) / gridCols, 50)
                                    return cellSize * gridRows + 25
                                }

                                // Sütun başlıkları
                                Row {
                                    id: colHeaders
                                    anchors.top: parent.top
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.horizontalCenterOffset: 15
                                    spacing: 2

                                    Repeater {
                                        model: gridCols
                                        Rectangle {
                                            width: Math.min((depthInputContent.width - 40) / gridCols, 50)
                                            height: 20
                                            color: "transparent"
                                            Text {
                                                anchors.centerIn: parent
                                                text: String.fromCharCode(65 + index)
                                                font.pixelSize: 10
                                                font.bold: true
                                                color: "#1A75A8"
                                            }
                                        }
                                    }
                                }

                                // Grid
                                Row {
                                    anchors.top: colHeaders.bottom
                                    anchors.topMargin: 2
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 2

                                    // Satır başlıkları
                                    Column {
                                        spacing: 2
                                        Repeater {
                                            model: gridRows
                                            Rectangle {
                                                width: 25
                                                height: Math.min((depthInputContent.width - 40) / gridCols, 50)
                                                color: "transparent"
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: (index + 1).toString()
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                    color: "#1A75A8"
                                                }
                                            }
                                        }
                                    }

                                    // Grid hücreleri
                                    Grid {
                                        columns: gridCols
                                        spacing: 2

                                        Repeater {
                                            model: gridRows * gridCols

                                            Rectangle {
                                                id: inputCell
                                                property int row: Math.floor(index / gridCols)
                                                property int col: index % gridCols
                                                property real depth: configManager ? configManager.getGridDepth(row, col) : 0
                                                property bool isSelected: selectedRow === row && selectedCol === col

                                                width: Math.min((depthInputContent.width - 40) / gridCols, 50)
                                                height: width
                                                radius: 4
                                                color: getDepthColor(depth)
                                                border.width: isSelected ? 2 : 1
                                                border.color: isSelected ? root.primaryColor : Qt.darker(color, 1.1)

                                                function getDepthColor(d) {
                                                    if (d <= 0) return root.surfaceColor
                                                    // Batimetrik renk skalası
                                                    var intensity = Math.min(d / 30, 1)
                                                    if (intensity < 0.1) return "#C6E7F2"
                                                    if (intensity < 0.2) return "#A8DAEB"
                                                    if (intensity < 0.3) return "#7AC5DE"
                                                    if (intensity < 0.4) return "#55B0D4"
                                                    if (intensity < 0.5) return "#3A9CC8"
                                                    if (intensity < 0.6) return "#2589BC"
                                                    if (intensity < 0.7) return "#1A75A8"
                                                    if (intensity < 0.8) return "#125E8C"
                                                    if (intensity < 0.9) return "#0B4770"
                                                    return "#063554"
                                                }

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: depth > 0 ? depth.toFixed(1) : "-"
                                                    font.pixelSize: parent.width > 40 ? 11 : 9
                                                    font.bold: true
                                                    color: depth > 10 ? "white" : root.textColor
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
                    }

                    // Hızlı doldurma araçları
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.margins: 16
                        Layout.preferredHeight: quickFillContent.height + 32
                        color: Qt.lighter(root.surfaceColor, 0.97)
                        radius: 8
                        border.width: 1
                        border.color: root.borderColor

                        ColumnLayout {
                            id: quickFillContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: tr("Quick Fill Tools")
                                font.pixelSize: 14
                                font.bold: true
                                color: root.textColor
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Button {
                                    Layout.fillWidth: true
                                    height: 36
                                    text: tr("Fill All")

                                    background: Rectangle {
                                        radius: 6
                                        color: parent.pressed ? Qt.darker("#1A75A8", 1.1) : "#1A75A8"
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 11
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: fillAllDialog.open()
                                }

                                Button {
                                    Layout.fillWidth: true
                                    height: 36
                                    text: tr("Random")

                                    background: Rectangle {
                                        radius: 6
                                        color: parent.pressed ? Qt.darker("#2589BC", 1.1) : "#2589BC"
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 11
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: {
                                        if (configManager) {
                                            for (var r = 0; r < gridRows; r++) {
                                                for (var c = 0; c < gridCols; c++) {
                                                    var depth = 2 + Math.random() * 25
                                                    configManager.setGridDepth(r, c, depth)
                                                }
                                            }
                                        }
                                    }
                                }

                                Button {
                                    Layout.fillWidth: true
                                    height: 36
                                    text: tr("Clear")

                                    background: Rectangle {
                                        radius: 6
                                        color: parent.pressed ? Qt.darker("#E53E3E", 1.1) : "#E53E3E"
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 11
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: {
                                        if (configManager) {
                                            for (var r = 0; r < gridRows; r++) {
                                                for (var c = 0; c < gridCols; c++) {
                                                    configManager.setGridDepth(r, c, 0)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.preferredHeight: 16 }
                }
            }
        }

        // Sağ panel - Canlı önizleme
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: root.surfaceColor
            radius: 12

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Önizleme başlığı
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: tr("Live Preview")
                        font.pixelSize: 14
                        font.bold: true
                        color: root.textColor
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: liveText.width + 16
                        height: 24
                        radius: 12
                        color: "#38A169"

                        Row {
                            anchors.centerIn: parent
                            spacing: 4

                            Rectangle {
                                width: 6
                                height: 6
                                radius: 3
                                color: "white"
                                anchors.verticalCenter: parent.verticalCenter

                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.3; duration: 500 }
                                    NumberAnimation { to: 1; duration: 500 }
                                }
                            }

                            Text {
                                id: liveText
                                text: "LIVE"
                                font.pixelSize: 10
                                font.bold: true
                                color: "white"
                            }
                        }
                    }
                }

                // Batimetrik harita önizlemesi
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#F7FAFC"
                    radius: 8
                    border.width: 2
                    border.color: "#1A75A8"

                    // Harita başlığı
                    Rectangle {
                        id: previewTitle
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 32
                        color: "#1A75A8"
                        radius: 6

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: parent.radius
                            color: parent.color
                        }

                        Text {
                            anchors.centerIn: parent
                            text: tr("Bathymetric Map") + " - " + tr("Preview")
                            font.pixelSize: 12
                            font.bold: true
                            color: "white"
                        }
                    }

                    // Batimetrik harita canvas'ı
                    BathymetricMapCanvas {
                        id: previewMap
                        anchors.top: previewTitle.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 8

                        gridRows: root.gridRows
                        gridCols: root.gridCols
                        gridDepths: root.gridDepths
                        maxDepth: root.maxDepth

                        showContours: true
                        contourInterval: 5
                        showGrid: false
                    }
                }

                // Lejant
                BathymetricLegend {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    title: tr("Depth Scale") + " (m)"
                    maxDepth: Math.max(root.maxDepth, 10)
                    textColor: root.textColor
                    backgroundColor: Qt.lighter(root.surfaceColor, 0.97)
                }
            }
        }
    }

    // Footer
    Rectangle {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 70
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
            width: Math.min(parent.width - 40, 300)
            height: 48
            text: tr("Save and Continue")

            background: Rectangle {
                radius: 10
                color: parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 15
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
        title: tr("Enter Depth Value")
        modal: true
        anchors.centerIn: parent
        width: 280

        background: Rectangle {
            color: themeManager ? themeManager.backgroundColor : "#f7fafc"
            radius: 12
            border.width: 1
            border.color: root.borderColor
        }

        header: Rectangle {
            width: parent.width
            height: 45
            color: root.primaryColor
            radius: 12

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.radius
                color: parent.color
            }

            Text {
                anchors.centerIn: parent
                text: tr("Cell") + " [" + String.fromCharCode(65 + selectedCol) + (selectedRow + 1) + "]"
                font.pixelSize: 14
                font.bold: true
                color: "white"
            }
        }

        contentItem: ColumnLayout {
            spacing: 12

            Item { Layout.preferredHeight: 4 }

            TextField {
                id: depthInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                placeholderText: tr("Depth") + " (m)"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                validator: DoubleValidator { bottom: 0; decimals: 2 }
                color: root.textColor
                placeholderTextColor: root.textSecondaryColor

                background: Rectangle {
                    color: root.surfaceColor
                    radius: 6
                    border.width: depthInput.activeFocus ? 2 : 1
                    border.color: depthInput.activeFocus ? root.primaryColor : root.borderColor
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: tr("Current value") + ": " + (
                    (selectedRow >= 0 && selectedCol >= 0 && configManager)
                        ? configManager.getGridDepth(selectedRow, selectedCol).toFixed(1) + " m"
                        : "0.0 m"
                )
                font.pixelSize: 11
                color: root.textSecondaryColor
            }
        }

        footer: RowLayout {
            spacing: 10

            Item { Layout.fillWidth: true }

            Button {
                text: tr("Cancel")
                flat: true

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 13
                    color: root.textSecondaryColor
                    horizontalAlignment: Text.AlignHCenter
                }

                onClicked: depthInputDialog.close()
            }

            Button {
                text: tr("Save")

                background: Rectangle {
                    radius: 6
                    color: parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 13
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

            Item { Layout.preferredWidth: 6 }
        }

        onOpened: {
            depthInput.text = ""
            depthInput.forceActiveFocus()
        }
    }

    // Fill All Dialog
    Dialog {
        id: fillAllDialog
        title: tr("Fill All Cells")
        modal: true
        anchors.centerIn: parent
        width: 280

        background: Rectangle {
            color: themeManager ? themeManager.backgroundColor : "#f7fafc"
            radius: 12
            border.width: 1
            border.color: root.borderColor
        }

        header: Rectangle {
            width: parent.width
            height: 45
            color: "#1A75A8"
            radius: 12

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.radius
                color: parent.color
            }

            Text {
                anchors.centerIn: parent
                text: tr("Fill All Cells")
                font.pixelSize: 14
                font.bold: true
                color: "white"
            }
        }

        contentItem: ColumnLayout {
            spacing: 12

            Item { Layout.preferredHeight: 4 }

            TextField {
                id: fillAllInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                placeholderText: tr("Depth") + " (m)"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                validator: DoubleValidator { bottom: 0; decimals: 2 }
                color: root.textColor
                placeholderTextColor: root.textSecondaryColor

                background: Rectangle {
                    color: root.surfaceColor
                    radius: 6
                    border.width: fillAllInput.activeFocus ? 2 : 1
                    border.color: fillAllInput.activeFocus ? "#1A75A8" : root.borderColor
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: tr("This will fill all") + " " + (gridRows * gridCols) + " " + tr("cells")
                font.pixelSize: 11
                color: root.textSecondaryColor
            }
        }

        footer: RowLayout {
            spacing: 10

            Item { Layout.fillWidth: true }

            Button {
                text: tr("Cancel")
                flat: true

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 13
                    color: root.textSecondaryColor
                    horizontalAlignment: Text.AlignHCenter
                }

                onClicked: fillAllDialog.close()
            }

            Button {
                text: tr("Fill")

                background: Rectangle {
                    radius: 6
                    color: parent.pressed ? Qt.darker("#1A75A8", 1.2) : "#1A75A8"
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 13
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                }

                onClicked: {
                    var val = parseFloat(fillAllInput.text)
                    if (!isNaN(val) && val >= 0 && configManager) {
                        for (var r = 0; r < gridRows; r++) {
                            for (var c = 0; c < gridCols; c++) {
                                configManager.setGridDepth(r, c, val)
                            }
                        }
                    }
                    fillAllDialog.close()
                }
            }

            Item { Layout.preferredWidth: 6 }
        }

        onOpened: {
            fillAllInput.text = ""
            fillAllInput.forceActiveFocus()
        }
    }
}
