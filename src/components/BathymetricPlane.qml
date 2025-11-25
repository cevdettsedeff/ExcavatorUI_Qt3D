import QtQuick
import QtQuick3D

Node {
    id: bathymetricPlaneRoot

    property real gridSize: 800
    property real seaFloorDepth: 40

    // Ana deniz tabanı
    Model {
        source: "#Rectangle"
        position: Qt.vector3d(0, -seaFloorDepth, 0)
        eulerRotation.x: -90
        scale: Qt.vector3d(gridSize / 100, gridSize / 100, 1)

        materials: PrincipledMaterial {
            baseColor: "#505050"
            roughness: 0.9
            metalness: 0.1
        }
    }

    // Grid çizgileri - X yönü (10 çizgi)
    Model {
        source: "#Cube"
        position: Qt.vector3d(-400, -20, 0)
        scale: Qt.vector3d(1, 40, gridSize)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(-300, -20, 0)
        scale: Qt.vector3d(1, 40, gridSize)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(-200, -20, 0)
        scale: Qt.vector3d(1, 40, gridSize)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(-100, -20, 0)
        scale: Qt.vector3d(1, 40, gridSize)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, -20, 0)
        scale: Qt.vector3d(1, 40, gridSize)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(100, -20, 0)
        scale: Qt.vector3d(1, 40, gridSize)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(200, -20, 0)
        scale: Qt.vector3d(1, 40, gridSize)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(300, -20, 0)
        scale: Qt.vector3d(1, 40, gridSize)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(400, -20, 0)
        scale: Qt.vector3d(1, 40, gridSize)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }

    // Grid çizgileri - Z yönü (10 çizgi)
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, -20, -400)
        scale: Qt.vector3d(gridSize, 40, 1)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, -20, -300)
        scale: Qt.vector3d(gridSize, 40, 1)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, -20, -200)
        scale: Qt.vector3d(gridSize, 40, 1)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, -20, -100)
        scale: Qt.vector3d(gridSize, 40, 1)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, -20, 0)
        scale: Qt.vector3d(gridSize, 40, 1)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, -20, 100)
        scale: Qt.vector3d(gridSize, 40, 1)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, -20, 200)
        scale: Qt.vector3d(gridSize, 40, 1)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, -20, 300)
        scale: Qt.vector3d(gridSize, 40, 1)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, -20, 400)
        scale: Qt.vector3d(gridSize, 40, 1)
        materials: PrincipledMaterial { baseColor: "#2a2a2a" }
    }

    // Deniz seviyesi çerçevesi (cyan)
    Model {
        source: "#Cube"
        position: Qt.vector3d(-gridSize/2, 0, 0)
        scale: Qt.vector3d(gridSize, 3, 3)
        materials: PrincipledMaterial {
            baseColor: "#00bcd4"
            roughness: 0.2
            metalness: 0.8
        }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(gridSize/2, 0, 0)
        scale: Qt.vector3d(gridSize, 3, 3)
        materials: PrincipledMaterial {
            baseColor: "#00bcd4"
            roughness: 0.2
            metalness: 0.8
        }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, 0, -gridSize/2)
        scale: Qt.vector3d(3, 3, gridSize)
        materials: PrincipledMaterial {
            baseColor: "#00bcd4"
            roughness: 0.2
            metalness: 0.8
        }
    }
    Model {
        source: "#Cube"
        position: Qt.vector3d(0, 0, gridSize/2)
        scale: Qt.vector3d(3, 3, gridSize)
        materials: PrincipledMaterial {
            baseColor: "#00bcd4"
            roughness: 0.2
            metalness: 0.8
        }
    }
}
