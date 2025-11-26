#include "GeoTIFFLoader.h"
#include <QFile>
#include <QDebug>
#include <QImage>
#include <cmath>

// GDAL başlıkları - eğer sistemde varsa
#ifdef HAS_GDAL
#include <gdal/gdal_priv.h>
#include <gdal/cpl_conv.h>
#endif

GeoTIFFLoader::GeoTIFFLoader(QObject *parent)
    : QObject(parent)
    , m_isLoaded(false)
    , m_width(0)
    , m_height(0)
    , m_minDepth(0.0)
    , m_maxDepth(0.0)
{
#ifdef HAS_GDAL
    // GDAL'ı başlat
    GDALAllRegister();
    qDebug() << "GeoTIFFLoader: GDAL initialized successfully";
#else
    qDebug() << "GeoTIFFLoader: GDAL not available, using fallback mode";
#endif
}

GeoTIFFLoader::~GeoTIFFLoader()
{
    clearData();
}

bool GeoTIFFLoader::loadFile(const QString &filePath)
{
    qDebug() << "GeoTIFFLoader: Loading file:" << filePath;

    clearData();
    m_filePath = filePath;
    emit filePathChanged();

    if (!QFile::exists(filePath)) {
        setErrorMessage("File not found: " + filePath);
        emit loadingFinished(false);
        return false;
    }

    bool success = false;

#ifdef HAS_GDAL
    success = loadWithGDAL(filePath);
#else
    success = loadFallback(filePath);
#endif

    if (success) {
        calculateStatistics();
        m_isLoaded = true;
        emit isLoadedChanged();
        qDebug() << "GeoTIFFLoader: File loaded successfully"
                 << "Size:" << m_width << "x" << m_height
                 << "Depth range:" << m_minDepth << "to" << m_maxDepth;
    }

    emit loadingFinished(success);
    return success;
}

#ifdef HAS_GDAL
bool GeoTIFFLoader::loadWithGDAL(const QString &filePath)
{
    qDebug() << "GeoTIFFLoader: Using GDAL to load file";

    GDALDataset *dataset = (GDALDataset *)GDALOpen(filePath.toUtf8().constData(), GA_ReadOnly);
    if (dataset == nullptr) {
        setErrorMessage("GDAL failed to open file");
        return false;
    }

    // Dataset bilgilerini al
    m_width = dataset->GetRasterXSize();
    m_height = dataset->GetRasterYSize();
    emit widthChanged();
    emit heightChanged();

    qDebug() << "GeoTIFFLoader: Raster size:" << m_width << "x" << m_height;

    // İlk bandı al (genellikle elevation/bathymetry verisi)
    GDALRasterBand *band = dataset->GetRasterBand(1);
    if (band == nullptr) {
        setErrorMessage("Failed to get raster band");
        GDALClose(dataset);
        return false;
    }

    // Veriyi oku
    m_depthData.resize(m_height);
    float *scanline = new float[m_width];

    for (int y = 0; y < m_height; y++) {
        m_depthData[y].resize(m_width);

        // Satırı oku
        CPLErr err = band->RasterIO(GF_Read, 0, y, m_width, 1,
                                     scanline, m_width, 1, GDT_Float32, 0, 0);

        if (err != CE_None) {
            setErrorMessage("Failed to read raster data at row " + QString::number(y));
            delete[] scanline;
            GDALClose(dataset);
            return false;
        }

        // Veriyi kaydet
        for (int x = 0; x < m_width; x++) {
            m_depthData[y][x] = static_cast<double>(scanline[x]);
        }

        // İlerleme bildir (her %10'da bir)
        if (y % (m_height / 10) == 0) {
            int progress = (y * 100) / m_height;
            emit loadingProgress(progress);
        }
    }

    delete[] scanline;
    GDALClose(dataset);

    emit loadingProgress(100);
    return true;
}
#else
bool GeoTIFFLoader::loadWithGDAL(const QString &/*filePath*/)
{
    setErrorMessage("GDAL not available");
    return false;
}
#endif

