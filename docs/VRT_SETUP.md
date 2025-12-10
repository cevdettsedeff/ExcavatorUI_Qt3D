# Batimetrik Harita VRT Kurulumu

Bu dokümantasyon, GEBCO batimetrik GeoTIFF dosyalarından VRT (Virtual Raster) oluşturma ve overview piramitleri ekleme işlemlerini açıklar.

## Gereksinimler

1. **GDAL/OGR** (version 3.0+)
   ```bash
   # Ubuntu/Debian
   sudo apt-get install gdal-bin libgdal-dev

   # macOS
   brew install gdal

   # Windows
   # OSGeo4W installer kullanın: https://trac.osgeo.org/osgeo4w/
   ```

2. **GEBCO Batimetrik Veriler**
   - 9 adet GeoTIFF dosyası (toplam ~9GB)
   - Dosya formatı: `gebco_2025_sub_ice_nXX.X_sXX.X_wXX.X_eXX.X.tif`

## Adım 1: GeoTIFF Dosyalarını İndirme

GEBCO verilerini şu şekilde indirin:

```bash
# Örnek dosya isimleri:
gebco_2025_sub_ice_n90.0_s0.0_w90.0_e180.0.tif
gebco_2025_sub_ice_n90.0_s0.0_w-90.0_e0.0.tif
gebco_2025_sub_ice_n90.0_s0.0_w-180.0_e-90.0.tif
gebco_2025_sub_ice_n0.0_s-90.0_w90.0_e180.0.tif
gebco_2025_sub_ice_n0.0_s-90.0_w-90.0_e0.0.tif
gebco_2025_sub_ice_n0.0_s-90.0_w-180.0_e-90.0.tif
gebco_2025_sub_ice_n90.0_s0.0_w0.0_e90.0.tif
gebco_2025_sub_ice_n0.0_s-90.0_w0.0_e90.0.tif
gebco_2025_sub_ice_n90.0_s0.0_w-270.0_e-180.0.tif
```

## Adım 2: VRT Dosyası Oluşturma

Tüm GeoTIFF dosyalarını tek bir sanal raster'da birleştirin:

```bash
# Dosyaları bir klasörde toplayın
mkdir -p ~/bathymetry/gebco_data
cd ~/bathymetry/gebco_data

# VRT oluşturun
gdalbuildvrt gebco_world_bathymetry.vrt *.tif

# VRT bilgilerini kontrol edin
gdalinfo gebco_world_bathymetry.vrt
```

VRT dosyası, tüm GeoTIFF'leri referans eder ancak onları fiziksel olarak birleştirmez. Bu sayede:
- Disk alanı tasarrufu sağlanır
- Hızlı erişim
- Koordinat bazlı dinamik yükleme

## Adım 3: Overview (Piramit) Ekleme

Her bir GeoTIFF dosyasına overview (piramit) seviyelerini ekleyin. Bu, farklı zoom seviyelerinde performanslı rendering sağlar:

```bash
# Her dosya için overview oluşturun
for file in *.tif; do
    echo "Processing $file..."
    gdaladdo -r average "$file" 2 4 8 16 32 64
done
```

**Parametreler:**
- `-r average`: Resample metodu (ortalama değer)
- `2 4 8 16 32 64`: Overview faktörleri (2x, 4x, 8x, 16x, 32x, 64x düşük çözünürlük)

**Alternatif resample metodları:**
- `nearest`: En yakın komşu (en hızlı, düşük kalite)
- `bilinear`: Bilinear interpolasyon (orta)
- `cubic`: Cubic interpolasyon (yüksek kalite, yavaş)
- `average`: Ortalama (önerilen batimetri için)

## Adım 4: Overview Bilgilerini Kontrol Etme

```bash
# Bir dosyanın overview bilgilerini görüntüleyin
gdalinfo gebco_2025_sub_ice_n90.0_s0.0_w90.0_e180.0.tif
```

Çıktıda şöyle bir bölüm göreceksiniz:
```
Band 1 Block=256x256 Type=Float32, ColorInterp=Gray
  Overviews: 21600x10800, 10800x5400, 5400x2700, 2700x1350, 1350x675, 675x337
```

## Adım 5: Uygulamada Kullanım

### 5.1 Config Dosyasını Güncelleme

`config/bathymetry_config.json` dosyasını düzenleyin:

```json
{
  "bathymetry": {
    "vrt_path": "/home/user/bathymetry/gebco_data/gebco_world_bathymetry.vrt",
    "tile_size": 256,
    "cache_size": 100,
    "default_lod": 0
  }
}
```

### 5.2 QML'de Kullanım

