#include "ExcavatorTracker.h"
#include <QDebug>
#include <cmath>

ExcavatorTracker::ExcavatorTracker(QObject *parent)
    : QObject(parent)
    , m_bucketPosition(0, 0, 0)
    , m_isExcavating(false)
    , m_currentGridRow(-1)
    , m_currentGridCol(-1)
    , m_gridSize(16)
    , m_cellSize(50.0)
    , m_simulationMode(false)
    , m_simulationAngle(0.0)
{
    // Simülasyon timer'ı oluştur
    m_simulationTimer = new QTimer(this);
    connect(m_simulationTimer, &QTimer::timeout, this, &ExcavatorTracker::updateSimulation);
}

ExcavatorTracker::~ExcavatorTracker()
{
    stopSimulation();
}

void ExcavatorTracker::setBucketPosition(const QVector3D &position)
{
    if (m_bucketPosition != position) {
        m_bucketPosition = position;
        emit bucketPositionChanged();
        updateGridPosition();
    }
}

void ExcavatorTracker::setIsExcavating(bool excavating)
{
    if (m_isExcavating != excavating) {
        m_isExcavating = excavating;
        emit isExcavatingChanged();
        qDebug() << "ExcavatorTracker: Excavating:" << m_isExcavating;
    }
}

void ExcavatorTracker::setGridSize(int size)
{
    if (m_gridSize != size && size > 0) {
        m_gridSize = size;
        emit gridSizeChanged();
        updateGridPosition();
    }
}

void ExcavatorTracker::setCellSize(double size)
{
    if (m_cellSize != size && size > 0) {
        m_cellSize = size;
        emit cellSizeChanged();
        updateGridPosition();
    }
}

void ExcavatorTracker::setSimulationMode(bool enabled)
{
    if (m_simulationMode != enabled) {
        m_simulationMode = enabled;
        emit simulationModeChanged();
        qDebug() << "ExcavatorTracker: Simulation mode:" << m_simulationMode;
    }
}

void ExcavatorTracker::updatePositionFromGPS(double latitude, double longitude, double depth)
{
    // GPS koordinatlarını lokal koordinatlara çevir
    // Bu basit bir implementasyon - gerçek uygulamada daha karmaşık dönüşüm gerekebilir

    // İstanbul referans koordinatları: 41.0082°N, 28.9784°E
    const double refLat = 41.0082;
    const double refLon = 28.9784;

    // Mesafe hesapla (basitleştirilmiş - düz dünya yaklaşımı)
    // 1 derece enlem ≈ 111 km
    // 1 derece boylam ≈ 111 * cos(lat) km
    double deltaLat = (latitude - refLat) * 111000.0; // metre
    double deltaLon = (longitude - refLon) * 111000.0 * std::cos(refLat * M_PI / 180.0);

    QVector3D newPosition(deltaLon, depth, deltaLat);
    setBucketPosition(newPosition);

    qDebug() << "ExcavatorTracker: GPS position updated -"
             << "Lat:" << latitude << "Lon:" << longitude << "Depth:" << depth
             << "-> World:" << newPosition;
}

bool ExcavatorTracker::worldToGrid(const QVector3D &position, int &outRow, int &outCol) const
{
    // Grid merkezi (0,0) kabul ediliyor
    double centerOffset = (m_gridSize * m_cellSize) / 2.0;

    // World pozisyonunu grid koordinatlarına çevir
    double gridX = (position.x() + centerOffset) / m_cellSize;
    double gridZ = (position.z() + centerOffset) / m_cellSize;

    outCol = static_cast<int>(std::floor(gridX));
    outRow = static_cast<int>(std::floor(gridZ));

    // Grid sınırları içinde mi kontrol et
    bool inBounds = (outRow >= 0 && outRow < m_gridSize &&
                     outCol >= 0 && outCol < m_gridSize);

    return inBounds;
}

QVector3D ExcavatorTracker::gridToWorld(int row, int col) const
{
    double centerOffset = (m_gridSize * m_cellSize) / 2.0;

    double x = (col * m_cellSize) - centerOffset + m_cellSize / 2.0;
    double z = (row * m_cellSize) - centerOffset + m_cellSize / 2.0;

    return QVector3D(x, 0, z);
}

void ExcavatorTracker::startSimulation()
{
    qDebug() << "ExcavatorTracker: Starting simulation";
    m_simulationMode = true;
    emit simulationModeChanged();

    // 100ms'de bir güncelle (10 FPS)
    m_simulationTimer->start(100);
}

void ExcavatorTracker::stopSimulation()
{
    qDebug() << "ExcavatorTracker: Stopping simulation";
    m_simulationTimer->stop();
    m_simulationMode = false;
    emit simulationModeChanged();
}

void ExcavatorTracker::updateSimulation()
{
    // Dairesel hareket simülasyonu
    m_simulationAngle += 0.05; // Radyan artışı

    double radius = 200.0; // Hareket yarıçapı
    double x = radius * std::cos(m_simulationAngle);
    double z = radius * std::sin(m_simulationAngle);
    double y = -10.0 + 5.0 * std::sin(m_simulationAngle * 3); // Yukarı aşağı hareket

    setBucketPosition(QVector3D(x, y, z));

    // Rastgele kazı durumu (derinliğe göre)
    bool excavating = (y < -5.0);
    setIsExcavating(excavating);
}

void ExcavatorTracker::updateGridPosition()
{
    int newRow, newCol;
    bool inGrid = worldToGrid(m_bucketPosition, newRow, newCol);

    if (inGrid) {
        // Grid pozisyonu değişti mi?
        if (newRow != m_currentGridRow || newCol != m_currentGridCol) {
            // Eski hücreden çık
            if (m_currentGridRow >= 0 && m_currentGridCol >= 0) {
                emit gridCellExited(m_currentGridRow, m_currentGridCol);
            }

            // Yeni hücreye gir
            m_currentGridRow = newRow;
            m_currentGridCol = newCol;
            emit currentGridRowChanged();
            emit currentGridColChanged();
            emit gridCellEntered(newRow, newCol);

            qDebug() << "ExcavatorTracker: Entered grid cell [" << newRow << "," << newCol << "]";
        }
    } else {
        // Grid dışına çıktı
        if (m_currentGridRow >= 0 || m_currentGridCol >= 0) {
            emit gridCellExited(m_currentGridRow, m_currentGridCol);
            m_currentGridRow = -1;
            m_currentGridCol = -1;
            emit currentGridRowChanged();
            emit currentGridColChanged();
            qDebug() << "ExcavatorTracker: Exited grid";
        }
    }
}
