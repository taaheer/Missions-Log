import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property color fillColor: Qt.alpha(Theme.secondaryColor, 0.9)
    property color strokeColor: Theme.primaryColor
    property int strokeWidth: strokeColor === Theme.transparent ? 0 : 3
    property bool mirrored: false

    readonly property real cutSize: Math.min(30, width / 2, height / 2)

    Shape{
        anchors.fill: parent

        preferredRendererType: Shape.CurveRenderer

        transform: Scale{
            origin.x: root.width / 2
            origin.y: root.height / 2
            xScale: root.mirrored ? -1 : 1
            yScale: 1
        }

        ShapePath{
            fillColor: root.fillColor
            strokeColor: root.strokeColor
            strokeWidth: root.strokeWidth

            startX: root.cutSize + 2
            startY: 0

            PathLine{
                x: root.width
                y: 0
            }
            PathLine{
                x: root.width
                y: root.height - root.cutSize
            }
            PathLine{
                x: root.width - root.cutSize - 2
                y: root.height
            }
            PathLine{
                x: 0
                y: root.height
            }
            PathLine{
                x: 0
                y: root.cutSize
            }
            PathLine{
                x: root.cutSize + 2
                y: 0
            }
        }

    }
}
