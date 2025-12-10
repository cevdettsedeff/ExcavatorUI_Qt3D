# Static Maps Setup Guide

Bu klasör batimetrik harita verilerini (GeoTIFF ve VRT dosyaları) içerir. Bu dosyalar boyutları nedeniyle Git'e eklenmemiştir.

## Klasör Yapısı

```
static_maps/
├── gebco_2025_sub_ice_n90.0_s0.0_w90.0_e180.0.tif
├── gebco_2025_sub_ice_n90.0_s0.0_w-90.0_e0.0.tif
├── gebco_2025_sub_ice_n90.0_s0.0_w-180.0_e-90.0.tif
├── gebco_2025_sub_ice_n0.0_s-90.0_w90.0_e180.0.tif
├── gebco_2025_sub_ice_n0.0_s-90.0_w-90.0_e0.0.tif
├── gebco_2025_sub_ice_n0.0_s-90.0_w-180.0_e-90.0.tif
├── gebco_2025_sub_ice_n90.0_s0.0_w0.0_e90.0.tif
├── gebco_2025_sub_ice_n0.0_s-90.0_w0.0_e90.0.tif
├── gebco_2025_sub_ice_n90.0_s0.0_w-270.0_e-180.0.tif
└── gebco_world_bathymetry.vrt (oluşturulacak)
```

## Kurulum Adımları

### 1. Klasörü Oluşturun

```bash
cd /home/user/ExcavatorUI_Qt3D
mkdir -p static_maps
cd static_maps
```

### 2. GEBCO GeoTIFF Dosyalarını İndirin ve Kopyalayın

GEBCO 2025 sub-ice batimetrik verilerini indirip bu klasöre kopyalayın:

```bash
# Dosyalarınızı buraya kopyalayın
cp ~/Downloads/gebco_2025_sub_ice_*.tif .
```

### 3. VRT Dosyası Oluşturun

Tüm GeoTIFF dosyalarını tek bir sanal raster'da birleştirin:

```bash
# VRT oluştur
gdalbuildvrt gebco_world_bathymetry.vrt *.tif

# VRT bilgilerini kontrol edin
gdalinfo gebco_world_bathymetry.vrt
```

**Beklenen çıktı:**
```
Driver: VRT/Virtual Raster
Files: gebco_world_bathymetry.vrt
       gebco_2025_sub_ice_n90.0_s0.0_w90.0_e180.0.tif
       [... diğer dosyalar ...]
Size is XXXXX, YYYYY
Coordinate System is:
GEOGCS["WGS 84", ...]
```

### 4. Overview (Piramit) Oluşturun

Her GeoTIFF dosyasına overview ekleyin (performans için kritik):

```bash
# Tek komutla tüm dosyalara overview ekle
for file in *.tif; do
    echo "Processing $file..."
    gdaladdo -r average "$file" 2 4 8 16 32 64
done
```

**Not:** Bu işlem uzun sürebilir (~10-30 dakika, dosya boyutuna bağlı)

**Opsiyonel - Hızlı test için:**
```bash
# Sadece ilk dosyaya ekleyin (test için)
gdaladdo -r average gebco_2025_sub_ice_n90.0_s0.0_w90.0_e180.0.tif 2 4 8 16 32 64
```

### 5. Dosyaları Doğrulayın

```bash
# VRT'nin çalıştığını test edin
gdalinfo gebco_world_bathymetry.vrt | grep "Size"

# Overview'ların eklendiğini kontrol edin
gdalinfo gebco_2025_sub_ice_n90.0_s0.0_w90.0_e180.0.tif | grep -A 5 "Overviews"
```

**Beklenen overview çıktısı:**
```
Band 1 Block=256x256 Type=Float32, ColorInterp=Gray
  Overviews: 21600x10800, 10800x5400, 5400x2700, 2700x1350, 1350x675, 675x337
```

## Dosya Boyutları

| Dosya | Boyut (yaklaşık) |
|-------|------------------|
| Her GeoTIFF | ~1 GB |
| Overview eklentisi | +15% (~150 MB per file) |
| VRT | ~10 KB |
| **Toplam** | **~10-11 GB** |

## Git Durumu

Bu klasör ve içindeki dosyalar `.gitignore` ile hariç tutulmuştur:

```gitignore
# .gitignore
static_maps/
*.tif
*.tiff
*.vrt
*.ovr
*.aux.xml
```

Bu dosyalar **asla Git'e eklenmeyecektir**.

## Yapılandırma

Uygulama `config/bathymetry_config.json` dosyasından VRT yolunu okur:

```json
{
  "bathymetry": {
    "vrt_path": "static_maps/gebco_world_bathymetry.vrt",
    ...
  }
}
```

**Not:** Yol görelidir (project root'a göre).

## Sorun Giderme

### Problem: "VRT file does not exist"

**Çözüm:**
```bash
# VRT'nin var olduğunu kontrol edin
ls -lh static_maps/gebco_world_bathymetry.vrt

# Yoksa tekrar oluşturun
cd static_maps
gdalbuildvrt gebco_world_bathymetry.vrt *.tif
```

### Problem: "Failed to open VRT file"

**Çözüm:**
```bash
# GeoTIFF dosyalarının var olduğunu kontrol edin
ls -lh static_maps/*.tif

# İzinleri kontrol edin
chmod 644 static_maps/*
```

### Problem: Yavaş rendering

**Çözüm:**
```bash
# Overview'ların mevcut olup olmadığını kontrol edin
gdalinfo static_maps/gebco_2025_sub_ice_n90.0_s0.0_w90.0_e180.0.tif | grep Overviews

# Yoksa ekleyin
cd static_maps
gdaladdo -r average *.tif 2 4 8 16 32 64
```

## Alternatif Veri Kaynakları

GEBCO dışında kullanabileceğiniz diğer batimetri kaynakları:

1. **GEBCO:** https://www.gebco.net/
   - Global coverage
   - 15 arc-second resolution
   - Free download

2. **NOAA NCEI:** https://www.ngdc.noaa.gov/mgg/bathymetry/
   - Regional high-resolution data
   - Various resolutions

3. **EMODnet:** https://www.emodnet-bathymetry.eu/
   - European waters
   - High resolution

## Test Verisi (Küçük Bölge)

Test için tüm dünyayı indirmek istemiyorsanız, küçük bir bölge kullanın:

```bash
# Türkiye çevresini kes (örnek)
gdal_translate -projwin 25 43 45 35 \
  gebco_world_bathymetry.vrt \
  turkey_bathymetry.tif

# Overview ekle
gdaladdo -r average turkey_bathymetry.tif 2 4 8 16

# Config'de kullan
# "vrt_path": "static_maps/turkey_bathymetry.tif"
```

## Yedekleme

Bu dosyalar büyük olduğu için:

1. **Harici disk** kullanın
2. **Network storage** (NAS) kullanın
3. **Cloud storage** (Google Drive, Dropbox) kullanın
   - Ancak sync kapatın (çok yavaş olur)

## Performans İpuçları

1. **SSD kullanın:** HDD çok yavaş olacaktır
2. **Overview oluşturun:** Mutlaka gerekli
3. **Tile size ayarlayın:** 256 (default) genellikle iyidir
4. **Cache size:** RAM'inize göre ayarlayın

## İletişim

Sorun yaşarsanız:
- GitHub Issues: https://github.com/cevdettsedeff/ExcavatorUI_Qt3D/issues
- Docs: `docs/VRT_SETUP.md`
