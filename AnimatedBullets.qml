import QtQuick
import QtQuick.Layouts

ColumnLayout{
    id: control

    property int pointSize: 12
    property color color: Theme.primaryColor
    property bool setDarkEven: true

    Repeater{
        model: 3

        Text{
            id: bullet

            readonly property bool darkEven: control.setDarkEven && index % 2 === 1

            text: "•"
            color: darkEven ? Qt.darker(control.color, 2) : control.color
            font.pointSize: control.pointSize
            opacity: 0

            SequentialAnimation{
                running: true
                loops: 1


                PauseAnimation {
                    duration: index * 300
                }

                NumberAnimation{
                    target: bullet
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 400
                    easing.type: Easing.OutQuad
                }
            }
        }
    }
}
