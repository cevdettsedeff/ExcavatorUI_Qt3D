import QtQuick
import QtQuick3D

Node {
    id: grid3DRoot

    property real gridSize: 1000  // Toplam grid boyutu
    property real cellSize: 50    // Her bir hücre boyutu
    property color gridColor: "#00bcd4"
    property real gridOpacity: 0.4
    property real gridThickness: 0.5

    // Grid çizgileri için materyal
    PrincipledMaterial {
        id: gridMaterial
        baseColor: Qt.rgba(gridColor.r, gridColor.g, gridColor.b, gridOpacity)
        metalness: 0.3
        roughness: 0.7
        alphaMode: PrincipledMaterial.Blend
    }

    // X ekseni boyunca çizgiler (Z yönünde uzanan)
    Repeater {
        model: Math.floor(gridSize / cellSize) + 1

        Model {
            source: "#Cube"
            position: Qt.vector3d(-gridSize/2 + index * cellSize, 0, 0)
            scale: Qt.vector3d(gridThickness, gridThickness, gridSize)
            materials: gridMaterial
        }
    }

    // Z ekseni boyunca çizgiler (X yönünde uzanan)
    Repeater {
        model: Math.floor(gridSize / cellSize) + 1

        Model {
            source: "#Cube"
            position: Qt.vector3d(0, 0, -gridSize/2 + index * cellSize)
            scale: Qt.vector3d(gridSize, gridThickness, gridThickness)
            materials: gridMaterial
        }
    }

    // Merkez çizgileri (daha kalın ve farklı renk)
    PrincipledMaterial {
        id: centerLineMaterial
        baseColor: Qt.rgba(1.0, 0.8, 0.0, 0.6)
        metalness: 0.5
        roughness: 0.5
        alphaMode: PrincipledMaterial.Blend
    }

    // X ekseni merkez çizgisi
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, 0.5, 0)
        scale: Qt.vector3d(gridThickness * 2, gridThickness, gridSize)
        materials: centerLineMaterial
    }

    // Z ekseni merkez çizgisi
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, 0.5, 0)
        scale: Qt.vector3d(gridSize, gridThickness, gridThickness * 2)
        materials: centerLineMaterial
    }
}
