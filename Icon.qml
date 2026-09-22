pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: customIcon
    width: 40 * iconScale
    height: 48 * iconScale

    property real iconScale: 1.0

    Item {
        id: container
        width: 40
        height: 48
        scale: customIcon.iconScale
        anchors.centerIn: parent

        Text {
            text: "⏷"
            font.pointSize: 20
            color: Qt.darker(Theme.primaryColor, 2)
            anchors.horizontalCenter: centerCross.horizontalCenter
            anchors.top: centerCross.top
            anchors.topMargin: -7
        }

        Text {
            id: centerCross
            text: "🞥"
            font.pointSize: 32
            color: Theme.primaryColor
            anchors.centerIn: parent
            rotation: 45
            transformOrigin: Item.Center
        }

        Text {
            text: "⏶"
            font.pointSize: 20
            color: Qt.darker(Theme.primaryColor, 2)
            anchors.horizontalCenter: centerCross.horizontalCenter
            anchors.bottom: centerCross.bottom
            anchors.bottomMargin: -4
        }
    }
}
