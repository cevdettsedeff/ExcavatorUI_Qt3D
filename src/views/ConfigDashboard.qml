import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * ConfigDashboard - Ana konfigürasyon dashboard'u
 *
 * Kullanıcı giriş yaptıktan sonra bu ekran gösterilir.
 * 4 konfigürasyon kutucuğu içerir:
 * 1. Ekskavatör Ayarları
 * 2. Kazı Alanı Ayarları
 * 3. Harita Ayarları
 * 4. Alarm Ayarları
 */
Rectangle {
    id: root
    color: themeManager.backgroundColor

    // Signals
    signal configurationComplete()
    signal openExcavatorConfig()
    signal openDigAreaConfig()
    signal openMapConfig()
    signal openAlarmConfig()

    // StackView for navigation
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: dashboardView
    }

    // Dashboard Ana Görünümü
    Component {
        id: dashboardView

        Rectangle {
            color: themeManager.backgroundColor

            ScrollView {
                anchors.fill: parent
                contentWidth: parent.width

                ColumnLayout {
                    width: parent.width
                    spacing: 20

                    // Header
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        color: themeManager.primaryColor

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: qsTr("Konfigürasyon Merkezi")
                                font.pixelSize: 28
                                font.bold: true
                                color: "white"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: qsTr("Lütfen aşağıdaki ayarları tamamlayın")
                                font.pixelSize: 14
                                color: Qt.rgba(1, 1, 1, 0.8)
                                Layout.alignment: Qt.AlignHCenter
                            }

                            // Progress indicator
                            Rectangle {
                                Layout.preferredWidth: 200
                                Layout.preferredHeight: 6
                                Layout.alignment: Qt.AlignHCenter
                                radius: 3
                                color: Qt.rgba(1, 1, 1, 0.3)

                                Rectangle {
                                    width: parent.width * configProgress
                                    height: parent.height
                                    radius: 3
                                    color: "white"

                                    Behavior on width {
                                        NumberAnimation { duration: 300 }
                                    }
                                }
                            }

                            property real configProgress: {
                                var count = 0;
                                if (configManager.excavatorConfigured) count++;
                                if (configManager.digAreaConfigured) count++;
                                if (configManager.mapConfigured) count++;
                                if (configManager.alarmConfigured) count++;
                                return count / 4;
                            }
                        }
                    }

                    // Config Tiles Grid
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.margins: 20
                        columns: 2
                        rowSpacing: 20
                        columnSpacing: 20

                        // 1. Ekskavatör Ayarları
                        ConfigTile {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 200
                            title: qsTr("Ekskavatör Ayarları")
                            description: qsTr("Boom, arm uzunlukları ve ekskavatör adı")
                            imageSource: "qrc:/ExcavatorUI_Qt3D/resources/icons/app_icon.ico"
                            stepNumber: 1
                            isConfigured: configManager.excavatorConfigured
                            isEnabled: true

                            onClicked: {
                                stackView.push(excavatorConfigComponent)
                            }
                        }

                        // 2. Kazı Alanı Ayarları
                        ConfigTile {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 200
                            title: qsTr("Kazı Alanı Ayarları")
                            description: qsTr("Grid sistemi ve batimetrik veri girişi")
                            icon: "📐"
                            stepNumber: 2
                            isConfigured: configManager.digAreaConfigured
                            isEnabled: true

                            onClicked: {
                                stackView.push(digAreaConfigComponent)
                            }
                        }

                        // 3. Harita Ayarları
                        ConfigTile {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 200
                            title: qsTr("Harita Ayarları")
                            description: qsTr("Kazı yapılacak alanı haritadan seçin")
                            icon: "🗺"
                            stepNumber: 3
                            isConfigured: configManager.mapConfigured
                            isEnabled: true

                            onClicked: {
                                stackView.push(mapConfigComponent)
                            }
                        }

                        // 4. Alarm Ayarları
                        ConfigTile {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 200
                            title: qsTr("Alarm Ayarları")
                            description: qsTr("Alarm renklerini özelleştirin")
                            icon: "🔔"
                            stepNumber: 4
                            isConfigured: configManager.alarmConfigured
                            isEnabled: true

                            onClicked: {
                                stackView.push(alarmConfigComponent)
                            }
                        }
                    }

                    // Ana Ekrana Geç Butonu
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 300
                        Layout.preferredHeight: 56
                        Layout.bottomMargin: 40
                        text: qsTr("Ana Ekrana Geç")
                        enabled: configManager.isConfigured

                        background: Rectangle {
                            radius: 12
                            color: parent.enabled
                                ? (parent.pressed ? Qt.darker(themeManager.primaryColor, 1.2) : themeManager.primaryColor)
                                : themeManager.surfaceColor

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 18
                            font.bold: true
                            color: parent.enabled ? "white" : themeManager.textSecondaryColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            configManager.saveConfig()
                            root.configurationComplete()
                        }
                    }

                    // Yardım metni
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 20
                        text: configManager.isConfigured
                            ? qsTr("Tüm ayarlar tamamlandı!")
                            : qsTr("Tüm adımları tamamladığınızda ana ekrana geçebilirsiniz")
                        font.pixelSize: 12
                        color: configManager.isConfigured ? themeManager.successColor : themeManager.textSecondaryColor
                    }
                }
            }
        }
    }

    // Excavator Config Component
    Component {
        id: excavatorConfigComponent
        ExcavatorConfigPage {
            onBack: stackView.pop()
            onConfigSaved: {
                configManager.markExcavatorConfigured()
                configManager.saveConfig()
                stackView.pop()
            }
        }
    }

    // Dig Area Config Component
    Component {
        id: digAreaConfigComponent
        DigAreaConfigPage {
            onBack: stackView.pop()
            onConfigSaved: {
                configManager.markDigAreaConfigured()
                configManager.saveConfig()
                stackView.pop()
            }
        }
    }

    // Map Config Component
    Component {
        id: mapConfigComponent
        MapConfigPage {
            onBack: stackView.pop()
            onConfigSaved: {
                configManager.markMapConfigured()
                configManager.saveConfig()
                stackView.pop()
            }
        }
    }

    // Alarm Config Component
    Component {
        id: alarmConfigComponent
        AlarmConfigPage {
            onBack: stackView.pop()
            onConfigSaved: {
                configManager.markAlarmConfigured()
                configManager.saveConfig()
                stackView.pop()
            }
        }
    }

    // ConfigTile Component
    component ConfigTile: Rectangle {
        id: tile

        property string title: ""
        property string description: ""
        property string icon: ""
        property string imageSource: ""  // Opsiyonel resim kaynağı
        property int stepNumber: 1
        property bool isConfigured: false
        property bool isEnabled: true

        signal clicked()

        // Tamamlanan kutucuklar mavi, diğerleri normal
        color: tile.isConfigured ? themeManager.primaryColor : themeManager.surfaceColor
        radius: 16
        border.width: tile.isConfigured ? 0 : 1
        border.color: themeManager.borderColor

        // Shadow using border (simple approach without layer effect)
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: tile.radius + 2
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.1)
            z: -1
        }

        MouseArea {
            anchors.fill: parent
            enabled: tile.isEnabled
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                tile.clicked()
            }

            onPressed: {
                tile.scale = 0.98
            }

            onReleased: {
                tile.scale = 1.0
            }
        }

        Behavior on scale {
            NumberAnimation { duration: 100 }
        }

        Behavior on color {
            ColorAnimation { duration: 200 }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 4

            // Üst kısım: Başlık ve durum badge yan yana
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Başlık - kutucuğun üstünde belirgin şekilde
                Text {
                    Layout.fillWidth: true
                    text: tile.title
                    font.pixelSize: 14
                    font.bold: true
                    color: tile.isConfigured ? "white" : themeManager.textColor
                    elide: Text.ElideRight
                }

                // Status indicator
                Rectangle {
                    Layout.preferredWidth: statusText.width + 12
                    Layout.preferredHeight: 22
                    radius: 11
                    color: tile.isConfigured
                        ? Qt.rgba(1, 1, 1, 0.25)
                        : Qt.rgba(themeManager.warningColor.r, themeManager.warningColor.g, themeManager.warningColor.b, 0.2)

                    Text {
                        id: statusText
                        anchors.centerIn: parent
                        text: tile.isConfigured ? "✓" : "..."
                        font.pixelSize: 10
                        font.bold: true
                        color: tile.isConfigured ? "white" : themeManager.warningColor
                    }
                }
            }

            // Icon - Emoji veya Image
            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: true
                Layout.preferredWidth: 56
                Layout.preferredHeight: 56

                // Emoji icon - sadece imageSource boşsa göster
                Text {
                    anchors.centerIn: parent
                    text: tile.icon
                    font.pixelSize: 48
                    visible: tile.imageSource.length === 0
                }

                // Image icon - imageSource doluysa göster
                Image {
                    anchors.centerIn: parent
                    source: tile.imageSource
                    width: 52
                    height: 52
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    antialiasing: true
                    visible: tile.imageSource.length > 0
                }
            }

            // Description
            Text {
                Layout.fillWidth: true
                text: tile.description
                font.pixelSize: 11
                color: tile.isConfigured ? Qt.rgba(1, 1, 1, 0.8) : themeManager.textSecondaryColor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            // Alt kısımda düzenle/yapılandır butonu görünümü
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                radius: 6
                color: tile.isConfigured ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(themeManager.primaryColor.r, themeManager.primaryColor.g, themeManager.primaryColor.b, 0.1)

                Text {
                    anchors.centerIn: parent
                    text: tile.isConfigured ? qsTr("Düzenle") : qsTr("Yapılandır")
                    font.pixelSize: 12
                    font.bold: true
                    color: tile.isConfigured ? "white" : themeManager.primaryColor
                }
            }
        }
    }
}
