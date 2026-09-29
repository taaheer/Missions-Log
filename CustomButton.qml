pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Button {
    id: control

    property color strokeColor: Theme.colorPrimary
    property int strokeWidth: 4
    property int pointSize: Theme.fontSizeS
    property color color: Theme.textColorPrimary
    property color fillColor: Qt.alpha(Theme.colorSecondary, 0.8)

    implicitWidth: 200
    implicitHeight: implicitContentHeight * (Device.isMobile ? 1.5 : 1.3)

    HoverHandler { cursorShape: Qt.PointingHandCursor }

    contentItem: Text {
        text: control.text
        color: control.color
        font{
            pointSize: control.pointSize
            capitalization: Font.AllUppercase
            family: Theme.fontFamilyTitle
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: HexagonPanel{
        strokeColor: control.strokeColor
        mirrored: true
        cutLength: Theme.cutXS
        strokeWidth: control.strokeWidth
        fillColor: control.fillColor
    }
}