bool GeoTIFFLoader::loadFallback(const QString &filePath)
{
    qDebug() << "GeoTIFFLoader: Using fallback mode (demo data)";

    // GDAL yoksa, demo/test verisi oluştur
    // Gerçek kullanımda GDAL gerekli olacak
    setErrorMessage("GDAL not available - using demo data");

    // 32x32 demo grid oluştur
    m_width = 32;
    m_height = 32;
    emit widthChanged();
    emit heightChanged();

    m_depthData.resize(m_height);

    // Liman benzeri batimetri oluştur (BathymetricMapView.qml'deki gibi)
    double centerX = m_width / 2.0;
    double centerY = m_height / 2.0;

    for (int row = 0; row < m_height; row++) {
        m_depthData[row].resize(m_width);

        for (int col = 0; col < m_width; col++) {
            // Merketten uzaklık
            double distFromCenter = std::sqrt(
                std::pow(col - centerX, 2) +
                std::pow(row - centerY, 2)
            );

            // Kıyı etkisi (sol ve üst kenarlara yakın sığ)
            double distFromLeftEdge = col;
            double distFromTopEdge = row;
            double shoreEffect = std::min(distFromLeftEdge, distFromTopEdge) * 3.0;

            // Derinlik hesapla (negatif değerler - deniz seviyesinin altı)
            double depth = -5.0 - (distFromCenter * 2.0) + shoreEffect;
            depth = std::max(depth, -60.0); // Maksimum derinlik -60m
            depth = std::min(depth, -2.0);  // Minimum derinlik -2m

            // Biraz rastgele varyasyon ekle
            double randomVariation = (std::rand() % 100) / 100.0 - 0.5; // -0.5 to +0.5
            depth += randomVariation;

            m_depthData[row][col] = depth;
        }

        // İlerleme bildir
        if (row % (m_height / 10) == 0) {
            int progress = (row * 100) / m_height;
            emit loadingProgress(progress);
        }
    }

    emit loadingProgress(100);
    qDebug() << "GeoTIFFLoader: Demo data generated";
    return true;
}

void GeoTIFFLoader::calculateStatistics()
{
    if (m_depthData.isEmpty()) {
        return;
    }

    m_minDepth = m_depthData[0][0];
    m_maxDepth = m_depthData[0][0];

    for (const auto &row : m_depthData) {
        for (double depth : row) {
            m_minDepth = std::min(m_minDepth, depth);
            m_maxDepth = std::max(m_maxDepth, depth);
        }
    }

    emit minDepthChanged();
    emit maxDepthChanged();

    qDebug() << "GeoTIFFLoader: Statistics - Min:" << m_minDepth << "Max:" << m_maxDepth;
}

double GeoTIFFLoader::getDepthAt(int x, int y) const
{
    if (!m_isLoaded || x < 0 || x >= m_width || y < 0 || y >= m_height) {
        return 0.0;
    }

    return m_depthData[y][x];
}

QVariantList GeoTIFFLoader::getBathymetricGrid(int gridWidth, int gridHeight) const
{
    QVariantList result;

    if (!m_isLoaded || gridWidth <= 0 || gridHeight <= 0) {
        return result;
    }

    // Resample data to requested grid size
    double scaleX = static_cast<double>(m_width) / gridWidth;
    double scaleY = static_cast<double>(m_height) / gridHeight;

    for (int row = 0; row < gridHeight; row++) {
        QVariantList rowData;

        for (int col = 0; col < gridWidth; col++) {
            // Nearest neighbor sampling
            int srcX = static_cast<int>(col * scaleX);
            int srcY = static_cast<int>(row * scaleY);

            // Sınırları kontrol et
            srcX = qBound(0, srcX, m_width - 1);
            srcY = qBound(0, srcY, m_height - 1);

            double depth = m_depthData[srcY][srcX];
            rowData.append(depth);
        }

        result.append(QVariant::fromValue(rowData));
    }

    return result;
}

double GeoTIFFLoader::normalizeDepth(double depth) const
{
    if (m_maxDepth == m_minDepth) {
        return 0.5; // Varsayılan orta değer
    }

    return (depth - m_minDepth) / (m_maxDepth - m_minDepth);
}

QString GeoTIFFLoader::getDepthColor(double normalizedDepth) const
{
    // Renk gradyanı: sığ (açık yeşil) -> orta (turkuaz) -> derin (koyu mavi)
    if (normalizedDepth > 0.7) {
        return "#90EE90"; // Açık yeşil (sığ)
    } else if (normalizedDepth > 0.5) {
        return "#4DB8A8"; // Yeşil-turkuaz
    } else if (normalizedDepth > 0.35) {
        return "#3EADC4"; // Turkuaz
    } else if (normalizedDepth > 0.2) {
        return "#2E8BC0"; // Açık mavi
    } else {
        return "#1F5F8B"; // Koyu mavi (derin)
    }
}

void GeoTIFFLoader::clearData()
{
    m_depthData.clear();
    m_isLoaded = false;
    m_width = 0;
    m_height = 0;
    m_minDepth = 0.0;
    m_maxDepth = 0.0;
    m_errorMessage.clear();

    emit isLoadedChanged();
    emit widthChanged();
    emit heightChanged();
    emit minDepthChanged();
    emit maxDepthChanged();
    emit errorMessageChanged();
}

void GeoTIFFLoader::setErrorMessage(const QString &error)
{
    m_errorMessage = error;
    emit errorMessageChanged();
    qWarning() << "GeoTIFFLoader Error:" << error;
}
