import QtQuick
import QtQuick.Controls

Button {
    id: control

    property color strokeColor: Theme.primaryColor
    property int strokeWidth: strokeColor !== Theme.primaryColor ? 7 : 4

    implicitWidth: 200

    contentItem: Text {
        text: control.text
        color: Theme.primaryTextColor
        font{
            pointSize: 14
            capitalization: Font.AllUppercase
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: HexagonPanel{
        strokeColor: control.strokeColor
        mirrored: true
        cutLength: 10
        strokeWidth: control.strokeWidth
    }
}
