import QtQuick
import QtQuick.Controls

Button {
    id: control

    property color color

    contentItem: Text{
        text: parent.text
        color: control.color
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font{
            bold: true
            pointSize: 32
        }
    }
}
