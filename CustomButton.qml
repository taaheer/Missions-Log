import QtQuick
import QtQuick.Controls

Button {
    id: control

    property color strokeColor: Theme.primaryColor
    property int strokeWidth: 4
    property int pointSize: 14
    property color color: Theme.primaryTextColor
    property color fillColor: Qt.alpha(Theme.secondaryColor, 0.8)

    implicitWidth: 200

    contentItem: Text {
        text: control.text
        color: control.color
        font{
            pointSize: control.pointSize
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
        fillColor: control.fillColor
    }
}
