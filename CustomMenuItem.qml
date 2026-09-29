pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

MenuItem {
    id: control

    property color fillColor: control.hovered ? Theme.colorPrimary : Qt.alpha(Theme.colorSecondary, 0.8)

    hoverEnabled: true

    height: 30


    contentItem: Text {
        id: option
        text: control.text
        font{
            pointSize: Theme.fontSizeXS
            family: Theme.fontFamilySubTitle
        }
        color: control.hovered ? Theme.textColorTertiary : Theme.textColorPrimary
        verticalAlignment: Text.AlignVCenter
    }

    background: HexagonPanel {
        mirrored: true
        cutLength: Theme.cutS
        fillColor: control.fillColor
        strokeColor: Theme.transparent
    }
}
