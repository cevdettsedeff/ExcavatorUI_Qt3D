# Batimetrik Harita Base Layer Özelliği

## Genel Bakış

Bu özellik, ExcavatorUI_Qt3D uygulamasına profesyonel GDAL VRT tabanlı batimetrik harita altlığı ekler. Kullanıcılar, GEBCO batimetrik verilerini kullanarak dünya genelindeki deniz tabanı topografyasını 3D olarak görüntüleyebilir.

## Özellikler

### ✅ Tamamlanan Özellikler

1. **GDAL VRT Desteği**
   - Birden fazla GeoTIFF dosyasını tek sanal raster olarak birleştirme
   - Otomatik koordinat dönüşümleri (Lat/Lon ↔ Pixel)
   - No-data value yönetimi

2. **LOD (Level of Detail) Sistemi**
   - Overview piramit seviyelerini kullanma
   - Zoom seviyesine göre otomatik LOD seçimi
   - 6 seviyeye kadar LOD desteği (2x, 4x, 8x, 16x, 32x, 64x)

3. **Tile-Based Veri Yükleme**
   - Lazy loading: Sadece görünür tile'ları yükle
   - Yapılandırılabilir tile boyutu (128, 256, 512, 1024)
   - LRU cache mekanizması (varsayılan: 100 tile)

4. **Qt3D Entegrasyonu**
   - Real-time 3D görselleştirme
   - Derinlik bazlı renklendirme
   - Mouse ile kamera kontrolü (orbit, zoom)

5. **Performans Optimizasyonları**
   - Multi-threaded veri okuma (hazır, şu an kullanılmıyor)
   - Memory-efficient tile caching
   - Overview kullanarak hızlı rendering

## Dosya Yapısı

```
ExcavatorUI_Qt3D/
├── src/
│   ├── bathymetry/
│   │   ├── BathymetricDataLoader.h      # Ana GDAL loader sınıfı
│   │   └── BathymetricDataLoader.cpp
│   └── views/
│       ├── BathymetricMapView.qml       # Eski mock data versiyonu
│       └── BathymetricMapView_V2.qml    # Yeni VRT-based versiyon
├── config/
│   └── bathymetry_config.json           # Yapılandırma dosyası
└── docs/
    ├── VRT_SETUP.md                     # VRT kurulum kılavuzu
    └── BATHYMETRY_FEATURE.md            # Bu dosya
```

## Kurulum

### 1. GDAL Kurulumu

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install gdal-bin libgdal-dev
```

**macOS:**
```bash
brew install gdal
```

**Windows:**
- OSGeo4W installer: https://trac.osgeo.org/osgeo4w/

### 2. GEBCO Verilerini İndirme

GEBCO 2025 sub-ice batimetrik verilerini indirin:
- Kaynak: https://www.gebco.net/
- 9 adet GeoTIFF dosyası (toplam ~9GB)
- Dosya adları: `gebco_2025_sub_ice_n{lat}_s{lat}_w{lon}_e{lon}.tif`

### 3. VRT Oluşturma

```bash
# Dosyaları bir klasörde toplayın
mkdir -p ~/bathymetry/gebco_data
cd ~/bathymetry/gebco_data

# GeoTIFF dosyalarını buraya kopyalayın

# VRT oluşturun
gdalbuildvrt gebco_world_bathymetry.vrt *.tif

# Her dosyaya overview ekleyin
for file in *.tif; do
    gdaladdo -r average "$file" 2 4 8 16 32 64
done
```

Detaylı kurulum için: [VRT_SETUP.md](VRT_SETUP.md)

### 4. Yapılandırma

`config/bathymetry_config.json` dosyasını düzenleyin:

```json
{
  "bathymetry": {
    "vrt_path": "/home/user/bathymetry/gebco_data/gebco_world_bathymetry.vrt",
    "tile_size": 256,
    "cache_size": 100
  }
}
```

### 5. Derleme

```bash
cd ExcavatorUI_Qt3D
mkdir build && cd build
cmake ..
make -j$(nproc)
```

GDAL bulunamazsa:
```bash
cmake .. -DGDAL_ROOT=/path/to/gdal
```

## Kullanım

### QML'de Kullanım

```qml
import QtQuick
import QtQuick3D
import ExcavatorUI_Qt3D

