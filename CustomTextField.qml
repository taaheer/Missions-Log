pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

TextField {
    id: control

    property color strokeColor
    property bool mirrored: false
    property int cutLength: 30

    placeholderTextColor: Qt.darker(color, 2)

    leftPadding: 22

    background: HexagonPanel{
        strokeColor: control.strokeColor
        mirrored: control.mirrored
        cutLength: control.cutLength
    }
}
