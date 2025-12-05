#ifndef TILELOADTASK_H
#define TILELOADTASK_H

#include <QRunnable>
#include <QObject>
#include "BathymetricDataLoader.h"

/**
 * Asynchronous tile loading task for QThreadPool
 * Loads a bathymetric tile in background thread and emits signal when complete
 */
class TileLoadTask : public QObject, public QRunnable
{
    Q_OBJECT

public:
    TileLoadTask(BathymetricDataLoader *loader, int tileX, int tileY, int lodLevel, QObject *parent = nullptr);
    ~TileLoadTask() override;

    void run() override;

    int tileX() const { return m_tileX; }
    int tileY() const { return m_tileY; }
    int lodLevel() const { return m_lodLevel; }

signals:
    void tileLoadComplete(int tileX, int tileY, int lodLevel, BathymetricTile *tile);
    void tileLoadFailed(int tileX, int tileY, int lodLevel, const QString &error);

private:
    BathymetricDataLoader *m_loader;
    int m_tileX;
    int m_tileY;
    int m_lodLevel;
};

#endif // TILELOADTASK_H
