#include "BathymetricMeshGenerator.h"
#include <QDebug>
#include <cmath>

BathymetricMeshGenerator::BathymetricMeshGenerator(QQuick3DObject *parent)
    : QQuick3DGeometry(parent)
    , m_gridResolution(32)
    , m_verticalScale(2.0)
    , m_horizontalScale(10.0)
{
}

BathymetricMeshGenerator::~BathymetricMeshGenerator()
{
}

void BathymetricMeshGenerator::setGridResolution(int resolution)
{
    if (m_gridResolution != resolution && resolution > 0) {
        m_gridResolution = resolution;
        emit gridResolutionChanged();
    }
}

void BathymetricMeshGenerator::setVerticalScale(double scale)
{
    if (m_verticalScale != scale && scale > 0) {
        m_verticalScale = scale;
        emit verticalScaleChanged();
    }
}

void BathymetricMeshGenerator::setHorizontalScale(double scale)
{
    if (m_horizontalScale != scale && scale > 0) {
        m_horizontalScale = scale;
        emit horizontalScaleChanged();
    }
}

bool BathymetricMeshGenerator::generateFromTile(BathymetricTile *tile)
{
    if (!tile || !tile->isValid || tile->depths.isEmpty()) {
        qWarning() << "Invalid tile for mesh generation";
        return false;
    }

    generateMesh(tile->depths, tile->width, tile->height);
    emit meshGenerated();
    return true;
}

bool BathymetricMeshGenerator::generateFromDepthArray(const QVector<float> &depths, int width, int height)
{
    if (depths.isEmpty() || width <= 0 || height <= 0) {
        qWarning() << "Invalid depth array for mesh generation";
        return false;
    }

    if (depths.size() != width * height) {
        qWarning() << "Depth array size mismatch:" << depths.size() << "!=" << (width * height);
        return false;
    }

    generateMesh(depths, width, height);
    emit meshGenerated();
    return true;
}

void BathymetricMeshGenerator::generateMesh(const QVector<float> &depths, int width, int height)
{
    qDebug() << "Generating heightmap mesh:" << width << "x" << height << "→" << m_gridResolution << "x" << m_gridResolution;

    // Resample if needed
    QVector<float> workingDepths = depths;
    int workingWidth = width;
    int workingHeight = height;

    if (width != m_gridResolution || height != m_gridResolution) {
        workingDepths = resampleDepths(depths, width, height, m_gridResolution, m_gridResolution);
        workingWidth = m_gridResolution;
        workingHeight = m_gridResolution;
    }

    // Create vertices and texture coordinates
    QVector<QVector3D> vertices;
    QVector<QVector2D> texCoords;
    createVertices(workingDepths, workingWidth, workingHeight, vertices, texCoords);

    // Create indices (triangles)
    QVector<quint32> indices;
    createIndices(workingWidth, workingHeight, indices);

    // Calculate normals
    QVector<QVector3D> normals;
    calculateNormals(vertices, indices, normals);

    // Pack vertex data
    QByteArray vertexData;
    int vertexCount = vertices.size();
    vertexData.resize(vertexCount * sizeof(float) * 8); // position(3) + normal(3) + texcoord(2)

    float *vertexPtr = reinterpret_cast<float*>(vertexData.data());
    for (int i = 0; i < vertexCount; ++i) {
        // Position
        *vertexPtr++ = vertices[i].x();
        *vertexPtr++ = vertices[i].y();
        *vertexPtr++ = vertices[i].z();

        // Normal
        *vertexPtr++ = normals[i].x();
        *vertexPtr++ = normals[i].y();
        *vertexPtr++ = normals[i].z();

        // TexCoord
        *vertexPtr++ = texCoords[i].x();
        *vertexPtr++ = texCoords[i].y();
    }

    // Pack index data
    QByteArray indexData;
    indexData.resize(indices.size() * sizeof(quint32));
    memcpy(indexData.data(), indices.data(), indexData.size());

    // Set geometry data
    clear();
    setPrimitiveType(QQuick3DGeometry::PrimitiveType::Triangles);

    addAttribute(QQuick3DGeometry::Attribute::PositionSemantic,
                 0,
                 QQuick3DGeometry::Attribute::ComponentType::F32Type);

    addAttribute(QQuick3DGeometry::Attribute::NormalSemantic,
                 3 * sizeof(float),
                 QQuick3DGeometry::Attribute::ComponentType::F32Type);

    addAttribute(QQuick3DGeometry::Attribute::TexCoord0Semantic,
                 6 * sizeof(float),
                 QQuick3DGeometry::Attribute::ComponentType::F32Type);

    addAttribute(QQuick3DGeometry::Attribute::IndexSemantic,
                 0,
                 QQuick3DGeometry::Attribute::ComponentType::U32Type);

    setStride(8 * sizeof(float));
    setVertexData(vertexData);
    setIndexData(indexData);

    update();

    qDebug() << "✓ Mesh generated:" << vertexCount << "vertices," << indices.size() / 3 << "triangles";
}

