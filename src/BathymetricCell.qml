import QtQuick
import QtQuick3D

Model {
    id: cellModel
    source: "#Cube"

    property color cellColor: Qt.rgba(0.5, 0.5, 0.5, 1.0)

    materials: PrincipledMaterial {
        baseColor: cellColor
        metalness: 0.1
        roughness: 0.8
    }
}
