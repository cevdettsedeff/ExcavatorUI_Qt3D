# 10.1 inç Responsive Design Guide

## Global Responsive Değişkenler (AppRoot'tan)

Tüm sayfalarda kullanılabilir. `ApplicationWindow.window` ile erişilebilir.

### Font Boyutları
```qml
property var app: ApplicationWindow.window

Text {
    font.pixelSize: app.baseFontSize      // 14px scaled (normal metin)
    font.pixelSize: app.smallFontSize     // 11px scaled (küçük metin)
    font.pixelSize: app.mediumFontSize    // 16px scaled (orta metin)
    font.pixelSize: app.largeFontSize     // 20px scaled (başlıklar)
    font.pixelSize: app.xlFontSize        // 24px scaled (büyük başlıklar)
}
```

### Buton Boyutları
```qml
Button {
    Layout.preferredHeight: app.buttonHeight       // 45px scaled
    Layout.preferredHeight: app.smallButtonHeight  // 35px scaled
    Layout.preferredHeight: app.largeButtonHeight  // 55px scaled
}
```

### İkon Boyutları
```qml
Image {
    width: app.iconSize       // 28px scaled
    width: app.smallIconSize  // 20px scaled
    width: app.largeIconSize  // 36px scaled
}
```

### Spacing/Padding
```qml
ColumnLayout {
    spacing: app.normalSpacing    // 12px scaled
    spacing: app.smallSpacing     // 6px scaled
    spacing: app.largeSpacing     // 20px scaled
    spacing: app.xlSpacing        // 30px scaled
}

Rectangle {
    anchors.margins: app.normalPadding  // 15px scaled
    anchors.margins: app.smallPadding   // 8px scaled
    anchors.margins: app.largePadding   // 25px scaled
}
```

### Border Radius
```qml
Rectangle {
    radius: app.normalRadius  // 8px scaled
    radius: app.smallRadius   // 4px scaled
    radius: app.largeRadius   // 12px scaled
}
```

## Kullanım Örneği

```qml
Rectangle {
    id: examplePage
    
    // AppRoot'a erişim için shortcut
    property var app: ApplicationWindow.window
    
    ColumnLayout {
        anchors.fill: parent
        spacing: app.normalSpacing
        anchors.margins: app.normalPadding
        
        Text {
            text: "Başlık"
            font.pixelSize: app.largeFontSize
            font.bold: true
        }
        
        Button {
            Layout.preferredHeight: app.buttonHeight
            text: "Tıkla"
            font.pixelSize: app.baseFontSize
        }
    }
}
```

## ÖNEMLİ: Sabit Pixel Kullanma!

❌ YANLIŞ:
```qml
font.pixelSize: 14
spacing: 12
width: 100
```

✅ DOĞRU:
```qml
font.pixelSize: app.baseFontSize
spacing: app.normalSpacing
width: app.iconSize * 3.5
```
