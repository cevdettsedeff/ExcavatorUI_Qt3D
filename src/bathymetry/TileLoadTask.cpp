#include "TileLoadTask.h"
#include <QDebug>

TileLoadTask::TileLoadTask(BathymetricDataLoader *loader, int tileX, int tileY, int lodLevel, QObject *parent)
    : QObject(parent)
    , QRunnable()
    , m_loader(loader)
    , m_tileX(tileX)
    , m_tileY(tileY)
    , m_lodLevel(lodLevel)
{
    setAutoDelete(true);  // Task will be deleted automatically after run()
}

TileLoadTask::~TileLoadTask()
{
}

void TileLoadTask::run()
{
    if (!m_loader) {
        emit tileLoadFailed(m_tileX, m_tileY, m_lodLevel, "Loader is null");
        return;
    }

    qDebug() << "  [Thread" << QThread::currentThreadId() << "] Loading tile" << m_tileX << m_tileY << "LOD" << m_lodLevel;

    // Load tile (thread-safe operation)
    BathymetricTile *tile = m_loader->loadTile(m_tileX, m_tileY, m_lodLevel);

    if (tile && tile->isValid) {
        qDebug() << "  [Thread" << QThread::currentThreadId() << "] Tile loaded successfully:" << m_tileX << m_tileY;
        emit tileLoadComplete(m_tileX, m_tileY, m_lodLevel, tile);
    } else {
        qDebug() << "  [Thread" << QThread::currentThreadId() << "] Tile load failed:" << m_tileX << m_tileY;
        emit tileLoadFailed(m_tileX, m_tileY, m_lodLevel, "Failed to load tile data");
    }
}
