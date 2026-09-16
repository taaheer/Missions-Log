import QtQuick
import QtQuick.Controls

MenuItem {
    id: control

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
        fillColor: control.hovered ? Theme.primaryColor : Qt.alpha(Theme.secondaryColor, 0.8)
        strokeColor: Theme.transparent
    }
}