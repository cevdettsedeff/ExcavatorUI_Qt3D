#ifndef GEOTIFFLOADER_H
#define GEOTIFFLOADER_H

#include <QObject>
#include <QString>
#include <QVector>
#include <QVariantMap>
#include <QQmlEngine>

/**
 * @brief GeoTIFF dosyalarını yükleyen ve batimetrik verileri parse eden sınıf
 *
 * Bu sınıf GDAL kütüphanesini kullanarak GeoTIFF formatındaki batimetrik
 * verileri okur ve Qt/QML ile kullanılabilir hale getirir.
 */
class GeoTIFFLoader : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(bool isLoaded READ isLoaded NOTIFY isLoadedChanged)
    Q_PROPERTY(QString filePath READ filePath NOTIFY filePathChanged)
    Q_PROPERTY(int width READ width NOTIFY widthChanged)
    Q_PROPERTY(int height READ height NOTIFY heightChanged)
    Q_PROPERTY(double minDepth READ minDepth NOTIFY minDepthChanged)
    Q_PROPERTY(double maxDepth READ maxDepth NOTIFY maxDepthChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

public:
    explicit GeoTIFFLoader(QObject *parent = nullptr);
    ~GeoTIFFLoader();

    // Property getters
    bool isLoaded() const { return m_isLoaded; }
    QString filePath() const { return m_filePath; }
    int width() const { return m_width; }
    int height() const { return m_height; }
    double minDepth() const { return m_minDepth; }
    double maxDepth() const { return m_maxDepth; }
    QString errorMessage() const { return m_errorMessage; }

    /**
     * @brief GeoTIFF dosyasını yükler
     * @param filePath Yüklenecek GeoTIFF dosyasının yolu
     * @return Başarılı ise true, aksi halde false
     */
    Q_INVOKABLE bool loadFile(const QString &filePath);

    /**
     * @brief Belirli bir grid pozisyonundaki derinlik değerini döndürür
     * @param x X koordinatı (0 to width-1)
     * @param y Y koordinatı (0 to height-1)
     * @return Derinlik değeri (metre cinsinden)
     */
    Q_INVOKABLE double getDepthAt(int x, int y) const;

    /**
     * @brief Tüm batimetrik veriyi QVariantList olarak döndürür (QML için)
     * @param gridWidth İstenen grid genişliği
     * @param gridHeight İstenen grid yüksekliği
     * @return Grid formatında derinlik verileri
     */
    Q_INVOKABLE QVariantList getBathymetricGrid(int gridWidth, int gridHeight) const;

    /**
     * @brief Normalize edilmiş derinlik değerini döndürür (0.0 - 1.0)
     * @param depth Ham derinlik değeri
     * @return Normalize edilmiş değer
     */
    Q_INVOKABLE double normalizeDepth(double depth) const;

    /**
     * @brief Derinliğe göre renk döndürür
     * @param normalizedDepth Normalize edilmiş derinlik (0.0 - 1.0)
     * @return Hex renk kodu (örn: "#90EE90")
     */
    Q_INVOKABLE QString getDepthColor(double normalizedDepth) const;

    /**
     * @brief Yüklü veriyi temizler
     */
    Q_INVOKABLE void clearData();

signals:
    void isLoadedChanged();
    void filePathChanged();
    void widthChanged();
    void heightChanged();
    void minDepthChanged();
    void maxDepthChanged();
    void errorMessageChanged();
    void loadingProgress(int percentage);
    void loadingFinished(bool success);

private:
    bool m_isLoaded;
    QString m_filePath;
    int m_width;
    int m_height;
    double m_minDepth;
    double m_maxDepth;
    QString m_errorMessage;

    // Batimetrik veri matrisi
    QVector<QVector<double>> m_depthData;

    void setErrorMessage(const QString &error);
    bool loadWithGDAL(const QString &filePath);
    bool loadFallback(const QString &filePath); // GDAL yoksa basit okuma
    void calculateStatistics();
};

#endif // GEOTIFFLOADER_H