Rectangle {
    Component.onCompleted: {
        // VRT dosyasını yükle
        bathymetryLoader.vrtPath = "/path/to/gebco_world_bathymetry.vrt"

        if (bathymetryLoader.loadVRT()) {
            console.log("✓ VRT loaded")
            console.log("  Bounds:", bathymetryLoader.geoBounds)
            console.log("  Overviews:", bathymetryLoader.overviewCount)

            // Belirli koordinatta derinlik sorgula
            var depth = bathymetryLoader.getDepthAt(41.0082, 28.9784, 0)
            console.log("  Depth at Istanbul:", depth, "meters")

            // Tile yükle
            var tile = bathymetryLoader.loadTile(100, 50, 0)
            if (tile && tile.isValid) {
                console.log("  Tile loaded:", tile.width, "x", tile.height)
            }
        }
    }
}
```

### C++ API

```cpp
#include "src/bathymetry/BathymetricDataLoader.h"

BathymetricDataLoader loader;
loader.setVrtPath("/path/to/gebco_world_bathymetry.vrt");

if (loader.loadVRT()) {
    // Tek nokta sorgusu
    float depth = loader.getDepthAt(41.0082, 28.9784, 0);
    qDebug() << "Depth:" << depth << "meters";

    // Tile yükleme
    BathymetricTile* tile = loader.loadTile(100, 50, 0);
    if (tile && tile->isValid) {
        qDebug() << "Tile depths:" << tile->depths.size();
    }

    // Bölge sorgusu
    QRectF bounds(28.0, 40.0, 2.0, 2.0);  // (lon, lat, width, height)
    QVector<float> depths = loader.getDepthRegion(bounds, 512, 512, 0);
}
```

## API Referansı

### BathymetricDataLoader

#### Properties
- `QString vrtPath`: VRT dosya yolu
- `bool isLoaded`: VRT yüklenmiş mi?
- `QRectF geoBounds`: Coğrafi sınırlar (lon_min, lat_min, width, height)
- `int tileSize`: Tile boyutu (piksel)
- `int overviewCount`: Overview seviye sayısı

#### Methods

**`bool loadVRT()`**
- VRT dosyasını yükler
- Return: Başarılı ise `true`

**`float getDepthAt(double lat, double lon, int lodLevel = 0)`**
- Belirli koordinatta derinlik değerini döner
- Parameters:
  - `lat`: Latitude (enlem)
  - `lon`: Longitude (boylam)
  - `lodLevel`: LOD seviyesi (0 = en yüksek çözünürlük)
- Return: Derinlik (metre, negatif = deniz altı)

**`BathymetricTile* loadTile(int tileX, int tileY, int lodLevel = 0)`**
- Belirli bir tile'ı yükler
- Parameters:
  - `tileX, tileY`: Tile indeksleri
  - `lodLevel`: LOD seviyesi
- Return: Tile pointer (cache'den veya yeni yüklenen)

**`QVector<float> getDepthRegion(const QRectF &bounds, int width, int height, int lodLevel = 0)`**
- Dikdörtgen bölge için derinlik verisi döner
- Parameters:
  - `bounds`: Coğrafi sınırlar
  - `width, height`: Çıktı boyutu (piksel)
  - `lodLevel`: LOD seviyesi
- Return: Derinlik değerleri vektörü (row-major)

**`QPointF geoToPixel(double lat, double lon, int lodLevel = 0)`**
- Coğrafi koordinatları piksel koordinatlarına çevirir

**`QPointF pixelToGeo(int x, int y, int lodLevel = 0)`**
- Piksel koordinatlarını coğrafi koordinatlara çevirir

**`int getRecommendedLOD(double zoomLevel)`**
- Zoom seviyesine göre önerilen LOD döner

**`void clearCache()`**
- Tile cache'ini temizler

**`QString getCacheStats()`**
- Cache istatistiklerini döner

#### Signals

- `vrtPathChanged()`: VRT yolu değiştiğinde
- `isLoadedChanged()`: Yükleme durumu değiştiğinde
- `loadingProgress(int percent)`: Yükleme ilerlemesi (0-100)
- `errorOccurred(const QString &error)`: Hata oluştuğunda
- `tileLoaded(int tileX, int tileY, int lodLevel)`: Tile yüklendiğinde

## Performans İpuçları

### Memory Kullanımı

| Tile Size | Tile Count (4x4 grid) | Memory per LOD |
|-----------|----------------------|----------------|
| 128x128   | 16                   | ~1 MB          |
| 256x256   | 16                   | ~4 MB          |
| 512x512   | 16                   | ~16 MB         |
| 1024x1024 | 16                   | ~64 MB         |

### Önerilen Ayarlar

**Düşük RAM (<4GB):**
```json
{
  "tile_size": 128,
  "cache_size": 50
}
```

**Orta RAM (4-8GB):**
```json
{
  "tile_size": 256,
  "cache_size": 100
}
```

**Yüksek RAM (>8GB):**
```json
{
  "tile_size": 512,
  "cache_size": 200
}
```

### LOD Kullanımı

```javascript
// Kamera uzaklığına göre LOD seçimi
function updateLOD() {
    var distance = calculateCameraDistance()
    var zoomLevel = distance / 200.0
    var recommendedLOD = bathymetryLoader.getRecommendedLOD(zoomLevel)

    if (recommendedLOD !== currentLOD) {
        currentLOD = recommendedLOD
        reloadVisibleTiles()
    }
}
```

## Bilinen Kısıtlamalar

1. **Gerçek Zamanlı Heightmap Rendering**
   - Şu anda basit küp mesh kullanılıyor
   - TODO: Custom geometry veya heightmap texture implementasyonu

2. **Viewport Frustum Culling**
   - Tüm tile'lar yükleniyor (görünmeyenler dahil)
   - TODO: Sadece görünür tile'ları yükleme

3. **Streaming**
   - Tile'lar senkron yükleniyor
   - TODO: Background thread'de asenkron yükleme

4. **Detaylı Mesh**
   - Her tile için tek bir ortalama derinlik kullanılıyor
   - TODO: Her tile için detaylı vertex grid oluşturma

## Gelecek Geliştirmeler

### Öncelikli (High Priority)
- [ ] Gerçek heightmap mesh rendering
- [ ] Viewport frustum culling
- [ ] Asenkron tile yükleme
- [ ] Config dosyasından ayarları okuma

### Orta Öncelik (Medium Priority)
- [ ] Tile cache LRU algoritması iyileştirmesi
- [ ] Progressive tile loading (düşük LOD → yüksek LOD)
- [ ] Tile prefetching (kamera yönüne göre)
- [ ] Derinlik contour çizgileri

### Düşük Öncelik (Low Priority)
- [ ] Multi-threaded tile loading
- [ ] GPU-accelerated rendering
- [ ] Tile compression
- [ ] Web-based tile streaming

## Sorun Giderme

### Problem: "GDAL not found" CMake hatası
**Çözüm:**
```bash
# GDAL'ın kurulu olduğunu kontrol edin
gdal-config --version

