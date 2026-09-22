pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Button {
    id: control

    property color color

    contentItem: Text{
        text: control.text
        color: control.color
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font{
            bold: true
            pointSize: 32
        }
    }
}
