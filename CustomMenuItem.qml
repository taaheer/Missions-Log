pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

MenuItem {
    id: control

    property color fillColor: control.hovered ? Theme.primaryColor : Qt.alpha(Theme.secondaryColor, 0.8)

    hoverEnabled: true

    height: 30


    contentItem: Text {
        text: control.text
        font.pointSize: 12
        color: control.hovered ? Theme.teritiaryTextColor : Theme.primaryTextColor
        verticalAlignment: Text.AlignVCenter
    }

    background: HexagonPanel {
        mirrored: true
        cutLength: 15
        fillColor: control.fillColor
        strokeColor: Theme.transparent
    }
}
