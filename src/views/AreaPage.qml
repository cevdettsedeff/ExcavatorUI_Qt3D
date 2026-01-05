import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Kazı Alanı Sayfası - Derinlik grid'i ile görselleştirme
Rectangle {
    id: areaPage
    color: themeManager ? themeManager.backgroundColor : "#1a1a1a"

    // Dil değişikliği tetikleyici
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    // ConfigManager'dan gelen veriler
    property int gridRows: configManager ? configManager.gridRows : 5
    property int gridCols: configManager ? configManager.gridCols : 5
    property var gridDepths: configManager ? configManager.gridDepths : []

    // Theme colors
    property color primaryColor: themeManager ? themeManager.primaryColor : "#38b2ac"
    property color surfaceColor: themeManager ? themeManager.surfaceColor : "#ffffff"
    property color textColor: themeManager ? themeManager.textColor : "#ffffff"
    property color textSecondaryColor: themeManager ? themeManager.textColorSecondary : "#888888"
    property color borderColor: themeManager ? themeManager.borderColor : "#333333"

    function tr(text) {
        return languageTrigger >= 0 ? qsTranslate("Main", text) : ""
    }

    Connections {
        target: translationService
        function onLanguageChanged() {
            languageTrigger++
        }
    }

    // Derinliğe göre renk hesapla
    function getDepthColor(depth) {
        if (depth === undefined || depth === null || isNaN(depth)) {
            return "#cccccc"  // Tanımsız
        }

        var absDepth = Math.abs(depth)

        if (absDepth < 0.5) return "#4CAF50"       // Yeşil - sığ
        if (absDepth < 1.0) return "#8BC34A"       // Açık yeşil
        if (absDepth < 1.5) return "#CDDC39"       // Sarı-yeşil
        if (absDepth < 2.0) return "#FFEB3B"       // Sarı
        if (absDepth < 2.5) return "#FFC107"       // Amber
        if (absDepth < 3.0) return "#FF9800"       // Turuncu
        if (absDepth < 3.5) return "#FF5722"       // Koyu turuncu
        return "#f44336"                           // Kırmızı - derin
    }

    // Hücre derinlik değerini al
    function getCellDepth(row, col) {
        var index = row * gridCols + col
        if (gridDepths && index < gridDepths.length) {
            return gridDepths[index]
        }
        return null
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Başlık
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: areaPage.primaryColor

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                Text {
                    text: tr("Dig Area")
                    font.pixelSize: 20
                    font.bold: true
                    color: "white"
                }

                Item { Layout.fillWidth: true }

                // Grid bilgisi
                Rectangle {
                    Layout.preferredWidth: gridInfoText.width + 20
                    Layout.preferredHeight: 32
                    radius: 16
                    color: Qt.rgba(1, 1, 1, 0.2)

                    Text {
                        id: gridInfoText
                        anchors.centerIn: parent
                        text: gridRows + " x " + gridCols + " " + tr("Grid")
                        font.pixelSize: 12
                        font.bold: true
                        color: "white"
                    }
                }
            }
        }

        // Ana içerik
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 16
            spacing: 16

            // Sol: Derinlik Grid'i
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: areaPage.surfaceColor
                radius: 12

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    // Grid başlığı
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: tr("Depth Grid")
                            font.pixelSize: 16
                            font.bold: true
                            color: areaPage.textColor
                        }

                        Item { Layout.fillWidth: true }

                        // Ekskavatör konumu göstergesi
                        Rectangle {
                            width: excavatorPosText.width + 16
                            height: 28
                            radius: 14
                            color: "#FF6B35"

                            Text {
                                id: excavatorPosText
                                anchors.centerIn: parent
                                text: "📍 C3"
                                font.pixelSize: 11
                                font.bold: true
                                color: "white"
                            }
                        }
                    }

                    // Sütun başlıkları
                    Row {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 25
                        spacing: 2

                        // Boş köşe
                        Item {
                            width: 35
                            height: 25
                        }

                        Repeater {
                            model: gridCols

                            Rectangle {
                                width: (parent.parent.width - 37) / gridCols - 2
                                height: 25
                                color: "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: String.fromCharCode(65 + index)  // A, B, C, ...
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: areaPage.textSecondaryColor
                                }
                            }
                        }
                    }

                    // Grid satırları
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Column {
                            anchors.fill: parent
                            spacing: 2

                            Repeater {
                                model: gridRows

                                Row {
                                    property int rowIndex: index
                                    width: parent.width
                                    height: (parent.height - (gridRows - 1) * 2) / gridRows
                                    spacing: 2

                                    // Satır başlığı
                                    Rectangle {
                                        width: 35
                                        height: parent.height
                                        color: "transparent"

                                        Text {
                                            anchors.centerIn: parent
                                            text: (rowIndex + 1).toString()
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: areaPage.textSecondaryColor
                                        }
                                    }

                                    // Grid hücreleri
                                    Repeater {
                                        model: gridCols

                                        Rectangle {
                                            property int colIndex: index
                                            property var depth: getCellDepth(rowIndex, colIndex)
                                            property bool hasDepth: depth !== null && !isNaN(depth)
                                            property bool isExcavatorHere: rowIndex === 2 && colIndex === 2  // Örnek konum

                                            width: (parent.width - 37 - (gridCols - 1) * 2) / gridCols
                                            height: parent.height
                                            radius: 4
                                            color: hasDepth ? getDepthColor(depth) : "#e0e0e0"
                                            border.width: isExcavatorHere ? 3 : 1
                                            border.color: isExcavatorHere ? "#FF6B35" : Qt.darker(color, 1.1)

                                            Column {
                                                anchors.centerIn: parent
                                                spacing: 2

                                                // Ekskavatör ikonu
                                                Image {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    width: 20
                                                    height: 20
                                                    source: "qrc:/ExcavatorUI_Qt3D/resources/icons/nav_excavator.png"
                                                    fillMode: Image.PreserveAspectFit
                                                    visible: isExcavatorHere
                                                }

                                                // Derinlik değeri
                                                Text {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: hasDepth ? depth.toFixed(1) + "m" : "-"
                                                    font.pixelSize: parent.parent.height > 50 ? 12 : 10
                                                    font.bold: true
                                                    color: hasDepth ? "#ffffff" : "#888888"
                                                    style: hasDepth ? Text.Outline : Text.Normal
                                                    styleColor: "#00000040"
                                                }
                                            }

                                            // Hover efekti
                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true

                                                ToolTip.visible: containsMouse && hasDepth
                                                ToolTip.text: String.fromCharCode(65 + colIndex) + (rowIndex + 1) + ": " + (hasDepth ? depth.toFixed(2) + "m" : tr("No data"))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Sağ: Derinlik skalası ve istatistikler
            Rectangle {
                Layout.preferredWidth: 200
                Layout.fillHeight: true
                color: areaPage.surfaceColor
                radius: 12

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    // Derinlik skalası başlık
                    Text {
                        text: tr("Depth Scale")
                        font.pixelSize: 14
                        font.bold: true
                        color: areaPage.textColor
                    }

                    // Derinlik renk skalası
                    Column {
                        Layout.fillWidth: true
                        spacing: 4

                        Repeater {
                            model: [
                                { depth: "0 - 0.5m", color: "#4CAF50", label: tr("Very Shallow") },
                                { depth: "0.5 - 1.0m", color: "#8BC34A", label: tr("Shallow") },
                                { depth: "1.0 - 1.5m", color: "#CDDC39", label: "" },
                                { depth: "1.5 - 2.0m", color: "#FFEB3B", label: tr("Medium") },
                                { depth: "2.0 - 2.5m", color: "#FFC107", label: "" },
                                { depth: "2.5 - 3.0m", color: "#FF9800", label: tr("Deep") },
                                { depth: "3.0 - 3.5m", color: "#FF5722", label: "" },
                                { depth: "> 3.5m", color: "#f44336", label: tr("Very Deep") }
                            ]

                            Row {
                                spacing: 8
                                width: parent.width

                                Rectangle {
                                    width: 24
                                    height: 24
                                    color: modelData.color
                                    radius: 4
                                    border.width: 1
                                    border.color: Qt.darker(modelData.color, 1.1)
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 0

                                    Text {
                                        text: modelData.depth
                                        font.pixelSize: 11
                                        color: areaPage.textColor
                                    }

                                    Text {
                                        text: modelData.label
                                        font.pixelSize: 9
                                        color: areaPage.textSecondaryColor
                                        visible: modelData.label !== ""
                                    }
                                }
                            }
                        }
                    }

                    // Ayırıcı
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: areaPage.borderColor
                    }

                    // İstatistikler
                    Text {
                        text: tr("Statistics")
                        font.pixelSize: 14
                        font.bold: true
                        color: areaPage.textColor
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 8

                        // Toplam hücre
                        Row {
                            spacing: 8
                            Text {
                                text: tr("Total Cells") + ":"
                                font.pixelSize: 12
                                color: areaPage.textSecondaryColor
                            }
                            Text {
                                text: (gridRows * gridCols).toString()
                                font.pixelSize: 12
                                font.bold: true
                                color: areaPage.textColor
                            }
                        }

                        // Tanımlı hücre
                        Row {
                            spacing: 8
                            Text {
                                text: tr("Defined") + ":"
                                font.pixelSize: 12
                                color: areaPage.textSecondaryColor
                            }
                            Text {
                                text: gridDepths ? gridDepths.length.toString() : "0"
                                font.pixelSize: 12
                                font.bold: true
                                color: "#4CAF50"
                            }
                        }

                        // Min derinlik
                        Row {
                            spacing: 8
                            Text {
                                text: tr("Min Depth") + ":"
                                font.pixelSize: 12
                                color: areaPage.textSecondaryColor
                            }
                            Text {
                                text: {
                                    if (!gridDepths || gridDepths.length === 0) return "-"
                                    var min = Math.min.apply(null, gridDepths.filter(d => !isNaN(d)))
                                    return isFinite(min) ? min.toFixed(2) + "m" : "-"
                                }
                                font.pixelSize: 12
                                font.bold: true
                                color: "#4CAF50"
                            }
                        }

                        // Max derinlik
                        Row {
                            spacing: 8
                            Text {
                                text: tr("Max Depth") + ":"
                                font.pixelSize: 12
                                color: areaPage.textSecondaryColor
                            }
                            Text {
                                text: {
                                    if (!gridDepths || gridDepths.length === 0) return "-"
                                    var max = Math.max.apply(null, gridDepths.filter(d => !isNaN(d)))
                                    return isFinite(max) ? max.toFixed(2) + "m" : "-"
                                }
                                font.pixelSize: 12
                                font.bold: true
                                color: "#f44336"
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Yapılandırma durumu
                    Rectangle {
                        Layout.fillWidth: true
                        height: 50
                        radius: 8
                        color: configManager && configManager.digAreaConfigured
                            ? Qt.rgba(0.3, 0.69, 0.31, 0.2)
                            : Qt.rgba(1, 0.6, 0, 0.2)

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: configManager && configManager.digAreaConfigured ? "✓" : "⚠"
                                font.pixelSize: 18
                                color: configManager && configManager.digAreaConfigured ? "#4CAF50" : "#FF9800"
                            }

                            Text {
                                text: configManager && configManager.digAreaConfigured
                                    ? tr("Configured")
                                    : tr("Not Configured")
                                font.pixelSize: 12
                                font.bold: true
                                color: configManager && configManager.digAreaConfigured ? "#4CAF50" : "#FF9800"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
