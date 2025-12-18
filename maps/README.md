# Offline Harita Tile'ları

Bu klasör, offline harita görüntüleme için XYZ Tile formatında harita tile'larını içerir.

## Klasör Yapısı

Tile'lar aşağıdaki XYZ formatında organize edilmelidir:

```
maps/
├── {zoom}/
│   ├── {x}/
│   │   ├── {y}.png
│   │   ├── {y}.png
│   │   └── ...
│   └── ...
└── ...
```

## Örnek

Eğer zoom 12, x=2365, y=1527 için bir tile'ınız varsa:

```
maps/12/2365/1527.png
```

## Kullanım

1. Harita tile'larınızı yukarıdaki formatta bu klasöre yerleştirin
2. Uygulamayı çalıştırın
3. Harita sekmesine gidin - otomatik olarak "Offline" modu açılır
4. Tile'larınız görüntülenecektir

## Notlar

- Tile dosyaları `.gitignore` ile ignore edilir (çok büyük olabilirler)
- Sadece bu README dosyası git'e commit edilir
- Desteklenen zoom seviyeleri: 3-18
- Tile formatı: PNG (256x256 piksel)
- Koordinat sistemi: Web Mercator (EPSG:3857)

## Tile İndirme

Online harita görünümünden belirli bir bölgeyi indirebilirsiniz:
1. Online harita sekmesine gidin
2. Bölgeyi seçin
3. İndirme butonuna tıklayın
4. Tile'lar otomatik olarak cache'lenir ve offline görünümde kullanılabilir

veya

Harici araçlarla (MOBAC, QGIS, vb.) tile'ları indirebilir ve bu klasöre kopyalayabilirsiniz.
