
# ExcavatorUI Qt3D

3D ekskavatör görselleştirme uygulaması. Qt Quick 3D kullanılarak geliştirilmiştir.

## Özellikler

- **3D Ekskavatör Modeli**: Detaylı 3D ekskavatör görselleştirmesi
- **İnteraktif Kontroller**:
  - Manuel ve otomatik rotasyon
  - Zoom (yakınlaştırma/uzaklaştırma)
  - Ölçeklendirme
  - Açı ayarları
- **Harita Görünümü**: Yan panel ile harita entegrasyonu
- **Gerçekçi Ortam**: Deniz zemini ile gerçekçi sahne

## Gereksinimler

- Qt 6.4 veya üzeri
- CMake 3.21 veya üzeri
- C++17 desteği olan derleyici
- Qt Quick3D modülü

## Derleme

```bash
mkdir build
cd build
cmake ..
cmake --build .
```

## Çalıştırma

Derleme tamamlandıktan sonra:

```bash
./ExcavatorUI_Qt3DApp
```

## Proje Yapısı

```
ExcavatorUI_Qt3D/
├── src/                    # QML kaynak dosyaları
│   ├── Main.qml           # Ana uygulama penceresi
│   ├── ExcavatorView.qml  # 3D görünüm ve kontroller
│   ├── MapView.qml        # Harita görünümü
│   └── Excavator.qml      # 3D ekskavatör modeli
├── resources/             # Uygulama kaynakları
│   ├── meshes/           # 3D mesh dosyaları
│   └── textures/         # Doku dosyaları
│   └── icons/            # İkon dosyaları
├── main.cpp              # C++ giriş noktası
├── CMakeLists.txt        # CMake yapılandırması
└── README.md             # Bu dosya
```

## Kontroller

- **OTO**: Otomatik rotasyonu başlat/durdur
- **AÇI**: Ekskavatörü manuel olarak döndür
- **ZOOM**: Kamera mesafesini ayarla
- **ÖLÇEK**: Ekskavatör boyutunu değiştir
- **RESET**: Tüm ayarları varsayılana döndür
- **Fare**: Sürükle - rotasyon, Scroll - zoom

