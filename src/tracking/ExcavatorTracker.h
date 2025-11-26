#ifndef EXCAVATORTRACKER_H
#define EXCAVATORTRACKER_H

#include <QObject>
#include <QVector3D>
#include <QTimer>
#include <QQmlEngine>

/**
 * @brief Ekskavatör kepçe pozisyonunu takip eden ve grid hücresini hesaplayan sınıf
 *
 * Bu sınıf GPS/sensör verilerinden gelen pozisyonu alır ve hangi grid hücresinde
 * kazı yapıldığını belirler. Gerçek zamanlı pozisyon güncellemeleri sağlar.
 */
class ExcavatorTracker : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QVector3D bucketPosition READ bucketPosition WRITE setBucketPosition NOTIFY bucketPositionChanged)
    Q_PROPERTY(bool isExcavating READ isExcavating WRITE setIsExcavating NOTIFY isExcavatingChanged)
    Q_PROPERTY(int currentGridRow READ currentGridRow NOTIFY currentGridRowChanged)
    Q_PROPERTY(int currentGridCol READ currentGridCol NOTIFY currentGridColChanged)
    Q_PROPERTY(int gridSize READ gridSize WRITE setGridSize NOTIFY gridSizeChanged)
    Q_PROPERTY(double cellSize READ cellSize WRITE setCellSize NOTIFY cellSizeChanged)
    Q_PROPERTY(bool simulationMode READ simulationMode WRITE setSimulationMode NOTIFY simulationModeChanged)

public:
    explicit ExcavatorTracker(QObject *parent = nullptr);
    ~ExcavatorTracker();

    // Property getters
    QVector3D bucketPosition() const { return m_bucketPosition; }
    bool isExcavating() const { return m_isExcavating; }
    int currentGridRow() const { return m_currentGridRow; }
    int currentGridCol() const { return m_currentGridCol; }
    int gridSize() const { return m_gridSize; }
    double cellSize() const { return m_cellSize; }
    bool simulationMode() const { return m_simulationMode; }

    // Property setters
    void setBucketPosition(const QVector3D &position);
    void setIsExcavating(bool excavating);
    void setGridSize(int size);
    void setCellSize(double size);
    void setSimulationMode(bool enabled);

    /**
     * @brief GPS koordinatlarından 3D pozisyon günceller
     * @param latitude Enlem
     * @param longitude Boylam
     * @param depth Derinlik (metre)
     */
    Q_INVOKABLE void updatePositionFromGPS(double latitude, double longitude, double depth);

    /**
     * @brief 3D world pozisyonundan grid koordinatlarını hesaplar
     * @param position 3D pozisyon
     * @param outRow Grid satırı (output)
     * @param outCol Grid sütunu (output)
     * @return Grid sınırları içindeyse true
     */
    Q_INVOKABLE bool worldToGrid(const QVector3D &position, int &outRow, int &outCol) const;

    /**
     * @brief Grid koordinatlarından 3D world pozisyonunu hesaplar
     * @param row Grid satırı
     * @param col Grid sütunu
     * @return 3D world pozisyonu
     */
    Q_INVOKABLE QVector3D gridToWorld(int row, int col) const;

    /**
     * @brief Simülasyon modunu başlatır/durdurur
     */
    Q_INVOKABLE void startSimulation();
    Q_INVOKABLE void stopSimulation();

signals:
    void bucketPositionChanged();
    void isExcavatingChanged();
    void currentGridRowChanged();
    void currentGridColChanged();
    void gridSizeChanged();
    void cellSizeChanged();
    void simulationModeChanged();
    void gridCellEntered(int row, int col);
    void gridCellExited(int row, int col);

private slots:
    void updateSimulation();

private:
    QVector3D m_bucketPosition;
    bool m_isExcavating;
    int m_currentGridRow;
    int m_currentGridCol;
    int m_gridSize;
    double m_cellSize;
    bool m_simulationMode;

    QTimer *m_simulationTimer;
    double m_simulationAngle;

    void updateGridPosition();
};

#endif // EXCAVATORTRACKER_H
