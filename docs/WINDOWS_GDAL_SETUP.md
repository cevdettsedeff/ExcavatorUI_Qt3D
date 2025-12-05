# Windows için GDAL Kurulum Kılavuzu

Bu kılavuz, ExcavatorUI_Qt3D projesi için Windows'ta GDAL kurulumunu açıklar.

## Yöntem 1: OSGeo4W (Önerilen - En Kolay) ⭐

### Adım 1: OSGeo4W İndir

1. https://trac.osgeo.org/osgeo4w/ adresine gidin
2. **OSGeo4W Network Installer (64bit)** indirin
3. `osgeo4w-setup.exe` dosyasını çalıştırın

### Adım 2: GDAL Paketlerini Seçin

1. **Advanced Install** seçin → Next
2. **Install from Internet** → Next
3. Root directory: `C:\OSGeo4W64` (default) → Next
4. Local Package Directory seçin → Next
5. İnternet bağlantısı seçin → Next
6. Mirror seçin → Next

**Önemli:** Select Packages ekranında:
- **Libs** kategorisini genişletin
- `gdal` paketini bulun ve **Skip** yazan yere tıklayarak en son sürümü seçin
- `gdal-devel` paketini de seçin (development headers için)
- `gdal-python` opsiyonel (Python script'leri kullanacaksanız)

7. Next → Accept licenses → Install

### Adım 3: Environment Variables Ayarlayın

**Otomatik (PowerShell - Yönetici olarak çalıştırın):**
```powershell
[System.Environment]::SetEnvironmentVariable("GDAL_ROOT", "C:\OSGeo4W64", [System.EnvironmentVariableTarget]::Machine)
$path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("Path", $path + ";C:\OSGeo4W64\bin", [System.EnvironmentVariableTarget]::Machine)
```

**Manuel:**
1. **Windows Arama** → "Environment Variables" / "Ortam Değişkenleri"
2. **System Properties** → **Environment Variables**
3. **System variables** bölümünde **New**:
   - Variable name: `GDAL_ROOT`
   - Variable value: `C:\OSGeo4W64`
4. **Path** değişkenini düzenleyin ve ekleyin:
   - `C:\OSGeo4W64\bin`

### Adım 4: Doğrulama

PowerShell veya CMD'de:
```cmd
gdalinfo --version
```

**Beklenen çıktı:**
```
GDAL 3.8.x, released 2024/xx/xx
```

### Adım 5: Qt Creator'ı Yeniden Başlatın

Environment variable'lar yüklenmesi için Qt Creator'ı kapatıp açın.

---

## Yöntem 2: Conda/Miniconda (Hızlı)

### Adım 1: Miniconda İndirin

1. https://docs.conda.io/en/latest/miniconda.html
2. Windows 64-bit installer'ı indirin ve kurun

### Adım 2: GDAL Kurun

```bash
# Conda Prompt açın (başlangıç menüsünden)
conda install -c conda-forge gdal

# Verify
gdalinfo --version
```

### Adım 3: CMake için Conda Path'i Ayarlayın

Qt Creator → Projects → Build Settings → CMake:

**CMake Options:**
```
-DGDAL_ROOT=%CONDA_PREFIX%
```

Ya da environment variable:
```cmd
setx GDAL_ROOT "%CONDA_PREFIX%"
```

---

## Yöntem 3: vcpkg (Gelişmiş)

### Adım 1: vcpkg Kurun

```powershell
cd C:\
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
.\bootstrap-vcpkg.bat
.\vcpkg integrate install
```

### Adım 2: GDAL Kurun

```cmd
vcpkg install gdal:x64-windows
```

**Not:** Bu işlem uzun sürebilir (1-2 saat) çünkü tüm dependencies'leri source'tan build eder.

### Adım 3: CMake Toolchain Ayarlayın

Qt Creator → Projects → Build Settings → CMake:

**CMake Options:**
```
-DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake
```

---

## CMake Yapılandırması

### Otomatik Detection (Önerilen)

CMakeLists.txt artık otomatik olarak şu yolları kontrol eder:
- `C:/OSGeo4W64`
- `C:/OSGeo4W`
- `%GDAL_ROOT%`
- `%CONDA_PREFIX%`
- `%VCPKG_ROOT%/installed/x64-windows`

Standart OSGeo4W kurulumu yaparsanız, ek yapılandırma **gerekmez**.

### Manuel CMake Ayarı (Gerekirse)

Qt Creator → Projects → Build Settings → CMake:

**CMake arguments:**
```
-DGDAL_ROOT=C:/OSGeo4W64
```

---

## Sorun Giderme

### Problem: "Could NOT find GDAL"

**Çözüm 1:** GDAL_ROOT environment variable'ı ayarlayın:
```powershell
[System.Environment]::SetEnvironmentVariable("GDAL_ROOT", "C:\OSGeo4W64", [System.EnvironmentVariableTarget]::User)
```

**Çözüm 2:** CMake'e manuel olarak belirtin:
```
cmake -DGDAL_ROOT=C:/OSGeo4W64 ..
```

**Çözüm 3:** Qt Creator'ı yönetici olarak çalıştırın

### Problem: "gdal_i.lib not found"

OSGeo4W'de `gdal-devel` paketinin kurulu olduğundan emin olun:
```cmd
C:\OSGeo4W64\bin\osgeo4w-setup.exe
```
Advanced Install → Libs → gdal-devel seçin

### Problem: Runtime'da "gdal308.dll not found"

`C:\OSGeo4W64\bin` klasörü Path'e ekli mi kontrol edin:
```cmd
echo %PATH%
```

Yoksa ekleyin ve bilgisayarı yeniden başlatın.

### Problem: MinGW ile uyumsuzluk

OSGeo4W MSVC ile derlenmiş olabilir. MinGW kullanıyorsanız:

**Seçenek A:** MSVC derleyicisine geçin (önerilen)
- Qt Creator → Kits → MSVC 2019/2022 seçin

**Seçenek B:** Conda GDAL kullanın (MinGW uyumlu)
```bash
conda install -c conda-forge gdal
```

---

## Doğrulama Checklist

Kurulum tamamlandıktan sonra:

- [ ] `gdalinfo --version` çalışıyor
- [ ] `GDAL_ROOT` environment variable ayarlı
- [ ] `C:\OSGeo4W64\bin` Path'de var
- [ ] Qt Creator yeniden başlatıldı
- [ ] CMake configuration başarılı
- [ ] Build başarılı

## CMake Çıktısı (Başarılı)

Başarılı bir GDAL detection şöyle görünmeli:
```
-- Found potential GDAL installation at: C:/OSGeo4W64
-- ✓ GDAL found: 3.8.4
--   Include: C:/OSGeo4W64/include
--   Libraries: C:/OSGeo4W64/lib/gdal_i.lib
```

## Build Komutu (PowerShell)

```powershell
cd C:\Users\cevde\Desktop\Excavator\ExcavatorUI_Qt3D
mkdir build -Force
cd build
cmake .. -G "MinGW Makefiles" -DGDAL_ROOT=C:/OSGeo4W64
cmake --build .
```

## Visual Studio ile Build (Alternatif)

```cmd
cd C:\Users\cevde\Desktop\Excavator\ExcavatorUI_Qt3D
mkdir build
cd build
cmake .. -G "Visual Studio 17 2022" -DGDAL_ROOT=C:/OSGeo4W64
cmake --build . --config Release
```

## Ek Kaynaklar

- OSGeo4W: https://trac.osgeo.org/osgeo4w/
- GDAL Documentation: https://gdal.org/
- Qt GDAL Integration: https://doc.qt.io/qt-6/cmake-manual.html
- vcpkg GDAL: https://github.com/microsoft/vcpkg/tree/master/ports/gdal

## İletişim

Sorun yaşarsanız:
- GitHub Issues: https://github.com/cevdettsedeff/ExcavatorUI_Qt3D/issues
- GDAL Mailing List: https://lists.osgeo.org/mailman/listinfo/gdal-dev