```qml
Component.onCompleted: {
    // VRT dosyasını yükle
    bathymetryLoader.vrtPath = "file:///home/user/bathymetry/gebco_data/gebco_world_bathymetry.vrt"

    if (bathymetryLoader.loadVRT()) {
        console.log("VRT loaded successfully")
        console.log("Geographic bounds:", bathymetryLoader.geoBounds)
        console.log("Overview count:", bathymetryLoader.overviewCount)

        // Belirli bir koordinattaki derinliği sorgula
        var depth = bathymetryLoader.getDepthAt(41.0082, 28.9784, 0)
        console.log("Depth at Istanbul:", depth, "meters")
    } else {
        console.error("Failed to load VRT")
    }
}
```

## Performans İpuçları

### 1. Tile Size Optimizasyonu
- `tile_size: 256`: Küçük, hızlı yükleme, fazla tile sayısı
- `tile_size: 512`: Orta (önerilen)
- `tile_size: 1024`: Büyük, yavaş yükleme, az tile sayısı

### 2. Cache Size
- Düşük RAM: `cache_size: 50`
- Orta RAM (8GB): `cache_size: 100` (önerilen)
- Yüksek RAM (16GB+): `cache_size: 200`

### 3. LOD Kullanımı
```javascript
// Kamera uzaklığına göre LOD seçimi
var cameraDistance = calculateDistance(camera.position)
var zoomLevel = cameraDistance / 1000.0
var lod = bathymetryLoader.getRecommendedLOD(zoomLevel)

// Uygun LOD ile veri yükle
var tile = bathymetryLoader.loadTile(tileX, tileY, lod)
```

## Dosya Boyutları

| Dosya Türü | Overview Öncesi | Overview Sonrası | Artış |
|------------|----------------|-----------------|-------|
| GeoTIFF    | ~1 GB          | ~1.15 GB        | ~15%  |
| VRT        | ~10 KB         | ~10 KB          | -     |

**Not:** Overview'lar her dosyaya ~15% boyut ekler, ancak rendering performansını 10-50x artırır.

## Sorun Giderme

### Problem: "VRT file does not exist"
**Çözüm:** Dosya yolunu mutlak path olarak belirtin:
```javascript
bathymetryLoader.vrtPath = "file:///absolute/path/to/gebco_world_bathymetry.vrt"
```

### Problem: "Failed to open VRT file"
**Çözüm:**
1. GeoTIFF dosyalarının VRT ile aynı klasörde olduğundan emin olun
2. VRT içindeki yolları kontrol edin: `cat gebco_world_bathymetry.vrt`
3. Dosya izinlerini kontrol edin: `chmod 644 *.tif *.vrt`

### Problem: Yavaş rendering
**Çözüm:**
1. Overview'ların oluşturulduğundan emin olun: `gdalinfo dosya.tif | grep Overviews`
2. LOD seviyesini artırın (uzak görünümlerde düşük detay)
3. Tile size'ı azaltın (256 veya 128)
4. Cache size'ı artırın

### Problem: Yüksek RAM kullanımı
**Çözüm:**
1. Cache size'ı azaltın: `"cache_size": 50`
2. Tile size'ı azaltın: `"tile_size": 128`
3. Sadece görünür tile'ları yükleyin (viewport culling)

## Örnek Python Script: Toplu Overview Oluşturma

```python
#!/usr/bin/env python3
import os
import subprocess
from pathlib import Path

def add_overviews(directory, factors=[2, 4, 8, 16, 32, 64], method='average'):
    """Add overviews to all GeoTIFF files in directory"""
    tif_files = Path(directory).glob('*.tif')

    for tif_file in tif_files:
        print(f"Processing {tif_file.name}...")
        cmd = ['gdaladdo', '-r', method, str(tif_file)] + [str(f) for f in factors]

        try:
            subprocess.run(cmd, check=True)
            print(f"  ✓ Overviews added successfully")
        except subprocess.CalledProcessError as e:
            print(f"  ✗ Error: {e}")

if __name__ == '__main__':
    import sys
    if len(sys.argv) < 2:
        print("Usage: python add_overviews.py <directory>")
        sys.exit(1)

    directory = sys.argv[1]
    add_overviews(directory)
    print("Done!")
```

Kullanım:
```bash
python add_overviews.py ~/bathymetry/gebco_data
```

## Referanslar

- [GDAL VRT Tutorial](https://gdal.org/drivers/raster/vrt.html)
- [GDAL Overview (Pyramids)](https://gdal.org/programs/gdaladdo.html)
- [GEBCO Bathymetric Data](https://www.gebco.net/)