void BathymetricMeshGenerator::createVertices(const QVector<float> &depths, int width, int height,
                                               QVector<QVector3D> &vertices, QVector<QVector2D> &texCoords)
{
    vertices.clear();
    texCoords.clear();

    vertices.reserve(width * height);
    texCoords.reserve(width * height);

    float halfWidth = (width - 1) * m_horizontalScale * 0.5f;
    float halfHeight = (height - 1) * m_horizontalScale * 0.5f;

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            float depth = getDepthValue(depths, width, height, x, y);

            // Position (centered)
            float posX = x * m_horizontalScale - halfWidth;
            float posY = depth * m_verticalScale;
            float posZ = y * m_horizontalScale - halfHeight;

            vertices.append(QVector3D(posX, posY, posZ));

            // Texture coordinate
            float u = static_cast<float>(x) / (width - 1);
            float v = static_cast<float>(y) / (height - 1);
            texCoords.append(QVector2D(u, v));
        }
    }
}

void BathymetricMeshGenerator::createIndices(int width, int height, QVector<quint32> &indices)
{
    indices.clear();

    int quadCount = (width - 1) * (height - 1);
    indices.reserve(quadCount * 6); // 2 triangles per quad

    for (int y = 0; y < height - 1; ++y) {
        for (int x = 0; x < width - 1; ++x) {
            quint32 topLeft = y * width + x;
            quint32 topRight = topLeft + 1;
            quint32 bottomLeft = (y + 1) * width + x;
            quint32 bottomRight = bottomLeft + 1;

            // First triangle (top-left, bottom-left, top-right)
            indices.append(topLeft);
            indices.append(bottomLeft);
            indices.append(topRight);

            // Second triangle (top-right, bottom-left, bottom-right)
            indices.append(topRight);
            indices.append(bottomLeft);
            indices.append(bottomRight);
        }
    }
}

void BathymetricMeshGenerator::calculateNormals(const QVector<QVector3D> &vertices,
                                                 const QVector<quint32> &indices,
                                                 QVector<QVector3D> &normals)
{
    normals.clear();
    normals.fill(QVector3D(0, 0, 0), vertices.size());

    // Accumulate face normals
    for (int i = 0; i < indices.size(); i += 3) {
        quint32 i0 = indices[i];
        quint32 i1 = indices[i + 1];
        quint32 i2 = indices[i + 2];

        QVector3D v0 = vertices[i0];
        QVector3D v1 = vertices[i1];
        QVector3D v2 = vertices[i2];

        QVector3D edge1 = v1 - v0;
        QVector3D edge2 = v2 - v0;
        QVector3D faceNormal = QVector3D::crossProduct(edge1, edge2);

        normals[i0] += faceNormal;
        normals[i1] += faceNormal;
        normals[i2] += faceNormal;
    }

    // Normalize
    for (int i = 0; i < normals.size(); ++i) {
        normals[i].normalize();
    }
}

float BathymetricMeshGenerator::getDepthValue(const QVector<float> &depths, int width, int height, int x, int y) const
{
    if (x < 0 || x >= width || y < 0 || y >= height) {
        return 0.0f;
    }

    int index = y * width + x;
    if (index < 0 || index >= depths.size()) {
        return 0.0f;
    }

    float depth = depths[index];

    // Check for no-data value
    if (depth < -32000) {
        return 0.0f;
    }

    return depth;
}

QVector<float> BathymetricMeshGenerator::resampleDepths(const QVector<float> &depths,
                                                         int inWidth, int inHeight,
                                                         int outWidth, int outHeight) const
{
    QVector<float> resampled(outWidth * outHeight);

    for (int y = 0; y < outHeight; ++y) {
        for (int x = 0; x < outWidth; ++x) {
            // Bilinear interpolation
            float u = static_cast<float>(x) / (outWidth - 1) * (inWidth - 1);
            float v = static_cast<float>(y) / (outHeight - 1) * (inHeight - 1);

            int x0 = static_cast<int>(std::floor(u));
            int x1 = std::min(x0 + 1, inWidth - 1);
            int y0 = static_cast<int>(std::floor(v));
            int y1 = std::min(y0 + 1, inHeight - 1);

            float fx = u - x0;
            float fy = v - y0;

            float d00 = getDepthValue(depths, inWidth, inHeight, x0, y0);
            float d10 = getDepthValue(depths, inWidth, inHeight, x1, y0);
            float d01 = getDepthValue(depths, inWidth, inHeight, x0, y1);
            float d11 = getDepthValue(depths, inWidth, inHeight, x1, y1);

            float d0 = d00 * (1 - fx) + d10 * fx;
            float d1 = d01 * (1 - fx) + d11 * fx;
            float depth = d0 * (1 - fy) + d1 * fy;

            resampled[y * outWidth + x] = depth;
        }
    }

    return resampled;
}

void BathymetricMeshGenerator::clear()
{
    QQuick3DGeometry::clear();
}
