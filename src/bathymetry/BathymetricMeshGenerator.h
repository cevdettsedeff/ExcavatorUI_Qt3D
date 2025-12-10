#ifndef BATHYMETRICMESHGENERATOR_H
#define BATHYMETRICMESHGENERATOR_H

#include <QQuick3DGeometry>
#include <QVector3D>
#include <QVector2D>
#include "BathymetricDataLoader.h"

/**
 * Generates 3D heightmap mesh from bathymetric tile data
 * Creates detailed vertex grid with proper normals and texture coordinates
 */
class BathymetricMeshGenerator : public QQuick3DGeometry
{
    Q_OBJECT
    Q_PROPERTY(int gridResolution READ gridResolution WRITE setGridResolution NOTIFY gridResolutionChanged)
    Q_PROPERTY(double verticalScale READ verticalScale WRITE setVerticalScale NOTIFY verticalScaleChanged)
    Q_PROPERTY(double horizontalScale READ horizontalScale WRITE setHorizontalScale NOTIFY horizontalScaleChanged)

public:
    explicit BathymetricMeshGenerator(QQuick3DObject *parent = nullptr);
    ~BathymetricMeshGenerator() override;

    int gridResolution() const { return m_gridResolution; }
    void setGridResolution(int resolution);

    double verticalScale() const { return m_verticalScale; }
    void setVerticalScale(double scale);

    double horizontalScale() const { return m_horizontalScale; }
    void setHorizontalScale(double scale);

    /**
     * Generate mesh from bathymetric tile data
     * @param tile Tile containing depth values
     * @return true if successful
     */
    Q_INVOKABLE bool generateFromTile(BathymetricTile *tile);

    /**
     * Generate mesh from depth array
     * @param depths Depth values (row-major)
     * @param width Grid width
     * @param height Grid height
     * @return true if successful
     */
    Q_INVOKABLE bool generateFromDepthArray(const QVector<float> &depths, int width, int height);

    /**
     * Clear mesh data
     */
    Q_INVOKABLE void clear();

signals:
    void gridResolutionChanged();
    void verticalScaleChanged();
    void horizontalScaleChanged();
    void meshGenerated();

private:
    int m_gridResolution;      // Subdivision level (e.g., 32 = 32x32 vertices)
    double m_verticalScale;    // Vertical exaggeration factor
    double m_horizontalScale;  // Horizontal scale (world units per pixel)

    // Mesh generation helpers
    void generateMesh(const QVector<float> &depths, int width, int height);
    void createVertices(const QVector<float> &depths, int width, int height,
                       QVector<QVector3D> &vertices, QVector<QVector2D> &texCoords);
    void createIndices(int width, int height, QVector<quint32> &indices);
    void calculateNormals(const QVector<QVector3D> &vertices,
                         const QVector<quint32> &indices,
                         QVector<QVector3D> &normals);
    float getDepthValue(const QVector<float> &depths, int width, int height, int x, int y) const;
    QVector<float> resampleDepths(const QVector<float> &depths, int inWidth, int inHeight,
                                  int outWidth, int outHeight) const;
};

#endif // BATHYMETRICMESHGENERATOR_H
