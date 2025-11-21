import QtQuick
import QtQuick3D

Node {
    id: bathymetricPlaneRoot

    property real planeSize: 1000
    property string textureSource: "../resources/textures/deniz.png"
    property real heightOffset: -2  // Grid'in biraz altında olacak

    // Ana batimetrik düzlem - harita altlığı
    Model {
        id: mapPlane
        source: "#Rectangle"
        position: Qt.vector3d(0, heightOffset, 0)
        eulerRotation.x: -90
        scale: Qt.vector3d(planeSize / 100, planeSize / 100, 1)

        materials: PrincipledMaterial {
            id: bathymetricMaterial
            baseColorMap: Texture {
                source: bathymetricPlaneRoot.textureSource
                scaleU: 10
                scaleV: 10
            }
            baseColor: "#8ab4d4"
            roughness: 0.3
            metalness: 0.4
            alphaMode: PrincipledMaterial.Opaque
        }
    }

    // Çerçeve - harita sınırları
    Repeater {
        model: 4

        Model {
            source: "#Cube"
            property real angle: index * 90
            position: Qt.vector3d(
                Math.cos(angle * Math.PI / 180) * planeSize / 2,
                heightOffset,
                Math.sin(angle * Math.PI / 180) * planeSize / 2
            )
            eulerRotation.y: angle
            scale: Qt.vector3d(planeSize, 2, 2)

            materials: PrincipledMaterial {
                baseColor: "#ffc107"
                metalness: 0.8
                roughness: 0.2
            }
        }
    }

    // Köşe işaretleri
    Repeater {
        model: [
            Qt.vector3d(-planeSize/2, heightOffset + 5, -planeSize/2),
            Qt.vector3d(planeSize/2, heightOffset + 5, -planeSize/2),
            Qt.vector3d(-planeSize/2, heightOffset + 5, planeSize/2),
            Qt.vector3d(planeSize/2, heightOffset + 5, planeSize/2)
        ]

        Model {
            source: "#Sphere"
            position: modelData
            scale: Qt.vector3d(3, 3, 3)

            materials: PrincipledMaterial {
                baseColor: "#ff5722"
                metalness: 0.9
                roughness: 0.1
            }
        }
    }
}
