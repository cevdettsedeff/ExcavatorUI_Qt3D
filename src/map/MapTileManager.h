#ifndef MAPTILEMANAGER_H
#define MAPTILEMANAGER_H

#include <QObject>
#include <QString>
#include <QImage>
#include <QQmlEngine>

/**
 * @brief Harita altlığı (base layer) texture'larını yöneten sınıf
 *
 * Bu sınıf OpenStreetMap veya diğer tile servislerinden harita altlıkları
 * sağlar. Offline çalışma için default bir texture da içerir.
 */
class MapTileManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString baseLayerTexture READ baseLayerTexture NOTIFY baseLayerTextureChanged)
    Q_PROPERTY(bool isOnline READ isOnline WRITE setIsOnline NOTIFY isOnlineChanged)
    Q_PROPERTY(QString tileServerUrl READ tileServerUrl WRITE setTileServerUrl NOTIFY tileServerUrlChanged)

public:
    explicit MapTileManager(QObject *parent = nullptr);
    ~MapTileManager();

    QString baseLayerTexture() const { return m_baseLayerTexture; }
    bool isOnline() const { return m_isOnline; }
    QString tileServerUrl() const { return m_tileServerUrl; }

    void setIsOnline(bool online);
    void setTileServerUrl(const QString &url);

    /**
     * @brief Default offline harita texture'ı oluşturur
     * @return Texture dosya yolu
     */
    Q_INVOKABLE QString generateDefaultTexture();

    /**
     * @brief Belirli koordinatlar için OSM tile URL'i oluşturur
     * @param lat Enlem
     * @param lon Boylam
     * @param zoom Zoom seviyesi
     * @return Tile URL'i
     */
    Q_INVOKABLE QString getTileUrl(double lat, double lon, int zoom);

    /**
     * @brief Basit grid harita texture'ı oluşturur (offline mod için)
     * @param width Texture genişliği
     * @param height Texture yüksekliği
     * @return QImage texture
     */
    Q_INVOKABLE QImage createGridTexture(int width, int height);

signals:
    void baseLayerTextureChanged();
    void isOnlineChanged();
    void tileServerUrlChanged();

private:
    QString m_baseLayerTexture;
    bool m_isOnline;
    QString m_tileServerUrl;

    void generateAndSaveDefaultTexture();
    QString getTempTexturePath() const;
};

#endif // MAPTILEMANAGER_H
