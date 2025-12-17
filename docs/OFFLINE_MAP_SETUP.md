# Offline Map Setup - Türkiye Haritası İndirme Kılavuzu

Bu kılavuz, CartoDB Positron harita tile'larını önceden indirip projeye statik olarak eklemenizi sağlar. Bu sayede uygulama her çalıştığında tile'ları tekrar indirmek zorunda kalmaz.

## 📋 İçindekiler
- [Yöntem 1: Uygulama İçinden İndirme (Önerilen)](#yöntem-1-uygulama-içinden-indirme-önerilen)
- [Yöntem 2: Python Script ile İndirme](#yöntem-2-python-script-ile-indirme)
- [Yöntem 3: QGIS ile İndirme](#yöntem-3-qgis-ile-indirme)

---

## Yöntem 1: Uygulama İçinden İndirme (Önerilen)

En kolay yöntem, uygulamanın kendi indirme özelliğini kullanmaktır.

### Adımlar:

1. **Uygulamayı çalıştırın** ve "Harita" sekmesine gidin

2. **Online** veya **Offline** sekmesini açın

3. **"OFFLINE HARITA"** panelini açın (sağ üstte turuncu panel)

4. Ayarları yapın:
   - **Harita:** `CartoDB Positron` seçin
   - **Alan:** `Türkiye Tümü` seçin
   - **Zoom:** İhtiyacınıza göre seçin (örn: `13-16 Normal`)

5. **"Bölgeyi İndir"** butonuna tıklayın

6. İndirme tamamlandığında, cache dizininden static dizine kopyalayın:

### Linux/Mac:
```bash
# Cache'den static dizine kopyala
cp -r ~/.cache/ExcavatorUI/cartodb_tiles ./static_maps/

# Veya symbolic link oluştur (daha hızlı)
ln -s ~/.cache/ExcavatorUI/cartodb_tiles ./static_maps/cartodb_tiles
```

### Windows:
```cmd
REM Cache'den static dizine kopyala
xcopy /E /I "%LOCALAPPDATA%\ExcavatorUI\cartodb_tiles" "static_maps\cartodb_tiles"

REM Veya junction oluştur (daha hızlı)
mklink /J "static_maps\cartodb_tiles" "%LOCALAPPDATA%\ExcavatorUI\cartodb_tiles"
```

---

## Yöntem 2: Python Script ile İndirme

Python scripti ile tile'ları doğrudan static dizine indirebilirsiniz.

### Gereksinimler:
```bash
pip install requests pillow
```

### Script Kullanımı:

```bash
cd /path/to/ExcavatorUI_Qt3D
python scripts/download_tiles.py --provider cartodb --region turkey --zoom-min 13 --zoom-max 16
```

### Script Seçenekleri:

```bash
# Tüm seçenekler
python scripts/download_tiles.py \
    --provider cartodb \         # veya osm
    --region turkey \             # önceden tanımlı bölge
    --zoom-min 13 \               # minimum zoom seviyesi
    --zoom-max 16 \               # maksimum zoom seviyesi
    --output static_maps/cartodb_tiles \  # çıktı dizini
    --workers 4                   # paralel indirme sayısı (varsayılan: 2)

# Özel koordinatlar ile:
python scripts/download_tiles.py \
    --provider cartodb \
    --lat-min 36.0 --lat-max 42.1 \
    --lon-min 26.0 --lon-max 45.0 \
    --zoom-min 13 --zoom-max 16
```

---

## Yöntem 3: QGIS ile İndirme

QGIS kullanarak tile'ları indirebilir ve mevcut tile formatına dönüştürebilirsiniz.

### Adımlar:

1. **QGIS'i açın** (3.x veya üzeri)

2. **XYZ Tiles bağlantısı ekleyin:**
   - `Browser Panel` → sağ tık `XYZ Tiles` → `New Connection`
   - **Name:** `CartoDB Positron`
   - **URL:** `https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png`
   - Min/Max Zoom: `0` / `20`

3. **QTiles eklentisini yükleyin:**
   - `Plugins` → `Manage and Install Plugins`
   - `QTiles` arayın ve yükleyin

4. **Tile'ları indirin:**
   - CartoDB Positron layer'ını ekleyin
   - `Web` → `QTiles` → `QTiles`
   - **Extent:** Türkiye sınırlarını çizin veya koordinatları girin:
     - Min Lat: `36.0`, Max Lat: `42.1`
     - Min Lon: `26.0`, Max Lon: `45.0`
   - **Zoom levels:** `13-16` (veya istediğiniz aralık)
   - **Output format:** `Directory of PNG tiles`
   - **Output directory:** `static_maps/cartodb_tiles`
   - `Run` tıklayın

5. Tile'lar otomatik olarak `{z}/{x}/{y}.png` formatında kaydedilecektir.

---

## 📊 Tahmini İndirme Boyutları

### Türkiye Tümü (36°-42°N, 26°-45°E):

| Zoom Seviyesi | Tile Sayısı | Tahmini Boyut | Kullanım Senaryosu |
|---------------|-------------|---------------|---------------------|
| 13-15         | ~3,500      | ~105 MB       | Genel görünüm, planlama |
| 13-16         | ~14,000     | ~420 MB       | Normal kullanım (Önerilen) |
| 13-17         | ~56,000     | ~1.7 GB       | Detaylı görünüm |
| 13-18         | ~224,000    | ~6.7 GB       | Maksimum detay |

**Not:** CartoDB tile'ları genellikle OSM'den daha küçüktür (~25-35 KB/tile yerine ~30 KB/tile).

---

## 🗂️ Dizin Yapısı

İndirme tamamlandığında dizin yapınız şöyle olmalı:

```
ExcavatorUI_Qt3D/
├── static_maps/
│   └── cartodb_tiles/
│       ├── 13/
│       │   ├── 4768/
│       │   │   ├── 2987.png
│       │   │   ├── 2988.png
│       │   │   └── ...
│       │   └── 4769/
│       ├── 14/
│       ├── 15/
│       └── 16/
```

---

## ✅ Doğrulama

İndirmenin başarılı olduğunu doğrulamak için:

```bash
# Tile sayısını kontrol et
find static_maps/cartodb_tiles -name "*.png" | wc -l

# Toplam boyutu kontrol et (Linux/Mac)
du -sh static_maps/cartodb_tiles

# Toplam boyutu kontrol et (Windows)
dir /s static_maps\cartodb_tiles
```

---

## 🚀 Kullanım

Tile'lar indirildikten sonra:

1. **Uygulamayı çalıştırın**
2. **Harita** → **Offline** sekmesine gidin
3. **Harita provider'ı** `CartoDB Positron` olarak seçin
4. Harita otomatik olarak `static_maps/cartodb_tiles/` dizinindeki tile'ları kullanacaktır
5. İnternet bağlantısına gerek yoktur! 🎉

---

## 🔄 Güncelleme

Harita tile'larını güncellemek için:

1. Eski tile'ları silin:
   ```bash
   rm -rf static_maps/cartodb_tiles
   ```

2. Yukarıdaki yöntemlerden birini kullanarak yeniden indirin

---

## 📝 Notlar

- **Git:** `static_maps/cartodb_tiles/` dizini `.gitignore`'a eklenmiştir, repo'ya pushlanmaz
- **Cache:** Uygulama önce static tile'lara bakar, yoksa cache'e bakar, o da yoksa indirir
- **Performans:** Static tile'lar cache'den ~2-3x daha hızlı yüklenir
- **Disk Alanı:** SSD kullanmanız önerilir (HDD'de tile yükleme yavaş olabilir)

---

## 🆘 Sorun Giderme

### "Static tile'lar yüklenmiyor"

1. Dizin yapısını kontrol edin:
   ```bash
   ls -la static_maps/cartodb_tiles/13/4768/
   ```

2. Tile dosyalarının PNG formatında olduğundan emin olun

3. Dosya izinlerini kontrol edin:
   ```bash
   chmod -R 755 static_maps/cartodb_tiles
   ```

### "İndirme çok yavaş"

1. `--workers` parametresini artırın (max 4-6)
2. Daha dar bir bölge seçin
3. Zoom seviyesini azaltın

### "Disk alanı yetersiz"

1. Daha düşük zoom seviyesi seçin (örn: 13-15)
2. Sadece ihtiyacınız olan bölgeyi indirin
3. Geçici cache'i temizleyin:
   ```bash
   rm -rf ~/.cache/ExcavatorUI/cartodb_tiles
   ```

---

## 📚 Ek Kaynaklar

- **CartoDB Maps API:** https://carto.com/basemaps/
- **Tile Koordinat Sistemi:** https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
- **QGIS Dökümanı:** https://qgis.org/

---

**Son Güncelleme:** 2025-12-11
