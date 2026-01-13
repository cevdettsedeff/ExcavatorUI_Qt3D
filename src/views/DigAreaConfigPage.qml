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

    // Global responsive değişkenlere erişim
    property var app: ApplicationWindow.window

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

    // Theme colors with fallbacks (dark theme optimized)
    property color primaryColor: (themeManager && themeManager.primaryColor) ? themeManager.primaryColor : "#319795"
    property color surfaceColor: (themeManager && themeManager.surfaceColor) ? themeManager.surfaceColor : "#ffffff"
    property color textColor: "white"  // Always white for dark backgrounds
    property color textSecondaryColor: Qt.rgba(1, 1, 1, 0.7)  // Semi-transparent white
    property color borderColor: Qt.rgba(1, 1, 1, 0.3)  // Light border for dark theme
    property color inputTextColor: "#2d3748"  // Dark text for input fields (white backgrounds)
    property color inputBorderColor: (themeManager && themeManager.borderColor) ? themeManager.borderColor : "#e2e8f0"

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
        height: app ? app.buttonHeight * 1.5 : 60
        color: root.primaryColor

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: app ? app.smallPadding : 16
            anchors.rightMargin: app ? app.smallPadding : 16

            Button {
                Layout.preferredWidth: app ? app.buttonHeight : 40
                Layout.preferredHeight: app ? app.buttonHeight : 40
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
                text: root.tr("Kazı Alanı Ayarları")
                font.pixelSize: app ? app.mediumFontSize : 20
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.preferredWidth: app ? app.buttonHeight : 40 }
        }
    }

    // Content - Split view
    RowLayout {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
        anchors.margins: app ? app.smallPadding : 16
        spacing: app ? app.normalSpacing : 16

        // Sol panel - Ayarlar ve veri girişi
        Rectangle {
            Layout.preferredWidth: parent.width * 0.35
            Layout.fillHeight: true
            color: Qt.rgba(1, 1, 1, 0.05)  // Dark semi-transparent background
            radius: 12
            border.width: 1
            border.color: root.borderColor

            ScrollView {
                anchors.fill: parent
                contentWidth: parent.width

                ColumnLayout {
                    width: parent.width
                    spacing: app ? app.normalSpacing : 16

                    Item { Layout.preferredHeight: app ? app.smallSpacing : 8 }

                    // Grid Boyutu Kontrolleri
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.margins: app ? app.smallPadding : 16
                        Layout.preferredHeight: gridSizeContent.height + 32
                        color: Qt.rgba(1, 1, 1, 0.08)  // Slightly lighter for contrast
                        radius: 8
                        border.width: 1
                        border.color: root.borderColor

                        ColumnLayout {
                            id: gridSizeContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: app ? app.smallPadding : 16
                            spacing: app ? app.smallSpacing : 12

                            Text {
                                text: root.tr("Izgara Boyutu")
                                font.pixelSize: app ? app.baseFontSize : 14
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
                                        text: root.tr("Satır")
                                        font.pixelSize: app ? app.smallFontSize : 12
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
                                        text: root.tr("Sütun")
                                        font.pixelSize: app ? app.smallFontSize : 12
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
                                text: root.tr("Toplam") + ": " + (configManager ? (configManager.gridRows * configManager.gridCols) : 25) + " " + root.tr("hücre doldurulacak")
                                font.pixelSize: app ? app.smallFontSize * 0.9 : 11
                                color: root.textSecondaryColor
                            }
                        }
                    }

                    // Derinlik Veri Girişi Grid'i
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.margins: app ? app.smallPadding : 16
                        Layout.preferredHeight: depthInputContent.height + 32
                        color: Qt.rgba(1, 1, 1, 0.08)
                        radius: 8
                        border.width: 1
                        border.color: root.borderColor

                        ColumnLayout {
                            id: depthInputContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: app ? app.smallPadding : 16
                            spacing: app ? app.smallSpacing : 12

                            Row {
                                spacing: 8

                                Text {
                                    text: root.tr("Batimetrik Veri Girişi")
                                    font.pixelSize: app ? app.baseFontSize : 14
                                    font.bold: true
                                    color: root.textColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Rectangle {
                                    width: infoIcon.width + 8
                                    height: infoIcon.height + 8
                                    radius: height / 2
                                    color: root.primaryColor

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
                                        ToolTip.text: root.tr("Derinlik girmek için hücrelere tıklayın (m)")
                                    }
                                }
                            }

                            Text {
                                text: root.tr("Derinlik girmek için hücrelere tıklayın (m)")
                                font.pixelSize: app ? app.smallFontSize * 0.9 : 11
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
                                                font.pixelSize: app ? app.smallFontSize * 0.8 : 10
                                                font.bold: true
                                                color: root.primaryColor
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
                                                    font.pixelSize: app ? app.smallFontSize * 0.8 : 10
                                                    font.bold: true
                                                    color: root.primaryColor
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
                                                // gridDepths değiştiğinde depth'i yeniden hesapla
                                                property real depth: {
                                                    // root.gridDepths'e bağımlılık ekleyerek değişiklikleri yakalıyoruz
                                                    var _ = root.gridDepths
                                                    return configManager ? configManager.getGridDepth(row, col) : 0
                                                }
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
                                                    font.pixelSize: parent.width > 40 ? (app ? app.smallFontSize * 0.9 : 11) : (app ? app.smallFontSize * 0.7 : 9)
                                                    font.bold: true
                                                    color: {
                                                        if (depth <= 0) return root.textSecondaryColor
                                                        return depth > 10 ? "white" : "#2d3748"  // Dark text for light cells, white for dark cells
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
                    }

                    // Koordinat Girişi
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.margins: app ? app.smallPadding : 16
                        Layout.preferredHeight: coordInputContent.height + 32
                        color: Qt.rgba(1, 1, 1, 0.08)
                        radius: 8
                        border.width: 1
                        border.color: root.borderColor

                        ColumnLayout {
                            id: coordInputContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: app ? app.smallPadding : 16
                            spacing: app ? app.smallSpacing : 12

                            Text {
                                text: root.tr("Koordinat Sınırları")
                                font.pixelSize: app ? app.baseFontSize : 14
                                font.bold: true
                                color: root.textColor
                            }

                            Text {
                                text: root.tr("Grid için coğrafi alanı tanımlayın")
                                font.pixelSize: app ? app.smallFontSize * 0.9 : 11
                                color: root.textSecondaryColor
                            }

                            // Başlangıç koordinatları
                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                rowSpacing: 8
                                columnSpacing: 12

                                Text {
                                    text: root.tr("Başl. Enlem") + ":"
                                    font.pixelSize: app ? app.smallFontSize * 0.9 : 11
                                    color: root.textSecondaryColor
                                }

                                TextField {
                                    id: startLatField
                                    Layout.fillWidth: true
                                    height: app ? app.buttonHeight * 0.7 : 36
                                    text: configManager ? configManager.gridStartLatitude.toFixed(6) : "40.710000"
                                    font.pixelSize: app ? app.smallFontSize : 12
                                    color: root.inputTextColor
                                    horizontalAlignment: Text.AlignRight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    validator: DoubleValidator { bottom: -90; top: 90; decimals: 6 }

                                    background: Rectangle {
                                        color: root.surfaceColor
                                        radius: 4
                                        border.width: parent.activeFocus ? 2 : 1
                                        border.color: parent.activeFocus ? root.primaryColor : root.inputBorderColor
                                    }

                                    onEditingFinished: {
                                        if (configManager) configManager.gridStartLatitude = parseFloat(text)
                                    }
                                }

                                Text {
                                    text: root.tr("Başl. Boylam") + ":"
                                    font.pixelSize: app ? app.smallFontSize * 0.9 : 11
                                    color: root.textSecondaryColor
                                }

                                TextField {
                                    id: startLonField
                                    Layout.fillWidth: true
                                    height: app ? app.buttonHeight * 0.7 : 36
                                    text: configManager ? configManager.gridStartLongitude.toFixed(6) : "29.000000"
                                    font.pixelSize: app ? app.smallFontSize : 12
                                    color: root.inputTextColor
                                    horizontalAlignment: Text.AlignRight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    validator: DoubleValidator { bottom: -180; top: 180; decimals: 6 }

                                    background: Rectangle {
                                        color: root.surfaceColor
                                        radius: 4
                                        border.width: parent.activeFocus ? 2 : 1
                                        border.color: parent.activeFocus ? root.primaryColor : root.inputBorderColor
                                    }

                                    onEditingFinished: {
                                        if (configManager) configManager.gridStartLongitude = parseFloat(text)
                                    }
                                }

                                Text {
                                    text: root.tr("Bitiş Enlem") + ":"
                                    font.pixelSize: app ? app.smallFontSize * 0.9 : 11
                                    color: root.textSecondaryColor
                                }

                                TextField {
                                    id: endLatField
                                    Layout.fillWidth: true
                                    height: app ? app.buttonHeight * 0.7 : 36
                                    text: configManager ? configManager.gridEndLatitude.toFixed(6) : "40.720000"
                                    font.pixelSize: app ? app.smallFontSize : 12
                                    color: root.inputTextColor
                                    horizontalAlignment: Text.AlignRight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    validator: DoubleValidator { bottom: -90; top: 90; decimals: 6 }

                                    background: Rectangle {
                                        color: root.surfaceColor
                                        radius: 4
                                        border.width: parent.activeFocus ? 2 : 1
                                        border.color: parent.activeFocus ? root.primaryColor : root.inputBorderColor
                                    }

                                    onEditingFinished: {
                                        if (configManager) configManager.gridEndLatitude = parseFloat(text)
                                    }
                                }

                                Text {
                                    text: root.tr("Bitiş Boylam") + ":"
                                    font.pixelSize: app ? app.smallFontSize * 0.9 : 11
                                    color: root.textSecondaryColor
                                }

                                TextField {
                                    id: endLonField
                                    Layout.fillWidth: true
                                    height: app ? app.buttonHeight * 0.7 : 36
                                    text: configManager ? configManager.gridEndLongitude.toFixed(6) : "29.010000"
                                    font.pixelSize: app ? app.smallFontSize : 12
                                    color: root.inputTextColor
                                    horizontalAlignment: Text.AlignRight
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    validator: DoubleValidator { bottom: -180; top: 180; decimals: 6 }

                                    background: Rectangle {
                                        color: root.surfaceColor
                                        radius: 4
                                        border.width: parent.activeFocus ? 2 : 1
                                        border.color: parent.activeFocus ? root.primaryColor : root.inputBorderColor
                                    }

                                    onEditingFinished: {
                                        if (configManager) configManager.gridEndLongitude = parseFloat(text)
                                    }
                                }
                            }
                        }
                    }

                    // Hızlı doldurma araçları
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.margins: app ? app.smallPadding : 16
                        Layout.preferredHeight: quickFillContent.height + 32
                        color: Qt.rgba(1, 1, 1, 0.08)
                        radius: 8
                        border.width: 1
                        border.color: root.borderColor

                        ColumnLayout {
                            id: quickFillContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: app ? app.smallPadding : 16
                            spacing: app ? app.smallSpacing : 12

                            Text {
                                text: root.tr("Hızlı Doldurma Araçları")
                                font.pixelSize: app ? app.baseFontSize : 14
                                font.bold: true
                                color: root.textColor
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Button {
                                    Layout.fillWidth: true
                                    height: app ? app.buttonHeight * 0.7 : 36
                                    text: root.tr("Hepsini Doldur")

                                    background: Rectangle {
                                        radius: 6
                                        color: parent.pressed ? Qt.darker(root.primaryColor, 1.1) : root.primaryColor
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: app ? app.smallFontSize * 0.9 : 11
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: fillAllDialog.open()
                                }

                                Button {
                                    Layout.fillWidth: true
                                    height: app ? app.buttonHeight * 0.7 : 36
                                    text: root.tr("Rastgele")

                                    background: Rectangle {
                                        radius: 6
                                        color: parent.pressed ? Qt.darker("#2589BC", 1.1) : "#2589BC"
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: app ? app.smallFontSize * 0.9 : 11
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
                                    height: app ? app.buttonHeight * 0.7 : 36
                                    text: root.tr("Temizle")

                                    background: Rectangle {
                                        radius: 6
                                        color: parent.pressed ? Qt.darker("#E53E3E", 1.1) : "#E53E3E"
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: app ? app.smallFontSize * 0.9 : 11
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
            color: Qt.rgba(1, 1, 1, 0.05)
            radius: 12
            border.width: 1
            border.color: root.borderColor

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: app ? app.smallPadding : 16
                spacing: app ? app.smallSpacing : 12

                // Önizleme başlığı
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: root.tr("Canlı Önizleme")
                        font.pixelSize: app ? app.baseFontSize : 14
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
                            text: root.tr("Batimetrik Harita") + " - " + root.tr("Önizleme")
                            font.pixelSize: app ? app.smallFontSize : 12
                            font.bold: true
                            color: "white"
                        }
                    }

                    // Batimetrik harita canvas'ı - konturlar kapalı (performans için)
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

                        // Koordinatlar
                        startLatitude: configManager ? configManager.gridStartLatitude : 40.71
                        startLongitude: configManager ? configManager.gridStartLongitude : 29.00
                        endLatitude: configManager ? configManager.gridEndLatitude : 40.72
                        endLongitude: configManager ? configManager.gridEndLongitude : 29.01

                        showContours: false
                        showGrid: true
                        showCoordinates: true
                        smoothTransitions: true

                        // Tema renkleri
                        containerColor: Qt.lighter(root.surfaceColor, 1.02)
                        labelColor: root.textSecondaryColor
                    }
                }

                // Lejant
                BathymetricLegend {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    title: root.tr("Derinlik Skalası") + " (m)"
                    maxDepth: Math.max(root.maxDepth, 10)
                    textColor: root.textColor
                    backgroundColor: Qt.rgba(1, 1, 1, 0.08)
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
        height: app ? app.buttonHeight * 1.4 : 70
        color: Qt.rgba(1, 1, 1, 0.05)
        border.width: 1
        border.color: root.borderColor

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
            height: app ? app.buttonHeight : 48
            text: root.tr("Kaydet ve Devam Et")

            background: Rectangle {
                radius: 10
                color: parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: app ? app.mediumFontSize : 15
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

    // Depth Input Dialog - Popup olarak klavyenin önünde
    Popup {
        id: depthInputDialog
        modal: true
        x: (parent.width - width) / 2
        y: 50  // Ekranın en üstünde, klavye altında kalmayacak
        width: 300
        height: 220
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        z: 1000
        padding: 0

        // Mevcut değeri sakla
        property real currentDepthValue: 0

        background: Rectangle {
            color: root.surfaceColor
            radius: 12
            border.width: 2
            border.color: root.primaryColor

            // Basit gölge efekti
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 4
                anchors.leftMargin: 2
                anchors.rightMargin: -2
                anchors.bottomMargin: -4
                z: -1
                radius: parent.radius
                color: "#40000000"
            }
        }

        contentItem: Column {
            id: dialogContent
            width: parent.width
            spacing: 0

            // Header
            Rectangle {
                width: parent.width
                height: 50
                color: root.primaryColor
                radius: 10

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.radius
                    color: parent.color
                }

                Text {
                    anchors.centerIn: parent
                    text: root.tr("Hücre") + " [" + String.fromCharCode(65 + selectedCol) + (selectedRow + 1) + "]"
                    font.pixelSize: app ? app.baseFontSize : 16
                    font.bold: true
                    color: "white"
                }
            }

            // Content
            Item {
                width: parent.width
                height: 170

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    TextField {
                        id: depthInput
                        width: parent.width
                        height: app ? app.buttonHeight : 50
                        placeholderText: root.tr("Derinlik") + " (m)"
                        font.pixelSize: app ? app.mediumFontSize : 18
                        horizontalAlignment: Text.AlignHCenter
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        color: root.inputTextColor
                        placeholderTextColor: Qt.rgba(0.5, 0.5, 0.5, 0.5)

                        background: Rectangle {
                            color: root.surfaceColor
                            radius: 8
                            border.width: depthInput.activeFocus ? 2 : 1
                            border.color: depthInput.activeFocus ? root.primaryColor : root.inputBorderColor
                        }
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: root.tr("Mevcut değer") + ": " + depthInputDialog.currentDepthValue.toFixed(1) + " m"
                        font.pixelSize: app ? app.smallFontSize : 12
                        color: root.textColor
                    }

                    // Buttons
                    Row {
                        width: parent.width
                        spacing: 12
                        layoutDirection: Qt.RightToLeft

                        Button {
                            width: 100
                            height: app ? app.buttonHeight * 0.8 : 42
                            text: root.tr("Kaydet")

                            background: Rectangle {
                                radius: 8
                                color: parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor
                            }

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: app ? app.baseFontSize : 14
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                // Virgülü noktaya çevir (Türkçe klavye desteği)
                                var inputText = depthInput.text.replace(",", ".")
                                var val = parseFloat(inputText)
                                if (!isNaN(val) && val >= 0 && selectedRow >= 0 && selectedCol >= 0 && configManager) {
                                    configManager.setGridDepth(selectedRow, selectedCol, val)
                                }
                                depthInputDialog.close()
                            }
                        }

                        Button {
                            width: 80
                            height: app ? app.buttonHeight * 0.8 : 42
                            text: root.tr("İptal")
                            flat: true

                            background: Rectangle {
                                radius: 8
                                color: parent.pressed ? Qt.rgba(0.5, 0.5, 0.5, 0.2) : "transparent"
                                border.width: 1
                                border.color: root.borderColor
                            }

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: app ? app.baseFontSize : 14
                                color: root.textColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: depthInputDialog.close()
                        }
                    }
                }
            }
        }

        onAboutToShow: {
            // Dialog açılmadan önce mevcut değeri al
            if (selectedRow >= 0 && selectedCol >= 0 && configManager) {
                currentDepthValue = configManager.getGridDepth(selectedRow, selectedCol)
            } else {
                currentDepthValue = 0
            }
            depthInput.text = ""
        }

        onOpened: {
            depthInput.forceActiveFocus()
        }
    }

    // Fill All Dialog - Popup olarak klavyenin önünde
    Popup {
        id: fillAllDialog
        modal: true
        x: (parent.width - width) / 2
        y: 50  // Ekranın en üstünde
        width: 300
        height: 220
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        z: 1000
        padding: 0

        background: Rectangle {
            color: root.surfaceColor
            radius: 12
            border.width: 2
            border.color: "#1A75A8"

            // Basit gölge efekti
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 4
                anchors.leftMargin: 2
                anchors.rightMargin: -2
                anchors.bottomMargin: -4
                z: -1
                radius: parent.radius
                color: "#40000000"
            }
        }

        contentItem: Column {
            id: fillAllContent
            width: parent.width
            spacing: 0

            // Header
            Rectangle {
                width: parent.width
                height: 50
                color: "#1A75A8"
                radius: 10

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.radius
                    color: parent.color
                }

                Text {
                    anchors.centerIn: parent
                    text: root.tr("Tüm Hücreleri Doldur")
                    font.pixelSize: app ? app.baseFontSize : 16
                    font.bold: true
                    color: "white"
                }
            }

            // Content
            Item {
                width: parent.width
                height: 170

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    TextField {
                        id: fillAllInput
                        width: parent.width
                        height: app ? app.buttonHeight : 50
                        placeholderText: root.tr("Derinlik") + " (m)"
                        font.pixelSize: app ? app.mediumFontSize : 18
                        horizontalAlignment: Text.AlignHCenter
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        color: root.inputTextColor
                        placeholderTextColor: Qt.rgba(0.5, 0.5, 0.5, 0.5)

                        background: Rectangle {
                            color: root.surfaceColor
                            radius: 8
                            border.width: fillAllInput.activeFocus ? 2 : 1
                            border.color: fillAllInput.activeFocus ? root.primaryColor : root.inputBorderColor
                        }
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: root.tr("Bu işlem") + " " + (gridRows * gridCols) + " " + root.tr("hücreyi dolduracak")
                        font.pixelSize: app ? app.smallFontSize : 12
                        color: root.textColor
                    }

                    // Buttons
                    Row {
                        width: parent.width
                        spacing: 12
                        layoutDirection: Qt.RightToLeft

                        Button {
                            width: 100
                            height: app ? app.buttonHeight * 0.8 : 42
                            text: root.tr("Doldur")

                            background: Rectangle {
                                radius: 8
                                color: parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor
                            }

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: app ? app.baseFontSize : 14
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                // Virgülü noktaya çevir (Türkçe klavye desteği)
                                var inputText = fillAllInput.text.replace(",", ".")
                                var val = parseFloat(inputText)
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

                        Button {
                            width: 80
                            height: app ? app.buttonHeight * 0.8 : 42
                            text: root.tr("İptal")
                            flat: true

                            background: Rectangle {
                                radius: 8
                                color: parent.pressed ? Qt.rgba(0.5, 0.5, 0.5, 0.2) : "transparent"
                                border.width: 1
                                border.color: root.borderColor
                            }

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: app ? app.baseFontSize : 14
                                color: root.textColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: fillAllDialog.close()
                        }
                    }
                }
            }
        }

        onAboutToShow: {
            fillAllInput.text = ""
        }

        onOpened: {
            fillAllInput.forceActiveFocus()
        }
    }
}
