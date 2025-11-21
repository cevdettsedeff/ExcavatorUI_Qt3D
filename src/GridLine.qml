import QtQuick
import QtQuick3D

Model {
    id: lineModel
    source: "#Cube"

    materials: PrincipledMaterial {
        baseColor: Qt.rgba(0.1, 0.1, 0.1, 1.0)
        metalness: 0.3
        roughness: 0.8
    }
}
