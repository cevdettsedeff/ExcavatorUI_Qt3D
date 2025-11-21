import QtQuick
import QtQuick3D

Model {
    id: frameModel
    source: "#Cube"

    materials: PrincipledMaterial {
        baseColor: Qt.rgba(0.0, 0.9, 1.0, 1.0)
        metalness: 0.8
        roughness: 0.2
    }
}