# CMake'e GDAL yolunu belirtin
cmake .. -DGDAL_ROOT=/usr/local
```

### Problem: "Failed to open VRT file"
**Çözüm:**
1. VRT dosya yolunun doğru olduğundan emin olun
2. GeoTIFF dosyalarının VRT ile aynı klasörde olduğunu kontrol edin
3. Dosya izinlerini kontrol edin: `chmod 644 *.tif *.vrt`

### Problem: Yavaş rendering
**Çözüm:**
1. Overview'ların oluşturulduğundan emin olun
2. LOD seviyesini artırın
3. Tile size'ı azaltın (256 veya 128)
4. Cache size'ı artırın

### Problem: Yüksek RAM kullanımı
**Çözüm:**
1. Cache size'ı azaltın
2. Tile size'ı azaltın
3. Daha yüksek LOD kullanın

## Testler

### Manuel Test

```bash
# Test verileri için küçük bir VRT oluşturun
cd test_data
gdalbuildvrt test_bathymetry.vrt sample_*.tif

# Uygulamayı çalıştırın
./ExcavatorUI_Qt3DApp

# Harita sekmesine gidin ve VRT'nin yüklendiğini kontrol edin
```

### Birim Testleri (TODO)

```cpp
// test_bathymetric_loader.cpp
void TestBathymetricLoader::testLoadVRT() {
    BathymetricDataLoader loader;
    loader.setVrtPath("test_data/test_bathymetry.vrt");
    QVERIFY(loader.loadVRT());
    QVERIFY(loader.isLoaded());
}

void TestBathymetricLoader::testGetDepthAt() {
    BathymetricDataLoader loader;
    loader.setVrtPath("test_data/test_bathymetry.vrt");
    loader.loadVRT();

    float depth = loader.getDepthAt(41.0, 29.0, 0);
    QVERIFY(depth > -10000 && depth < 10000);
}
```

## Katkıda Bulunma

1. Feature branch oluşturun: `git checkout -b feature/bathymetry-improvements`
2. Değişikliklerinizi commit edin
3. Branch'i push edin: `git push origin feature/bathymetry-improvements`
4. Pull request oluşturun

## Lisans

Bu proje ExcavatorUI_Qt3D projesinin lisansı altındadır.

## İletişim

- GitHub Issues: https://github.com/cevdettsedeff/ExcavatorUI_Qt3D/issues
- Email: [proje-email]

## Referanslar

- [GDAL Documentation](https://gdal.org/)
- [GEBCO Bathymetric Data](https://www.gebco.net/)
- [Qt3D Documentation](https://doc.qt.io/qt-6/qt3d-index.html)
- [VRT Format Specification](https://gdal.org/drivers/raster/vrt.html)
